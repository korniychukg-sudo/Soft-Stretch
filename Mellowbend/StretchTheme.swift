import SwiftUI

enum SoftTheme {

    static let cream = Color(red: 0.984, green: 0.965, blue: 0.937)
    static let card = Color(red: 1.0, green: 0.992, blue: 0.976)
    static let ink = Color(red: 0.239, green: 0.220, blue: 0.278)
    static let inkSoft = Color(red: 0.239, green: 0.220, blue: 0.278).opacity(0.62)
    static let line = Color(red: 0.239, green: 0.220, blue: 0.278).opacity(0.10)

    static let coral = Color(red: 0.949, green: 0.475, blue: 0.361)
    static let coralDeep = Color(red: 0.855, green: 0.373, blue: 0.278)
    static let lavender = Color(red: 0.616, green: 0.549, blue: 0.839)
    static let sage = Color(red: 0.498, green: 0.663, blue: 0.545)
    static let sun = Color(red: 0.961, green: 0.757, blue: 0.361)
    static let sky = Color(red: 0.475, green: 0.686, blue: 0.792)
    static let rose = Color(red: 0.910, green: 0.588, blue: 0.643)

    static let buddyBody = Color(red: 0.561, green: 0.796, blue: 0.706)
    static let buddyBodyDeep = Color(red: 0.435, green: 0.671, blue: 0.580)
    static let buddyCheek = Color(red: 0.965, green: 0.663, blue: 0.584)
    static let muscleGlow = Color(red: 1.0, green: 0.549, blue: 0.353)
    static let mat = Color(red: 0.898, green: 0.769, blue: 0.686)

    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let cardCorner: CGFloat = 22
    static let screenPad: CGFloat = 20

    static let contentMaxWidth: CGFloat = 640

    static var cardShadow: Color { ink.opacity(0.07) }
}

private struct SoftAppear: ViewModifier {
    let delay: Double
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 14)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func softAppear(delay: Double = 0) -> some View { modifier(SoftAppear(delay: delay)) }
}

enum SoftDaypart {
    case dawn, day, dusk, night

    static func current(hour: Int = Calendar.current.component(.hour, from: Date())) -> SoftDaypart {
        switch hour {
        case 5..<9: return .dawn
        case 9..<17: return .day
        case 17..<21: return .dusk
        default: return .night
        }
    }

    var skyTop: Color {
        switch self {
        case .dawn: return Color(red: 0.973, green: 0.800, blue: 0.694)
        case .day: return Color(red: 0.702, green: 0.851, blue: 0.914)
        case .dusk: return Color(red: 0.894, green: 0.635, blue: 0.588)
        case .night: return Color(red: 0.294, green: 0.294, blue: 0.451)
        }
    }

    var skyBottom: Color {
        switch self {
        case .dawn: return Color(red: 0.984, green: 0.902, blue: 0.776)
        case .day: return Color(red: 0.851, green: 0.929, blue: 0.902)
        case .dusk: return Color(red: 0.729, green: 0.616, blue: 0.788)
        case .night: return Color(red: 0.412, green: 0.427, blue: 0.584)
        }
    }

    var isDark: Bool { self == .night }
}

extension BodyArea {
    var tint: Color {
        switch self {
        case .neckShoulders: return SoftTheme.lavender
        case .backCore: return SoftTheme.sky
        case .hipsLegs: return SoftTheme.sage
        case .armsChest: return SoftTheme.rose
        case .fullBody: return SoftTheme.sun
        }
    }
}
