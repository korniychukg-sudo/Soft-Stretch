import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var store: StretchStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SectionHeader(title: "Your progress",
                              subtitle: "Every soft minute counts")
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    StatTile(icon: .flame, value: "\(store.currentStreak)", label: "current streak", tint: SoftTheme.coral)
                    StatTile(icon: .arrowUp, value: "\(store.bestStreak)", label: "best streak", tint: SoftTheme.sun)
                }
                HStack(spacing: 12) {
                    StatTile(icon: .clock, value: "\(store.totalMinutes)", label: "total minutes", tint: SoftTheme.lavender)
                    StatTile(icon: .check, value: "\(store.sessionCount)", label: "sessions", tint: SoftTheme.sage)
                }

                weekChart

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
