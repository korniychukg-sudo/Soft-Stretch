import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore
    let startRoutine: (Routine) -> Void

    @State private var waveCount = 0
    @State private var bubbleLine: String? = nil
    @State private var bubbleAt = Date.distantPast

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
                    .softAppear()

                nookCard
                    .softAppear(delay: 0.05)

                todaysPickCard
                    .softAppear(delay: 0.1)

                HStack(spacing: 12) {
                    StatTile(icon: .flame, value: "\(store.currentStreak)",
                             label: store.currentStreak == 1 ? "day streak" : "day streak",
                             tint: SoftTheme.coral)
                    StatTile(icon: .clock, value: "\(store.totalMinutes)",
                             label: "soft minutes", tint: SoftTheme.lavender)
                    StatTile(icon: .check, value: "\(store.sessionCount)",
                             label: "sessions", tint: SoftTheme.sage)
                }
                .softAppear(delay: 0.15)

                quickRow
                    .softAppear(delay: 0.2)

                if !store.settings.favoriteRoutines.isEmpty {
                    favorites
                        .softAppear(delay: 0.25)
                }
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

    // Buddy's living nook — tap Buddy to say hi, chip opens the studio.
    private var nookCard: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                BuddyNookView(level: companion.level,
                              outfit: companion.outfit,
                              mood: nookMood(store: store),
                              reduceMotion: store.settings.reduceMotion,
                              waveTrigger: waveCount)
                if let line = bubbleLine {
                    SpeechBubble(text: line)
                        .padding(.bottom, 10)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { buddyTapped() }

            NavigationLink(destination: BuddyStudioView()) {
                FriendshipChip(level: companion.level,
                               fraction: Friendship.progressToNext(companion.xp).fraction)
            }
            .buttonStyle(SoftPressStyle())
            .padding(10)
        }
        .background(SoftTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous))
        .shadow(color: SoftTheme.cardShadow, radius: 12, x: 0, y: 6)
    }

    private func buddyTapped() {
        SoftHaptics.tap(store)
        waveCount += 1
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            bubbleLine = contextualLine()
        }
        bubbleAt = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            if Date().timeIntervalSince(bubbleAt) >= 3.4 {
                withAnimation(.easeOut(duration: 0.3)) { bubbleLine = nil }
            }
        }
    }

    private func contextualLine() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        var pool: [String] = []
        if store.stretchedToday {
            pool = ["We already stretched - I feel taller!",
                    "Best part of my day, honestly.",
                    "Round two later? No pressure."]
        } else if hour < 9 {
            pool = ["Morning! My arms are still asleep.",
                    "A sunrise stretch would be lovely.",
                    "Yawn... shall we wake up gently?"]
        } else if hour >= 21 {
            pool = ["A slow wind-down, then bed?",
                    "My shoulders vote for Evening Unwind.",
                    "Sleepy stretches are the softest."]
        } else if store.currentStreak >= 3 {
            pool = ["Day \(store.currentStreak) together - we're on a roll!",
                    "Streak buddies! Let's keep it warm.",
                    "You keep showing up. I love that."]
        } else {
            pool = ["Got five soft minutes for me?",
                    "Desk Undo is my favorite, just saying.",
                    "Stretch like a cat. Zero guilt.",
                    "I practiced my toe-touch. Still can't.",
                    "Your neck called - it wants a tilt."]
        }
        return pool[(waveCount + (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0)) % pool.count]
    }

    // Compact daily-pick card under the nook.
    private var todaysPickCard: some View {
        Button(action: { startRoutine(todaysPick) }) {
            HStack(spacing: 16) {
                ArtImage(name: todaysPick.artName, corner: 14)
                    .frame(width: 68, height: 68)
                VStack(alignment: .leading, spacing: 3) {
                    Text("TODAY'S PICK")
                        .font(SoftTheme.body(10, .bold))
                        .foregroundColor(SoftTheme.coral)
                        .kerning(1.2)
                    Text(todaysPick.name)
                        .font(SoftTheme.display(17))
                        .foregroundColor(SoftTheme.ink)
                    Text("\(todaysPick.totalSeconds(library: PoseLibrary.byID) / 60) min - \(todaysPick.subtitle)")
                        .font(SoftTheme.body(12))
                        .foregroundColor(SoftTheme.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                ZStack {
                    Circle().fill(SoftTheme.coral).frame(width: 42, height: 42)
                    SoftIcon(kind: .play, size: 17, color: .white)
                        .offset(x: 1.5)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                    .fill(SoftTheme.card)
                    .shadow(color: SoftTheme.cardShadow, radius: 10, x: 0, y: 5)
            )
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
                                .minimumScaleFactor(0.65)
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
                        HStack(spacing: 16) {
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

}
