import SwiftUI

struct BuddyRig {

    static let designSize = CGSize(width: 320, height: 360)

    let pose: BuddyPose
    let facing: BuddyFacing
    let groundLevel: CGFloat

    private let torsoLen: CGFloat = 66
    private let neckLen: CGFloat = 9
    private let headR: CGFloat = 31
    private let upperArm: CGFloat = 36
    private let foreArm: CGFloat = 31
    private let thigh: CGFloat = 41
    private let shin: CGFloat = 38
    private let shoulderSpread: CGFloat = 24
    private let hipSpread: CGFloat = 12

    struct Joints {
        var hip = CGPoint.zero
        var hipL = CGPoint.zero, hipR = CGPoint.zero
        var chest = CGPoint.zero
        var neck = CGPoint.zero
        var head = CGPoint.zero
        var shoulderL = CGPoint.zero, shoulderR = CGPoint.zero
        var elbowL = CGPoint.zero, elbowR = CGPoint.zero
        var handL = CGPoint.zero, handR = CGPoint.zero
        var kneeL = CGPoint.zero, kneeR = CGPoint.zero
        var footL = CGPoint.zero, footR = CGPoint.zero
        var spineAngle: CGFloat = -90
        var chestAngle: CGFloat = -90
        var headAngle: CGFloat = -90
    }

    private static func rad(_ deg: CGFloat) -> CGFloat { deg * .pi / 180 }

    private static func offset(_ p: CGPoint, _ deg: CGFloat, _ len: CGFloat) -> CGPoint {
        CGPoint(x: p.x + cos(rad(deg)) * len, y: p.y + sin(rad(deg)) * len)
    }

    var joints: Joints {
        var j = Joints()
        let floorY: CGFloat = 322 - groundLevel

        let standHipY = floorY - (thigh + shin) - 8
        j.hip = CGPoint(x: 160 + pose.hipX, y: standHipY + pose.hipY)

        j.spineAngle = -90 + pose.torsoLean
        j.chest = Self.offset(j.hip, j.spineAngle, torsoLen * 0.55)
        j.chestAngle = j.spineAngle + pose.chestBend
        j.neck = Self.offset(j.chest, j.chestAngle, torsoLen * 0.45)
        j.headAngle = j.chestAngle + pose.headTilt
        j.head = Self.offset(j.neck, j.headAngle, neckLen + headR * 0.86)

        let perp = j.chestAngle + 90
        let spread = facing == .front ? shoulderSpread : shoulderSpread * 0.28
        j.shoulderL = Self.offset(j.neck, perp, -spread)
        j.shoulderR = Self.offset(j.neck, perp, spread)

        let hang = j.chestAngle + 180
        let upperDirL: CGFloat
        let upperDirR: CGFloat
        let foreDirL: CGFloat
        let foreDirR: CGFloat
        if facing == .front {

            upperDirL = hang + pose.armRaiseL
            upperDirR = hang - pose.armRaiseR
            foreDirL = upperDirL - pose.elbowL
            foreDirR = upperDirR + pose.elbowR
        } else {

            upperDirL = hang - pose.armRaiseL
            upperDirR = hang - pose.armRaiseR
            foreDirL = upperDirL - pose.elbowL
            foreDirR = upperDirR - pose.elbowR
        }
        j.elbowL = Self.offset(j.shoulderL, upperDirL, upperArm)
        j.handL = Self.offset(j.elbowL, foreDirL, foreArm)
        j.elbowR = Self.offset(j.shoulderR, upperDirR, upperArm)
        j.handR = Self.offset(j.elbowR, foreDirR, foreArm)

        let hipPerp = j.spineAngle + 90
        let hSpread = facing == .front ? hipSpread : hipSpread * 0.3
        j.hipL = Self.offset(j.hip, hipPerp, -hSpread)
        j.hipR = Self.offset(j.hip, hipPerp, hSpread)
        let legDirL: CGFloat
        let legDirR: CGFloat
        let shinDirL: CGFloat
        let shinDirR: CGFloat
        if facing == .front {
            legDirL = 90 + pose.legOutL
            legDirR = 90 - pose.legOutR
            shinDirL = legDirL - pose.kneeL
            shinDirR = legDirR + pose.kneeR
        } else {
            legDirL = 90 - pose.legOutL
            legDirR = 90 - pose.legOutR
            shinDirL = legDirL + pose.kneeL
            shinDirR = legDirR + pose.kneeR
        }
        j.kneeL = Self.offset(j.hipL, legDirL, thigh)
        j.footL = Self.offset(j.kneeL, shinDirL, shin)
        j.kneeR = Self.offset(j.hipR, legDirR, thigh)
        j.footR = Self.offset(j.kneeR, shinDirR, shin)
        return j
    }

    func glowSegments(_ zone: MuscleZone, _ j: Joints) -> [(CGPoint, CGPoint)] {
        let perp = j.spineAngle + 90
        switch zone {
        case .neck:
            return [(j.neck, Self.offset(j.neck, j.headAngle, neckLen + 8))]
        case .shoulderL:
            return [(Self.offset(j.neck, perp, -6), j.shoulderL)]
        case .shoulderR:
            return [(Self.offset(j.neck, perp, 6), j.shoulderR)]
        case .upperArmL: return [(j.shoulderL, j.elbowL)]
        case .upperArmR: return [(j.shoulderR, j.elbowR)]
        case .forearmL: return [(j.elbowL, j.handL)]
        case .forearmR: return [(j.elbowR, j.handR)]
        case .chest:
            return [(Self.offset(j.chest, perp, -14), Self.offset(j.chest, perp, 14))]
        case .spine:
            return [(j.hip, j.neck)]
        case .sideL:
            return [(Self.offset(j.hip, perp, -20), Self.offset(j.neck, perp, -16))]
        case .sideR:
            return [(Self.offset(j.hip, perp, 20), Self.offset(j.neck, perp, 16))]
        case .hipL: return [(j.hipL, Self.offset(j.hipL, 90, 10))]
        case .hipR: return [(j.hipR, Self.offset(j.hipR, 90, 10))]
        case .thighL: return [(j.hipL, j.kneeL)]
        case .thighR: return [(j.hipR, j.kneeR)]
        case .calfL: return [(j.kneeL, j.footL)]
        case .calfR: return [(j.kneeR, j.footR)]
        }
    }
}

struct BuddyCanvas: View {
    let pose: BuddyPose
    let facing: BuddyFacing
    let groundLevel: CGFloat
    let muscles: [MuscleZone]
    let glowPhase: CGFloat
    var showMat: Bool = true
    var outfit: BuddyOutfit = .classic
    var mood: BuddyMood = .content

    var body: some View {
        Canvas { context, size in
            let design = BuddyRig.designSize
            let scale = min(size.width / design.width, size.height / design.height)
            let dx = (size.width - design.width * scale) / 2
            let dy = (size.height - design.height * scale) / 2
            context.translateBy(x: dx, y: dy)
            context.scaleBy(x: scale, y: scale)
            renderBuddy(context, pose: pose, facing: facing, groundLevel: groundLevel,
                        muscles: muscles, glowPhase: glowPhase, showMat: showMat,
                        outfit: outfit, mood: mood)
        }
    }
}

func renderBuddy(_ context: GraphicsContext, pose: BuddyPose, facing: BuddyFacing,
                 groundLevel: CGFloat, muscles: [MuscleZone], glowPhase: CGFloat,
                 showMat: Bool, outfit: BuddyOutfit = .classic, mood: BuddyMood = .content) {
    let rig = BuddyRig(pose: pose, facing: facing, groundLevel: groundLevel)
    let j = rig.joints
    let floorY: CGFloat = 322 - groundLevel
    let skin = BuddySkins.byID(outfit.skinID)

    if showMat {
        let mat = Path(roundedRect: CGRect(x: 52, y: floorY - 2, width: 216, height: 16), cornerRadius: 8)
        context.fill(mat, with: .color(SoftTheme.mat))
        let matEdge = Path(roundedRect: CGRect(x: 52, y: floorY + 8, width: 216, height: 6), cornerRadius: 3)
        context.fill(matEdge, with: .color(SoftTheme.mat.opacity(0.6)))
    }
    let shadowW: CGFloat = 130 - abs(pose.hipY) * 0.15
    let shadow = Path(ellipseIn: CGRect(x: j.hip.x - shadowW / 2, y: floorY - 7, width: shadowW, height: 18))
    context.fill(shadow, with: .color(SoftTheme.ink.opacity(0.10)))

    if !muscles.isEmpty {
        let pulse = 0.55 + 0.45 * sin(glowPhase * .pi * 2)
        var glowCtx = context
        glowCtx.addFilter(.blur(radius: 7))
        for zone in muscles {
            for seg in rig.glowSegments(zone, j) {
                var p = Path()
                p.move(to: seg.0)
                p.addLine(to: seg.1)
                glowCtx.stroke(p, with: .color(SoftTheme.muscleGlow.opacity(0.35 + 0.4 * pulse)),
                               style: StrokeStyle(lineWidth: 30, lineCap: .round))
            }
        }
    }

    let back = skin.deep
    let front = skin.body

    let backTint = facing == .side ? back : front
    buddyDrawLeg(context, hip: j.hipL, knee: j.kneeL, foot: j.footL, color: backTint)
    buddyDrawArm(context, shoulder: j.shoulderL, elbow: j.elbowL, hand: j.handL, color: backTint)

    var torso = Path()
    torso.move(to: j.hip)
    torso.addQuadCurve(to: j.neck, control: j.chest)
    let torsoW: CGFloat = facing == .front ? 46 : 40
    context.stroke(torso, with: .color(front), style: StrokeStyle(lineWidth: torsoW, lineCap: .round))

    let belly = Path(ellipseIn: CGRect(x: j.hip.x - 27, y: j.hip.y - 24, width: 54, height: 46))
    context.fill(belly, with: .color(front))

    buddyDrawLeg(context, hip: j.hipR, knee: j.kneeR, foot: j.footR, color: front)

    let headRect = CGRect(x: j.head.x - 31, y: j.head.y - 29, width: 62, height: 58)
    context.fill(Path(ellipseIn: headRect), with: .color(front))
    buddyDrawFace(context, j: j, facing: facing, pose: pose, skin: skin, mood: mood)

    buddyDrawArm(context, shoulder: j.shoulderR, elbow: j.elbowR, hand: j.handR, color: front)

    if !muscles.isEmpty {
        let pulse = 0.5 + 0.5 * sin(glowPhase * .pi * 2)
        for zone in muscles {
            for seg in rig.glowSegments(zone, j) {
                let mid = CGPoint(x: (seg.0.x + seg.1.x) / 2, y: (seg.0.y + seg.1.y) / 2)
                let r: CGFloat = 3 + 2 * pulse
                let dot = Path(ellipseIn: CGRect(x: mid.x - r, y: mid.y - r, width: r * 2, height: r * 2))
                context.fill(dot, with: .color(.white.opacity(0.55 + 0.35 * pulse)))
            }
        }
    }

    if let acc = outfit.accessoryID {
        BuddyAccessoryDrawer.draw(acc, in: context, joints: j, skin: skin)
    }

    if mood == .sleepy {
        let zink = SoftTheme.ink.opacity(0.4)
        for (i, s) in [CGFloat(9), 6].enumerated() {
            let p = CGPoint(x: j.head.x + 42 + CGFloat(i) * 12,
                            y: j.head.y - 24 - CGFloat(i) * 14 - glowPhase * 6)
            var z = Path()
            z.move(to: CGPoint(x: p.x - s / 2, y: p.y - s / 2))
            z.addLine(to: CGPoint(x: p.x + s / 2, y: p.y - s / 2))
            z.addLine(to: CGPoint(x: p.x - s / 2, y: p.y + s / 2))
            z.addLine(to: CGPoint(x: p.x + s / 2, y: p.y + s / 2))
            z.closeSubpath()
            context.stroke(z, with: .color(zink),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

private func buddyDrawArm(_ context: GraphicsContext, shoulder: CGPoint, elbow: CGPoint, hand: CGPoint, color: Color) {
    var p = Path()
    p.move(to: shoulder)
    p.addLine(to: elbow)
    p.addLine(to: hand)
    context.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: 17, lineCap: .round, lineJoin: .round))
    let mitt = Path(ellipseIn: CGRect(x: hand.x - 10.5, y: hand.y - 10.5, width: 21, height: 21))
    context.fill(mitt, with: .color(color))
}

private func buddyDrawLeg(_ context: GraphicsContext, hip: CGPoint, knee: CGPoint, foot: CGPoint, color: Color) {
    var p = Path()
    p.move(to: hip)
    p.addLine(to: knee)
    p.addLine(to: foot)
    context.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: 19, lineCap: .round, lineJoin: .round))

    let boot = Path(ellipseIn: CGRect(x: foot.x - 12, y: foot.y - 9, width: 26, height: 19))
    context.fill(boot, with: .color(color))
}

private func buddyDrawFace(_ context: GraphicsContext, j: BuddyRig.Joints,
                           facing: BuddyFacing, pose: BuddyPose,
                           skin: BuddySkin, mood: BuddyMood) {
    let c = j.head
    let ink = SoftTheme.ink.opacity(0.82)
    if facing == .front {
        let drift = pose.headTurn * 5
        switch mood {
        case .content, .proud:
            for sx in [CGFloat(-11), 11] {
                let eye = Path(ellipseIn: CGRect(x: c.x + sx + drift - 3.2, y: c.y - 6, width: 6.4, height: 8.6))
                context.fill(eye, with: .color(ink))
            }
        case .sleepy:
            for sx in [CGFloat(-11), 11] {
                var lid = Path()
                lid.move(to: CGPoint(x: c.x + sx - 4 + drift, y: c.y - 1))
                lid.addQuadCurve(to: CGPoint(x: c.x + sx + 4 + drift, y: c.y - 1),
                                 control: CGPoint(x: c.x + sx + drift, y: c.y + 2.5))
                context.stroke(lid, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            }
        case .happy:
            for sx in [CGFloat(-11), 11] {
                var arc = Path()
                arc.move(to: CGPoint(x: c.x + sx - 4 + drift, y: c.y - 2))
                arc.addQuadCurve(to: CGPoint(x: c.x + sx + 4 + drift, y: c.y - 2),
                                 control: CGPoint(x: c.x + sx + drift, y: c.y - 8))
                context.stroke(arc, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            }
        }
        switch mood {
        case .content:
            var smile = Path()
            smile.move(to: CGPoint(x: c.x - 7 + drift, y: c.y + 9))
            smile.addQuadCurve(to: CGPoint(x: c.x + 7 + drift, y: c.y + 9),
                               control: CGPoint(x: c.x + drift, y: c.y + 15))
            context.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        case .sleepy:
            let o = Path(ellipseIn: CGRect(x: c.x - 3 + drift, y: c.y + 8, width: 6, height: 7))
            context.stroke(o, with: .color(ink), lineWidth: 2.2)
        case .happy:
            var grin = Path()
            grin.move(to: CGPoint(x: c.x - 8 + drift, y: c.y + 8))
            grin.addQuadCurve(to: CGPoint(x: c.x + 8 + drift, y: c.y + 8),
                              control: CGPoint(x: c.x + drift, y: c.y + 17))
            grin.closeSubpath()
            context.fill(grin, with: .color(ink))
        case .proud:
            var grin = Path()
            grin.move(to: CGPoint(x: c.x - 9 + drift, y: c.y + 8))
            grin.addQuadCurve(to: CGPoint(x: c.x + 9 + drift, y: c.y + 8),
                              control: CGPoint(x: c.x + drift, y: c.y + 18))
            context.stroke(grin, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            drawSparkle(context, at: CGPoint(x: c.x + 40, y: c.y - 18), r: 4, color: SoftTheme.sun)
            drawSparkle(context, at: CGPoint(x: c.x + 46, y: c.y - 4), r: 2.6, color: SoftTheme.sun)
        }
        for sx in [CGFloat(-19), 19] {
            let cheek = Path(ellipseIn: CGRect(x: c.x + sx - 5, y: c.y + 5, width: 10, height: 6.5))
            context.fill(cheek, with: .color(skin.cheek.opacity(0.75)))
        }
    } else {

        switch mood {
        case .content, .proud:
            let eye = Path(ellipseIn: CGRect(x: c.x + 12 - 3.2, y: c.y - 6 + pose.headTurn * 4, width: 6.4, height: 8.6))
            context.fill(eye, with: .color(ink))
        case .sleepy:
            var lid = Path()
            lid.move(to: CGPoint(x: c.x + 8, y: c.y - 2))
            lid.addQuadCurve(to: CGPoint(x: c.x + 16, y: c.y - 2),
                             control: CGPoint(x: c.x + 12, y: c.y + 1.5))
            context.stroke(lid, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        case .happy:
            var arc = Path()
            arc.move(to: CGPoint(x: c.x + 8, y: c.y - 3))
            arc.addQuadCurve(to: CGPoint(x: c.x + 16, y: c.y - 3),
                             control: CGPoint(x: c.x + 12, y: c.y - 9))
            context.stroke(arc, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        }
        switch mood {
        case .sleepy:
            let o = Path(ellipseIn: CGRect(x: c.x + 16, y: c.y + 6, width: 5.5, height: 6.5))
            context.stroke(o, with: .color(ink), lineWidth: 2.2)
        case .proud:
            var smile = Path()
            smile.move(to: CGPoint(x: c.x + 13, y: c.y + 9))
            smile.addQuadCurve(to: CGPoint(x: c.x + 24, y: c.y + 4),
                               control: CGPoint(x: c.x + 21, y: c.y + 12))
            context.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
            drawSparkle(context, at: CGPoint(x: c.x + 34, y: c.y - 14), r: 3.4, color: SoftTheme.sun)
        default:
            var smile = Path()
            smile.move(to: CGPoint(x: c.x + 14, y: c.y + 8))
            smile.addQuadCurve(to: CGPoint(x: c.x + 23, y: c.y + 5),
                               control: CGPoint(x: c.x + 20, y: c.y + 11))
            context.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        }
        let cheek = Path(ellipseIn: CGRect(x: c.x + 6, y: c.y + 4, width: 10, height: 6.5))
        context.fill(cheek, with: .color(skin.cheek.opacity(0.75)))
    }
}

func drawSparkle(_ ctx: GraphicsContext, at p: CGPoint, r: CGFloat, color: Color) {
    var star = Path()
    star.move(to: CGPoint(x: p.x, y: p.y - r))
    star.addQuadCurve(to: CGPoint(x: p.x + r, y: p.y), control: p)
    star.addQuadCurve(to: CGPoint(x: p.x, y: p.y + r), control: p)
    star.addQuadCurve(to: CGPoint(x: p.x - r, y: p.y), control: p)
    star.addQuadCurve(to: CGPoint(x: p.x, y: p.y - r), control: p)
    ctx.fill(star, with: .color(color))
}

struct AnimatedBuddy: View {
    let stretch: Stretch
    var mirrored: Bool = false
    var reduceMotion: Bool = false
    var showMat: Bool = true
    var outfit: BuddyOutfit = .classic

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 / 20 : 1.0 / 40)) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let muscles = mirrored ? stretch.muscles.map { $0.mirrored } : stretch.muscles
            BuddyCanvas(pose: livePose(now: now),
                        facing: stretch.facing,
                        groundLevel: stretch.groundLevel,
                        muscles: muscles,
                        glowPhase: CGFloat((now / 1.6).truncatingRemainder(dividingBy: 1)),
                        showMat: showMat,
                        outfit: outfit)
        }
    }

    private func livePose(now: TimeInterval) -> BuddyPose {
        let cycleT = CGFloat((now / stretch.cycleSeconds).truncatingRemainder(dividingBy: 1))
        let base = stretch.pose(at: cycleT)
        var pose = mirrored ? base.mirrored : base

        pose.hipY += CGFloat(sin(now * 1.5)) * 1.6 * pose.breathe
        return pose
    }
}

struct BuddyPreview: View {
    let stretch: Stretch
    var frameT: CGFloat = 0.45
    var showGlow: Bool = true
    var outfit: BuddyOutfit = .classic

    var body: some View {
        BuddyCanvas(pose: stretch.pose(at: frameT),
                    facing: stretch.facing,
                    groundLevel: stretch.groundLevel,
                    muscles: showGlow ? stretch.muscles : [],
                    glowPhase: 0.25,
                    showMat: false,
                    outfit: outfit)
    }
}
