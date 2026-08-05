import SwiftUI

struct BuddySkin {
    let id: String
    let name: String
    let body: Color
    let deep: Color
    let cheek: Color
}

enum BuddySkins {
    static let all: [BuddySkin] = [
        BuddySkin(id: "mint", name: "Classic Mint",
                  body: Color(red: 0.561, green: 0.796, blue: 0.706),
                  deep: Color(red: 0.435, green: 0.671, blue: 0.580),
                  cheek: Color(red: 0.965, green: 0.663, blue: 0.584)),
        BuddySkin(id: "peach", name: "Warm Peach",
                  body: Color(red: 0.973, green: 0.714, blue: 0.600),
                  deep: Color(red: 0.898, green: 0.580, blue: 0.463),
                  cheek: Color(red: 0.937, green: 0.494, blue: 0.475)),
        BuddySkin(id: "sky", name: "Morning Sky",
                  body: Color(red: 0.596, green: 0.769, blue: 0.851),
                  deep: Color(red: 0.463, green: 0.647, blue: 0.745),
                  cheek: Color(red: 0.949, green: 0.639, blue: 0.616)),
        BuddySkin(id: "lilac", name: "Soft Lilac",
                  body: Color(red: 0.741, green: 0.678, blue: 0.878),
                  deep: Color(red: 0.616, green: 0.549, blue: 0.780),
                  cheek: Color(red: 0.957, green: 0.647, blue: 0.667)),
        BuddySkin(id: "sand", name: "Dune Sand",
                  body: Color(red: 0.890, green: 0.796, blue: 0.635),
                  deep: Color(red: 0.788, green: 0.671, blue: 0.494),
                  cheek: Color(red: 0.937, green: 0.588, blue: 0.514)),
        BuddySkin(id: "sunrise", name: "Sunrise Gold",
                  body: Color(red: 0.949, green: 0.769, blue: 0.478),
                  deep: Color(red: 0.867, green: 0.643, blue: 0.333),
                  cheek: Color(red: 0.945, green: 0.545, blue: 0.455))
    ]

    static func byID(_ id: String) -> BuddySkin {
        all.first { $0.id == id } ?? all[0]
    }
}

struct BuddyAccessoryInfo: Identifiable {
    let id: String
    let name: String
}

enum BuddyAccessories {
    static let all: [BuddyAccessoryInfo] = [
        BuddyAccessoryInfo(id: "sweatband", name: "Sweatband"),
        BuddyAccessoryInfo(id: "scarf", name: "Cozy Scarf"),
        BuddyAccessoryInfo(id: "flowers", name: "Flower Crown"),
        BuddyAccessoryInfo(id: "glasses", name: "Round Glasses"),
        BuddyAccessoryInfo(id: "beanie", name: "Pompom Beanie"),
        BuddyAccessoryInfo(id: "bowtie", name: "Bow Tie")
    ]
}

enum BuddyMood {
    case content
    case sleepy
    case happy
    case proud
}

enum BuddyAccessoryDrawer {
    static func draw(_ id: String, in ctx: GraphicsContext,
                     joints j: BuddyRig.Joints, skin: BuddySkin) {
        let c = j.head

        let tilt = (j.headAngle + 90) * .pi / 180
        func onHead(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {

            let x = dx * cos(tilt) - dy * sin(tilt)
            let y = dx * sin(tilt) + dy * cos(tilt)
            return CGPoint(x: c.x + x, y: c.y + y)
        }
        switch id {
        case "sweatband":
            var band = Path()
            band.move(to: onHead(-27, -13))
            band.addQuadCurve(to: onHead(27, -13), control: onHead(0, -22))
            ctx.stroke(band, with: .color(Color(red: 0.949, green: 0.475, blue: 0.361)),
                       style: StrokeStyle(lineWidth: 9, lineCap: .round))
        case "scarf":
            let neckP = j.neck
            let loop = Path(ellipseIn: CGRect(x: neckP.x - 17, y: neckP.y - 6, width: 34, height: 16))
            ctx.fill(loop, with: .color(Color(red: 0.910, green: 0.588, blue: 0.643)))
            var tail = Path()
            tail.move(to: CGPoint(x: neckP.x + 8, y: neckP.y + 2))
            tail.addQuadCurve(to: CGPoint(x: neckP.x + 14, y: neckP.y + 26),
                              control: CGPoint(x: neckP.x + 18, y: neckP.y + 12))
            ctx.stroke(tail, with: .color(Color(red: 0.910, green: 0.588, blue: 0.643)),
                       style: StrokeStyle(lineWidth: 10, lineCap: .round))
            let fringe = Path(roundedRect: CGRect(x: neckP.x + 9, y: neckP.y + 24, width: 11, height: 7), cornerRadius: 2)
            ctx.fill(fringe, with: .color(Color(red: 0.855, green: 0.373, blue: 0.278)))
        case "flowers":
            let petals: [Color] = [Color(red: 0.957, green: 0.647, blue: 0.667),
                                   Color(red: 0.961, green: 0.757, blue: 0.361),
                                   Color(red: 0.741, green: 0.678, blue: 0.878),
                                   Color(red: 0.957, green: 0.647, blue: 0.667),
                                   Color(red: 0.961, green: 0.757, blue: 0.361)]
            for (i, color) in petals.enumerated() {
                let dx = CGFloat(i - 2) * 12
                let p = onHead(dx, -26 + abs(dx) * 0.18)
                for k in 0..<5 {
                    let a = CGFloat(k) / 5 * 2 * .pi
                    let petal = Path(ellipseIn: CGRect(x: p.x + cos(a) * 3.6 - 2.4,
                                                       y: p.y + sin(a) * 3.6 - 2.4, width: 4.8, height: 4.8))
                    ctx.fill(petal, with: .color(color))
                }
                let heart = Path(ellipseIn: CGRect(x: p.x - 2.2, y: p.y - 2.2, width: 4.4, height: 4.4))
                ctx.fill(heart, with: .color(.white.opacity(0.9)))
            }
        case "glasses":
            let ink = Color(red: 0.239, green: 0.220, blue: 0.278).opacity(0.75)
            for sx in [CGFloat(-11), 11] {
                let center = onHead(sx, -2)
                let lens = Path(ellipseIn: CGRect(x: center.x - 8.5, y: center.y - 8.5,
                                                  width: 17, height: 17))
                ctx.stroke(lens, with: .color(ink), lineWidth: 2.4)
            }
            var bridge = Path()
            bridge.move(to: onHead(-3, -3))
            bridge.addQuadCurve(to: onHead(3, -3), control: onHead(0, -6))
            ctx.stroke(bridge, with: .color(ink), lineWidth: 2.4)
        case "beanie":
            var dome = Path()
            dome.move(to: onHead(-25, -14))
            dome.addQuadCurve(to: onHead(25, -14), control: onHead(0, -46))
            dome.closeSubpath()
            ctx.fill(dome, with: .color(Color(red: 0.616, green: 0.549, blue: 0.839)))
            var brim = Path()
            brim.move(to: onHead(-26, -13))
            brim.addQuadCurve(to: onHead(26, -13), control: onHead(0, -21))
            ctx.stroke(brim, with: .color(Color(red: 0.518, green: 0.451, blue: 0.741)),
                       style: StrokeStyle(lineWidth: 8, lineCap: .round))
            let pomC = onHead(0, -38)
            let pom = Path(ellipseIn: CGRect(x: pomC.x - 6, y: pomC.y - 6, width: 12, height: 12))
            ctx.fill(pom, with: .color(.white.opacity(0.92)))
        case "bowtie":
            let n = j.neck
            let tie = Color(red: 0.949, green: 0.475, blue: 0.361)
            var left = Path()
            left.move(to: CGPoint(x: n.x, y: n.y + 6))
            left.addLine(to: CGPoint(x: n.x - 13, y: n.y))
            left.addLine(to: CGPoint(x: n.x - 13, y: n.y + 12))
            left.closeSubpath()
            var right = Path()
            right.move(to: CGPoint(x: n.x, y: n.y + 6))
            right.addLine(to: CGPoint(x: n.x + 13, y: n.y))
            right.addLine(to: CGPoint(x: n.x + 13, y: n.y + 12))
            right.closeSubpath()
            ctx.fill(left, with: .color(tie))
            ctx.fill(right, with: .color(tie))
            let knot = Path(ellipseIn: CGRect(x: n.x - 3.5, y: n.y + 2.5, width: 7, height: 7))
            ctx.fill(knot, with: .color(Color(red: 0.855, green: 0.373, blue: 0.278)))
        default:
            break
        }
    }
}
