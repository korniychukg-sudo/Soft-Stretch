import SwiftUI

enum PoseLibrary {

    private static func p(hx: CGFloat = 0, hy: CGFloat = 0, lean: CGFloat = 0, bend: CGFloat = 0,
                          head: CGFloat = 0, turn: CGFloat = 0,
                          alL: CGFloat = 0, elL: CGFloat = 0, alR: CGFloat = 0, elR: CGFloat = 0,
                          lgL: CGFloat = 0, knL: CGFloat = 0, lgR: CGFloat = 0, knR: CGFloat = 0,
                          breathe: CGFloat = 1) -> BuddyPose {
        var pose = BuddyPose()
        pose.hipX = hx; pose.hipY = hy
        pose.torsoLean = lean; pose.chestBend = bend
        pose.headTilt = head; pose.headTurn = turn
        pose.armRaiseL = alL; pose.elbowL = elL
        pose.armRaiseR = alR; pose.elbowR = elR
        pose.legOutL = lgL; pose.kneeL = knL
        pose.legOutR = lgR; pose.kneeR = knR
        pose.breathe = breathe
        return pose
    }

    private static func kf(_ t: CGFloat, _ pose: BuddyPose, _ cue: String = "") -> PoseKeyframe {
        PoseKeyframe(t: t, pose: pose, cue: cue)
    }

    static let all: [Stretch] = [

        Stretch(id: "neck-tilt", name: "Neck Tilt", area: .neckShoulders, facing: .front,
                bilateral: true, muscles: [.neck],
                muscleNames: "Side of the neck",
                benefit: "Melts the tension that piles up between your ear and shoulder.",
                howTo: ["Sit or stand tall, shoulders heavy.",
                        "Let one ear sink toward the shoulder.",
                        "Breathe slowly; never pull with force."],
                cycleSeconds: 10,
                keyframes: [
                    kf(0, p(), "Stand tall, shoulders soft"),
                    kf(0.22, p(head: -26, turn: -0.3), "Ear sinks toward the shoulder"),
                    kf(0.72, p(head: -30, turn: -0.3), "Breathe into the side of your neck"),
                    kf(0.9, p(), "Float back to center"),
                    kf(1, p())
                ]),

        Stretch(id: "neck-roll", name: "Slow Neck Roll", area: .neckShoulders, facing: .front,
                bilateral: false, muscles: [.neck],
                muscleNames: "Neck, upper traps",
                benefit: "A gentle half-circle that unwinds the whole neck.",
                howTo: ["Drop your chin toward your chest.",
                        "Roll the chin from shoulder to shoulder.",
                        "Keep the half-circle low and slow."],
                cycleSeconds: 9,
                keyframes: [
                    kf(0, p(head: -22, turn: -0.6), "Chin low, roll gently"),
                    kf(0.25, p(head: -6, turn: -0.2)),
                    kf(0.5, p(head: 22, turn: 0.6), "Sweep to the other side"),
                    kf(0.75, p(head: -6, turn: -0.2)),
                    kf(1, p(head: -22, turn: -0.6))
                ]),

        Stretch(id: "shoulder-rolls", name: "Shoulder Rolls", area: .neckShoulders, facing: .front,
                bilateral: false, muscles: [.shoulderL, .shoulderR],
                muscleNames: "Shoulders, upper back",
                benefit: "Wakes up stiff shoulders and resets your posture.",
                howTo: ["Let both arms hang loose.",
                        "Draw big slow circles with your shoulders.",
                        "Roll up, back and down — never forced."],
                cycleSeconds: 4,
                keyframes: [
                    kf(0, p(bend: 3, alL: 6, elL: 20, alR: 6, elR: 20), "Big slow circles"),
                    kf(0.35, p(hy: -3, bend: -5, alL: 20, elL: 26, alR: 20, elR: 26), "Lift and roll back"),
                    kf(0.7, p(bend: 4, alL: 10, elL: 18, alR: 10, elR: 18), "Melt them down"),
                    kf(1, p(bend: 3, alL: 6, elL: 20, alR: 6, elR: 20))
                ]),

        Stretch(id: "arm-cross", name: "Arm Cross Hug", area: .neckShoulders, facing: .front,
                bilateral: true, muscles: [.shoulderL, .upperArmL],
                muscleNames: "Rear shoulder",
                benefit: "Reaches the back of the shoulder that mouse days forget.",
                howTo: ["Sweep one arm across your chest.",
                        "Hug it closer with the other forearm.",
                        "Keep the shoulder low, not shrugged."],
                cycleSeconds: 11,
                keyframes: [
                    kf(0, p(), "Sweep the arm across"),
                    kf(0.2, p(turn: 0.3, alL: -72, elL: 6, alR: 32, elR: 108), "Hug it gently closer"),
                    kf(0.75, p(turn: 0.3, alL: -78, elL: 6, alR: 34, elR: 112), "Shoulder stays low"),
                    kf(0.92, p()),
                    kf(1, p())
                ]),

        Stretch(id: "arm-circles", name: "Arm Circles", area: .neckShoulders, facing: .front,
                bilateral: false, muscles: [.shoulderL, .shoulderR, .upperArmL, .upperArmR],
                muscleNames: "Shoulders, arms",
                benefit: "Floods the shoulder joints with easy motion.",
                howTo: ["Reach both arms out to the sides.",
                        "Swim them up overhead and back down.",
                        "Keep the circles round and unhurried."],
                cycleSeconds: 6,
                keyframes: [
                    kf(0, p(alL: 15, alR: 15), "Swim the arms up"),
                    kf(0.45, p(hy: -3, alL: 165, alR: 165), "Reach the sky"),
                    kf(0.62, p(alL: 95, elL: 8, alR: 95, elR: 8), "Wide and round"),
                    kf(1, p(alL: 15, alR: 15))
                ]),

        Stretch(id: "wrist-stretch", name: "Wrist Soother", area: .armsChest, facing: .front,
                bilateral: true, muscles: [.forearmL],
                muscleNames: "Forearm, wrist",
                benefit: "Sweet relief for typing hands and phone thumbs.",
                howTo: ["Reach one arm out, palm up.",
                        "Use the other hand to ease the fingers back.",
                        "Hold softly — a warm pull, never pain."],
                cycleSeconds: 10,
                keyframes: [
                    kf(0, p(), "Reach the arm long"),
                    kf(0.2, p(turn: -0.3, alL: 82, elL: 0, alR: 40, elR: 95), "Ease the fingers back"),
                    kf(0.75, p(turn: -0.3, alL: 86, elL: 0, alR: 44, elR: 100), "Soft steady hold"),
                    kf(0.92, p()),
                    kf(1, p())
                ]),

        Stretch(id: "chest-opener", name: "Chest Opener", area: .armsChest, facing: .front,
                bilateral: false, muscles: [.chest, .shoulderL, .shoulderR],
                muscleNames: "Chest, front shoulders",
                benefit: "Undoes the laptop hunch and lets you breathe wider.",
                howTo: ["Open both arms wide like wings.",
                        "Lift your chest and look slightly up.",
                        "Feel the front of your chest bloom open."],
                cycleSeconds: 9,
                keyframes: [
                    kf(0, p(alL: 30, alR: 30), "Open your wings"),
                    kf(0.3, p(bend: -8, head: -4, alL: 66, alR: 66), "Chest blooms open"),
                    kf(0.75, p(bend: -10, head: -6, alL: 72, alR: 72), "Breathe wide"),
                    kf(1, p(alL: 30, alR: 30))
                ]),

        Stretch(id: "gentle-twist", name: "Gentle Twist", area: .backCore, facing: .front,
                bilateral: false, muscles: [.spine, .sideL, .sideR],
                muscleNames: "Spine, waist",
                benefit: "A washing-machine sway that loosens the whole spine.",
                howTo: ["Stand soft, knees unlocked.",
                        "Let your arms swing side to side.",
                        "Let the head follow the swing."],
                cycleSeconds: 5,
                keyframes: [
                    kf(0, p(lean: -8, turn: -0.7, alL: 34, elL: 62, alR: -18, elR: 40), "Swing easy"),
                    kf(0.5, p(lean: 8, turn: 0.7, alL: -18, elL: 40, alR: 34, elR: 62), "And back the other way"),
                    kf(1, p(lean: -8, turn: -0.7, alL: 34, elL: 62, alR: -18, elR: 40))
                ]),

        Stretch(id: "side-bend", name: "Standing Side Bend", area: .backCore, facing: .front,
                bilateral: true, muscles: [.sideR],
                muscleNames: "Obliques, lats",
                benefit: "Opens the whole side body from hip to fingertips.",
                howTo: ["Reach one arm high overhead.",
                        "Lean away like a palm tree in wind.",
                        "Keep both feet rooted and heavy."],
                cycleSeconds: 11,
                keyframes: [
                    kf(0, p(), "Reach up tall"),
                    kf(0.22, p(lean: -16, head: -6, alL: 24, elL: 92, alR: 158, elR: 4), "Lean like a palm tree"),
                    kf(0.72, p(lean: -20, head: -8, alL: 26, elL: 96, alR: 164, elR: 4), "Long from hip to fingertips"),
                    kf(0.9, p()),
                    kf(1, p())
                ]),

        Stretch(id: "back-bend", name: "Standing Back Bend", area: .backCore, facing: .side,
                bilateral: false, muscles: [.spine, .chest],
                muscleNames: "Lower back, chest",
                benefit: "A tiny sunrise arch that counters hours of sitting.",
                howTo: ["Rest both hands on your lower back.",
                        "Lift your chest and arch gently back.",
                        "Keep the arch small and supported."],
                cycleSeconds: 10,
                keyframes: [
                    kf(0, p(), "Hands on your lower back"),
                    kf(0.25, p(lean: -10, bend: -9, head: -10, alL: -28, elL: -58, alR: -28, elR: -58), "Lift and arch gently"),
                    kf(0.7, p(lean: -13, bend: -11, head: -12, alL: -28, elL: -58, alR: -28, elR: -58), "Small supported arch"),
                    kf(0.9, p()),
                    kf(1, p())
                ]),

        Stretch(id: "cat-cow", name: "Cat and Cow", area: .backCore, facing: .side,
                bilateral: false, muscles: [.spine],
                muscleNames: "Whole spine",
                benefit: "The classic wave that keeps every vertebra happy.",
                howTo: ["Come to hands and knees.",
                        "Round your back up like a cat.",
                        "Then dip it low and look up — cow."],
                cycleSeconds: 8,
                keyframes: [
                    kf(0, p(hy: 44, lean: 76, bend: 26, head: 46, alL: 148, alR: 152, lgL: -35, knL: 55, lgR: -35, knR: 55), "Round up like a cat"),
                    kf(0.5, p(hy: 42, lean: 80, bend: -22, head: -42, alL: 152, alR: 156, lgL: -35, knL: 55, lgR: -35, knR: 55), "Dip low, look up — cow"),
                    kf(1, p(hy: 44, lean: 76, bend: 26, head: 46, alL: 148, alR: 152, lgL: -35, knL: 55, lgR: -35, knR: 55))
                ]),

        Stretch(id: "childs-pose", name: "Resting Fold", area: .backCore, facing: .side,
                bilateral: false, muscles: [.spine, .shoulderL, .shoulderR],
                muscleNames: "Back, shoulders",
                benefit: "The coziest reset — a fold that asks for nothing.",
                howTo: ["Kneel and sit back toward your heels.",
                        "Walk your hands far forward.",
                        "Let your forehead get heavy."],
                cycleSeconds: 9,
                keyframes: [
                    kf(0, p(hy: 56, lean: 88, bend: 8, head: 14, alL: 172, alR: 176, lgL: -30, knL: 62, lgR: -30, knR: 62), "Sink back and reach"),
                    kf(0.5, p(hy: 58, lean: 95, bend: 10, head: 16, alL: 178, alR: 182, lgL: -30, knL: 64, lgR: -30, knR: 64), "Heavy and soft"),
                    kf(1, p(hy: 56, lean: 88, bend: 8, head: 14, alL: 172, alR: 176, lgL: -30, knL: 62, lgR: -30, knR: 62))
                ]),

        Stretch(id: "forward-fold", name: "Rag Doll Fold", area: .backCore, facing: .side,
                bilateral: false, muscles: [.thighL, .thighR, .spine],
                muscleNames: "Hamstrings, lower back",
                benefit: "Hang like a rag doll and let gravity do the stretching.",
                howTo: ["Soften your knees generously.",
                        "Fold forward from the hips.",
                        "Let arms and head simply hang."],
                cycleSeconds: 12,
                keyframes: [
                    kf(0, p(), "Stand tall, breathe in"),
                    kf(0.14, p(hy: -3, alL: 162, alR: 166), "Reach up"),
                    kf(0.4, p(hx: -12, lean: 112, bend: 16, head: 12, alL: 145, alR: 149, lgL: 4, knL: 10, lgR: 4, knR: 10), "Fold and hang heavy"),
                    kf(0.78, p(hx: -12, lean: 118, bend: 18, head: 14, alL: 150, alR: 154, lgL: 4, knL: 12, lgR: 4, knR: 12), "Sway a little, let go"),
                    kf(0.95, p()),
                    kf(1, p())
                ]),

        Stretch(id: "hip-circles", name: "Hip Circles", area: .hipsLegs, facing: .front,
                bilateral: false, muscles: [.hipL, .hipR],
                muscleNames: "Hips, lower back",
                benefit: "Round, lazy circles that oil the hip joints.",
                howTo: ["Rest your hands on your hips.",
                        "Draw slow circles with your hips.",
                        "Keep knees springy and shoulders still."],
                cycleSeconds: 5,
                keyframes: [
                    kf(0, p(hx: -12, lean: 4, alL: 26, elL: 96, alR: 26, elR: 96), "Slow lazy circles"),
                    kf(0.25, p(hy: 4, alL: 26, elL: 96, alR: 26, elR: 96)),
                    kf(0.5, p(hx: 12, lean: -4, alL: 26, elL: 96, alR: 26, elR: 96), "Keep the shoulders still"),
                    kf(0.75, p(hy: -3, alL: 26, elL: 96, alR: 26, elR: 96)),
                    kf(1, p(hx: -12, lean: 4, alL: 26, elL: 96, alR: 26, elR: 96))
                ]),

        Stretch(id: "lunge", name: "Low Lunge", area: .hipsLegs, facing: .side,
                bilateral: true, muscles: [.hipL, .thighL],
                muscleNames: "Hip flexors",
                benefit: "Opens the front of the hip that chairs keep folded.",
                howTo: ["Step one foot far forward.",
                        "Sink your hips low and forward.",
                        "Reach up if it feels sweet."],
                cycleSeconds: 12,
                keyframes: [
                    kf(0, p(), "Step forward"),
                    kf(0.22, p(hy: 24, lean: 8, alL: 152, alR: 158, lgL: -36, knL: 14, lgR: 44, knR: 58), "Sink low and proud"),
                    kf(0.72, p(hy: 30, lean: 8, alL: 158, alR: 164, lgL: -38, knL: 14, lgR: 46, knR: 62), "Hips melt forward"),
                    kf(0.92, p()),
                    kf(1, p())
                ]),

        Stretch(id: "quad-stretch", name: "Standing Quad Hold", area: .hipsLegs, facing: .side,
                bilateral: true, muscles: [.thighL],
                muscleNames: "Quadriceps",
                benefit: "Lengthens the front thigh and steadies your balance.",
                howTo: ["Catch one foot behind you.",
                        "Draw the heel toward your seat.",
                        "Keep the knees close together."],
                cycleSeconds: 11,
                keyframes: [
                    kf(0, p(), "Find your balance"),
                    kf(0.22, p(lean: 6, alL: -50, elL: -92, alR: 148, lgL: -14, knL: 128, lgR: 2, knR: 4), "Heel toward your seat"),
                    kf(0.75, p(lean: 6, alL: -54, elL: -96, alR: 154, lgL: -16, knL: 136, lgR: 2, knR: 4), "Knees kiss together"),
                    kf(0.93, p()),
                    kf(1, p())
                ]),

        Stretch(id: "calf-stretch", name: "Wall Calf Press", area: .hipsLegs, facing: .side,
                bilateral: true, muscles: [.calfL],
                muscleNames: "Calves",
                benefit: "A long easy press for springy, happy calves.",
                howTo: ["Press both palms into a wall.",
                        "Step one leg straight back.",
                        "Sink the back heel into the floor."],
                cycleSeconds: 11,
                keyframes: [
                    kf(0, p(), "Hands to the wall"),
                    kf(0.22, p(lean: 17, alL: 74, elL: 4, alR: 80, elR: 4, lgL: -30, knL: 2, lgR: 14, knR: 26), "Back heel sinks down"),
                    kf(0.75, p(lean: 19, alL: 76, elL: 4, alR: 82, elR: 4, lgL: -33, knL: 2, lgR: 15, knR: 29), "Long steady press"),
                    kf(0.93, p()),
                    kf(1, p())
                ]),

        Stretch(id: "knee-hug", name: "Standing Knee Hug", area: .hipsLegs, facing: .side,
                bilateral: true, muscles: [.hipR, .thighR],
                muscleNames: "Glutes, lower back",
                benefit: "A balancing hug that eases the seat and low back.",
                howTo: ["Lift one knee toward your chest.",
                        "Wrap both hands below the knee.",
                        "Stand tall on the rooted leg."],
                cycleSeconds: 11,
                keyframes: [
                    kf(0, p(), "Lift the knee"),
                    kf(0.22, p(lean: -3, alL: 52, elL: 98, alR: 58, elR: 94, lgR: 72, knR: 96), "Hug it home"),
                    kf(0.75, p(lean: -4, alL: 54, elL: 102, alR: 60, elR: 98, lgR: 78, knR: 102), "Tall and steady"),
                    kf(0.93, p()),
                    kf(1, p())
                ]),

        Stretch(id: "seated-hamstring", name: "Seated Reach", area: .hipsLegs, facing: .side,
                bilateral: false, muscles: [.thighL, .thighR, .spine],
                muscleNames: "Hamstrings, back",
                benefit: "A patient reach along the back of the legs.",
                howTo: ["Sit with legs long in front.",
                        "Hinge forward from the hips.",
                        "Reach for shins, ankles or toes."],
                cycleSeconds: 12,
                keyframes: [
                    kf(0, p(hy: 74, lean: 12, alL: 24, alR: 28, lgL: 86, knL: 4, lgR: 86, knR: 4), "Sit tall, legs long"),
                    kf(0.35, p(hy: 74, lean: 46, bend: 12, head: 8, alL: 108, alR: 112, lgL: 86, knL: 5, lgR: 86, knR: 5), "Hinge and reach"),
                    kf(0.78, p(hy: 74, lean: 52, bend: 14, head: 10, alL: 116, alR: 120, lgL: 86, knL: 5, lgR: 86, knR: 5), "A little further, no rush"),
                    kf(1, p(hy: 74, lean: 12, alL: 24, alR: 28, lgL: 86, knL: 4, lgR: 86, knR: 4))
                ]),

        Stretch(id: "butterfly", name: "Butterfly Sit", area: .hipsLegs, facing: .front,
                bilateral: false, muscles: [.hipL, .hipR],
                muscleNames: "Inner thighs, hips",
                benefit: "Soles together, knees floating — hips learn to open.",
                howTo: ["Sit and bring the soles together.",
                        "Hold your ankles like a book.",
                        "Let the knees float down, never pushed."],
                cycleSeconds: 8,
                keyframes: [
                    kf(0, p(hy: 74, alL: 16, elL: 52, alR: 16, elR: 52, lgL: 52, knL: 112, lgR: 52, knR: 112), "Soles together"),
                    kf(0.5, p(hy: 74, lean: 3, alL: 18, elL: 54, alR: 18, elR: 54, lgL: 62, knL: 122, lgR: 62, knR: 122), "Knees float like wings"),
                    kf(1, p(hy: 74, alL: 16, elL: 52, alR: 16, elR: 52, lgL: 52, knL: 112, lgR: 52, knR: 112))
                ]),

        Stretch(id: "overhead-reach", name: "Overhead Reach", area: .fullBody, facing: .front,
                bilateral: false, muscles: [.sideL, .sideR, .spine],
                muscleNames: "Side body, spine",
                benefit: "The tallest version of you — a full-body yawn.",
                howTo: ["Interlace fingers and press palms up.",
                        "Grow taller with every inhale.",
                        "Keep shoulders away from ears."],
                cycleSeconds: 8,
                keyframes: [
                    kf(0, p(alL: 20, alR: 20), "Grow tall"),
                    kf(0.4, p(hy: -5, alL: 162, elL: 6, alR: 162, elR: 6), "A full-body yawn"),
                    kf(0.75, p(hy: -6, alL: 168, elL: 6, alR: 168, elR: 6), "Shoulders away from ears"),
                    kf(1, p(alL: 20, alR: 20))
                ]),

        Stretch(id: "sky-breath", name: "Sky Reach Breath", area: .fullBody, facing: .front,
                bilateral: false, muscles: [.chest, .sideL, .sideR],
                muscleNames: "Breath, whole body",
                benefit: "Arms ride the breath — the gentlest way in or out.",
                howTo: ["Inhale: float both arms to the sky.",
                        "Exhale: let them drift back down.",
                        "Match the movement to your breath."],
                cycleSeconds: 8,
                keyframes: [
                    kf(0, p(breathe: 1.4), "Inhale, arms float up"),
                    kf(0.45, p(hy: -5, alL: 158, alR: 158, breathe: 1.4), "Full like a balloon"),
                    kf(0.55, p(hy: -5, alL: 158, alR: 158, breathe: 1.4), "Exhale, drift down"),
                    kf(1, p(breathe: 1.4))
                ])
    ]

    static let byID: [String: Stretch] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func area(_ area: BodyArea) -> [Stretch] {
        all.filter { $0.area == area }
    }
}

enum RoutineLibrary {
    static let all: [Routine] = [
        Routine(id: "morning", name: "Morning Sunrise",
                subtitle: "Wake the body up kindly",
                artName: "cover_morning", tintArea: .fullBody,
                steps: [
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 30),
                    RoutineStep(stretchID: "neck-roll", secondsPerSide: 30),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 30),
                    RoutineStep(stretchID: "overhead-reach", secondsPerSide: 30),
                    RoutineStep(stretchID: "side-bend", secondsPerSide: 30),
                    RoutineStep(stretchID: "forward-fold", secondsPerSide: 40),
                    RoutineStep(stretchID: "back-bend", secondsPerSide: 30),
                    RoutineStep(stretchID: "hip-circles", secondsPerSide: 30),
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 30)
                ]),
        Routine(id: "desk", name: "Desk Undo",
                subtitle: "For screen-shaped shoulders",
                artName: "cover_desk", tintArea: .neckShoulders,
                steps: [
                    RoutineStep(stretchID: "neck-tilt", secondsPerSide: 25),
                    RoutineStep(stretchID: "neck-roll", secondsPerSide: 30),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 30),
                    RoutineStep(stretchID: "arm-cross", secondsPerSide: 25),
                    RoutineStep(stretchID: "wrist-stretch", secondsPerSide: 25),
                    RoutineStep(stretchID: "chest-opener", secondsPerSide: 35),
                    RoutineStep(stretchID: "gentle-twist", secondsPerSide: 30),
                    RoutineStep(stretchID: "back-bend", secondsPerSide: 30)
                ]),
        Routine(id: "evening", name: "Evening Unwind",
                subtitle: "Soft landing before sleep",
                artName: "cover_evening", tintArea: .backCore,
                steps: [
                    RoutineStep(stretchID: "neck-roll", secondsPerSide: 30),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 30),
                    RoutineStep(stretchID: "gentle-twist", secondsPerSide: 40),
                    RoutineStep(stretchID: "cat-cow", secondsPerSide: 60),
                    RoutineStep(stretchID: "childs-pose", secondsPerSide: 60),
                    RoutineStep(stretchID: "seated-hamstring", secondsPerSide: 60),
                    RoutineStep(stretchID: "butterfly", secondsPerSide: 60),
                    RoutineStep(stretchID: "knee-hug", secondsPerSide: 30),
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 60)
                ]),
        Routine(id: "fullbody", name: "Full Body Flow",
                subtitle: "Ten minutes, everything",
                artName: "cover_fullbody", tintArea: .fullBody,
                steps: [
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 30),
                    RoutineStep(stretchID: "neck-tilt", secondsPerSide: 20),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 30),
                    RoutineStep(stretchID: "arm-circles", secondsPerSide: 30),
                    RoutineStep(stretchID: "side-bend", secondsPerSide: 25),
                    RoutineStep(stretchID: "chest-opener", secondsPerSide: 30),
                    RoutineStep(stretchID: "forward-fold", secondsPerSide: 45),
                    RoutineStep(stretchID: "lunge", secondsPerSide: 30),
                    RoutineStep(stretchID: "quad-stretch", secondsPerSide: 30),
                    RoutineStep(stretchID: "calf-stretch", secondsPerSide: 25),
                    RoutineStep(stretchID: "cat-cow", secondsPerSide: 45),
                    RoutineStep(stretchID: "seated-hamstring", secondsPerSide: 45),
                    RoutineStep(stretchID: "childs-pose", secondsPerSide: 45),
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 30)
                ]),
        Routine(id: "neckmelt", name: "Neck and Shoulder Melt",
                subtitle: "Where the day gets stored",
                artName: "cover_neck", tintArea: .neckShoulders,
                steps: [
                    RoutineStep(stretchID: "neck-tilt", secondsPerSide: 30),
                    RoutineStep(stretchID: "neck-roll", secondsPerSide: 40),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 40),
                    RoutineStep(stretchID: "arm-cross", secondsPerSide: 30),
                    RoutineStep(stretchID: "chest-opener", secondsPerSide: 40),
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 40)
                ]),
        Routine(id: "hips", name: "Happy Hips",
                subtitle: "Unlock the sitting hours",
                artName: "cover_hips", tintArea: .hipsLegs,
                steps: [
                    RoutineStep(stretchID: "hip-circles", secondsPerSide: 40),
                    RoutineStep(stretchID: "lunge", secondsPerSide: 35),
                    RoutineStep(stretchID: "knee-hug", secondsPerSide: 30),
                    RoutineStep(stretchID: "butterfly", secondsPerSide: 60),
                    RoutineStep(stretchID: "side-bend", secondsPerSide: 25),
                    RoutineStep(stretchID: "seated-hamstring", secondsPerSide: 45),
                    RoutineStep(stretchID: "childs-pose", secondsPerSide: 45)
                ]),
        Routine(id: "hamstrings", name: "Hamstring Helper",
                subtitle: "For the backs of your legs",
                artName: "cover_hamstring", tintArea: .hipsLegs,
                steps: [
                    RoutineStep(stretchID: "forward-fold", secondsPerSide: 45),
                    RoutineStep(stretchID: "seated-hamstring", secondsPerSide: 60),
                    RoutineStep(stretchID: "calf-stretch", secondsPerSide: 30),
                    RoutineStep(stretchID: "lunge", secondsPerSide: 30),
                    RoutineStep(stretchID: "knee-hug", secondsPerSide: 25),
                    RoutineStep(stretchID: "cat-cow", secondsPerSide: 45),
                    RoutineStep(stretchID: "childs-pose", secondsPerSide: 40)
                ]),
        Routine(id: "posture", name: "Posture Reset",
                subtitle: "Stand like you mean it",
                artName: "cover_posture", tintArea: .armsChest,
                steps: [
                    RoutineStep(stretchID: "chest-opener", secondsPerSide: 40),
                    RoutineStep(stretchID: "back-bend", secondsPerSide: 35),
                    RoutineStep(stretchID: "gentle-twist", secondsPerSide: 40),
                    RoutineStep(stretchID: "shoulder-rolls", secondsPerSide: 30),
                    RoutineStep(stretchID: "arm-cross", secondsPerSide: 25),
                    RoutineStep(stretchID: "overhead-reach", secondsPerSide: 35),
                    RoutineStep(stretchID: "cat-cow", secondsPerSide: 40),
                    RoutineStep(stretchID: "sky-breath", secondsPerSide: 30)
                ])
    ]

    static let byID: [String: Routine] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
