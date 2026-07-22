import SwiftUI

// Library of all stretches, filterable by body area; each opens a live demo.
struct LibraryView: View {
    @EnvironmentObject var store: StretchStore
    @State private var selectedArea: BodyArea? = nil

    private var filtered: [Stretch] {
        guard let area = selectedArea else { return PoseLibrary.all }
        return PoseLibrary.all.filter { $0.area == area }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                SectionHeader(title: "Stretch library",
                              subtitle: "Tap any stretch to watch Buddy demo it")
                    .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        areaChip(nil, label: "All")
                        ForEach(BodyArea.allCases) { area in
                            areaChip(area, label: area.title)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { stretch in
                        NavigationLink(destination: StretchDetailView(stretch: stretch)) {
                            StretchCard(stretch: stretch)
                        }
                        .buttonStyle(SoftPressStyle())
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

    private func areaChip(_ area: BodyArea?, label: String) -> some View {
        let active = selectedArea == area
        let tint = area?.tint ?? SoftTheme.coral
        return Button(action: {
            SoftHaptics.tap(store)
            withAnimation(.easeOut(duration: 0.2)) { selectedArea = area }
        }) {
            Text(label)
                .font(SoftTheme.body(13, .semibold))
                .foregroundColor(active ? .white : SoftTheme.ink.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(active ? tint : SoftTheme.card))
                .overlay(Capsule().stroke(active ? Color.clear : SoftTheme.line, lineWidth: 1))
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct StretchCard: View {
    let stretch: Stretch

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(stretch.area.tint.opacity(0.10))
                BuddyPreview(stretch: stretch)
                    .frame(height: 110)
                    .padding(6)
            }
            .frame(height: 122)
            VStack(spacing: 2) {
                Text(stretch.name)
                    .font(SoftTheme.body(14, .bold))
                    .foregroundColor(SoftTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(stretch.muscleNames)
                    .font(SoftTheme.body(11))
                    .foregroundColor(SoftTheme.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 8)
        }
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SoftTheme.card)
                .shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4)
        )
    }
}

struct StretchDetailView: View {
    @EnvironmentObject var store: StretchStore
    @Environment(\.presentationMode) var presentationMode
    let stretch: Stretch

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        ZStack {
                            Circle().fill(SoftTheme.card).frame(width: 36, height: 36)
                                .shadow(color: SoftTheme.cardShadow, radius: 4, x: 0, y: 2)
                            SoftIcon(kind: .chevronLeft, size: 18, color: SoftTheme.ink)
                        }
                    }
                    .buttonStyle(SoftPressStyle())
                    Spacer()
                    SoftPill(text: stretch.area.title, tint: stretch.area.tint)
                }
                .padding(.top, 8)

                // Live demo stage
                ZStack {
                    RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                        .fill(
                            LinearGradient(colors: [stretch.area.tint.opacity(0.14),
                                                    stretch.area.tint.opacity(0.05)],
                                           startPoint: .top, endPoint: .bottom))
                    AnimatedBuddy(stretch: stretch,
                                  reduceMotion: store.settings.reduceMotion)
                        .frame(height: 280)
                        .padding(10)
                }
                .frame(height: 300)

                VStack(alignment: .leading, spacing: 6) {
                    Text(stretch.name)
                        .font(SoftTheme.display(26))
                        .foregroundColor(SoftTheme.ink)
                    Text(stretch.benefit)
                        .font(SoftTheme.body(15))
                        .foregroundColor(SoftTheme.inkSoft)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    infoTag(icon: .sparkle, text: stretch.muscleNames, tint: SoftTheme.muscleGlow)
                    if stretch.bilateral {
                        infoTag(icon: .reset, text: "Both sides", tint: SoftTheme.lavender)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                SoftCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to")
                            .font(SoftTheme.body(12, .bold))
                            .foregroundColor(SoftTheme.inkSoft)
                            .kerning(1.2)
                        ForEach(Array(stretch.howTo.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle().fill(stretch.area.tint.opacity(0.15))
                                        .frame(width: 26, height: 26)
                                    Text("\(index + 1)")
                                        .font(SoftTheme.body(13, .bold))
                                        .foregroundColor(stretch.area.tint)
                                }
                                Text(step)
                                    .font(SoftTheme.body(15))
                                    .foregroundColor(SoftTheme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }

                SoftCard {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(SoftTheme.muscleGlow.opacity(0.15)).frame(width: 40, height: 40)
                            SoftIcon(kind: .sparkle, size: 20, color: SoftTheme.muscleGlow)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("The warm glow")
                                .font(SoftTheme.body(14, .bold))
                                .foregroundColor(SoftTheme.ink)
                            Text("Buddy glows where you should feel this stretch — a warm pull, never a sharp pain.")
                                .font(SoftTheme.body(13))
                                .foregroundColor(SoftTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
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

    private func infoTag(icon: SoftIconKind, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            SoftIcon(kind: icon, size: 14, color: tint)
            Text(text)
                .font(SoftTheme.body(12, .semibold))
                .foregroundColor(SoftTheme.ink.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.10)))
    }
}
