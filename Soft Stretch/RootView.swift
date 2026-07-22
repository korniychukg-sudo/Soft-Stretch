import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: StretchStore
    @State private var selectedTab = 0
    @State private var activePlayer: Routine? = nil

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
                            NavigationView { RoutinesView(startRoutine: startRoutine) }
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
        .fullScreenCover(item: $activePlayer) { routine in
            PlayerView(routine: routine)
                .environmentObject(store)
        }
    }

    private func startRoutine(_ routine: Routine) {
        SoftHaptics.step(store)
        activePlayer = routine
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
            VStack(spacing: 3) {
                SoftIcon(kind: icon, size: 23,
                         color: active ? SoftTheme.coral : SoftTheme.ink.opacity(0.36))
                Text(label)
                    .font(SoftTheme.body(10, active ? .bold : .medium))
                    .foregroundColor(active ? SoftTheme.coral : SoftTheme.ink.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
        .buttonStyle(SoftPressStyle())
    }
}

// Routine already conforms to Identifiable via `id`.
