import SwiftUI

final class StretchStore: ObservableObject {
    static let sessionsKey = "soft.sessions.v1"
    static let settingsKey = "soft.settings.v1"
    static let badgesKey = "soft.badges.v1"
    static let customKey = "soft.customroutines.v1"

    @Published var sessions: [SessionRecord] = []
    @Published var settings = SoftSettings()
    @Published var unlockedBadges: [String: Date] = [:]
    @Published var customRoutines: [CustomRoutine] = []

    @Published var freshBadges: [BadgeSpec] = []

    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: Self.sessionsKey),
           let list = try? decoder.decode([SessionRecord].self, from: data) {
            sessions = list
        }
        if let data = defaults.data(forKey: Self.settingsKey),
           let s = try? decoder.decode(SoftSettings.self, from: data) {
            settings = s
        }
        if let data = defaults.data(forKey: Self.badgesKey),
           let b = try? decoder.decode([String: Date].self, from: data) {
            unlockedBadges = b
        }
        if let data = defaults.data(forKey: Self.customKey),
           let c = try? decoder.decode([CustomRoutine].self, from: data) {
            customRoutines = c
        }
    }

    func saveAll() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sessions) { defaults.set(data, forKey: Self.sessionsKey) }
        if let data = try? encoder.encode(settings) { defaults.set(data, forKey: Self.settingsKey) }
        if let data = try? encoder.encode(unlockedBadges) { defaults.set(data, forKey: Self.badgesKey) }
        if let data = try? encoder.encode(customRoutines) { defaults.set(data, forKey: Self.customKey) }
    }

    func saveCustomRoutine(_ r: CustomRoutine) {
        if let idx = customRoutines.firstIndex(where: { $0.id == r.id }) {
            customRoutines[idx] = r
        } else {
            customRoutines.append(r)
        }
        saveAll()
    }

    func deleteCustomRoutine(_ id: UUID) {
        customRoutines.removeAll { $0.id == id }
        saveAll()
    }

    func updateSettings(_ mutate: (inout SoftSettings) -> Void) {
        mutate(&settings)
        saveAll()
    }

    func recordSession(routine: Routine, seconds: Int, stretchCount: Int,
                       areaSeconds: [String: Int]? = nil) {
        let record = SessionRecord(date: Date(), routineID: routine.id,
                                   routineName: routine.name,
                                   seconds: max(seconds, 1), stretchCount: stretchCount,
                                   areaSeconds: areaSeconds)
        sessions.append(record)
        let newly = evaluateBadges()
        freshBadges = newly
        saveAll()
    }

    func resetEverything() {
        sessions = []
        unlockedBadges = [:]
        settings = SoftSettings(onboarded: true)
        freshBadges = []
        saveAll()
    }

    var totalSeconds: Int { sessions.reduce(0) { $0 + $1.seconds } }
    var totalMinutes: Int { totalSeconds / 60 }
    var sessionCount: Int { sessions.count }

    private var calendar: Calendar { Calendar.current }

    func sessions(on day: Date) -> [SessionRecord] {
        sessions.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    var stretchedToday: Bool { !sessions(on: Date()).isEmpty }

    var currentStreak: Int {
        var streak = 0
        var day = Date()
        if sessions(on: day).isEmpty {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        while !sessions(on: day).isEmpty {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    var bestStreak: Int {
        let days = Set(sessions.map { calendar.startOfDay(for: $0.date) }).sorted()
        var best = 0, run = 0
        var prev: Date?
        for day in days {
            if let p = prev, let next = calendar.date(byAdding: .day, value: 1, to: p),
               calendar.isDate(next, inSameDayAs: day) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            prev = day
        }
        return best
    }

    var distinctRoutinesTried: Set<String> {
        Set(sessions.map { $0.routineID })
            .intersection(Set(RoutineLibrary.all.map { $0.id }))
    }

    func minutes(on day: Date) -> Int {
        sessions(on: day).reduce(0) { $0 + $1.seconds } / 60
    }

    func areaBalance() -> [(area: BodyArea, fraction: CGFloat)] {
        var totals: [String: Int] = [:]
        for s in sessions {
            for (k, v) in s.areaSeconds ?? [:] { totals[k, default: 0] += v }
        }
        let sum = totals.values.reduce(0, +)
        let areas: [BodyArea] = [.neckShoulders, .backCore, .hipsLegs, .armsChest]
        return areas.map { a in
            (a, sum > 0 ? CGFloat(totals[a.rawValue] ?? 0) / CGFloat(sum) : 0)
        }
    }

    func recentMinutes(days: Int) -> [(date: Date, minutes: Int)] {
        var out: [(Date, Int)] = []
        for offset in stride(from: days - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let mins = sessions(on: day).reduce(0) { $0 + $1.seconds } / 60
            out.append((day, mins))
        }
        return out
    }

    static let badgeSpecs: [BadgeSpec] = [
        BadgeSpec(id: "first", name: "First Stretch", detail: "Finish your first session", emblem: 0),
        BadgeSpec(id: "three", name: "Warming Up", detail: "Finish 3 sessions", emblem: 1),
        BadgeSpec(id: "ten", name: "Regular", detail: "Finish 10 sessions", emblem: 2),
        BadgeSpec(id: "twentyfive", name: "Devoted", detail: "Finish 25 sessions", emblem: 3),
        BadgeSpec(id: "sixty-min", name: "One Hour Soft", detail: "Stretch 60 total minutes", emblem: 4),
        BadgeSpec(id: "threehundred-min", name: "Five Hours Deep", detail: "Stretch 300 total minutes", emblem: 5),
        BadgeSpec(id: "streak3", name: "Three in a Row", detail: "Keep a 3-day streak", emblem: 6),
        BadgeSpec(id: "streak7", name: "One Soft Week", detail: "Keep a 7-day streak", emblem: 7),
        BadgeSpec(id: "streak14", name: "Fortnight Flow", detail: "Keep a 14-day streak", emblem: 8),
        BadgeSpec(id: "explorer", name: "Explorer", detail: "Try every routine once", emblem: 9),
        BadgeSpec(id: "earlybird", name: "Early Bird", detail: "Stretch before 8 in the morning", emblem: 10),
        BadgeSpec(id: "nightowl", name: "Night Owl", detail: "Stretch after 9 in the evening", emblem: 11)
    ]

    func isUnlocked(_ id: String) -> Bool { unlockedBadges[id] != nil }

    @discardableResult
    private func evaluateBadges() -> [BadgeSpec] {
        var fresh: [BadgeSpec] = []
        func unlock(_ id: String) {
            guard unlockedBadges[id] == nil else { return }
            unlockedBadges[id] = Date()
            if let spec = Self.badgeSpecs.first(where: { $0.id == id }) { fresh.append(spec) }
        }
        if sessionCount >= 1 { unlock("first") }
        if sessionCount >= 3 { unlock("three") }
        if sessionCount >= 10 { unlock("ten") }
        if sessionCount >= 25 { unlock("twentyfive") }
        if totalMinutes >= 60 { unlock("sixty-min") }
        if totalMinutes >= 300 { unlock("threehundred-min") }
        let streak = currentStreak
        if streak >= 3 { unlock("streak3") }
        if streak >= 7 { unlock("streak7") }
        if streak >= 14 { unlock("streak14") }
        if distinctRoutinesTried.count >= RoutineLibrary.all.count { unlock("explorer") }
        if let last = sessions.last {
            let hour = calendar.component(.hour, from: last.date)
            if hour < 8 { unlock("earlybird") }
            if hour >= 21 { unlock("nightowl") }
        }
        return fresh
    }

    func toggleFavorite(_ routineID: String) {
        if let idx = settings.favoriteRoutines.firstIndex(of: routineID) {
            settings.favoriteRoutines.remove(at: idx)
        } else {
            settings.favoriteRoutines.append(routineID)
        }
        saveAll()
    }

    func isFavorite(_ routineID: String) -> Bool {
        settings.favoriteRoutines.contains(routineID)
    }
}

enum SoftHaptics {
    static func tap(_ store: StretchStore) {
        guard store.settings.hapticsOn else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func step(_ store: StretchStore) {
        guard store.settings.hapticsOn else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success(_ store: StretchStore) {
        guard store.settings.hapticsOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
