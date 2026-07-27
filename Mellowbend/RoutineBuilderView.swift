import SwiftUI

// "My Own" segment: user-built routines + the builder sheet.

struct MyRoutinesSection: View {
    @EnvironmentObject var store: StretchStore
    let startRoutine: (Routine) -> Void

    private struct BuilderTarget: Identifiable {
        let routine: CustomRoutine?
        var id: String { routine?.id.uuidString ?? "new" }
    }

    @State private var editorTarget: BuilderTarget? = nil
    @State private var deleteTarget: CustomRoutine? = nil

    var body: some View {
        VStack(spacing: 14) {
            if store.customRoutines.isEmpty {
                SoftCard {
                    HStack(spacing: 12) {
                        BuddyPreview(stretch: PoseLibrary.all[0], showGlow: false)
                            .frame(width: 74, height: 84)
                        Text("No routines of your own yet - build one and Buddy will learn it.")
                            .font(SoftTheme.body(14, .medium))
                            .foregroundColor(SoftTheme.inkSoft)
                            .lineSpacing(2)
                        Spacer(minLength: 0)
                    }
                }
            }

            ForEach(store.customRoutines) { custom in
                customCard(custom)
            }

            Button(action: { editorTarget = BuilderTarget(routine: nil) }) {
                VStack(spacing: 8) {
                    SoftIcon(kind: .sparkle, size: 24, color: SoftTheme.coral)
                    Text("Build your own")
                        .font(SoftTheme.body(15, .bold))
                        .foregroundColor(SoftTheme.coral)
                    Text("Pick stretches, set the pace, make it yours")
                        .font(SoftTheme.body(12))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .background(
                    RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                        .stroke(SoftTheme.coral.opacity(0.5),
                                style: StrokeStyle(lineWidth: 2, dash: [7]))
                        .background(
                            RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                                .fill(SoftTheme.coral.opacity(0.04)))
                )
            }
            .buttonStyle(SoftPressStyle())
        }
        .sheet(item: $editorTarget) { target in
            RoutineBuilderView(editing: target.routine) { store.saveCustomRoutine($0) }
        }
        .alert(item: $deleteTarget) { custom in
            Alert(title: Text("Delete \(custom.name)?"),
                  message: Text("Buddy will forget this routine."),
                  primaryButton: .destructive(Text("Delete")) {
                      store.deleteCustomRoutine(custom.id)
                  },
                  secondaryButton: .cancel())
        }
    }

    private func customCard(_ custom: CustomRoutine) -> some View {
        let firstStretch = custom.steps.first.flatMap { PoseLibrary.byID[$0.stretchID] }
        let minutes = custom.steps.reduce(0) { sum, s in
            let sides = (PoseLibrary.byID[s.stretchID]?.bilateral ?? false) ? 2 : 1
            return sum + s.seconds * sides
        } / 60
        return VStack(alignment: .leading, spacing: 0) {
            ZStack {
                LinearGradient(colors: [custom.tintArea.tint.opacity(0.5),
                                        custom.tintArea.tint.opacity(0.22)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 88)
                if let stretch = firstStretch {
                    BuddyPreview(stretch: stretch, showGlow: false)
                        .frame(width: 84, height: 84)
                }
            }
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(custom.name)
                        .font(SoftTheme.display(17))
                        .foregroundColor(SoftTheme.ink)
                    Text("\(custom.steps.count) stretches - \(max(minutes, 1)) min")
                        .font(SoftTheme.body(12))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                Spacer()
                Button(action: { editorTarget = BuilderTarget(routine: custom) }) {
                    Text("Edit")
                        .font(SoftTheme.body(13, .bold))
                        .foregroundColor(SoftTheme.inkSoft)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(SoftTheme.cream))
                }
                .buttonStyle(SoftPressStyle())
                Button(action: { deleteTarget = custom }) {
                    SoftIcon(kind: .close, size: 13, color: SoftTheme.coralDeep)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(SoftTheme.coral.opacity(0.12)))
                }
                .buttonStyle(SoftPressStyle())
                Button(action: { startRoutine(custom.asRoutine()) }) {
                    ZStack {
                        Circle().fill(SoftTheme.coral).frame(width: 40, height: 40)
                        SoftIcon(kind: .play, size: 16, color: .white).offset(x: 1.5)
                    }
                }
                .buttonStyle(SoftPressStyle())
            }
            .padding(12)
        }
        .background(SoftTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous))
        .shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

struct RoutineBuilderView: View {
    @Environment(\.presentationMode) var presentationMode
    var editing: CustomRoutine? = nil
    let onSave: (CustomRoutine) -> Void

    @State private var name: String
    @State private var tint: BodyArea
    @State private var steps: [CustomStep]

    private let secondOptions = [20, 30, 45, 60]

    init(editing: CustomRoutine? = nil, onSave: @escaping (CustomRoutine) -> Void) {
        self.editing = editing
        self.onSave = onSave
        _name = State(initialValue: editing?.name ?? "")
        _tint = State(initialValue: editing?.tintArea ?? .fullBody)
        _steps = State(initialValue: editing?.steps ?? [])
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && steps.count >= 2
    }

    private var totalMinutes: Int {
        steps.reduce(0) { sum, s in
            let sides = (PoseLibrary.byID[s.stretchID]?.bilateral ?? false) ? 2 : 1
            return sum + s.seconds * sides
        } / 60
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(SoftTheme.ink.opacity(0.15))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            HStack {
                Text(editing == nil ? "New Routine" : "Edit Routine")
                    .font(SoftTheme.display(20))
                    .foregroundColor(SoftTheme.ink)
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle().fill(SoftTheme.cream).frame(width: 32, height: 32)
                        SoftIcon(kind: .close, size: 14, color: SoftTheme.ink)
                    }
                }
                .buttonStyle(SoftPressStyle())
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.top, 14)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Name it something soft", text: $name)
                        .font(SoftTheme.body(16, .semibold))
                        .foregroundColor(SoftTheme.ink)
                        .disableAutocorrection(true)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SoftTheme.cream))

                    HStack(spacing: 12) {
                        Text("Tint")
                            .font(SoftTheme.body(13, .semibold))
                            .foregroundColor(SoftTheme.inkSoft)
                        ForEach(BodyArea.allCases) { area in
                            Button(action: { tint = area }) {
                                Circle()
                                    .fill(area.tint)
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(tint == area ? SoftTheme.ink.opacity(0.55) : .clear,
                                                             lineWidth: 2.5))
                            }
                            .buttonStyle(SoftPressStyle())
                        }
                        Spacer()
                    }

                    if !steps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your flow")
                                .font(SoftTheme.display(16))
                                .foregroundColor(SoftTheme.ink)
                            ForEach(steps.indices, id: \.self) { i in
                                flowRow(i)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add stretches")
                            .font(SoftTheme.display(16))
                            .foregroundColor(SoftTheme.ink)
                        ForEach([BodyArea.neckShoulders, .backCore, .hipsLegs, .armsChest], id: \.self) { area in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(area.title.uppercased())
                                    .font(SoftTheme.body(10, .bold))
                                    .foregroundColor(area.tint)
                                    .kerning(1.1)
                                    .padding(.top, 4)
                                ForEach(PoseLibrary.area(area)) { stretch in
                                    pickRow(stretch)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, SoftTheme.screenPad)
                .padding(.bottom, 16)
            }

            VStack(spacing: 10) {
                Text("\(steps.count) stretches - about \(max(totalMinutes, steps.isEmpty ? 0 : 1)) min")
                    .font(SoftTheme.body(12, .semibold))
                    .foregroundColor(SoftTheme.inkSoft)
                Button(action: save) {
                    Text("Save routine")
                        .font(SoftTheme.body(17, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(
                            LinearGradient(colors: [SoftTheme.coral, SoftTheme.coral.opacity(0.82)],
                                           startPoint: .top, endPoint: .bottom)))
                        .opacity(canSave ? 1 : 0.45)
                }
                .buttonStyle(SoftPressStyle())
                .disabled(!canSave)
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.vertical, 12)
            .background(SoftTheme.card.ignoresSafeArea(edges: .bottom))
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func flowRow(_ i: Int) -> some View {
        let step = steps[i]
        let stretch = PoseLibrary.byID[step.stretchID]
        return HStack(spacing: 10) {
            if let stretch = stretch {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(stretch.area.tint.opacity(0.12))
                        .frame(width: 46, height: 46)
                    BuddyPreview(stretch: stretch, showGlow: false)
                        .frame(width: 42, height: 42)
                }
                Text(stretch.name)
                    .font(SoftTheme.body(14, .semibold))
                    .foregroundColor(SoftTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Button(action: { cycleSeconds(i) }) {
                SoftPill(text: "\(step.seconds)s", tint: stretch?.area.tint ?? SoftTheme.coral)
            }
            .buttonStyle(SoftPressStyle())
            VStack(spacing: 2) {
                Button(action: { if i > 0 { steps.swapAt(i, i - 1) } }) {
                    SoftIcon(kind: .arrowUp, size: 12,
                             color: i > 0 ? SoftTheme.inkSoft : SoftTheme.ink.opacity(0.15))
                        .frame(width: 24, height: 16)
                }
                .buttonStyle(SoftPressStyle())
                .disabled(i == 0)
                Button(action: { if i < steps.count - 1 { steps.swapAt(i, i + 1) } }) {
                    SoftIcon(kind: .arrowUp, size: 12,
                             color: i < steps.count - 1 ? SoftTheme.inkSoft : SoftTheme.ink.opacity(0.15))
                        .rotationEffect(.degrees(180))
                        .frame(width: 24, height: 16)
                }
                .buttonStyle(SoftPressStyle())
                .disabled(i == steps.count - 1)
            }
            Button(action: { steps.remove(at: i) }) {
                SoftIcon(kind: .close, size: 12, color: SoftTheme.coralDeep)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(SoftTheme.coral.opacity(0.10)))
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(SoftTheme.cream))
    }

    private func pickRow(_ stretch: Stretch) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(stretch.area.tint.opacity(0.10))
                    .frame(width: 42, height: 42)
                BuddyPreview(stretch: stretch, showGlow: false)
                    .frame(width: 38, height: 38)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(stretch.name)
                    .font(SoftTheme.body(13, .semibold))
                    .foregroundColor(SoftTheme.ink)
                Text(stretch.muscleNames)
                    .font(SoftTheme.body(11))
                    .foregroundColor(SoftTheme.inkSoft)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: {
                steps.append(CustomStep(stretchID: stretch.id, seconds: 30))
            }) {
                Text("+ Add")
                    .font(SoftTheme.body(12, .bold))
                    .foregroundColor(stretch.area.tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(stretch.area.tint.opacity(0.13)))
            }
            .buttonStyle(SoftPressStyle())
        }
    }

    private func cycleSeconds(_ i: Int) {
        let current = steps[i].seconds
        let idx = secondOptions.firstIndex(of: current) ?? 1
        steps[i].seconds = secondOptions[(idx + 1) % secondOptions.count]
    }

    private func save() {
        guard canSave else { return }
        let routine = CustomRoutine(id: editing?.id ?? UUID(),
                                    name: trimmedName,
                                    tintAreaRaw: tint.rawValue,
                                    steps: steps)
        onSave(routine)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        presentationMode.wrappedValue.dismiss()
    }
}
