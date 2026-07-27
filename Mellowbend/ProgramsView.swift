import SwiftUI

// Programs tab segment: 7-day journey cards + day-by-day detail.

struct ProgramsListView: View {
    @EnvironmentObject var companion: CompanionStore
    let startProgramDay: (StretchProgram, ProgramDay) -> Void

    var body: some View {
        VStack(spacing: 16) {
            ForEach(ProgramLibrary.all) { program in
                NavigationLink(destination: ProgramDetailView(program: program,
                                                              startProgramDay: startProgramDay)) {
                    ProgramCard(program: program)
                }
                .buttonStyle(SoftPressStyle())
            }
        }
    }
}

struct ProgramCard: View {
    @EnvironmentObject var companion: CompanionStore
    let program: StretchProgram

    var body: some View {
        let done = companion.completedDays(program.id)
        let next = companion.nextDay(program.id, totalDays: 7)
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ArtImage(name: program.artName)
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                    .clipped()
                if next == nil {
                    SoftPill(text: "Completed", tint: .white)
                        .background(Capsule().fill(program.tint.opacity(0.85)))
                        .padding(10)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(program.name)
                            .font(SoftTheme.display(18))
                            .foregroundColor(SoftTheme.ink)
                        Text(program.tagline)
                            .font(SoftTheme.body(13))
                            .foregroundColor(SoftTheme.inkSoft)
                    }
                    Spacer()
                    if let next = next {
                        SoftPill(text: "Day \(next) next", tint: program.tint)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(1...7, id: \.self) { d in
                        Circle()
                            .fill(done.contains(d) ? program.tint : program.tint.opacity(next == d ? 0.0 : 0.15))
                            .overlay(Circle().stroke(next == d ? program.tint : Color.clear, lineWidth: 2))
                            .frame(width: 10, height: 10)
                    }
                    Spacer()
                    Text("\(done.count)/7 days")
                        .font(SoftTheme.body(11, .semibold))
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

struct ProgramDetailView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore
    @Environment(\.presentationMode) var presentationMode
    let program: StretchProgram
    let startProgramDay: (StretchProgram, ProgramDay) -> Void

    var body: some View {
        let done = companion.completedDays(program.id)
        let next = companion.nextDay(program.id, totalDays: 7)
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ZStack(alignment: .top) {
                    ArtImage(name: program.artName, corner: SoftTheme.cardCorner)
                        .frame(height: 190)
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
                    }
                    .padding(12)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(program.name)
                        .font(SoftTheme.display(26))
                        .foregroundColor(SoftTheme.ink)
                    Text(program.tagline)
                        .font(SoftTheme.body(15))
                        .foregroundColor(SoftTheme.inkSoft)
                    // Overall progress
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(program.tint.opacity(0.14))
                            Capsule().fill(program.tint)
                                .frame(width: max(g.size.width * CGFloat(done.count) / 7, done.isEmpty ? 0 : 10))
                        }
                    }
                    .frame(height: 8)
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if next == nil {
                    SoftCard {
                        HStack(spacing: 14) {
                            BuddyCanvas(pose: .standing, facing: .front, groundLevel: 0,
                                        muscles: [], glowPhase: 0.25, showMat: false,
                                        outfit: companion.outfit, mood: .proud)
                                .frame(width: 90, height: 100)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("You finished \(program.name)!")
                                    .font(SoftTheme.body(16, .bold))
                                    .foregroundColor(SoftTheme.ink)
                                Text("Buddy is very proud. Any day below can be repeated whenever you like.")
                                    .font(SoftTheme.body(13))
                                    .foregroundColor(SoftTheme.inkSoft)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }

                VStack(spacing: 10) {
                    ForEach(Array(program.days.enumerated()), id: \.offset) { _, day in
                        dayRow(day, done: done.contains(day.day), isNext: next == day.day)
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

    private func dayRow(_ day: ProgramDay, done: Bool, isNext: Bool) -> some View {
        let routine = RoutineLibrary.byID[day.routineID]
        let minutes = routine.map { $0.totalSeconds(library: PoseLibrary.byID) / 60 } ?? 0
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(done ? SoftTheme.sage : (isNext ? program.tint : program.tint.opacity(0.12)))
                    .frame(width: 40, height: 40)
                if done {
                    SoftIcon(kind: .check, size: 17, color: .white)
                } else {
                    Text("\(day.day)")
                        .font(SoftTheme.body(15, .bold))
                        .foregroundColor(isNext ? .white : program.tint)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(day.title)
                    .font(SoftTheme.body(15, .bold))
                    .foregroundColor(SoftTheme.ink)
                Text("\(day.blurb) - \(routine?.name ?? "") - \(minutes) min")
                    .font(SoftTheme.body(12))
                    .foregroundColor(SoftTheme.inkSoft)
                    .lineLimit(1)
            }
            Spacer()
            if isNext {
                Button(action: { startProgramDay(program, day) }) {
                    Text("Start")
                        .font(SoftTheme.body(13, .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(program.tint))
                }
                .buttonStyle(SoftPressStyle())
            } else if done {
                Button(action: { startProgramDay(program, day) }) {
                    SoftIcon(kind: .reset, size: 16, color: SoftTheme.inkSoft)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(SoftTheme.cream))
                }
                .buttonStyle(SoftPressStyle())
            } else {
                SoftIcon(kind: .lock, size: 15, color: SoftTheme.ink.opacity(0.25))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SoftTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isNext ? program.tint.opacity(0.5) : Color.clear, lineWidth: 1.6))
                .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3)
        )
    }
}
