import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: StretchStore
    let startRoutine: (Routine) -> Void

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        case 18..<22: return "Good evening"
        default: return "Hello, night friend"
        }
    }

    // Rotates daily; leans toward the fitting routine for the time of day.
    private var todaysPick: Routine {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 10, let r = RoutineLibrary.byID["morning"] { return r }
        if hour >= 20, let r = RoutineLibrary.byID["evening"] { return r }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let pool = RoutineLibrary.all.filter { $0.id != "morning" && $0.id != "evening" }
        return pool[day % pool.count]
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header

                heroCard

                HStack(spacing: 12) {
                    StatTile(icon: .flame, value: "\(store.currentStreak)",
                             label: store.currentStreak == 1 ? "day streak" : "day streak",
                             tint: SoftTheme.coral)
                    StatTile(icon: .clock, value: "\(store.totalMinutes)",
                             label: "soft minutes", tint: SoftTheme.lavender)
                    StatTile(icon: .check, value: "\(store.sessionCount)",
                             label: "sessions", tint: SoftTheme.sage)
                }

                quickRow

                if !store.settings.favoriteRoutines.isEmpty {
                    favorites
                }

                buddyCorner
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: SoftTheme.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(SoftTheme.cream.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(dateLine.uppercased())
                    .font(SoftTheme.body(11, .bold))
                    .foregroundColor(SoftTheme.inkSoft)
                    .kerning(1.2)
                Text(greeting)
                    .font(SoftTheme.display(28))
                    .foregroundColor(SoftTheme.ink)
            }
            Spacer()
            if store.stretchedToday {
                SoftPill(text: "Stretched today", tint: SoftTheme.sage)
                    .padding(.top, 6)
            }
        }
    }

    private var heroCard: some View {
        Button(action: { startRoutine(todaysPick) }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    ArtImage(name: todaysPick.artName)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    SoftPill(text: "TODAY'S PICK", tint: .white)
                        .background(Capsule().fill(SoftTheme.ink.opacity(0.35)))
                        .padding(12)
                }
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(todaysPick.name)
                            .font(SoftTheme.display(20))
                            .foregroundColor(SoftTheme.ink)
                        Text("\(todaysPick.totalSeconds(library: PoseLibrary.byID) / 60) min - \(todaysPick.subtitle)")
                            .font(SoftTheme.body(13))
                            .foregroundColor(SoftTheme.inkSoft)
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(SoftTheme.coral).frame(width: 46, height: 46)
                        SoftIcon(kind: .play, size: 19, color: .white)
                            .offset(x: 2)
                    }
                }
                .padding(16)
            }
            .background(SoftTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous))
            .shadow(color: SoftTheme.cardShadow, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(SoftPressStyle())
    }

    private var quickRow: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Quick relief", subtitle: "Five minutes, right now")
            HStack(spacing: 12) {
                quickChip(RoutineLibrary.byID["desk"], icon: .sun)
                quickChip(RoutineLibrary.byID["neckmelt"], icon: .drop)
            }
        }
    }

    private func quickChip(_ routine: Routine?, icon: SoftIconKind) -> some View {
        Group {
            if let routine = routine {
                Button(action: { startRoutine(routine) }) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle().fill(routine.tintArea.tint.opacity(0.16)).frame(width: 38, height: 38)
                            SoftIcon(kind: icon, size: 19, color: routine.tintArea.tint)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(routine.name)
                                .font(SoftTheme.body(14, .bold))
                                .foregroundColor(SoftTheme.ink)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text("\(routine.totalSeconds(library: PoseLibrary.byID) / 60) min")
                                .font(SoftTheme.body(12))
                                .foregroundColor(SoftTheme.inkSoft)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(SoftTheme.card)
                            .shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(SoftPressStyle())
            }
        }
    }

    private var favorites: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Your favorites")
            ForEach(store.settings.favoriteRoutines, id: \.self) { id in
                if let routine = RoutineLibrary.byID[id] {
                    Button(action: { startRoutine(routine) }) {
                        HStack(spacing: 12) {
                            ArtImage(name: routine.artName, corner: 12)
                                .frame(width: 56, height: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(routine.name)
                                    .font(SoftTheme.body(15, .bold))
                                    .foregroundColor(SoftTheme.ink)
                                Text("\(routine.totalSeconds(library: PoseLibrary.byID) / 60) min")
                                    .font(SoftTheme.body(12))
                                    .foregroundColor(SoftTheme.inkSoft)
                            }
                            Spacer()
                            SoftIcon(kind: .heartFill, size: 18, color: SoftTheme.rose)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(SoftTheme.card)
                                .shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(SoftPressStyle())
                }
            }
        }
    }

    private var buddyCorner: some View {
        SoftCard {
            HStack(spacing: 14) {
                AnimatedBuddy(stretch: PoseLibrary.byID["sky-breath"] ?? PoseLibrary.all[0],
                              reduceMotion: store.settings.reduceMotion, showMat: false)
                    .frame(width: 110, height: 130)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Buddy says")
                        .font(SoftTheme.body(11, .bold))
                        .foregroundColor(SoftTheme.inkSoft)
                        .kerning(1.1)
                    Text(buddyLine)
                        .font(SoftTheme.body(15, .medium))
                        .foregroundColor(SoftTheme.ink)
                        .lineSpacing(2)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var buddyLine: String {
        let lines = [
            "A soft body is a happy body. One small stretch counts.",
            "You do not need to touch your toes. Just say hi to them.",
            "Breathe out slowly - that is where the stretch lives.",
            "Tight shoulders carry the day. Let's put it down.",
            "Slow is not lazy. Slow is how muscles listen.",
            "Even two minutes today keeps us friends.",
            "Stretch like a cat: often, and with zero guilt."
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return lines[day % lines.count]
    }
}
