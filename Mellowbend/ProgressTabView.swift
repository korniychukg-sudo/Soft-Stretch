import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SectionHeader(title: "Your progress",
                              subtitle: "Every soft minute counts")
                    .padding(.top, 8)

                friendshipCard
                    .softAppear()

                HStack(spacing: 12) {
                    StatTile(icon: .flame, value: "\(store.currentStreak)", label: "current streak", tint: SoftTheme.coral)
                    StatTile(icon: .arrowUp, value: "\(store.bestStreak)", label: "best streak", tint: SoftTheme.sun)
                }
                .softAppear(delay: 0.05)
                HStack(spacing: 12) {
                    StatTile(icon: .clock, value: "\(store.totalMinutes)", label: "total minutes", tint: SoftTheme.lavender)
                    StatTile(icon: .check, value: "\(store.sessionCount)", label: "sessions", tint: SoftTheme.sage)
                }
                .softAppear(delay: 0.1)

                MonthHeatmap()
                    .softAppear(delay: 0.15)

                BodyBalanceCard()
                    .softAppear(delay: 0.2)

                weekChart
                    .softAppear(delay: 0.25)

                badgeGrid

                if !store.sessions.isEmpty {
                    history
                }
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.bottom, 24)
            .frame(maxWidth: SoftTheme.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(SoftTheme.cream.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Friendship summary

    private var friendshipCard: some View {
        let prog = Friendship.progressToNext(companion.xp)
        return SoftCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(SoftTheme.coral.opacity(0.18), lineWidth: 5)
                            .frame(width: 44, height: 44)
                        Circle().trim(from: 0, to: max(prog.fraction, 0.02))
                            .stroke(SoftTheme.coral, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 44, height: 44)
                        Text("\(companion.level)")
                            .font(SoftTheme.display(16))
                            .foregroundColor(SoftTheme.coral)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FRIENDSHIP WITH BUDDY")
                            .font(SoftTheme.body(10, .bold))
                            .foregroundColor(SoftTheme.coral)
                            .kerning(1.2)
                        Text(Friendship.levelName(companion.level))
                            .font(SoftTheme.display(18))
                            .foregroundColor(SoftTheme.ink)
                        Text(companion.level >= 12 ? "Max level - best friends forever"
                             : "\(prog.need - prog.have) xp to level \(companion.level + 1)")
                            .font(SoftTheme.body(12))
                            .foregroundColor(SoftTheme.inkSoft)
                    }
                    Spacer()
                }
                NavigationLink(destination: BuddyStudioView()) {
                    HStack {
                        Text("Open Buddy Studio")
                            .font(SoftTheme.body(13, .bold))
                            .foregroundColor(SoftTheme.coral)
                        Spacer()
                        SoftIcon(kind: .chevronRight, size: 14, color: SoftTheme.coral)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(SoftTheme.coral.opacity(0.08)))
                }
                .buttonStyle(SoftPressStyle())
            }
        }
    }

    // MARK: 14-day minutes chart (custom bars — no Charts framework)

    private var weekChart: some View {
        let data = store.recentMinutes(days: 14)
        let maxMins = max(data.map { $0.minutes }.max() ?? 1, 1)
        return SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Last two weeks")
                    .font(SoftTheme.body(12, .bold))
                    .foregroundColor(SoftTheme.inkSoft)
                    .kerning(1.2)
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(item.minutes > 0
                                      ? SoftTheme.coral
                                      : SoftTheme.ink.opacity(0.07))
                                .frame(height: barHeight(item.minutes, maxMins))
                                .frame(maxWidth: .infinity)
                            Text(dayLetter(item.date))
                                .font(SoftTheme.body(9, .semibold))
                                .foregroundColor(SoftTheme.inkSoft)
                        }
                    }
                }
                .frame(height: 110, alignment: .bottom)
                HStack {
                    Circle().fill(SoftTheme.coral).frame(width: 8, height: 8)
                    Text("minutes stretched")
                        .font(SoftTheme.body(11))
                        .foregroundColor(SoftTheme.inkSoft)
                    Spacer()
                    Text("best day: \(maxMins) min")
                        .font(SoftTheme.body(11, .semibold))
                        .foregroundColor(SoftTheme.inkSoft)
                }
            }
        }
    }

    private func barHeight(_ minutes: Int, _ maxMins: Int) -> CGFloat {
        let full: CGFloat = 88
        if minutes <= 0 { return 8 }
        return max(12, full * CGFloat(minutes) / CGFloat(maxMins))
    }

    private func dayLetter(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEEE"
        return f.string(from: date)
    }

    // MARK: Badges

    private var badgeGrid: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Badges",
                          subtitle: "\(store.unlockedBadges.count) of \(StretchStore.badgeSpecs.count) unlocked")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96, maximum: 140), spacing: 10)], spacing: 10) {
                ForEach(StretchStore.badgeSpecs) { spec in
                    let unlocked = store.isUnlocked(spec.id)
                    VStack(spacing: 7) {
                        BadgeEmblem(index: spec.emblem, unlocked: unlocked)
                            .frame(width: 52, height: 52)
                        Text(spec.name)
                            .font(SoftTheme.body(12, .bold))
                            .foregroundColor(unlocked ? SoftTheme.ink : SoftTheme.ink.opacity(0.35))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(spec.detail)
                            .font(SoftTheme.body(10))
                            .foregroundColor(SoftTheme.inkSoft.opacity(unlocked ? 1 : 0.6))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 26, alignment: .top)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SoftTheme.card)
                            .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3)
                    )
                }
            }
        }
    }

    // MARK: History

    private var history: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Recent sessions")
            ForEach(store.sessions.suffix(12).reversed()) { session in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill((RoutineLibrary.byID[session.routineID]?.tintArea.tint ?? SoftTheme.coral).opacity(0.14))
                            .frame(width: 40, height: 40)
                        SoftIcon(kind: .check, size: 18,
                                 color: RoutineLibrary.byID[session.routineID]?.tintArea.tint ?? SoftTheme.coral)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.routineName)
                            .font(SoftTheme.body(14, .bold))
                            .foregroundColor(SoftTheme.ink)
                        Text(sessionDate(session.date))
                            .font(SoftTheme.body(12))
                            .foregroundColor(SoftTheme.inkSoft)
                    }
                    Spacer()
                    Text("\(max(session.seconds / 60, 1)) min")
                        .font(SoftTheme.body(13, .semibold))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(SoftTheme.card)
                        .shadow(color: SoftTheme.cardShadow, radius: 5, x: 0, y: 2)
                )
            }
        }
    }

    private func sessionDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }
}

// Month calendar heatmap: day cells tinted by minutes stretched.
struct MonthHeatmap: View {
    @EnvironmentObject var store: StretchStore
    @State private var monthOffset = 0    // 0 = current month, negative = past

    private var monthStart: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        let start = cal.date(from: comps) ?? Date()
        return cal.date(byAdding: .month, value: monthOffset, to: start) ?? start
    }

    var body: some View {
        SoftCard {
            VStack(spacing: 12) {
                HStack {
                    monthArrow(dir: -1)
                    Spacer()
                    Text(monthTitle)
                        .font(SoftTheme.body(15, .bold)).foregroundColor(SoftTheme.ink)
                    Spacer()
                    monthArrow(dir: 1)
                }
                grid
                HStack(spacing: 10) {
                    Text("less").font(SoftTheme.body(10)).foregroundColor(SoftTheme.inkSoft)
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(SoftTheme.coral.opacity(intensity(i)))
                            .frame(width: 14, height: 14)
                    }
                    Text("more").font(SoftTheme.body(10)).foregroundColor(SoftTheme.inkSoft)
                    Spacer()
                }
            }
        }
    }

    private func intensity(_ step: Int) -> Double { [0.08, 0.3, 0.55, 0.9][step] }

    private func stepFor(minutes: Int) -> Int {
        switch minutes {
        case 0: return 0
        case 1..<5: return 1
        case 5..<12: return 2
        default: return 3
        }
    }

    private var monthTitle: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: monthStart)
    }

    private func monthArrow(dir: Int) -> some View {
        let cal = Calendar.current
        // Back is limited to the month of the earliest session; forward stops at now.
        let disabled: Bool
        if dir > 0 {
            disabled = monthOffset >= 0
        } else if let first = store.sessions.first {
            let firstMonth = cal.date(from: cal.dateComponents([.year, .month], from: first.date)) ?? Date()
            let target = cal.date(byAdding: .month, value: monthOffset + dir, to:
                cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()) ?? Date()
            disabled = target < firstMonth
        } else {
            disabled = true
        }
        return Button(action: { if !disabled { monthOffset += dir } }) {
            SoftIcon(kind: dir < 0 ? .chevronLeft : .chevronRight, size: 15,
                     color: disabled ? SoftTheme.ink.opacity(0.18) : SoftTheme.inkSoft)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(SoftPressStyle())
        .disabled(disabled)
    }

    private var grid: some View {
        let cal = Calendar.current
        let dayCount = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 28
        let firstWeekday = cal.component(.weekday, from: monthStart)      // 1 = Sun
        let leading = (firstWeekday + 5) % 7                              // Mon-start blanks
        let cells: [Int?] = Array(repeating: nil, count: leading) + (1...dayCount).map { $0 }
        let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
        let letters = ["M", "T", "W", "T", "F", "S", "S"]
        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(letters.indices, id: \.self) { i in
                Text(letters[i])
                    .font(SoftTheme.body(10, .semibold)).foregroundColor(SoftTheme.inkSoft)
            }
            ForEach(cells.indices, id: \.self) { i in
                if let day = cells[i], let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) {
                    let mins = date <= Date() ? store.minutes(on: date) : 0
                    RoundedRectangle(cornerRadius: 5)
                        .fill(SoftTheme.coral.opacity(intensity(stepFor(minutes: mins))))
                        .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(cal.isDateInToday(date) ? SoftTheme.coral : .clear, lineWidth: 1.6))
                        .frame(height: 22)
                } else {
                    Color.clear.frame(height: 22)
                }
            }
        }
    }
}

// Which body areas get the love — share of stretched time per area.
struct BodyBalanceCard: View {
    @EnvironmentObject var store: StretchStore

    var body: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Body balance")
                    .font(SoftTheme.display(17)).foregroundColor(SoftTheme.ink)
                let balance = store.areaBalance()
                if balance.allSatisfy({ $0.fraction == 0 }) {
                    Text("Finish a session and Buddy will chart which areas you care for most.")
                        .font(SoftTheme.body(13)).foregroundColor(SoftTheme.inkSoft)
                } else {
                    ForEach(balance, id: \.area) { item in
                        HStack(spacing: 10) {
                            Text(item.area.title)
                                .font(SoftTheme.body(12, .semibold))
                                .foregroundColor(SoftTheme.inkSoft)
                                .frame(width: 118, alignment: .leading)
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(item.area.tint.opacity(0.14))
                                    Capsule().fill(item.area.tint)
                                        .frame(width: max(g.size.width * item.fraction, item.fraction > 0 ? 6 : 0))
                                }
                            }
                            .frame(height: 10)
                            Text("\(Int((item.fraction * 100).rounded()))%")
                                .font(SoftTheme.body(11, .bold))
                                .foregroundColor(SoftTheme.ink.opacity(0.6))
                                .frame(width: 34, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
}

// Badge medallion drawn from Paths — 12 variants.
struct BadgeEmblem: View {
    let index: Int
    let unlocked: Bool

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let c = CGPoint(x: rect.midX, y: rect.midY)
            let r = min(rect.width, rect.height) / 2 - 2
            let palette: [Color] = [SoftTheme.coral, SoftTheme.lavender, SoftTheme.sage,
                                    SoftTheme.sun, SoftTheme.sky, SoftTheme.rose]
            let tint = unlocked ? palette[index % palette.count] : SoftTheme.ink.opacity(0.18)

            // Medallion base
            context.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                         with: .color(tint.opacity(unlocked ? 0.18 : 0.1)))
            context.stroke(Path(ellipseIn: CGRect(x: c.x - r + 2, y: c.y - r + 2, width: (r - 2) * 2, height: (r - 2) * 2)),
                           with: .color(tint), style: StrokeStyle(lineWidth: 2))

            // Emblem variant
            let ir = r * 0.45
            var p = Path()
            switch index % 6 {
            case 0: // star
                for i in 0..<5 {
                    let a = CGFloat(i) * .pi * 2 / 5 - .pi / 2
                    let a2 = a + .pi / 5
                    let outer = CGPoint(x: c.x + cos(a) * ir, y: c.y + sin(a) * ir)
                    let inner = CGPoint(x: c.x + cos(a2) * ir * 0.45, y: c.y + sin(a2) * ir * 0.45)
                    if i == 0 { p.move(to: outer) } else { p.addLine(to: outer) }
                    p.addLine(to: inner)
                }
                p.closeSubpath()
            case 1: // ring of dots
                for i in 0..<6 {
                    let a = CGFloat(i) * .pi / 3
                    let dot = CGPoint(x: c.x + cos(a) * ir * 0.8, y: c.y + sin(a) * ir * 0.8)
                    p.addEllipse(in: CGRect(x: dot.x - 3, y: dot.y - 3, width: 6, height: 6))
                }
            case 2: // triangle up
                p.move(to: CGPoint(x: c.x, y: c.y - ir))
                p.addLine(to: CGPoint(x: c.x + ir * 0.9, y: c.y + ir * 0.7))
                p.addLine(to: CGPoint(x: c.x - ir * 0.9, y: c.y + ir * 0.7))
                p.closeSubpath()
            case 3: // diamond
                p.move(to: CGPoint(x: c.x, y: c.y - ir))
                p.addLine(to: CGPoint(x: c.x + ir * 0.75, y: c.y))
                p.addLine(to: CGPoint(x: c.x, y: c.y + ir))
                p.addLine(to: CGPoint(x: c.x - ir * 0.75, y: c.y))
                p.closeSubpath()
            case 4: // moon sliver
                p.move(to: CGPoint(x: c.x + ir * 0.3, y: c.y - ir))
                p.addQuadCurve(to: CGPoint(x: c.x + ir * 0.3, y: c.y + ir),
                               control: CGPoint(x: c.x - ir * 1.1, y: c.y))
                p.addQuadCurve(to: CGPoint(x: c.x + ir * 0.3, y: c.y - ir),
                               control: CGPoint(x: c.x - ir * 0.2, y: c.y))
                p.closeSubpath()
            default: // concentric target
                p.addEllipse(in: CGRect(x: c.x - ir, y: c.y - ir, width: ir * 2, height: ir * 2))
                p.addEllipse(in: CGRect(x: c.x - ir * 0.45, y: c.y - ir * 0.45, width: ir * 0.9, height: ir * 0.9))
            }
            if index % 6 == 5 || index % 6 == 1 {
                context.stroke(p, with: .color(tint), style: StrokeStyle(lineWidth: 2))
            } else {
                context.fill(p, with: .color(tint))
            }
        }
        .opacity(unlocked ? 1 : 0.75)
    }
}
