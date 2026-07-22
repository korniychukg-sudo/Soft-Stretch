import SwiftUI

// 7-day guided journeys built from the existing routine library.

struct ProgramDay {
    let day: Int
    let routineID: String
    let title: String
    let blurb: String
}

struct StretchProgram: Identifiable {
    let id: String
    let name: String
    let tagline: String
    let artName: String     // reuses a routine cover
    let tint: Color
    let days: [ProgramDay]
}

enum ProgramLibrary {
    static let all: [StretchProgram] = [
        StretchProgram(
            id: "gentle-week", name: "Gentle Week",
            tagline: "Seven soft days to wake your whole body",
            artName: "cover_fullbody", tint: SoftTheme.sage,
            days: [
                ProgramDay(day: 1, routineID: "morning", title: "Say hello", blurb: "Easy sunrise wake-up"),
                ProgramDay(day: 2, routineID: "neckmelt", title: "Soft neck", blurb: "Melt the top tension"),
                ProgramDay(day: 3, routineID: "fullbody", title: "Head to toe", blurb: "Your first full flow"),
                ProgramDay(day: 4, routineID: "hips", title: "Happy hips", blurb: "Open what sitting closed"),
                ProgramDay(day: 5, routineID: "posture", title: "Stand tall", blurb: "Chest open, shoulders back"),
                ProgramDay(day: 6, routineID: "hamstrings", title: "Long legs", blurb: "Gentle hamstring care"),
                ProgramDay(day: 7, routineID: "fullbody", title: "Full circle", blurb: "The flow, now familiar")
            ]),
        StretchProgram(
            id: "desk-rescue", name: "Desk Rescue",
            tagline: "A week against screen-shaped shoulders",
            artName: "cover_desk", tint: SoftTheme.lavender,
            days: [
                ProgramDay(day: 1, routineID: "desk", title: "Undo the day", blurb: "The classic desk reset"),
                ProgramDay(day: 2, routineID: "neckmelt", title: "Neck melt", blurb: "Tilt away the stiffness"),
                ProgramDay(day: 3, routineID: "posture", title: "Reset posture", blurb: "Like you mean it"),
                ProgramDay(day: 4, routineID: "desk", title: "Desk undo II", blurb: "Deeper this time"),
                ProgramDay(day: 5, routineID: "hips", title: "Chair-free hips", blurb: "Sitting undone"),
                ProgramDay(day: 6, routineID: "neckmelt", title: "Soft again", blurb: "Neck and traps, round two"),
                ProgramDay(day: 7, routineID: "posture", title: "Tall finish", blurb: "Walk out taller")
            ]),
        StretchProgram(
            id: "winddown-week", name: "Wind-Down Week",
            tagline: "Seven calm evenings, softer sleep",
            artName: "cover_evening", tint: SoftTheme.sky,
            days: [
                ProgramDay(day: 1, routineID: "evening", title: "First unwind", blurb: "Slow evening ritual"),
                ProgramDay(day: 2, routineID: "hamstrings", title: "Leg release", blurb: "Let the legs let go"),
                ProgramDay(day: 3, routineID: "evening", title: "Unwind again", blurb: "Deeper calm tonight"),
                ProgramDay(day: 4, routineID: "hips", title: "Hip lullaby", blurb: "Rock the hips loose"),
                ProgramDay(day: 5, routineID: "neckmelt", title: "Pillow prep", blurb: "A soft neck sleeps well"),
                ProgramDay(day: 6, routineID: "hamstrings", title: "Long and light", blurb: "Hamstrings, kindly"),
                ProgramDay(day: 7, routineID: "evening", title: "Softest night", blurb: "The full wind-down")
            ])
    ]

    static func byID(_ id: String) -> StretchProgram? {
        all.first { $0.id == id }
    }
}
