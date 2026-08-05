import SwiftUI

struct BuddyOutfit: Equatable {
    var skinID: String = "mint"
    var accessoryID: String? = nil
    static let classic = BuddyOutfit()
}

enum Friendship {

    static let levelThresholds = [0, 10, 25, 45, 70, 100, 140, 190, 250, 320, 400, 500]

    static func level(for xp: Int) -> Int {
        var lvl = 1
        for (i, t) in levelThresholds.enumerated() where xp >= t { lvl = i + 1 }
        return lvl
    }

    static func progressToNext(_ xp: Int) -> (have: Int, need: Int, fraction: CGFloat) {
        let lvl = level(for: xp)
        guard lvl < levelThresholds.count else { return (0, 0, 1) }
        let base = levelThresholds[lvl - 1]
        let next = levelThresholds[lvl]
        let have = xp - base, need = next - base
        return (have, need, CGFloat(have) / CGFloat(max(need, 1)))
    }

    static let names = ["New Friends", "Hello Pals", "Warm Pals", "Good Company",
                        "Cozy Pals", "Stretch Mates", "True Buddies", "Close Friends",
                        "Dear Friends", "Soul Stretchers", "Heart Friends", "Best Friends"]

    static func levelName(_ level: Int) -> String {
        names[min(max(level, 1), names.count) - 1]
    }
}

enum RewardKind {
    case skin(String)
    case accessory(String)
}

struct FriendshipReward {
    let level: Int
    let kind: RewardKind
    let title: String
}

enum RewardTable {
    static let all: [FriendshipReward] = [
        FriendshipReward(level: 2, kind: .skin("peach"), title: "Peach skin"),
        FriendshipReward(level: 3, kind: .accessory("sweatband"), title: "Sporty sweatband"),
        FriendshipReward(level: 4, kind: .skin("sky"), title: "Sky skin"),
        FriendshipReward(level: 5, kind: .accessory("scarf"), title: "Cozy scarf"),
        FriendshipReward(level: 6, kind: .accessory("flowers"), title: "Flower crown"),
        FriendshipReward(level: 7, kind: .skin("lilac"), title: "Lilac skin"),
        FriendshipReward(level: 8, kind: .accessory("glasses"), title: "Round glasses"),
        FriendshipReward(level: 9, kind: .skin("sand"), title: "Sand skin"),
        FriendshipReward(level: 10, kind: .accessory("beanie"), title: "Pompom beanie"),
        FriendshipReward(level: 11, kind: .accessory("bowtie"), title: "Bow tie"),
        FriendshipReward(level: 12, kind: .skin("sunrise"), title: "Sunrise gold skin")
    ]

    static func reward(at level: Int) -> FriendshipReward? {
        all.first { $0.level == level }
    }

    static func skinUnlockLevel(_ id: String) -> Int {
        if id == "mint" { return 1 }
        for r in all { if case .skin(let s) = r.kind, s == id { return r.level } }
        return 1
    }

    static func accessoryUnlockLevel(_ id: String) -> Int {
        for r in all { if case .accessory(let a) = r.kind, a == id { return r.level } }
        return 1
    }
}

struct SessionReward {
    let gained: Int
    let oldLevel: Int
    let newLevel: Int
}

struct CompanionState: Codable {
    var xp: Int = 0
    var equippedSkin: String = "mint"
    var equippedAccessory: String? = nil
    var celebratedLevels: [Int] = []
    var programDays: [String: [Int: Date]] = [:]

    init() {}

    enum CodingKeys: String, CodingKey {
        case xp, equippedSkin, equippedAccessory, celebratedLevels, programDays
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        xp = (try? c.decode(Int.self, forKey: .xp)) ?? 0
        equippedSkin = (try? c.decode(String.self, forKey: .equippedSkin)) ?? "mint"
        equippedAccessory = try? c.decode(String.self, forKey: .equippedAccessory)
        celebratedLevels = (try? c.decode([Int].self, forKey: .celebratedLevels)) ?? []
        programDays = (try? c.decode([String: [Int: Date]].self, forKey: .programDays)) ?? [:]
    }
}

final class CompanionStore: ObservableObject {
    static let key = "soft.companion.v1"

    @Published var state = CompanionState()

    @Published var lastReward: SessionReward? = nil

    private let defaults = UserDefaults.standard

    init() {
        if let data = defaults.data(forKey: Self.key),
           let s = try? JSONDecoder().decode(CompanionState.self, from: data) {
            state = s
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.key)
        }
    }

    var xp: Int { state.xp }
    var level: Int { Friendship.level(for: state.xp) }
    var outfit: BuddyOutfit { BuddyOutfit(skinID: state.equippedSkin, accessoryID: state.equippedAccessory) }

    func award(seconds: Int, streakActive: Bool) {
        let old = level
        let gained = max(1, seconds / 60) + 5 + (streakActive ? 3 : 0)
        state.xp += gained
        lastReward = SessionReward(gained: gained, oldLevel: old, newLevel: level)
        save()
    }

    func isSkinUnlocked(_ id: String) -> Bool { level >= RewardTable.skinUnlockLevel(id) }
    func isAccessoryUnlocked(_ id: String) -> Bool { level >= RewardTable.accessoryUnlockLevel(id) }

    func equipSkin(_ id: String) {
        guard isSkinUnlocked(id) else { return }
        state.equippedSkin = id
        save()
    }

    func equipAccessory(_ id: String?) {
        if let id = id, !isAccessoryUnlocked(id) { return }
        state.equippedAccessory = id
        save()
    }

    func markCelebrated(_ level: Int) {
        guard !state.celebratedLevels.contains(level) else { return }
        state.celebratedLevels.append(level)
        save()
    }

    func completeProgramDay(programID: String, day: Int) {
        var days = state.programDays[programID] ?? [:]
        if days[day] == nil { days[day] = Date() }
        state.programDays[programID] = days
        save()
    }

    func completedDays(_ programID: String) -> Set<Int> {
        Set(state.programDays[programID]?.keys.map { $0 } ?? [])
    }

    func nextDay(_ programID: String, totalDays: Int) -> Int? {
        let done = completedDays(programID)
        for d in 1...totalDays where !done.contains(d) { return d }
        return nil
    }
}
