import SwiftUI

enum BodyArea: String, Codable, CaseIterable, Identifiable {
    case neckShoulders
    case backCore
    case hipsLegs
    case armsChest
    case fullBody

    var id: String { rawValue }

    var title: String {
        switch self {
        case .neckShoulders: return "Neck & Shoulders"
        case .backCore: return "Back & Core"
        case .hipsLegs: return "Hips & Legs"
        case .armsChest: return "Arms & Chest"
        case .fullBody: return "Full Body"
        }
    }
}

enum MuscleZone: String, Codable, CaseIterable {
    case neck
    case shoulderL, shoulderR
    case upperArmL, upperArmR
    case forearmL, forearmR
    case chest
    case spine
    case sideL, sideR
    case hipL, hipR
    case thighL, thighR
    case calfL, calfR

    var mirrored: MuscleZone {
        switch self {
        case .shoulderL: return .shoulderR
        case .shoulderR: return .shoulderL
        case .upperArmL: return .upperArmR
        case .upperArmR: return .upperArmL
        case .forearmL: return .forearmR
        case .forearmR: return .forearmL
        case .sideL: return .sideR
        case .sideR: return .sideL
        case .hipL: return .hipR
        case .hipR: return .hipL
        case .thighL: return .thighR
        case .thighR: return .thighL
        case .calfL: return .calfR
        case .calfR: return .calfL
        default: return self
        }
    }
}

enum BuddyFacing: String, Codable {
    case front
    case side
}

struct BuddyPose {
    var hipX: CGFloat = 0
    var hipY: CGFloat = 0
    var torsoLean: CGFloat = 0
    var chestBend: CGFloat = 0
    var headTilt: CGFloat = 0
    var headTurn: CGFloat = 0

    var armRaiseL: CGFloat = 0
    var elbowL: CGFloat = 0
    var armRaiseR: CGFloat = 0
    var elbowR: CGFloat = 0

    var legOutL: CGFloat = 0
    var kneeL: CGFloat = 0
    var legOutR: CGFloat = 0
    var kneeR: CGFloat = 0

    var breathe: CGFloat = 1

    static let standing = BuddyPose()

    static func lerp(_ a: BuddyPose, _ b: BuddyPose, _ t: CGFloat) -> BuddyPose {
        func m(_ x: CGFloat, _ y: CGFloat) -> CGFloat { x + (y - x) * t }
        var p = BuddyPose()
        p.hipX = m(a.hipX, b.hipX); p.hipY = m(a.hipY, b.hipY)
        p.torsoLean = m(a.torsoLean, b.torsoLean); p.chestBend = m(a.chestBend, b.chestBend)
        p.headTilt = m(a.headTilt, b.headTilt); p.headTurn = m(a.headTurn, b.headTurn)
        p.armRaiseL = m(a.armRaiseL, b.armRaiseL); p.elbowL = m(a.elbowL, b.elbowL)
        p.armRaiseR = m(a.armRaiseR, b.armRaiseR); p.elbowR = m(a.elbowR, b.elbowR)
        p.legOutL = m(a.legOutL, b.legOutL); p.kneeL = m(a.kneeL, b.kneeL)
        p.legOutR = m(a.legOutR, b.legOutR); p.kneeR = m(a.kneeR, b.kneeR)
        p.breathe = m(a.breathe, b.breathe)
        return p
    }

    var mirrored: BuddyPose {
        var p = self
        p.hipX = -hipX
        p.torsoLean = -torsoLean
        p.headTilt = -headTilt
        p.headTurn = -headTurn
        swap(&p.armRaiseL, &p.armRaiseR)
        swap(&p.elbowL, &p.elbowR)
        swap(&p.legOutL, &p.legOutR)
        swap(&p.kneeL, &p.kneeR)
        return p
    }
}

struct PoseKeyframe {
    let t: CGFloat
    let pose: BuddyPose
    var cue: String = ""
}

struct Stretch: Identifiable {
    let id: String
    let name: String
    let area: BodyArea
    let facing: BuddyFacing
    let bilateral: Bool
    let muscles: [MuscleZone]
    let muscleNames: String
    let benefit: String
    let howTo: [String]
    let cycleSeconds: Double
    let keyframes: [PoseKeyframe]
    var groundLevel: CGFloat = 0

    func pose(at cycleT: CGFloat) -> BuddyPose {
        guard let first = keyframes.first else { return .standing }
        guard keyframes.count > 1 else { return first.pose }
        let t = cycleT.truncatingRemainder(dividingBy: 1)
        var prev = keyframes[0]
        for kf in keyframes.dropFirst() {
            if t <= kf.t {
                let span = max(kf.t - prev.t, 0.0001)
                let local = (t - prev.t) / span
                let eased = local * local * (3 - 2 * local)
                return BuddyPose.lerp(prev.pose, kf.pose, eased)
            }
            prev = kf
        }
        return keyframes.last?.pose ?? first.pose
    }

    func cue(at cycleT: CGFloat) -> String {
        let t = cycleT.truncatingRemainder(dividingBy: 1)
        var current = keyframes.first?.cue ?? ""
        for kf in keyframes where kf.t <= t {
            if !kf.cue.isEmpty { current = kf.cue }
        }
        return current
    }
}

struct RoutineStep {
    let stretchID: String
    let secondsPerSide: Int
}

struct Routine: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let artName: String
    let tintArea: BodyArea
    let steps: [RoutineStep]

    func totalSeconds(library: [String: Stretch]) -> Int {
        steps.reduce(0) { sum, step in
            let sides = (library[step.stretchID]?.bilateral ?? false) ? 2 : 1
            return sum + step.secondsPerSide * sides
        }
    }
}

struct SessionRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let routineID: String
    let routineName: String
    let seconds: Int
    let stretchCount: Int

    var areaSeconds: [String: Int]? = nil
}

struct BadgeSpec: Identifiable {
    let id: String
    let name: String
    let detail: String
    let emblem: Int
}

struct CustomStep: Codable {
    var stretchID: String
    var seconds: Int
}

struct CustomRoutine: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var tintAreaRaw: String = BodyArea.fullBody.rawValue
    var steps: [CustomStep]

    var tintArea: BodyArea { BodyArea(rawValue: tintAreaRaw) ?? .fullBody }

    func asRoutine() -> Routine {
        Routine(id: "custom-\(id.uuidString)",
                name: name,
                subtitle: "Your own routine",
                artName: "",
                tintArea: tintArea,
                steps: steps.map { RoutineStep(stretchID: $0.stretchID, secondsPerSide: $0.seconds) })
    }
}

struct SoftSettings: Codable {
    var reduceMotion: Bool = false
    var hapticsOn: Bool = true
    var cuesOn: Bool = true
    var onboarded: Bool = false
    var favoriteRoutines: [String] = []
}
