import SwiftUI

struct RoutinesView: View {
    @EnvironmentObject var store: StretchStore
    let startRoutine: (Routine) -> Void
    let startProgramDay: (StretchProgram, ProgramDay) -> Void

    @State private var segment = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SectionHeader(title: "Routines",
                              subtitle: "Follow along with Buddy")
                    .padding(.top, 8)

                SoftSegmented(items: ["Routines", "Programs", "My Own"], selection: $segment)

                switch segment {
                case 0:
                    routineList
                case 1:
                    ProgramsListView(startProgramDay: startProgramDay)
                default:
                    MyRoutinesSection(startRoutine: startRoutine)
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

    private var routineList: some View {
        VStack(spacing: 16) {
            ForEach(RoutineLibrary.all) { routine in
                NavigationLink(destination: RoutineDetailView(routine: routine, startRoutine: startRoutine)) {
                    RoutineCard(routine: routine, isFavorite: store.isFavorite(routine.id))
                }
                .buttonStyle(SoftPressStyle())
            }
        }
    }
}

struct RoutineCard: View {
    let routine: Routine
    let isFavorite: Bool

    private var minutes: Int { routine.totalSeconds(library: PoseLibrary.byID) / 60 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ArtImage(name: routine.artName)
                    .aspectRatio(2.3, contentMode: .fit)   // same banner crop on every width (150pt tall on iPhone)
                    .frame(maxWidth: .infinity)
                    .clipped()
                if isFavorite {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.85)).frame(width: 32, height: 32)
                        SoftIcon(kind: .heartFill, size: 16, color: SoftTheme.rose)
                    }
                    .padding(10)
                }
            }
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(routine.name)
                        .font(SoftTheme.display(18))
                        .foregroundColor(SoftTheme.ink)
                    Text(routine.subtitle)
                        .font(SoftTheme.body(13))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                Spacer()
                VStack(spacing: 3) {
                    SoftPill(text: "\(minutes) min", tint: routine.tintArea.tint)
                    Text("\(routine.steps.count) stretches")
                        .font(SoftTheme.body(11))
                        .foregroundColor(SoftTheme.inkSoft)
                }
            }
            .padding(14)
        }
        .background(SoftTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous))
        .shadow(color: SoftTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}

struct RoutineDetailView: View {
    @EnvironmentObject var store: StretchStore
    @Environment(\.presentationMode) var presentationMode
    let routine: Routine
    let startRoutine: (Routine) -> Void

    private var minutes: Int { routine.totalSeconds(library: PoseLibrary.byID) / 60 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ZStack(alignment: .top) {
                    ArtImage(name: routine.artName, corner: SoftTheme.cardCorner)
                        .aspectRatio(1.67, contentMode: .fit)   // same header crop on every width (210pt tall on iPhone)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous))
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.9)).frame(width: 36, height: 36)
                                SoftIcon(kind: .chevronLeft, size: 18, color: SoftTheme.ink)
                            }
                        }
                        .buttonStyle(SoftPressStyle())
                        Spacer()
                        Button(action: {
                            SoftHaptics.tap(store)
                            store.toggleFavorite(routine.id)
                        }) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.9)).frame(width: 36, height: 36)
                                SoftIcon(kind: store.isFavorite(routine.id) ? .heartFill : .heart,
                                         size: 17,
                                         color: store.isFavorite(routine.id) ? SoftTheme.rose : SoftTheme.ink)
                            }
                        }
                        .buttonStyle(SoftPressStyle())
                    }
                    .padding(12)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(routine.name)
                        .font(SoftTheme.display(26))
                        .foregroundColor(SoftTheme.ink)
                    Text(routine.subtitle)
                        .font(SoftTheme.body(15))
                        .foregroundColor(SoftTheme.inkSoft)
                    HStack(spacing: 8) {
                        SoftPill(text: "\(minutes) min", tint: routine.tintArea.tint)
                        SoftPill(text: "\(routine.steps.count) stretches", tint: SoftTheme.lavender)
                        SoftPill(text: routine.tintArea.title, tint: SoftTheme.sage)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                SoftPrimaryButton(title: "Start with Buddy", icon: .play) {
                    startRoutine(routine)
                }

                VStack(spacing: 10) {
                    SectionHeader(title: "What's inside")
                    ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                        if let stretch = PoseLibrary.byID[step.stretchID] {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(stretch.area.tint.opacity(0.12))
                                        .frame(width: 64, height: 64)
                                    BuddyPreview(stretch: stretch, showGlow: false)
                                        .frame(width: 58, height: 58)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stretch.name)
                                        .font(SoftTheme.body(15, .bold))
                                        .foregroundColor(SoftTheme.ink)
                                    Text(stretch.muscleNames)
                                        .font(SoftTheme.body(12))
                                        .foregroundColor(SoftTheme.inkSoft)
                                }
                                Spacer()
                                Text(stretch.bilateral
                                     ? "\(step.secondsPerSide)s x 2"
                                     : "\(step.secondsPerSide)s")
                                    .font(SoftTheme.body(13, .semibold))
                                    .foregroundColor(stretch.area.tint)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(SoftTheme.card)
                                    .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3)
                            )
                        }
                    }
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
}
