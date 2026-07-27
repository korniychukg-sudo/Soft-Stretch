import SwiftUI

// Buddy's nook — the living Home hero. A cozy room that fills with keepsakes
// as friendship grows; Buddy idles inside, reacts to taps and chats.

func nookMood(store: StretchStore) -> BuddyMood {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour >= 21 || hour < 6 { return .sleepy }
    if store.stretchedToday { return store.currentStreak >= 3 ? .proud : .happy }
    if hour < 9 { return .sleepy }
    return .content
}

struct BuddyNookView: View {
    let level: Int
    let outfit: BuddyOutfit
    let mood: BuddyMood
    var reduceMotion: Bool = false
    var waveTrigger: Int = 0          // increment to make Buddy wave

    @State private var waveStartTime: TimeInterval = -10

    private static let design = CGSize(width: 360, height: 250)

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 30, paused: false)) { timeline in
            Canvas { ctx, size in
                let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let scale = size.width / Self.design.width
                ctx.scaleBy(x: scale, y: scale)
                let daypart = SoftDaypart.current()
                drawRoom(ctx, daypart: daypart, t: t)
                drawItems(ctx, daypart: daypart, t: t)
                drawBuddy(ctx, t: t)
            }
        }
        .aspectRatio(Self.design.width / Self.design.height, contentMode: .fit)
        .onChange(of: waveTrigger) { _ in
            waveStartTime = Date().timeIntervalSinceReferenceDate
        }
    }

    // MARK: Room

    private func drawRoom(_ ctx: GraphicsContext, daypart: SoftDaypart, t: TimeInterval) {
        let w = Self.design.width, h = Self.design.height
        // Wall + floor
        ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                 with: .color(Color(red: 0.976, green: 0.937, blue: 0.882)))
        ctx.fill(Path(CGRect(x: 0, y: 196, width: w, height: h - 196)),
                 with: .color(Color(red: 0.925, green: 0.847, blue: 0.757)))
        // Baseboard line
        ctx.fill(Path(CGRect(x: 0, y: 194, width: w, height: 3)),
                 with: .color(SoftTheme.ink.opacity(0.06)))

        // Window with the outside sky
        let win = CGRect(x: 226, y: 26, width: 104, height: 96)
        let winPath = Path(roundedRect: win, cornerRadius: 14)
        var sky = ctx
        sky.clip(to: winPath)
        sky.fill(Path(CGRect(x: win.minX, y: win.minY, width: win.width, height: win.height)),
                 with: .linearGradient(Gradient(colors: [daypart.skyTop, daypart.skyBottom]),
                                       startPoint: CGPoint(x: win.midX, y: win.minY),
                                       endPoint: CGPoint(x: win.midX, y: win.maxY)))
        // Sun or moon
        let discC = CGPoint(x: 278, y: 54)
        if daypart == .night {
            let moon = Path(ellipseIn: CGRect(x: discC.x - 11, y: discC.y - 11, width: 22, height: 22))
            sky.fill(moon, with: .color(Color(red: 0.945, green: 0.925, blue: 0.835)))
            let bite = Path(ellipseIn: CGRect(x: discC.x - 4, y: discC.y - 13, width: 20, height: 20))
            sky.fill(bite, with: .color(daypart.skyTop))
            for (dx, dy) in [(CGFloat(-28), CGFloat(-14)), (24, 26), (-18, 34)] {
                let star = Path(ellipseIn: CGRect(x: discC.x + dx, y: discC.y + dy, width: 2.4, height: 2.4))
                sky.fill(star, with: .color(.white.opacity(0.7 + 0.3 * sin(t * 2 + Double(dx)))))
            }
        } else {
            let sunTint: Color = daypart == .day ? SoftTheme.sun : SoftTheme.coral.opacity(0.85)
            let disc = Path(ellipseIn: CGRect(x: discC.x - 12, y: discC.y - 12, width: 24, height: 24))
            sky.fill(disc, with: .color(sunTint))
        }
        // Drifting clouds
        for (i, base) in [CGFloat(0), 70].enumerated() {
            let cx = win.minX + CGFloat(fmod(t * 6 + Double(base), 140)) - 20
            let cy = win.minY + 24 + CGFloat(i) * 34
            let puff = Path(ellipseIn: CGRect(x: cx, y: cy, width: 34, height: 12))
            sky.fill(puff, with: .color(.white.opacity(daypart == .night ? 0.14 : 0.55)))
            let puff2 = Path(ellipseIn: CGRect(x: cx + 10, y: cy - 5, width: 22, height: 11))
            sky.fill(puff2, with: .color(.white.opacity(daypart == .night ? 0.10 : 0.45)))
        }
        // Frame
        ctx.stroke(winPath, with: .color(.white), lineWidth: 5)
        var cross = Path()
        cross.move(to: CGPoint(x: win.midX, y: win.minY))
        cross.addLine(to: CGPoint(x: win.midX, y: win.maxY))
        ctx.stroke(cross, with: .color(.white.opacity(0.9)), lineWidth: 3)

        // Rug (upgrades at level 4)
        let rug = Path(ellipseIn: CGRect(x: 75, y: 201, width: 150, height: 30))
        ctx.fill(rug, with: .color(SoftTheme.mat.opacity(0.55)))
        if level >= 4 {
            let inner = Path(ellipseIn: CGRect(x: 95, y: 205, width: 110, height: 22))
            ctx.fill(inner, with: .color(SoftTheme.rose.opacity(0.25)))
        }
        // Buddy's small mat
        let mat = Path(roundedRect: CGRect(x: 96, y: 206, width: 108, height: 10), cornerRadius: 5)
        ctx.fill(mat, with: .color(SoftTheme.mat))

        // Night dims the room slightly
        if daypart.isDark {
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .color(SoftTheme.ink.opacity(0.08)))
        }
    }

    // MARK: Keepsakes (one per friendship level)

    private func drawItems(_ ctx: GraphicsContext, daypart: SoftDaypart, t: TimeInterval) {
        // L1+ plant (grows with early levels)
        if level >= 1 {
            let potX: CGFloat = 44, potY: CGFloat = 196
            var pot = Path()
            pot.move(to: CGPoint(x: potX - 13, y: potY - 20))
            pot.addLine(to: CGPoint(x: potX + 13, y: potY - 20))
            pot.addLine(to: CGPoint(x: potX + 9, y: potY))
            pot.addLine(to: CGPoint(x: potX - 9, y: potY))
            pot.closeSubpath()
            ctx.fill(pot, with: .color(Color(red: 0.804, green: 0.616, blue: 0.494)))
            let stemH: CGFloat = 26 + CGFloat(min(level, 5)) * 7
            var stem = Path()
            stem.move(to: CGPoint(x: potX, y: potY - 20))
            stem.addQuadCurve(to: CGPoint(x: potX + 2, y: potY - 20 - stemH),
                              control: CGPoint(x: potX - 4, y: potY - 20 - stemH / 2))
            ctx.stroke(stem, with: .color(SoftTheme.sage), lineWidth: 3)
            for i in 0..<min(level, 5) {
                let ly = potY - 34 - CGFloat(i) * (stemH / CGFloat(max(min(level, 5), 1)))
                let side: CGFloat = i % 2 == 0 ? -1 : 1
                let sway = CGFloat(sin(t * 0.9 + Double(i))) * 1.2
                let leaf = Path(ellipseIn: CGRect(x: potX + side * 4 + sway - (side < 0 ? 12 : 0),
                                                  y: ly - 4, width: 12, height: 8))
                ctx.fill(leaf, with: .color(SoftTheme.sage.opacity(0.9)))
            }
        }
        // L2 wall poster
        if level >= 2 {
            let frame = CGRect(x: 36, y: 44, width: 56, height: 72)
            ctx.fill(Path(roundedRect: frame, cornerRadius: 8), with: .color(.white.opacity(0.9)))
            ctx.stroke(Path(roundedRect: frame, cornerRadius: 8), with: .color(SoftTheme.line), lineWidth: 2)
            let skin = BuddySkins.byID(outfit.skinID)
            let head = Path(ellipseIn: CGRect(x: frame.midX - 12, y: frame.minY + 16, width: 24, height: 22))
            ctx.fill(head, with: .color(skin.body))
            var smile = Path()
            smile.move(to: CGPoint(x: frame.midX - 4, y: frame.minY + 26))
            smile.addQuadCurve(to: CGPoint(x: frame.midX + 4, y: frame.minY + 26),
                               control: CGPoint(x: frame.midX, y: frame.minY + 30))
            ctx.stroke(smile, with: .color(SoftTheme.ink.opacity(0.7)), lineWidth: 1.6)
            let caption = Path(roundedRect: CGRect(x: frame.midX - 16, y: frame.maxY - 22, width: 32, height: 5), cornerRadius: 2.5)
            ctx.fill(caption, with: .color(SoftTheme.coral.opacity(0.5)))
        }
        // L3 floor lamp
        if level >= 3 {
            let lx: CGFloat = 312
            var stem = Path()
            stem.move(to: CGPoint(x: lx, y: 196))
            stem.addLine(to: CGPoint(x: lx, y: 132))
            ctx.stroke(stem, with: .color(SoftTheme.ink.opacity(0.5)), lineWidth: 3)
            let base = Path(ellipseIn: CGRect(x: lx - 12, y: 192, width: 24, height: 7))
            ctx.fill(base, with: .color(SoftTheme.ink.opacity(0.5)))
            if daypart.isDark {
                let glow = Path(ellipseIn: CGRect(x: lx - 30, y: 118, width: 60, height: 52))
                ctx.fill(glow, with: .color(SoftTheme.sun.opacity(0.20)))
            }
            var shade = Path()
            shade.move(to: CGPoint(x: lx - 14, y: 132))
            shade.addLine(to: CGPoint(x: lx + 14, y: 132))
            shade.addLine(to: CGPoint(x: lx + 10, y: 114))
            shade.addLine(to: CGPoint(x: lx - 10, y: 114))
            shade.closeSubpath()
            ctx.fill(shade, with: .color(SoftTheme.sun.opacity(0.85)))
        }
        // L5 shelf + trophy
        if level >= 5 {
            let shelf = CGRect(x: 120, y: 58, width: 80, height: 6)
            ctx.fill(Path(roundedRect: shelf, cornerRadius: 3),
                     with: .color(Color(red: 0.804, green: 0.616, blue: 0.494)))
            let cx: CGFloat = 138
            var cup = Path()
            cup.move(to: CGPoint(x: cx - 7, y: 40))
            cup.addQuadCurve(to: CGPoint(x: cx + 7, y: 40), control: CGPoint(x: cx, y: 38))
            cup.addLine(to: CGPoint(x: cx + 5, y: 52))
            cup.addLine(to: CGPoint(x: cx - 5, y: 52))
            cup.closeSubpath()
            ctx.fill(cup, with: .color(SoftTheme.sun))
            let stem2 = Path(roundedRect: CGRect(x: cx - 2, y: 52, width: 4, height: 4), cornerRadius: 1)
            ctx.fill(stem2, with: .color(SoftTheme.sun.opacity(0.8)))
            let foot = Path(roundedRect: CGRect(x: cx - 6, y: 56, width: 12, height: 2.5), cornerRadius: 1)
            ctx.fill(foot, with: .color(SoftTheme.sun.opacity(0.9)))
        }
        // L6 string lights along the window top
        if level >= 6 {
            let tints: [Color] = [SoftTheme.coral, SoftTheme.sun, SoftTheme.sage]
            var wire = Path()
            wire.move(to: CGPoint(x: 222, y: 20))
            wire.addQuadCurve(to: CGPoint(x: 334, y: 20), control: CGPoint(x: 278, y: 28))
            ctx.stroke(wire, with: .color(SoftTheme.ink.opacity(0.25)), lineWidth: 1.4)
            for i in 0..<6 {
                let x = 228 + CGFloat(i) * 20
                let y = 22 + CGFloat(sin(t * 2 + Double(i))) * 1.5 + CGFloat(i % 2) * 2
                let alpha = daypart.isDark ? 0.5 + 0.5 * sin(t * 2.4 + Double(i)) : 0.9
                let bulb = Path(ellipseIn: CGRect(x: x, y: y, width: 5.5, height: 5.5))
                ctx.fill(bulb, with: .color(tints[i % 3].opacity(alpha)))
            }
        }
        // L7 hanging vine left of the window
        if level >= 7 {
            let vx: CGFloat = 212
            for (i, len) in [CGFloat(26), 38, 20].enumerated() {
                var strand = Path()
                let x = vx - CGFloat(i) * 7
                strand.move(to: CGPoint(x: x, y: 24))
                strand.addQuadCurve(to: CGPoint(x: x - 3 + CGFloat(sin(t * 0.8 + Double(i))) * 2, y: 24 + len),
                                    control: CGPoint(x: x - 5, y: 24 + len / 2))
                ctx.stroke(strand, with: .color(SoftTheme.sage.opacity(0.85)), lineWidth: 2)
                for k in 1...2 {
                    let ly = 24 + len * CGFloat(k) / 2.4
                    let leaf = Path(ellipseIn: CGRect(x: x - 6, y: ly, width: 7, height: 5))
                    ctx.fill(leaf, with: .color(SoftTheme.sage))
                }
            }
        }
        // L8 wall clock with real time
        if level >= 8 {
            let cc = CGPoint(x: 150, y: 34)
            let face = Path(ellipseIn: CGRect(x: cc.x - 15, y: cc.y - 15, width: 30, height: 30))
            ctx.fill(face, with: .color(.white))
            ctx.stroke(face, with: .color(SoftTheme.ink.opacity(0.4)), lineWidth: 2)
            let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let hour = CGFloat(comps.hour ?? 9 % 12), minute = CGFloat(comps.minute ?? 0)
            let hourA = (hour + minute / 60) / 12 * 2 * .pi - .pi / 2
            let minA = minute / 60 * 2 * .pi - .pi / 2
            var hh = Path()
            hh.move(to: cc)
            hh.addLine(to: CGPoint(x: cc.x + cos(hourA) * 7, y: cc.y + sin(hourA) * 7))
            ctx.stroke(hh, with: .color(SoftTheme.ink.opacity(0.7)), lineWidth: 2.2)
            var mh = Path()
            mh.move(to: cc)
            mh.addLine(to: CGPoint(x: cc.x + cos(minA) * 10, y: cc.y + sin(minA) * 10))
            ctx.stroke(mh, with: .color(SoftTheme.coral), lineWidth: 1.6)
        }
        // L9 sleeping cat on the rug
        if level >= 9 {
            let catC = CGPoint(x: 226, y: 208)
            let breathe = CGFloat(sin(t * 1.3)) * 0.8
            let body = Path(ellipseIn: CGRect(x: catC.x - 17, y: catC.y - 9 - breathe, width: 34, height: 18 + breathe))
            ctx.fill(body, with: .color(SoftTheme.ink.opacity(0.72)))
            let head = Path(ellipseIn: CGRect(x: catC.x + 8, y: catC.y - 13, width: 15, height: 13))
            ctx.fill(head, with: .color(SoftTheme.ink.opacity(0.75)))
            for ex in [CGFloat(10), 17] {
                var ear = Path()
                ear.move(to: CGPoint(x: catC.x + ex, y: catC.y - 12))
                ear.addLine(to: CGPoint(x: catC.x + ex + 2.4, y: catC.y - 17))
                ear.addLine(to: CGPoint(x: catC.x + ex + 4.8, y: catC.y - 12))
                ear.closeSubpath()
                ctx.fill(ear, with: .color(SoftTheme.ink.opacity(0.75)))
            }
            var tail = Path()
            tail.move(to: CGPoint(x: catC.x - 15, y: catC.y + 3))
            tail.addQuadCurve(to: CGPoint(x: catC.x - 27, y: catC.y - 6 + CGFloat(sin(t * 0.8)) * 4),
                              control: CGPoint(x: catC.x - 26, y: catC.y + 4))
            ctx.stroke(tail, with: .color(SoftTheme.ink.opacity(0.72)),
                       style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
        // L10 framed friends photo on the shelf
        if level >= 10 {
            let frame = CGRect(x: 164, y: 42, width: 20, height: 16)
            ctx.fill(Path(roundedRect: frame, cornerRadius: 2.5), with: .color(SoftTheme.coralDeep))
            ctx.fill(Path(roundedRect: frame.insetBy(dx: 2.4, dy: 2.4), cornerRadius: 1.5), with: .color(.white))
            let skin = BuddySkins.byID(outfit.skinID)
            let d1 = Path(ellipseIn: CGRect(x: frame.minX + 4.5, y: frame.minY + 6, width: 5, height: 5))
            ctx.fill(d1, with: .color(skin.body))
            let d2 = Path(ellipseIn: CGRect(x: frame.minX + 11, y: frame.minY + 6, width: 5, height: 5))
            ctx.fill(d2, with: .color(SoftTheme.coral))
        }
        // L11 candle on the shelf
        if level >= 11 {
            let bx: CGFloat = 192
            let body = Path(roundedRect: CGRect(x: bx - 4, y: 44, width: 8, height: 14), cornerRadius: 2)
            ctx.fill(body, with: .color(Color(red: 0.973, green: 0.929, blue: 0.855)))
            let flicker = reduceMotion ? 1 : 0.8 + 0.2 * sin(t * 7)
            let flame = Path(ellipseIn: CGRect(x: bx - 2.4, y: 44 - 8 * flicker, width: 4.8, height: 8 * flicker))
            ctx.fill(flame, with: .color(SoftTheme.sun))
        }
        // L12 golden sun catcher in the window
        if level >= 12 {
            let sc = CGPoint(x: 254, y: 44)
            var thread = Path()
            thread.move(to: CGPoint(x: sc.x, y: 28))
            thread.addLine(to: CGPoint(x: sc.x, y: sc.y - 7))
            ctx.stroke(thread, with: .color(.white.opacity(0.7)), lineWidth: 1)
            var rhomb = Path()
            rhomb.move(to: CGPoint(x: sc.x, y: sc.y - 7))
            rhomb.addLine(to: CGPoint(x: sc.x + 5, y: sc.y))
            rhomb.addLine(to: CGPoint(x: sc.x, y: sc.y + 7))
            rhomb.addLine(to: CGPoint(x: sc.x - 5, y: sc.y))
            rhomb.closeSubpath()
            ctx.fill(rhomb, with: .color(SoftTheme.sun.opacity(0.7 + 0.3 * sin(t * 1.4))))
            drawSparkle(ctx, at: CGPoint(x: sc.x + 9, y: sc.y - 4), r: 2.6,
                        color: SoftTheme.sun.opacity(0.5 + 0.5 * sin(t * 1.8)))
        }
    }

    // MARK: Buddy

    private func drawBuddy(_ ctx: GraphicsContext, t: TimeInterval) {
        var pose = BuddyPose.standing
        // Idle: breath bob + occasional gentle side lean ("mini stretch").
        pose.hipY = CGFloat(sin(t * 1.5)) * 1.8
        let leanPhase = fmod(t, 14)
        if leanPhase > 11 {
            let k = CGFloat((leanPhase - 11) / 3)
            let ease = sin(k * .pi)
            pose.torsoLean = ease * 10
            pose.armRaiseL = ease * 130
        }
        // Wave overrides for ~1.2 s after a tap.
        let sinceWave = t - waveStartTime
        if sinceWave < 1.2, sinceWave >= 0 {
            pose.armRaiseR = 150 + CGFloat(sin(sinceWave * 14)) * 18
            pose.elbowR = 20
        }
        var buddyCtx = ctx
        // Fit the 320x360 rig into the room at 0.62 scale, feet on the mat.
        buddyCtx.translateBy(x: 150 - 320 * 0.62 / 2, y: 214 - 322 * 0.62)
        buddyCtx.scaleBy(x: 0.62, y: 0.62)
        renderBuddy(buddyCtx, pose: pose, facing: .front, groundLevel: 0,
                    muscles: [], glowPhase: CGFloat(fmod(t / 1.6, 1)),
                    showMat: false, outfit: outfit, mood: mood)
    }
}

// Chat bubble above Buddy's head on Home.
struct SpeechBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(SoftTheme.body(13, .semibold))
            .foregroundColor(SoftTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(Color.white.opacity(0.95))
                    .shadow(color: SoftTheme.ink.opacity(0.12), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 24)
    }
}

// Level ring + name, shown on the nook corner and reused on Progress.
struct FriendshipChip: View {
    let level: Int
    let fraction: CGFloat
    var body: some View {
        HStack(spacing: 7) {
            ZStack {
                Circle().stroke(SoftTheme.coral.opacity(0.2), lineWidth: 3.5).frame(width: 26, height: 26)
                Circle().trim(from: 0, to: max(fraction, 0.02))
                    .stroke(SoftTheme.coral, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 26, height: 26)
                Text("\(level)")
                    .font(SoftTheme.body(11, .bold))
                    .foregroundColor(SoftTheme.coral)
            }
            Text(Friendship.levelName(level))
                .font(SoftTheme.body(12, .bold))
                .foregroundColor(SoftTheme.ink)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.92))
            .shadow(color: SoftTheme.ink.opacity(0.1), radius: 5, x: 0, y: 2))
    }
}
