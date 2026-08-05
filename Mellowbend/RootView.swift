import SwiftUI

struct PlayerLaunch: Identifiable {
    let routine: Routine
    var programID: String? = nil
    var programDay: Int? = nil
    var id: String { routine.id + "-" + String(programDay ?? -1) }
}

struct RootView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore
    @State private var selectedTab = 0
    @State private var activePlayer: PlayerLaunch? = nil

    var body: some View {
        ZStack {
            SoftTheme.cream.ignoresSafeArea()

            if !store.settings.onboarded {
                OnboardingView()
            } else {
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0:
                            NavigationView { HomeView(startRoutine: startRoutine) }
                                .navigationViewStyle(StackNavigationViewStyle())
                        case 1:
                            NavigationView { RoutinesView(startRoutine: startRoutine,
                                                          startProgramDay: startProgramDay) }
                                .navigationViewStyle(StackNavigationViewStyle())
                        case 2:
                            NavigationView { LibraryView() }
                                .navigationViewStyle(StackNavigationViewStyle())
                        case 3:
                            NavigationView { ProgressTabView() }
                                .navigationViewStyle(StackNavigationViewStyle())
                        default:
                            NavigationView { MoreView() }
                                .navigationViewStyle(StackNavigationViewStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    tabBar
                }
            }
        }
        .fullScreenCover(item: $activePlayer) { launch in
            PlayerView(routine: launch.routine,
                       programID: launch.programID,
                       programDay: launch.programDay)
                .environmentObject(store)
                .environmentObject(companion)
        }
    }

    private func startRoutine(_ routine: Routine) {
        SoftHaptics.step(store)
        activePlayer = PlayerLaunch(routine: routine)
    }

    private func startProgramDay(_ program: StretchProgram, _ day: ProgramDay) {
        guard let routine = RoutineLibrary.byID[day.routineID] else { return }
        SoftHaptics.step(store)
        activePlayer = PlayerLaunch(routine: routine, programID: program.id, programDay: day.day)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Home", .home)
            tabButton(1, "Routines", .routines)
            tabButton(2, "Stretches", .library)
            tabButton(3, "Progress", .progress)
            tabButton(4, "More", .more)
        }
        .padding(.top, 9)
        .padding(.bottom, 5)
        .background(
            SoftTheme.card
                .shadow(color: SoftTheme.ink.opacity(0.06), radius: 8, x: 0, y: -3)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, _ label: String, _ icon: SoftIconKind) -> some View {
        let active = selectedTab == index
        return Button(action: {
            if selectedTab != index {
                SoftHaptics.tap(store)
                selectedTab = index
            }
        }) {
            ZStack {
                if active {
                    Capsule()
                        .fill(SoftTheme.coral.opacity(0.12))
                        .frame(height: 46)
                        .padding(.horizontal, 4)
                }
                VStack(spacing: 3) {
                    SoftIcon(kind: icon, size: 23,
                             color: active ? SoftTheme.coral : SoftTheme.ink.opacity(0.36))
                    Text(label)
                        .font(SoftTheme.body(10, active ? .bold : .medium))
                        .foregroundColor(active ? SoftTheme.coral : SoftTheme.ink.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: active)
        }
        .buttonStyle(SoftPressStyle())
    }
}
