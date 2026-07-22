// Art generator for Soft Stretch — run once on macOS:
//   swiftc -O artgen.swift -o artgen && ./artgen "../Soft Stretch/Art" "../Soft Stretch/Assets.xcassets/AppIcon.appiconset"
// Produces routine covers, onboarding illustrations and the opaque app icon.

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// MARK: - Deterministic random

struct XorShift {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17
        return state
    }
    mutating func cg(_ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        lo + (hi - lo) * CGFloat(next() % 100_000) / 100_000
    }
}

// MARK: - Color helpers

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

let cream = rgb(0.984, 0.965, 0.937)
let ink = rgb(0.239, 0.220, 0.278)
let coral = rgb(0.949, 0.475, 0.361)
let lavender = rgb(0.616, 0.549, 0.839)
let sage = rgb(0.498, 0.663, 0.545)
let sun = rgb(0.961, 0.757, 0.361)
let sky = rgb(0.475, 0.686, 0.792)
let rose = rgb(0.910, 0.588, 0.643)
let mint = rgb(0.561, 0.796, 0.706)
let mintDeep = rgb(0.435, 0.671, 0.580)
let glowColor = rgb(1.0, 0.549, 0.353)

func mix(_ a: CGColor, _ b: CGColor, _ t: CGFloat) -> CGColor {
    let ca = a.components!, cb = b.components!
    return rgb(ca[0] + (cb[0] - ca[0]) * t,
               ca[1] + (cb[1] - ca[1]) * t,
               ca[2] + (cb[2] - ca[2]) * t)
}

// MARK: - Canvas

func makeContext(_ w: Int, _ h: Int) -> CGContext {
    let cs = CGColorSpaceCreateDeviceRGB()
    // noneSkipLast → opaque RGBX, no alpha channel in the PNG
    return CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                     bytesPerRow: 0, space: cs,
                     bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
}

func savePNG(_ ctx: CGContext, _ url: URL) {
    let img = ctx.makeImage()!
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(url.lastPathComponent)")
}

// Vertical gradient fill
func gradient(_ ctx: CGContext, _ rect: CGRect, _ colors: [CGColor]) {
    let cs = CGColorSpaceCreateDeviceRGB()
    let locs: [CGFloat] = colors.enumerated().map { CGFloat($0.offset) / CGFloat(max(colors.count - 1, 1)) }
    let grad = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: locs)!
    ctx.saveGState()
    ctx.clip(to: rect)
    ctx.drawLinearGradient(grad, start: CGPoint(x: rect.midX, y: rect.maxY),
                           end: CGPoint(x: rect.midX, y: rect.minY), options: [])
    ctx.restoreGState()
}

func radial(_ ctx: CGContext, center: CGPoint, radius: CGFloat, inner: CGColor, outer: CGColor) {
    let cs = CGColorSpaceCreateDeviceRGB()
    let grad = CGGradient(colorsSpace: cs, colors: [inner, outer] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(grad, startCenter: center, startRadius: 0,
                           endCenter: center, endRadius: radius,
                           options: [.drawsAfterEndLocation])
}

// Per-pixel grain so the flat art feels printed (and compresses honestly).
func grain(_ ctx: CGContext, _ w: Int, _ h: Int, seed: UInt64, strength: CGFloat = 0.055) {
    var rng = XorShift(seed: seed)
    let cell = 2
    for y in stride(from: 0, to: h, by: cell) {
        for x in stride(from: 0, to: w, by: cell) {
            let v = rng.cg(-strength, strength)
            let color = v > 0 ? rgb(1, 1, 1, v) : rgb(0.1, 0.08, 0.12, -v)
            ctx.setFillColor(color)
            ctx.fill(CGRect(x: x, y: y, width: cell, height: cell))
        }
    }
}

func sparkles(_ ctx: CGContext, _ rect: CGRect, count: Int, seed: UInt64, color: CGColor, maxR: CGFloat) {
    var rng = XorShift(seed: seed)
    for _ in 0..<count {
        let x = rng.cg(rect.minX, rect.maxX)
        let y = rng.cg(rect.minY, rect.maxY)
        let r = rng.cg(maxR * 0.25, maxR)
        let a = rng.cg(0.15, 0.6)
        ctx.setFillColor(color.copy(alpha: a)!)
        // four-point star
        let p = CGMutablePath()
        p.move(to: CGPoint(x: x, y: y + r))
        p.addQuadCurve(to: CGPoint(x: x + r, y: y), control: CGPoint(x: x + r * 0.22, y: y + r * 0.22))
        p.addQuadCurve(to: CGPoint(x: x, y: y - r), control: CGPoint(x: x + r * 0.22, y: y - r * 0.22))
        p.addQuadCurve(to: CGPoint(x: x - r, y: y), control: CGPoint(x: x - r * 0.22, y: y - r * 0.22))
        p.addQuadCurve(to: CGPoint(x: x, y: y + r), control: CGPoint(x: x - r * 0.22, y: y + r * 0.22))
        ctx.addPath(p)
        ctx.fillPath()
    }
}

func hills(_ ctx: CGContext, _ w: CGFloat, baseY: CGFloat, amp: CGFloat, color: CGColor, seed: UInt64) {
    var rng = XorShift(seed: seed)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: 0, y: 0))
    p.addLine(to: CGPoint(x: 0, y: baseY))
    var x: CGFloat = 0
    var y = baseY
    while x < w {
        let nx = x + rng.cg(w * 0.18, w * 0.33)
        let ny = baseY + rng.cg(-amp, amp)
        p.addQuadCurve(to: CGPoint(x: nx, y: ny),
                       control: CGPoint(x: (x + nx) / 2, y: max(y, ny) + amp * 0.7))
        x = nx; y = ny
    }
    p.addLine(to: CGPoint(x: w, y: 0))
    p.closeSubpath()
    ctx.setFillColor(color)
    ctx.addPath(p)
    ctx.fillPath()
}

// MARK: - Buddy figure (CG version for illustrations)

struct BuddySpec {
    var lean: CGFloat = 0          // torso lean degrees, + = right
    var armL: CGFloat = 10         // raise from hanging, + = out/up
    var armR: CGFloat = 10
    var elbowL: CGFloat = 0
    var elbowR: CGFloat = 0
    var headTilt: CGFloat = 0
    var glowSide: Bool = false     // warm glow along the right side
    var glowArms: Bool = false
}

// `groundAt` is the point where the feet touch (the shadow line).
func drawBuddy(_ ctx: CGContext, groundAt: CGPoint, scale s: CGFloat, spec: BuddySpec) {
    func rad(_ d: CGFloat) -> CGFloat { d * .pi / 180 }
    func off(_ p: CGPoint, _ deg: CGFloat, _ len: CGFloat) -> CGPoint {
        CGPoint(x: p.x + cos(rad(deg)) * len, y: p.y + sin(rad(deg)) * len)
    }
    // CG y-axis is up in our flipped drawing; angles: 90 = up
    let hip = CGPoint(x: groundAt.x, y: groundAt.y + 84 * s)
    let spineA: CGFloat = 90 - spec.lean
    let chest = off(hip, spineA, 66 * s)
    let neck = off(hip, spineA, 118 * s)
    let head = off(neck, spineA + spec.headTilt, 52 * s)

    // glow
    if spec.glowSide {
        // Soft warm aura radiating from the stretched side (opposite the lean).
        let sideDir: CGFloat = spec.lean >= 0 ? -1 : 1
        let glowC = CGPoint(x: chest.x + sideDir * 40 * s, y: chest.y)
        radial(ctx, center: glowC, radius: 110 * s,
               inner: glowColor.copy(alpha: 0.42)!, outer: glowColor.copy(alpha: 0.0)!)
        radial(ctx, center: CGPoint(x: hip.x + sideDir * 30 * s, y: hip.y + 14 * s), radius: 70 * s,
               inner: glowColor.copy(alpha: 0.3)!, outer: glowColor.copy(alpha: 0.0)!)
    }

    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)

    func limb(_ from: CGPoint, _ midDeg: CGFloat, _ midLen: CGFloat,
              _ endDeg: CGFloat, _ endLen: CGFloat, width: CGFloat, color: CGColor) {
        let m = off(from, midDeg, midLen)
        let e = off(m, endDeg, endLen)
        ctx.setStrokeColor(color)
        ctx.setLineWidth(width)
        ctx.move(to: from)
        ctx.addLine(to: m)
        ctx.addLine(to: e)
        ctx.strokePath()
        ctx.setFillColor(color)
        let r = width * 0.62
        ctx.fillEllipse(in: CGRect(x: e.x - r, y: e.y - r, width: r * 2, height: r * 2))
    }

    // legs
    limb(CGPoint(x: hip.x - 13 * s, y: hip.y), -90 - 4, 41 * s, -90 - 2, 38 * s, width: 19 * s, color: mintDeep)
    limb(CGPoint(x: hip.x + 13 * s, y: hip.y), -90 + 4, 41 * s, -90 + 2, 38 * s, width: 19 * s, color: mint)

    // torso
    ctx.setStrokeColor(mint)
    ctx.setLineWidth(46 * s)
    ctx.move(to: hip)
    ctx.addQuadCurve(to: neck, control: chest)
    ctx.strokePath()
    ctx.setFillColor(mint)
    ctx.fillEllipse(in: CGRect(x: hip.x - 27 * s, y: hip.y - 20 * s, width: 54 * s, height: 46 * s))

    // arms: hang = spineA + 180
    let hang = spineA + 180
    let shoulderL = off(neck, spineA + 90, 26 * s)
    let shoulderR = off(neck, spineA - 90, 26 * s)
    limb(shoulderL, hang - spec.armL, 36 * s, hang - spec.armL - spec.elbowL, 31 * s, width: 17 * s, color: mintDeep)
    limb(shoulderR, hang + spec.armR, 36 * s, hang + spec.armR + spec.elbowR, 31 * s, width: 17 * s, color: mint)

    // head + face
    ctx.setFillColor(mint)
    ctx.fillEllipse(in: CGRect(x: head.x - 31 * s, y: head.y - 29 * s, width: 62 * s, height: 58 * s))
    ctx.setFillColor(ink.copy(alpha: 0.82)!)
    for sx in [-11 * s, 11 * s] {
        ctx.fillEllipse(in: CGRect(x: head.x + sx - 3.2 * s, y: head.y - 1 * s, width: 6.4 * s, height: 8.6 * s))
    }
    ctx.setStrokeColor(ink.copy(alpha: 0.82)!)
    ctx.setLineWidth(2.6 * s)
    ctx.move(to: CGPoint(x: head.x - 7 * s, y: head.y - 8 * s))
    ctx.addQuadCurve(to: CGPoint(x: head.x + 7 * s, y: head.y - 8 * s),
                     control: CGPoint(x: head.x, y: head.y - 14 * s))
    ctx.strokePath()
    ctx.setFillColor(rgb(0.965, 0.663, 0.584, 0.75))
    for sx in [-19 * s, 19 * s] {
        ctx.fillEllipse(in: CGRect(x: head.x + sx - 5 * s, y: head.y - 9 * s, width: 10 * s, height: 6.5 * s))
    }
}

// MARK: - Covers

struct CoverSpec {
    let name: String
    let colors: [CGColor]     // sky gradient bottom→top
    let hillA: CGColor
    let hillB: CGColor
    let orb: CGColor          // sun / moon
    let orbY: CGFloat         // fraction of height
    let sparkle: CGColor
    let moon: Bool
    let buddy: BuddySpec
}

let covers: [CoverSpec] = [
    CoverSpec(name: "cover_morning",
              colors: [mix(sun, cream, 0.55), mix(rose, cream, 0.35), mix(sky, cream, 0.55)],
              hillA: mix(sage, cream, 0.25), hillB: sage, orb: sun, orbY: 0.68,
              sparkle: sun, moon: false,
              buddy: BuddySpec(lean: 0, armL: 155, armR: 155, headTilt: 0)),
    CoverSpec(name: "cover_desk",
              colors: [mix(lavender, cream, 0.7), mix(lavender, cream, 0.4), mix(sky, cream, 0.45)],
              hillA: mix(lavender, cream, 0.35), hillB: mix(lavender, ink, 0.25), orb: mix(sun, cream, 0.3), orbY: 0.74,
              sparkle: lavender, moon: false,
              buddy: BuddySpec(lean: 0, armL: 25, armR: 100, elbowR: 60, headTilt: -14, glowArms: false)),
    CoverSpec(name: "cover_evening",
              colors: [mix(lavender, ink, 0.45), mix(lavender, ink, 0.2), mix(rose, lavender, 0.4)],
              hillA: mix(ink, lavender, 0.72), hillB: mix(ink, lavender, 0.55), orb: mix(cream, sun, 0.3), orbY: 0.72,
              sparkle: cream, moon: true,
              buddy: BuddySpec(lean: 0, armL: 45, armR: 45, elbowL: 60, elbowR: 60, headTilt: 6)),
    CoverSpec(name: "cover_fullbody",
              colors: [mix(sage, cream, 0.5), mix(sun, cream, 0.5), mix(sky, cream, 0.4)],
              hillA: mix(sage, cream, 0.2), hillB: mintDeep, orb: sun, orbY: 0.7,
              sparkle: coral, moon: false,
              buddy: BuddySpec(lean: -14, armL: 20, armR: 160, headTilt: -8, glowSide: true)),
    CoverSpec(name: "cover_neck",
              colors: [mix(rose, cream, 0.55), mix(rose, cream, 0.3), mix(lavender, cream, 0.5)],
              hillA: mix(rose, cream, 0.25), hillB: mix(rose, ink, 0.15), orb: mix(sun, cream, 0.4), orbY: 0.75,
              sparkle: rose, moon: false,
              buddy: BuddySpec(lean: 0, armL: 8, armR: 8, headTilt: 24)),
    CoverSpec(name: "cover_hips",
              colors: [mix(sage, cream, 0.45), mix(sage, cream, 0.25), mix(sun, cream, 0.55)],
              hillA: mix(sage, cream, 0.15), hillB: sage, orb: mix(sun, cream, 0.25), orbY: 0.72,
              sparkle: sage, moon: false,
              buddy: BuddySpec(lean: 6, armL: 30, armR: 30, elbowL: 90, elbowR: 90, headTilt: 0)),
    CoverSpec(name: "cover_hamstring",
              colors: [mix(sky, cream, 0.5), mix(sky, cream, 0.3), mix(sage, cream, 0.45)],
              hillA: mix(sky, cream, 0.2), hillB: mix(sky, ink, 0.2), orb: mix(cream, sun, 0.5), orbY: 0.76,
              sparkle: sky, moon: false,
              buddy: BuddySpec(lean: 30, armL: 120, armR: 120, headTilt: 15, glowArms: false)),
    CoverSpec(name: "cover_posture",
              colors: [mix(coral, cream, 0.6), mix(sun, cream, 0.45), mix(sky, cream, 0.55)],
              hillA: mix(coral, cream, 0.35), hillB: mix(coral, ink, 0.2), orb: sun, orbY: 0.7,
              sparkle: coral, moon: false,
              buddy: BuddySpec(lean: -4, armL: 70, armR: 70, headTilt: -6, glowSide: false))
]

func renderCover(_ spec: CoverSpec, dir: URL, index: Int) {
    let w = 1440, h = 1080
    let ctx = makeContext(w, h)
    let rect = CGRect(x: 0, y: 0, width: w, height: h)
    gradient(ctx, rect, spec.colors)

    // orb with halo
    let orbC = CGPoint(x: CGFloat(w) * 0.72, y: CGFloat(h) * spec.orbY)
    radial(ctx, center: orbC, radius: 260, inner: spec.orb.copy(alpha: 0.5)!, outer: spec.orb.copy(alpha: 0.0)!)
    ctx.setFillColor(spec.orb)
    if spec.moon {
        // crescent
        ctx.fillEllipse(in: CGRect(x: orbC.x - 70, y: orbC.y - 70, width: 140, height: 140))
        ctx.setFillColor(spec.colors[1])
        ctx.fillEllipse(in: CGRect(x: orbC.x - 30, y: orbC.y - 56, width: 124, height: 124))
    } else {
        ctx.fillEllipse(in: CGRect(x: orbC.x - 78, y: orbC.y - 78, width: 156, height: 156))
    }

    sparkles(ctx, CGRect(x: 0, y: CGFloat(h) * 0.45, width: CGFloat(w), height: CGFloat(h) * 0.55),
             count: 26, seed: UInt64(300 + index), color: spec.sparkle, maxR: 16)

    hills(ctx, CGFloat(w), baseY: CGFloat(h) * 0.34, amp: 60, color: spec.hillA.copy(alpha: 0.85)!, seed: UInt64(70 + index))
    hills(ctx, CGFloat(w), baseY: CGFloat(h) * 0.24, amp: 46, color: spec.hillB, seed: UInt64(140 + index))

    // soft ground shadow + Buddy
    ctx.setFillColor(ink.copy(alpha: 0.10)!)
    ctx.fillEllipse(in: CGRect(x: CGFloat(w) * 0.30 - 150, y: CGFloat(h) * 0.16 - 26, width: 300, height: 52))
    drawBuddy(ctx, groundAt: CGPoint(x: CGFloat(w) * 0.30, y: CGFloat(h) * 0.16), scale: 2.1, spec: spec.buddy)

    grain(ctx, w, h, seed: UInt64(1000 + index))
    savePNG(ctx, dir.appendingPathComponent("\(spec.name).png"))
}

// MARK: - Onboarding

func renderOnboarding(dir: URL) {
    let w = 1280, h = 1480
    let specs: [(String, [CGColor], BuddySpec, Bool)] = [
        ("onb_meet", [mix(sage, cream, 0.5), mix(sun, cream, 0.55), mix(sky, cream, 0.5)],
         BuddySpec(lean: 0, armL: 10, armR: 150, headTilt: -5), false),
        ("onb_glow", [mix(rose, cream, 0.5), mix(coral, cream, 0.6), mix(lavender, cream, 0.5)],
         BuddySpec(lean: -24, armL: 20, armR: 142, headTilt: -10, glowSide: true), true),
        ("onb_daily", [mix(sky, cream, 0.5), mix(lavender, cream, 0.55), mix(rose, cream, 0.5)],
         BuddySpec(lean: 0, armL: 150, armR: 150, headTilt: 0), false)
    ]
    for (i, spec) in specs.enumerated() {
        let ctx = makeContext(w, h)
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        gradient(ctx, rect, spec.1)

        // big soft circle stage
        radial(ctx, center: CGPoint(x: CGFloat(w) / 2, y: CGFloat(h) * 0.42), radius: CGFloat(w) * 0.52,
               inner: cream.copy(alpha: 0.75)!, outer: cream.copy(alpha: 0.0)!)

        sparkles(ctx, rect.insetBy(dx: 60, dy: 120), count: 34, seed: UInt64(900 + i),
                 color: i == 1 ? coral : sun, maxR: 20)

        ctx.setFillColor(ink.copy(alpha: 0.10)!)
        ctx.fillEllipse(in: CGRect(x: CGFloat(w) / 2 - 210, y: CGFloat(h) * 0.42 - 320, width: 420, height: 70))
        drawBuddy(ctx, groundAt: CGPoint(x: CGFloat(w) / 2, y: CGFloat(h) * 0.42 - 290), scale: 3.4, spec: spec.2)

        // dotted breath ring on slide 3
        if i == 2 {
            ctx.setStrokeColor(coral.copy(alpha: 0.6)!)
            ctx.setLineWidth(10)
            ctx.setLineDash(phase: 0, lengths: [2, 46])
            ctx.setLineCap(.round)
            ctx.strokeEllipse(in: CGRect(x: CGFloat(w) / 2 - 430, y: CGFloat(h) * 0.42 - 430, width: 860, height: 860))
            ctx.setLineDash(phase: 0, lengths: [])
        }
        grain(ctx, w, h, seed: UInt64(2000 + i))
        savePNG(ctx, dir.appendingPathComponent("\(spec.0).png"))
    }
}

// MARK: - App icon (abstract: soft ring orb, no figure)

func renderIcon(dir: URL) {
    let w = 1024, h = 1024
    let ctx = makeContext(w, h)
    let rect = CGRect(x: 0, y: 0, width: w, height: h)

    // muted peach radial background
    gradient(ctx, rect, [mix(coral, cream, 0.72), mix(rose, cream, 0.55), mix(sun, cream, 0.68)])
    radial(ctx, center: CGPoint(x: 512, y: 560), radius: 620,
           inner: cream.copy(alpha: 0.55)!, outer: cream.copy(alpha: 0.0)!)

    let c = CGPoint(x: 512, y: 512)

    // soft halo
    radial(ctx, center: c, radius: 360, inner: mint.copy(alpha: 0.35)!, outer: mint.copy(alpha: 0.0)!)

    // mint orb
    let orbR: CGFloat = 208
    let cs = CGColorSpaceCreateDeviceRGB()
    let orbGrad = CGGradient(colorsSpace: cs,
                             colors: [mix(mint, cream, 0.25), mintDeep] as CFArray,
                             locations: [0, 1])!
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: c.x - orbR, y: c.y - orbR, width: orbR * 2, height: orbR * 2))
    ctx.clip()
    ctx.drawLinearGradient(orbGrad, start: CGPoint(x: c.x - orbR, y: c.y + orbR),
                           end: CGPoint(x: c.x + orbR, y: c.y - orbR), options: [])
    ctx.restoreGState()

    // open arc ring around the orb (the "soft flow")
    ctx.setStrokeColor(mix(coral, rose, 0.35))
    ctx.setLineWidth(58)
    ctx.setLineCap(.round)
    ctx.addArc(center: c, radius: 318, startAngle: .pi * 0.78, endAngle: .pi * 2.14, clockwise: false)
    ctx.strokePath()

    // small companion dot on the ring gap
    let dotA: CGFloat = .pi * 0.46
    let dotP = CGPoint(x: c.x + cos(dotA) * 318, y: c.y + sin(dotA) * 318)
    ctx.setFillColor(sun)
    ctx.fillEllipse(in: CGRect(x: dotP.x - 44, y: dotP.y - 44, width: 88, height: 88))

    // orb highlight
    ctx.setFillColor(cream.copy(alpha: 0.35)!)
    ctx.fillEllipse(in: CGRect(x: c.x - 120, y: c.y + 30, width: 150, height: 110))

    // two tiny sparkles
    sparkles(ctx, CGRect(x: 640, y: 640, width: 240, height: 220), count: 2, seed: 77, color: cream, maxR: 34)
    sparkles(ctx, CGRect(x: 160, y: 150, width: 220, height: 200), count: 1, seed: 91, color: coral, maxR: 30)

    savePNG(ctx, dir.appendingPathComponent("AppIcon-1024.png"))
}

// MARK: - Main

let args = CommandLine.arguments
guard args.count >= 3 else {
    print("usage: artgen <artDir> <iconDir>")
    exit(1)
}
let artDir = URL(fileURLWithPath: args[1])
let iconDir = URL(fileURLWithPath: args[2])
try? FileManager.default.createDirectory(at: artDir, withIntermediateDirectories: true)
try? FileManager.default.createDirectory(at: iconDir, withIntermediateDirectories: true)

for (i, spec) in covers.enumerated() { renderCover(spec, dir: artDir, index: i) }
renderOnboarding(dir: artDir)
renderIcon(dir: iconDir)
print("all done")
