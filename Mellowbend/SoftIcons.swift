import SwiftUI

enum SoftIconKind {
    case home, routines, library, progress, more
    case play, pause, skipForward, skipBack, close, chevronRight, chevronLeft
    case heart, heartFill, flame, clock, check, sparkle, lock, arrowUp
    case leaf, drop, sun, moon, shield, reset
}

struct SoftIcon: View {
    let kind: SoftIconKind
    var size: CGFloat = 24
    var color: Color = SoftTheme.ink
    var lineWidth: CGFloat = 2.2

    var body: some View {
        canvasView
            .frame(width: size, height: size)
    }

    private var canvasView: some View {
        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: 1.5, dy: 1.5)
            draw(context: context, rect: rect)
        }
    }

    private func stroke(_ context: GraphicsContext, _ path: Path, _ lw: CGFloat? = nil) {
        context.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: lw ?? lineWidth, lineCap: .round, lineJoin: .round))
    }

    private func fill(_ context: GraphicsContext, _ path: Path) {
        context.fill(path, with: .color(color))
    }

    private func draw(context: GraphicsContext, rect: CGRect) {
        let w = rect.width, h = rect.height
        let x0 = rect.minX, y0 = rect.minY
        func pt(_ fx: CGFloat, _ fy: CGFloat) -> CGPoint { CGPoint(x: x0 + fx * w, y: y0 + fy * h) }

        switch kind {
        case .home:
            var p = Path()
            p.move(to: pt(0.1, 0.52))
            p.addLine(to: pt(0.5, 0.14))
            p.addLine(to: pt(0.9, 0.52))
            stroke(context, p)
            var body = Path()
            body.move(to: pt(0.2, 0.48))
            body.addLine(to: pt(0.2, 0.88))
            body.addLine(to: pt(0.8, 0.88))
            body.addLine(to: pt(0.8, 0.48))
            stroke(context, body)
            var door = Path()
            door.move(to: pt(0.5, 0.88))
            door.addLine(to: pt(0.5, 0.62))
            stroke(context, door)

        case .routines:
            for (i, fy) in [0.22, 0.5, 0.78].enumerated() {
                var line = Path()
                line.move(to: pt(0.34, CGFloat(fy)))
                line.addLine(to: pt(0.9, CGFloat(fy)))
                stroke(context, line)
                let r: CGFloat = 0.07
                let dot = Path(ellipseIn: CGRect(x: pt(0.12, CGFloat(fy)).x - r * w,
                                                 y: pt(0.12, CGFloat(fy)).y - r * h,
                                                 width: r * 2 * w, height: r * 2 * h))
                if i == 0 { fill(context, dot) } else { stroke(context, dot, lineWidth * 0.85) }
            }

        case .library:

            let head = Path(ellipseIn: CGRect(x: pt(0.5, 0.2).x - 0.1 * w, y: pt(0.5, 0.2).y - 0.1 * h,
                                              width: 0.2 * w, height: 0.2 * h))
            stroke(context, head)
            var bodyLine = Path()
            bodyLine.move(to: pt(0.5, 0.32))
            bodyLine.addLine(to: pt(0.5, 0.62))
            bodyLine.move(to: pt(0.5, 0.4))
            bodyLine.addLine(to: pt(0.18, 0.26))
            bodyLine.move(to: pt(0.5, 0.4))
            bodyLine.addLine(to: pt(0.85, 0.55))
            bodyLine.move(to: pt(0.5, 0.62))
            bodyLine.addLine(to: pt(0.28, 0.9))
            bodyLine.move(to: pt(0.5, 0.62))
            bodyLine.addLine(to: pt(0.74, 0.9))
            stroke(context, bodyLine)

        case .progress:
            for (i, fx) in [0.18, 0.5, 0.82].enumerated() {
                let tops: [CGFloat] = [0.55, 0.3, 0.42]
                var bar = Path()
                bar.move(to: pt(CGFloat(fx), 0.88))
                bar.addLine(to: pt(CGFloat(fx), tops[i]))
                stroke(context, bar, lineWidth * 1.7)
            }
            var cap = Path()
            cap.move(to: pt(0.1, 0.14))
            cap.addQuadCurve(to: pt(0.9, 0.14), control: pt(0.5, 0.02))
            stroke(context, cap, lineWidth * 0.8)

        case .more:
            for fx in [0.18, 0.5, 0.82] {
                let r: CGFloat = 0.075
                let dot = Path(ellipseIn: CGRect(x: pt(CGFloat(fx), 0.5).x - r * w,
                                                 y: pt(CGFloat(fx), 0.5).y - r * h,
                                                 width: r * 2 * w, height: r * 2 * h))
                fill(context, dot)
            }

        case .play:
            var p = Path()
            p.move(to: pt(0.3, 0.16))
            p.addLine(to: pt(0.88, 0.5))
            p.addLine(to: pt(0.3, 0.84))
            p.closeSubpath()
            fill(context, p)

        case .pause:
            for fx in [0.32, 0.68] {
                var bar = Path()
                bar.move(to: pt(CGFloat(fx), 0.18))
                bar.addLine(to: pt(CGFloat(fx), 0.82))
                stroke(context, bar, lineWidth * 2.2)
            }

        case .skipForward:
            var p = Path()
            p.move(to: pt(0.14, 0.2))
            p.addLine(to: pt(0.54, 0.5))
            p.addLine(to: pt(0.14, 0.8))
            p.closeSubpath()
            fill(context, p)
            var bar = Path()
            bar.move(to: pt(0.74, 0.2))
            bar.addLine(to: pt(0.74, 0.8))
            stroke(context, bar, lineWidth * 1.8)

        case .skipBack:
            var p = Path()
            p.move(to: pt(0.86, 0.2))
            p.addLine(to: pt(0.46, 0.5))
            p.addLine(to: pt(0.86, 0.8))
            p.closeSubpath()
            fill(context, p)
            var bar = Path()
            bar.move(to: pt(0.26, 0.2))
            bar.addLine(to: pt(0.26, 0.8))
            stroke(context, bar, lineWidth * 1.8)

        case .close:
            var p = Path()
            p.move(to: pt(0.22, 0.22)); p.addLine(to: pt(0.78, 0.78))
            p.move(to: pt(0.78, 0.22)); p.addLine(to: pt(0.22, 0.78))
            stroke(context, p)

        case .chevronRight:
            var p = Path()
            p.move(to: pt(0.35, 0.18))
            p.addLine(to: pt(0.7, 0.5))
            p.addLine(to: pt(0.35, 0.82))
            stroke(context, p)

        case .chevronLeft:
            var p = Path()
            p.move(to: pt(0.65, 0.18))
            p.addLine(to: pt(0.3, 0.5))
            p.addLine(to: pt(0.65, 0.82))
            stroke(context, p)

        case .heart, .heartFill:
            var p = Path()
            p.move(to: pt(0.5, 0.85))
            p.addCurve(to: pt(0.08, 0.32), control1: pt(0.22, 0.66), control2: pt(0.08, 0.52))
            p.addCurve(to: pt(0.5, 0.3), control1: pt(0.08, 0.1), control2: pt(0.36, 0.08))
            p.addCurve(to: pt(0.92, 0.32), control1: pt(0.64, 0.08), control2: pt(0.92, 0.1))
            p.addCurve(to: pt(0.5, 0.85), control1: pt(0.92, 0.52), control2: pt(0.78, 0.66))
            p.closeSubpath()
            if kind == .heartFill { fill(context, p) } else { stroke(context, p) }

        case .flame:
            var p = Path()
            p.move(to: pt(0.5, 0.08))
            p.addCurve(to: pt(0.82, 0.6), control1: pt(0.72, 0.28), control2: pt(0.82, 0.42))
            p.addCurve(to: pt(0.5, 0.92), control1: pt(0.82, 0.8), control2: pt(0.68, 0.92))
            p.addCurve(to: pt(0.18, 0.6), control1: pt(0.32, 0.92), control2: pt(0.18, 0.8))
            p.addCurve(to: pt(0.38, 0.36), control1: pt(0.18, 0.48), control2: pt(0.28, 0.44))
            p.addCurve(to: pt(0.5, 0.08), control1: pt(0.44, 0.28), control2: pt(0.46, 0.2))
            p.closeSubpath()
            stroke(context, p)
            let inner = Path(ellipseIn: CGRect(x: pt(0.5, 0.68).x - 0.08 * w, y: pt(0.5, 0.68).y - 0.08 * h,
                                               width: 0.16 * w, height: 0.16 * h))
            fill(context, inner)

        case .clock:
            let circle = Path(ellipseIn: rect.insetBy(dx: w * 0.08, dy: h * 0.08))
            stroke(context, circle)
            var hands = Path()
            hands.move(to: pt(0.5, 0.5)); hands.addLine(to: pt(0.5, 0.26))
            hands.move(to: pt(0.5, 0.5)); hands.addLine(to: pt(0.68, 0.58))
            stroke(context, hands)

        case .check:
            var p = Path()
            p.move(to: pt(0.16, 0.55))
            p.addLine(to: pt(0.42, 0.8))
            p.addLine(to: pt(0.85, 0.24))
            stroke(context, p, lineWidth * 1.3)

        case .sparkle:
            var p = Path()
            p.move(to: pt(0.5, 0.06))
            p.addQuadCurve(to: pt(0.62, 0.38), control: pt(0.54, 0.3))
            p.addQuadCurve(to: pt(0.94, 0.5), control: pt(0.7, 0.46))
            p.addQuadCurve(to: pt(0.62, 0.62), control: pt(0.7, 0.54))
            p.addQuadCurve(to: pt(0.5, 0.94), control: pt(0.54, 0.7))
            p.addQuadCurve(to: pt(0.38, 0.62), control: pt(0.46, 0.7))
            p.addQuadCurve(to: pt(0.06, 0.5), control: pt(0.3, 0.54))
            p.addQuadCurve(to: pt(0.38, 0.38), control: pt(0.3, 0.46))
            p.closeSubpath()
            fill(context, p)

        case .lock:
            var body = Path()
            body.addRoundedRect(in: CGRect(x: pt(0.2, 0.45).x, y: pt(0.2, 0.45).y,
                                           width: 0.6 * w, height: 0.45 * h), cornerSize: CGSize(width: 4, height: 4))
            stroke(context, body)
            var shackle = Path()
            shackle.move(to: pt(0.32, 0.45))
            shackle.addLine(to: pt(0.32, 0.3))
            shackle.addQuadCurve(to: pt(0.68, 0.3), control: pt(0.5, 0.06))
            shackle.addLine(to: pt(0.68, 0.45))
            stroke(context, shackle)

        case .arrowUp:
            var p = Path()
            p.move(to: pt(0.5, 0.85)); p.addLine(to: pt(0.5, 0.2))
            p.move(to: pt(0.25, 0.42)); p.addLine(to: pt(0.5, 0.15)); p.addLine(to: pt(0.75, 0.42))
            stroke(context, p)

        case .leaf:
            var p = Path()
            p.move(to: pt(0.5, 0.9))
            p.addQuadCurve(to: pt(0.85, 0.2), control: pt(0.9, 0.65))
            p.addQuadCurve(to: pt(0.5, 0.9), control: pt(0.2, 0.35))
            p.closeSubpath()
            stroke(context, p)
            var vein = Path()
            vein.move(to: pt(0.5, 0.88))
            vein.addQuadCurve(to: pt(0.78, 0.28), control: pt(0.6, 0.6))
            stroke(context, vein, lineWidth * 0.7)

        case .drop:
            var p = Path()
            p.move(to: pt(0.5, 0.08))
            p.addCurve(to: pt(0.5, 0.92), control1: pt(0.92, 0.55), control2: pt(0.78, 0.92))
            p.addCurve(to: pt(0.5, 0.08), control1: pt(0.22, 0.92), control2: pt(0.08, 0.55))
            p.closeSubpath()
            stroke(context, p)

        case .sun:
            let core = Path(ellipseIn: CGRect(x: pt(0.5, 0.5).x - 0.16 * w, y: pt(0.5, 0.5).y - 0.16 * h,
                                              width: 0.32 * w, height: 0.32 * h))
            stroke(context, core)
            for i in 0..<8 {
                let a = CGFloat(i) * .pi / 4
                var ray = Path()
                ray.move(to: CGPoint(x: pt(0.5, 0.5).x + cos(a) * 0.26 * w, y: pt(0.5, 0.5).y + sin(a) * 0.26 * h))
                ray.addLine(to: CGPoint(x: pt(0.5, 0.5).x + cos(a) * 0.4 * w, y: pt(0.5, 0.5).y + sin(a) * 0.4 * h))
                stroke(context, ray, lineWidth * 0.85)
            }

        case .moon:
            var p = Path()
            p.move(to: pt(0.62, 0.1))
            p.addCurve(to: pt(0.62, 0.9), control1: pt(0.2, 0.26), control2: pt(0.2, 0.74))
            p.addCurve(to: pt(0.62, 0.1), control1: pt(0.42, 0.72), control2: pt(0.42, 0.28))
            p.closeSubpath()
            stroke(context, p)

        case .shield:
            var p = Path()
            p.move(to: pt(0.5, 0.06))
            p.addLine(to: pt(0.88, 0.22))
            p.addCurve(to: pt(0.5, 0.94), control1: pt(0.88, 0.62), control2: pt(0.72, 0.84))
            p.addCurve(to: pt(0.12, 0.22), control1: pt(0.28, 0.84), control2: pt(0.12, 0.62))
            p.closeSubpath()
            stroke(context, p)

        case .reset:
            var p = Path()
            p.addArc(center: pt(0.5, 0.5), radius: 0.34 * min(w, h),
                     startAngle: .degrees(30), endAngle: .degrees(300), clockwise: false)
            stroke(context, p)
            var arrow = Path()
            arrow.move(to: pt(0.78, 0.18))
            arrow.addLine(to: pt(0.82, 0.4))
            arrow.addLine(to: pt(0.6, 0.36))
            fill(context, arrow)
        }
    }
}
