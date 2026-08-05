import SwiftUI
import Combine

struct PlayerView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore
    @Environment(\.presentationMode) var presentationMode

    let routine: Routine
    var programID: String? = nil
    var programDay: Int? = nil

    struct Segment {
        let stretch: Stretch
        let seconds: Int
        let sideLabel: String?
        let mirrored: Bool
    }

    @State private var segments: [Segment] = []
    @State private var segmentIndex = 0
    @State private var elapsedInSegment: Double = 0
    @State private var totalActiveSeconds: Double = 0
    @State private var isPaused = false
    @State private var countIn: Int = 3
    @State private var finished = false
    @State private var recorded = false
    @State private var areaSecondsAcc: [String: Double] = [:]

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            if finished {
                completionView
            } else if !segments.isEmpty {
                sessionView
            }
        }
        .onAppear {
            buildSegments()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            companion.lastReward = nil
        }
        .onReceive(timer) { _ in tick() }
    }

    private var current: Segment? {
        segments.indices.contains(segmentIndex) ? segments[segmentIndex] : nil
    }

    private var backgroundGradient: LinearGradient {
        let tint = current?.stretch.area.tint ?? SoftTheme.sage
        let daypart = SoftDaypart.current()
        return LinearGradient(
            colors: [SoftTheme.cream, daypart.skyBottom.opacity(0.18),
                     tint.opacity(0.16), SoftTheme.cream],
            startPoint: .top, endPoint: .bottom)
    }

    private func buildSegments() {
        var out: [Segment] = []
        for step in routine.steps {
            guard let stretch = PoseLibrary.byID[step.stretchID] else { continue }
            if stretch.bilateral {
                out.append(Segment(stretch: stretch, seconds: step.secondsPerSide,
                                   sideLabel: "Left side", mirrored: false))
                out.append(Segment(stretch: stretch, seconds: step.secondsPerSide,
                                   sideLabel: "Right side", mirrored: true))
            } else {
                out.append(Segment(stretch: stretch, seconds: step.secondsPerSide,
                                   sideLabel: nil, mirrored: false))
            }
        }
        segments = out
    }

    private func tick() {
        guard !finished, !isPaused, !segments.isEmpty else { return }
        if countIn > 0 {

            elapsedInSegment += 0.1
            if elapsedInSegment >= 1 {
                elapsedInSegment = 0
                countIn -= 1
                if countIn > 0 { SoftHaptics.tap(store) }
                else { SoftHaptics.step(store) }
            }
            return
        }
        elapsedInSegment += 0.1
        totalActiveSeconds += 0.1
        if let seg = current {

            let area = seg.stretch.area == .fullBody ? BodyArea.backCore : seg.stretch.area
            areaSecondsAcc[area.rawValue, default: 0] += 0.1
            if elapsedInSegment >= Double(seg.seconds) {
                advance()
            }
        }
    }

    private func advance() {
        if segmentIndex < segments.count - 1 {
            segmentIndex += 1
            elapsedInSegment = 0
            SoftHaptics.step(store)
        } else {
            finishSession()
        }
    }

    private func goBack() {
        if elapsedInSegment > 3 {
            elapsedInSegment = 0
        } else if segmentIndex > 0 {
            segmentIndex -= 1
            elapsedInSegment = 0
        } else {
            elapsedInSegment = 0
        }
        SoftHaptics.tap(store)
    }

    private func finishSession() {
        guard !recorded else { return }
        recorded = true
        finished = true
        SoftHaptics.success(store)
        store.recordSession(routine: routine,
                            seconds: Int(totalActiveSeconds),
                            stretchCount: routine.steps.count,
                            areaSeconds: areaSecondsAcc.mapValues { Int($0) })
        if let pid = programID, let day = programDay {
            companion.completeProgramDay(programID: pid, day: day)
        }
        awardFriendship()
    }

    private func awardFriendship() {
        let hadStreakYesterday: Bool = {
            guard let y = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return false }
            return !store.sessions(on: y).isEmpty
        }()

        companion.award(seconds: Int(totalActiveSeconds),
                        streakActive: hadStreakYesterday || store.sessions(on: Date()).count > 1)
    }

    private func closeEarly() {

        if !recorded && totalActiveSeconds >= 60 {
            recorded = true
            store.recordSession(routine: routine,
                                seconds: Int(totalActiveSeconds),
                                stretchCount: segmentIndex + 1,
                                areaSeconds: areaSecondsAcc.mapValues { Int($0) })
            awardFriendship()
        }
        presentationMode.wrappedValue.dismiss()
    }

    private var sessionView: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            Group {
                if isLandscape {
                    HStack(spacing: 0) {
                        buddyStage
                            .frame(width: geo.size.width * 0.52)
                        VStack(spacing: 12) {
                            topBar
                            Spacer(minLength: 0)
                            infoAndControls
                        }
                        .padding(.trailing, SoftTheme.screenPad)
                    }
                } else {
                    VStack(spacing: 0) {
                        topBar
                            .padding(.horizontal, SoftTheme.screenPad)
                        buddyStage
                        infoAndControls
                            .padding(.horizontal, SoftTheme.screenPad)
                            .frame(maxWidth: SoftTheme.contentMaxWidth)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: closeEarly) {
                    ZStack {
                        Circle().fill(SoftTheme.card.opacity(0.9)).frame(width: 36, height: 36)
                        SoftIcon(kind: .close, size: 16, color: SoftTheme.ink)
                    }
                }
                .buttonStyle(SoftPressStyle())
                Spacer()
                Text(routine.name)
                    .font(SoftTheme.body(15, .bold))
                    .foregroundColor(SoftTheme.ink)
                Spacer()
                Text("\(segmentIndex + 1)/\(segments.count)")
                    .font(SoftTheme.body(13, .semibold))
                    .foregroundColor(SoftTheme.inkSoft)
                    .frame(width: 36)
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(SoftTheme.ink.opacity(0.08))
                    Capsule()
                        .fill(current?.stretch.area.tint ?? SoftTheme.coral)
                        .frame(width: g.size.width * totalProgress)
                        .animation(.linear(duration: 0.2), value: totalProgress)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, 8)
    }

    private var totalProgress: CGFloat {
        guard !segments.isEmpty else { return 0 }
        let done = segments.prefix(segmentIndex).reduce(0) { $0 + Double($1.seconds) }
        let total = segments.reduce(0.0) { $0 + Double($1.seconds) }
        guard total > 0 else { return 0 }
        let now = countIn > 0 ? 0 : min(elapsedInSegment, Double(current?.seconds ?? 0))
        return CGFloat((done + now) / total)
    }

    private var buddyStage: some View {
        ZStack {
            if let seg = current {
                AnimatedBuddy(stretch: seg.stretch,
                              mirrored: seg.mirrored,
                              reduceMotion: store.settings.reduceMotion,
                              outfit: companion.outfit)
                    .padding(8)
                    .opacity(countIn > 0 ? 0.35 : 1)
                    .animation(.easeOut(duration: 0.3), value: countIn > 0)
            }
            if countIn > 0 {
                VStack(spacing: 8) {
                    Text("Get ready")
                        .font(SoftTheme.body(17, .semibold))
                        .foregroundColor(SoftTheme.inkSoft)
                    Text("\(countIn)")
                        .font(SoftTheme.display(74))
                        .foregroundColor(SoftTheme.coral)
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var infoAndControls: some View {
        VStack(spacing: 14) {
            if let seg = current {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text(seg.stretch.name)
                            .font(SoftTheme.display(22))
                            .foregroundColor(SoftTheme.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        if let side = seg.sideLabel {
                            SoftPill(text: side, tint: SoftTheme.lavender)
                        }
                    }
                    if store.settings.cuesOn {
                        Text(countIn > 0 ? "Watch Buddy and settle in" : currentCue)
                            .font(SoftTheme.body(14, .medium))
                            .foregroundColor(SoftTheme.inkSoft)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(minHeight: 36)
                    }
                    HStack(spacing: 5) {
                        SoftIcon(kind: .sparkle, size: 13, color: SoftTheme.muscleGlow)
                        Text(seg.stretch.muscleNames)
                            .font(SoftTheme.body(12, .semibold))
                            .foregroundColor(SoftTheme.muscleGlow)
                    }
                }
            }

            HStack(spacing: 26) {
                Button(action: goBack) {
                    controlCircle(icon: .skipBack, size: 52, iconSize: 20, filled: false)
                }
                .buttonStyle(SoftPressStyle())

                Button(action: {
                    isPaused.toggle()
                    SoftHaptics.tap(store)
                }) {
                    ZStack {
                        CountdownRing(progress: segmentRemainingFraction,
                                      lineWidth: 5,
                                      tint: current?.stretch.area.tint ?? SoftTheme.coral)
                            .frame(width: 86, height: 86)
                        Circle()
                            .fill(SoftTheme.coral)
                            .frame(width: 68, height: 68)
                            .shadow(color: SoftTheme.coral.opacity(0.35), radius: 8, x: 0, y: 4)
                        if isPaused {
                            SoftIcon(kind: .play, size: 26, color: .white).offset(x: 2)
                        } else {
                            Text(remainingLabel)
                                .font(SoftTheme.display(24))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(SoftPressStyle())

                Button(action: advance) {
                    controlCircle(icon: .skipForward, size: 52, iconSize: 20, filled: false)
                }
                .buttonStyle(SoftPressStyle())
            }

            if let next = nextSegment {
                HStack(spacing: 6) {
                    Text("Next:")
                        .font(SoftTheme.body(12, .semibold))
                        .foregroundColor(SoftTheme.inkSoft)
                    Text(next.stretch.name + (next.sideLabel.map { " - \($0)" } ?? ""))
                        .font(SoftTheme.body(12, .bold))
                        .foregroundColor(SoftTheme.ink.opacity(0.7))
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(SoftTheme.card.opacity(0.85)))
            } else {
                Text("Last one - enjoy it")
                    .font(SoftTheme.body(12, .semibold))
                    .foregroundColor(SoftTheme.inkSoft)
                    .padding(.vertical, 6)
            }
        }
        .padding(.bottom, 18)
    }

    private var nextSegment: Segment? {
        segments.indices.contains(segmentIndex + 1) ? segments[segmentIndex + 1] : nil
    }

    private var currentCue: String {
        guard let seg = current else { return "" }
        let cycleT = CGFloat((elapsedInSegment / seg.stretch.cycleSeconds)
            .truncatingRemainder(dividingBy: 1))
        let cue = seg.stretch.cue(at: cycleT)
        return cue.isEmpty ? seg.stretch.benefit : cue
    }

    private var segmentRemainingFraction: CGFloat {
        guard let seg = current, seg.seconds > 0 else { return 0 }
        return CGFloat(max(0, 1 - elapsedInSegment / Double(seg.seconds)))
    }

    private var remainingLabel: String {
        guard let seg = current else { return "" }
        return "\(max(0, seg.seconds - Int(elapsedInSegment)))"
    }

    private func controlCircle(icon: SoftIconKind, size: CGFloat, iconSize: CGFloat, filled: Bool) -> some View {
        ZStack {
            Circle()
                .fill(filled ? SoftTheme.coral : SoftTheme.card)
                .frame(width: size, height: size)
                .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3)
            SoftIcon(kind: icon, size: iconSize, color: filled ? .white : SoftTheme.ink.opacity(0.65))
        }
    }

    private var completionView: some View {
        ZStack {
            ConfettiBurst(active: true).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 30)
                    ZStack {
                        Circle().fill(SoftTheme.sage.opacity(0.15)).frame(width: 190, height: 190)
                        BuddyCanvas(pose: celebrationPose, facing: .front, groundLevel: 0,
                                    muscles: [], glowPhase: 0.25, showMat: false)
                            .frame(width: 180, height: 200)
                    }
                    Text("Lovely and loose")
                        .font(SoftTheme.display(28))
                        .foregroundColor(SoftTheme.ink)
                    Text("You and Buddy finished \(routine.name).")
                        .font(SoftTheme.body(15))
                        .foregroundColor(SoftTheme.inkSoft)

                    HStack(spacing: 12) {
                        StatTile(icon: .clock, value: minutesLabel, label: "stretched", tint: SoftTheme.lavender)
                        StatTile(icon: .check, value: "\(routine.steps.count)", label: "stretches", tint: SoftTheme.sage)
                        StatTile(icon: .flame, value: "\(store.currentStreak)", label: "day streak", tint: SoftTheme.coral)
                    }
                    .padding(.horizontal, SoftTheme.screenPad)

                    if let reward = companion.lastReward {
                        XPTallyCard(reward: reward)
                            .padding(.horizontal, SoftTheme.screenPad)
                        if reward.newLevel > reward.oldLevel {
                            LevelUpCard(newLevel: reward.newLevel,
                                        onEquip: { equipFreshReward(reward.newLevel) })
                                .padding(.horizontal, SoftTheme.screenPad)
                                .onAppear { companion.markCelebrated(reward.newLevel) }
                        }
                    }
                    if let day = programDay, let pid = programID,
                       let program = ProgramLibrary.byID(pid) {
                        SoftPill(text: "Day \(day) of \(program.name) complete",
                                 tint: program.tint)
                    }

                    if !store.freshBadges.isEmpty {
                        VStack(spacing: 10) {
                            Text("NEW BADGE" + (store.freshBadges.count > 1 ? "S" : ""))
                                .font(SoftTheme.body(11, .bold))
                                .foregroundColor(SoftTheme.sun)
                                .kerning(1.4)
                            ForEach(store.freshBadges) { badge in
                                HStack(spacing: 12) {
                                    BadgeEmblem(index: badge.emblem, unlocked: true)
                                        .frame(width: 46, height: 46)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(badge.name)
                                            .font(SoftTheme.body(15, .bold))
                                            .foregroundColor(SoftTheme.ink)
                                        Text(badge.detail)
                                            .font(SoftTheme.body(12))
                                            .foregroundColor(SoftTheme.inkSoft)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(SoftTheme.card)
                                        .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3)
                                )
                            }
                        }
                        .padding(.horizontal, SoftTheme.screenPad)
                    }

                    SoftPrimaryButton(title: "Done", tint: SoftTheme.sage) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 6)

                    Spacer(minLength: 30)
                }
                .frame(maxWidth: SoftTheme.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var minutesLabel: String {
        let mins = Int(totalActiveSeconds) / 60
        let secs = Int(totalActiveSeconds) % 60
        return mins > 0 ? "\(mins):" + String(format: "%02d", secs) : "\(secs)s"
    }

    private var celebrationPose: BuddyPose {
        var p = BuddyPose()
        p.armRaiseL = 150
        p.armRaiseR = 150
        p.headTilt = 4
        return p
    }

    private func equipFreshReward(_ level: Int) {
        guard let reward = RewardTable.reward(at: level) else { return }
        switch reward.kind {
        case .skin(let id): companion.equipSkin(id)
        case .accessory(let id): companion.equipAccessory(id)
        }
        SoftHaptics.success(store)
    }
}

struct XPTallyCard: View {
    let reward: SessionReward
    @State private var shown = 0
    private let timer = Timer.publish(every: 0.06, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(SoftTheme.coral.opacity(0.14)).frame(width: 42, height: 42)
                SoftIcon(kind: .heartFill, size: 20, color: SoftTheme.coral)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("FRIENDSHIP")
                    .font(SoftTheme.body(10, .bold)).foregroundColor(SoftTheme.coral).kerning(1.3)
                Text("+\(shown) xp with Buddy")
                    .font(SoftTheme.display(18)).foregroundColor(SoftTheme.ink)
            }
            Spacer()
            Text(Friendship.levelName(reward.newLevel))
                .font(SoftTheme.body(12, .semibold)).foregroundColor(SoftTheme.inkSoft)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(SoftTheme.card).shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4))
        .onReceive(timer) { _ in
            if shown < reward.gained { shown += 1 }
        }
    }
}

struct LevelUpCard: View {
    let newLevel: Int
    let onEquip: () -> Void
    @State private var equipped = false

    private var rewardTitle: String {
        RewardTable.reward(at: newLevel)?.title ?? "A new keepsake"
    }

    var body: some View {
        VStack(spacing: 10) {
            Canvas { ctx, size in
                drawSparkle(ctx, at: CGPoint(x: size.width / 2 - 26, y: 12), r: 5, color: .white.opacity(0.9))
                drawSparkle(ctx, at: CGPoint(x: size.width / 2, y: 7), r: 7, color: .white)
                drawSparkle(ctx, at: CGPoint(x: size.width / 2 + 26, y: 13), r: 4, color: .white.opacity(0.8))
            }
            .frame(height: 20)
            Text("LEVEL \(newLevel)")
                .font(SoftTheme.body(11, .bold))
                .foregroundColor(.white.opacity(0.85))
                .kerning(1.6)
            Text(Friendship.levelName(newLevel))
                .font(SoftTheme.display(22))
                .foregroundColor(.white)
            Text("Unlocked: \(rewardTitle)")
                .font(SoftTheme.body(14, .semibold))
                .foregroundColor(.white.opacity(0.95))
            Text("...and something new appeared in Buddy's nook")
                .font(SoftTheme.body(12))
                .foregroundColor(.white.opacity(0.8))
            if equipped {
                Text("Equipped")
                    .font(SoftTheme.body(13, .bold))
                    .foregroundColor(SoftTheme.coralDeep)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.9)))
            } else {
                Button(action: {
                    onEquip()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { equipped = true }
                }) {
                    Text("Equip now")
                        .font(SoftTheme.body(13, .bold))
                        .foregroundColor(SoftTheme.coralDeep)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                }
                .buttonStyle(SoftPressStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                .fill(LinearGradient(colors: [SoftTheme.coral, SoftTheme.rose],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: SoftTheme.coral.opacity(0.35), radius: 10, x: 0, y: 5)
        )
    }
}
