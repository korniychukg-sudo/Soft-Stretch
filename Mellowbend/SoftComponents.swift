import SwiftUI

struct SoftCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: SoftTheme.cardCorner, style: .continuous)
                    .fill(SoftTheme.card)
                    .shadow(color: SoftTheme.cardShadow, radius: 10, x: 0, y: 5)
            )
    }
}

struct SoftPill: View {
    let text: String
    var tint: Color = SoftTheme.coral

    var body: some View {
        Text(text)
            .font(SoftTheme.body(12, .bold))
            .foregroundColor(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.14)))
    }
}

struct SoftPrimaryButton: View {
    let title: String
    var icon: SoftIconKind? = nil
    var tint: Color = SoftTheme.coral
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    SoftIcon(kind: icon, size: 18, color: .white)
                }
                Text(title)
                    .font(SoftTheme.body(17, .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                Capsule().fill(
                    LinearGradient(colors: [tint, tint.opacity(0.82)],
                                   startPoint: .top, endPoint: .bottom))
            )
            .shadow(color: tint.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct SoftPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct CountdownRing: View {
    let progress: CGFloat
    var lineWidth: CGFloat = 8
    var tint: Color = SoftTheme.coral

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(progress, 0.001))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct StatTile: View {
    let icon: SoftIconKind
    let value: String
    let label: String
    var tint: Color = SoftTheme.coral

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(tint.opacity(0.14)).frame(width: 40, height: 40)
                SoftIcon(kind: icon, size: 20, color: tint)
            }
            Text(value)
                .font(SoftTheme.display(20))
                .foregroundColor(SoftTheme.ink)
            Text(label)
                .font(SoftTheme.body(12, .medium))
                .foregroundColor(SoftTheme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(SoftTheme.card)
                .shadow(color: SoftTheme.cardShadow, radius: 8, x: 0, y: 4)
        )
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(SoftTheme.display(20))
                .foregroundColor(SoftTheme.ink)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(SoftTheme.body(13))
                    .foregroundColor(SoftTheme.inkSoft)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ArtImage: View {
    let name: String
    var corner: CGFloat = 0

    var body: some View {
        if let ui = UIImage(named: name) ?? loadFromArtFolder() {

            Color.clear
                .overlay(Image(uiImage: ui).resizable().scaledToFill())
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(LinearGradient(colors: [SoftTheme.rose.opacity(0.5), SoftTheme.lavender.opacity(0.5)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }

    private func loadFromArtFolder() -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Art") else { return nil }
        return UIImage(contentsOfFile: path)
    }
}

struct ConfettiBurst: View {
    let active: Bool
    private let colors: [Color] = [SoftTheme.coral, SoftTheme.lavender, SoftTheme.sage, SoftTheme.sun, SoftTheme.sky, SoftTheme.rose]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            Canvas { context, size in
                guard active else { return }
                let t = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<56 {

                    let seed = CGFloat((i * 2654435761) % 1000) / 1000
                    let seed2 = CGFloat((i * 40503) % 1000) / 1000
                    let speed = 40 + seed * 90
                    let phase = (t * Double(speed) / 100 + Double(seed2)).truncatingRemainder(dividingBy: 1.6) / 1.6
                    let x = size.width * (0.06 + seed * 0.88) + sin(CGFloat(t) * 2 + seed * 12) * 14
                    let y = size.height * CGFloat(phase) * 1.05 - 20
                    let s = 5 + seed2 * 6
                    let color = colors[i % colors.count]
                    var ctx = context
                    ctx.translateBy(x: x + s / 2, y: y + s / 2)
                    ctx.rotate(by: .radians(Double(seed * 6 + CGFloat(t) * (1 + seed2 * 2))))
                    switch i % 3 {
                    case 0:

                        let h = s * (0.6 + seed * 0.8)
                        ctx.fill(Path(roundedRect: CGRect(x: -s / 2, y: -h / 2, width: s, height: h),
                                      cornerRadius: 2),
                                 with: .color(color.opacity(0.85)))
                    case 1:

                        ctx.fill(Path(ellipseIn: CGRect(x: -s / 2, y: -s / 2, width: s * 0.8, height: s * 0.8)),
                                 with: .color(color.opacity(0.85)))
                    default:

                        drawSparkle(ctx, at: .zero, r: s * 0.62, color: color.opacity(0.9))
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct SoftSegmented: View {
    let items: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { selection = i }
                }) {
                    Text(item)
                        .font(SoftTheme.body(13, selection == i ? .bold : .medium))
                        .foregroundColor(selection == i ? .white : SoftTheme.inkSoft)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule().fill(selection == i ? SoftTheme.coral : Color.clear)
                        )
                }
                .buttonStyle(SoftPressStyle())
            }
        }
        .padding(4)
        .background(Capsule().fill(SoftTheme.card)
            .shadow(color: SoftTheme.cardShadow, radius: 6, x: 0, y: 3))
    }
}

struct SoftToggleRow: View {
    let title: String
    let subtitle: String
    let icon: SoftIconKind
    var tint: Color = SoftTheme.coral
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(tint.opacity(0.14))
                    .frame(width: 38, height: 38)
                SoftIcon(kind: icon, size: 19, color: tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(SoftTheme.body(15, .semibold)).foregroundColor(SoftTheme.ink)
                Text(subtitle).font(SoftTheme.body(12)).foregroundColor(SoftTheme.inkSoft)
            }
            Spacer()
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { isOn.toggle() } }) {
                Capsule()
                    .fill(isOn ? tint : SoftTheme.ink.opacity(0.15))
                    .frame(width: 48, height: 29)
                    .overlay(
                        Circle().fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: isOn ? 9 : -9)
                            .shadow(color: SoftTheme.ink.opacity(0.2), radius: 2, x: 0, y: 1)
                    )
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(.vertical, 4)
    }
}
