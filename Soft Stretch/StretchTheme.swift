import SwiftUI

// Central palette + typography for Soft Stretch.
// Fixed warm-light look, independent of the system theme.
enum SoftTheme {
    // Base
    static let cream = Color(red: 0.984, green: 0.965, blue: 0.937)   // app background
    static let card = Color(red: 1.0, green: 0.992, blue: 0.976)      // card surface
    static let ink = Color(red: 0.239, green: 0.220, blue: 0.278)     // primary text
    static let inkSoft = Color(red: 0.239, green: 0.220, blue: 0.278).opacity(0.62)
    static let line = Color(red: 0.239, green: 0.220, blue: 0.278).opacity(0.10)

    // Accents
    static let coral = Color(red: 0.949, green: 0.475, blue: 0.361)   // primary action
    static let coralDeep = Color(red: 0.855, green: 0.373, blue: 0.278)
    static let lavender = Color(red: 0.616, green: 0.549, blue: 0.839)
    static let sage = Color(red: 0.498, green: 0.663, blue: 0.545)
    static let sun = Color(red: 0.961, green: 0.757, blue: 0.361)
    static let sky = Color(red: 0.475, green: 0.686, blue: 0.792)
    static let rose = Color(red: 0.910, green: 0.588, blue: 0.643)

    // Buddy the stretch companion
    static let buddyBody = Color(red: 0.561, green: 0.796, blue: 0.706)     // mint
    static let buddyBodyDeep = Color(red: 0.435, green: 0.671, blue: 0.580) // shaded mint
    static let buddyCheek = Color(red: 0.965, green: 0.663, blue: 0.584)
    static let muscleGlow = Color(red: 1.0, green: 0.549, blue: 0.353)      // active muscle
    static let mat = Color(red: 0.898, green: 0.769, blue: 0.686)           // exercise mat

    // Typography — rounded everywhere for the soft feel
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let cardCorner: CGFloat = 22
    static let screenPad: CGFloat = 20

    // Widest layout used for content on iPad so lines stay readable
    static let contentMaxWidth: CGFloat = 640

    static var cardShadow: Color { ink.opacity(0.07) }
}

// Per-body-area tint used across library, covers and player chips.
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
