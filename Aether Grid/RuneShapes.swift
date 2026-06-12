import SwiftUI

// MARK: - Element glyph (a small custom shape per element kind)

struct ElementGlyph: View {
    let kind: ElementKind
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            switch kind {
            case .fire:
                FlameShape().fill(Theme.ember)
            case .oil:
                Capsule().fill(Color.black.opacity(0.85))
                    .overlay(Capsule().stroke(Theme.ember.opacity(0.5), lineWidth: 1))
            case .water:
                DropShape().fill(Theme.aqua)
            case .ice:
                SnowflakeShape().stroke(Theme.frost, lineWidth: max(1, size * 0.08))
            case .charge:
                BoltShape().fill(Theme.storm)
            case .poison:
                CloudShape().fill(Theme.poison)
            case .vines:
                VineShape().stroke(Theme.vine, lineWidth: max(1.4, size * 0.10))
            case .steam:
                CloudShape().fill(Theme.steam.opacity(0.8))
            case .voidd:
                VoidShape().fill(Theme.voidc)
            }
        }
        .frame(width: size, height: size)
    }
}

struct FlameShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + h*0.65),
                       control: CGPoint(x: r.maxX, y: r.minY + h*0.25))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.maxY),
                       control: CGPoint(x: r.maxX - w*0.1, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.minY + h*0.65),
                       control: CGPoint(x: r.minX + w*0.1, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY),
                       control: CGPoint(x: r.minX, y: r.minY + h*0.25))
        p.closeSubpath()
        return p
    }
}

struct DropShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY + r.height*0.6),
                       control: CGPoint(x: r.maxX, y: r.minY + r.height*0.35))
        p.addArc(center: CGPoint(x: r.midX, y: r.minY + r.height*0.65),
                 radius: r.width*0.5, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY),
                       control: CGPoint(x: r.minX, y: r.minY + r.height*0.35))
        p.closeSubpath()
        return p
    }
}

struct SnowflakeShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        let rad = min(r.width, r.height) * 0.5
        for i in 0..<6 {
            let a = CGFloat(i) / 6 * .pi * 2
            p.move(to: c)
            p.addLine(to: CGPoint(x: c.x + cos(a)*rad, y: c.y + sin(a)*rad))
            // small barbs
            let mid = CGPoint(x: c.x + cos(a)*rad*0.6, y: c.y + sin(a)*rad*0.6)
            p.move(to: mid)
            p.addLine(to: CGPoint(x: mid.x + cos(a+0.6)*rad*0.25, y: mid.y + sin(a+0.6)*rad*0.25))
            p.move(to: mid)
            p.addLine(to: CGPoint(x: mid.x + cos(a-0.6)*rad*0.25, y: mid.y + sin(a-0.6)*rad*0.25))
        }
        return p
    }
}

struct BoltShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX + r.width*0.12, y: r.minY))
        p.addLine(to: CGPoint(x: r.minX + r.width*0.25, y: r.midY + r.height*0.05))
        p.addLine(to: CGPoint(x: r.midX, y: r.midY + r.height*0.05))
        p.addLine(to: CGPoint(x: r.minX + r.width*0.35, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX - r.width*0.2, y: r.midY - r.height*0.05))
        p.addLine(to: CGPoint(x: r.midX, y: r.midY - r.height*0.05))
        p.closeSubpath()
        return p
    }
}

struct CloudShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: r.minX, y: r.midY - r.height*0.1, width: r.width*0.5, height: r.height*0.5))
        p.addEllipse(in: CGRect(x: r.midX - r.width*0.15, y: r.minY + r.height*0.1, width: r.width*0.55, height: r.height*0.55))
        p.addEllipse(in: CGRect(x: r.midX, y: r.midY - r.height*0.05, width: r.width*0.5, height: r.height*0.5))
        p.addRect(CGRect(x: r.minX + r.width*0.1, y: r.midY + r.height*0.1, width: r.width*0.8, height: r.height*0.3))
        return p
    }
}

struct VineShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.midX, y: r.minY),
                   control1: CGPoint(x: r.maxX, y: r.midY + r.height*0.2),
                   control2: CGPoint(x: r.minX, y: r.midY - r.height*0.2))
        // leaves
        p.move(to: CGPoint(x: r.midX, y: r.midY + r.height*0.15))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.midY - r.height*0.05),
                       control: CGPoint(x: r.maxX, y: r.midY))
        p.move(to: CGPoint(x: r.midX, y: r.midY - r.height*0.2))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.midY - r.height*0.4),
                       control: CGPoint(x: r.minX, y: r.midY - r.height*0.3))
        return p
    }
}

struct VoidShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        let rad = min(r.width, r.height) * 0.5
        p.addArc(center: c, radius: rad, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        p.move(to: CGPoint(x: c.x + rad*0.5, y: c.y))
        p.addArc(center: c, radius: rad*0.5, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return p
    }
}

// MARK: - Element diamond (composite icon, used for branding)

struct ElementDiamondIcon: View {
    var size: CGFloat = 64
    var body: some View {
        ZStack {
            DiamondQuarter(corner: .top).fill(Theme.ember)
            DiamondQuarter(corner: .right).fill(Theme.aqua)
            DiamondQuarter(corner: .bottom).fill(Theme.poison)
            DiamondQuarter(corner: .left).fill(Theme.frost)
            DiamondOutline().stroke(Theme.gold, lineWidth: 2)
        }
        .frame(width: size, height: size)
    }
}

enum DiamondCorner { case top, right, bottom, left }

struct DiamondQuarter: Shape {
    let corner: DiamondCorner
    func path(in r: CGRect) -> Path {
        let c = CGPoint(x: r.midX, y: r.midY)
        let t = CGPoint(x: r.midX, y: r.minY)
        let rr = CGPoint(x: r.maxX, y: r.midY)
        let b = CGPoint(x: r.midX, y: r.maxY)
        let l = CGPoint(x: r.minX, y: r.midY)
        var p = Path()
        switch corner {
        case .top: p.move(to: c); p.addLine(to: t); p.addLine(to: rr)
        case .right: p.move(to: c); p.addLine(to: rr); p.addLine(to: b)
        case .bottom: p.move(to: c); p.addLine(to: b); p.addLine(to: l)
        case .left: p.move(to: c); p.addLine(to: l); p.addLine(to: t)
        }
        p.closeSubpath()
        return p
    }
}

struct DiamondOutline: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Generic UI rune glyphs (replacing SF Symbols)

struct ChevronGlyph: View {
    var size: CGFloat = 14
    var color: Color = Theme.gold
    var body: some View {
        ChevronShape().stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .frame(width: size*0.6, height: size)
    }
}
struct ChevronShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        return p
    }
}

struct StarGlyph: View {
    var size: CGFloat = 18
    var filled: Bool = true
    var body: some View {
        StarShape()
            .fill(filled ? Theme.gold : Color.clear)
            .overlay(StarShape().stroke(filled ? Theme.gold : Theme.goldDim, lineWidth: 1.5))
            .frame(width: size, height: size)
    }
}
struct StarShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: r.midX, y: r.midY)
        let outer = min(r.width, r.height)/2
        let inner = outer * 0.42
        for i in 0..<10 {
            let a = -CGFloat.pi/2 + CGFloat(i) * .pi/5
            let rad = i % 2 == 0 ? outer : inner
            let pt = CGPoint(x: c.x + cos(a)*rad, y: c.y + sin(a)*rad)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

struct CrossGlyph: View {
    var size: CGFloat = 16
    var color: Color = Theme.text
    var body: some View {
        ZStack {
            Capsule().fill(color).frame(width: size, height: size*0.16)
                .rotationEffect(.degrees(45))
            Capsule().fill(color).frame(width: size, height: size*0.16)
                .rotationEffect(.degrees(-45))
        }.frame(width: size, height: size)
    }
}

struct HeartGlyph: View {
    var size: CGFloat = 14
    var color: Color = Theme.danger
    var body: some View {
        HeartShape().fill(color).frame(width: size, height: size)
    }
}
struct HeartShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.minX, y: r.minY + r.height*0.3),
                   control1: CGPoint(x: r.minX + r.width*0.1, y: r.maxY - r.height*0.3),
                   control2: CGPoint(x: r.minX, y: r.minY + r.height*0.6))
        p.addArc(center: CGPoint(x: r.minX + r.width*0.25, y: r.minY + r.height*0.3),
                 radius: r.width*0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addArc(center: CGPoint(x: r.minX + r.width*0.75, y: r.minY + r.height*0.3),
                 radius: r.width*0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: r.midX, y: r.maxY),
                   control1: CGPoint(x: r.maxX, y: r.minY + r.height*0.6),
                   control2: CGPoint(x: r.maxX - r.width*0.1, y: r.maxY - r.height*0.3))
        p.closeSubpath()
        return p
    }
}

struct FlaskGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.aqua
    var body: some View {
        FlaskShape().fill(color.opacity(0.85))
            .overlay(FlaskShape().stroke(Theme.gold.opacity(0.7), lineWidth: 1))
            .frame(width: size, height: size)
    }
}
struct FlaskShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let neckW = r.width*0.28
        p.move(to: CGPoint(x: r.midX - neckW/2, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX - neckW/2, y: r.minY + r.height*0.35))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY - r.height*0.08))
        p.addQuadCurve(to: CGPoint(x: r.minX + r.width*0.1, y: r.maxY),
                       control: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX - r.width*0.1, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.maxY - r.height*0.08),
                       control: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.midX + neckW/2, y: r.minY + r.height*0.35))
        p.addLine(to: CGPoint(x: r.midX + neckW/2, y: r.minY))
        p.closeSubpath()
        return p
    }
}

struct RuneCircleGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.gold
    var body: some View {
        ZStack {
            Circle().stroke(color, lineWidth: max(1, size*0.06))
            ForEach(0..<6) { i in
                Rectangle().fill(color)
                    .frame(width: max(1, size*0.05), height: size*0.18)
                    .offset(y: -size*0.34)
                    .rotationEffect(.degrees(Double(i)*60))
            }
        }.frame(width: size, height: size)
    }
}

struct GearGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.gold
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                Rectangle().fill(color)
                    .frame(width: size*0.16, height: size*0.28)
                    .offset(y: -size*0.4)
                    .rotationEffect(.degrees(Double(i)*45))
            }
            Circle().stroke(color, lineWidth: max(1.5, size*0.1)).frame(width: size*0.55, height: size*0.55)
        }.frame(width: size, height: size)
    }
}

struct BookGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.gold
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size*0.08).stroke(color, lineWidth: max(1.2, size*0.07))
                .frame(width: size*0.8, height: size*0.95)
            Rectangle().fill(color).frame(width: max(1, size*0.05), height: size*0.85)
        }.frame(width: size, height: size)
    }
}

struct TrophyGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.gold
    var body: some View {
        ZStack {
            TrophyShape().fill(color).frame(width: size*0.8, height: size*0.8)
        }.frame(width: size, height: size)
    }
}
struct TrophyShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX + r.width*0.25, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - r.width*0.25, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - r.width*0.25, y: r.minY + r.height*0.4))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.minY + r.height*0.62),
                       control: CGPoint(x: r.midX, y: r.minY + r.height*0.6))
        p.addQuadCurve(to: CGPoint(x: r.minX + r.width*0.25, y: r.minY + r.height*0.4),
                       control: CGPoint(x: r.midX, y: r.minY + r.height*0.6))
        p.closeSubpath()
        p.addRect(CGRect(x: r.midX - r.width*0.06, y: r.minY + r.height*0.6, width: r.width*0.12, height: r.height*0.22))
        p.addRect(CGRect(x: r.minX + r.width*0.2, y: r.maxY - r.height*0.12, width: r.width*0.6, height: r.height*0.12))
        return p
    }
}

struct ChartGlyph: View {
    var size: CGFloat = 22
    var color: Color = Theme.gold
    var body: some View {
        HStack(alignment: .bottom, spacing: size*0.12) {
            Rectangle().fill(color).frame(width: size*0.18, height: size*0.45)
            Rectangle().fill(color).frame(width: size*0.18, height: size*0.8)
            Rectangle().fill(color).frame(width: size*0.18, height: size*0.6)
        }.frame(width: size, height: size, alignment: .bottom)
    }
}

struct LockGlyph: View {
    var size: CGFloat = 18
    var color: Color = Theme.textDim
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: size*0.2).stroke(color, lineWidth: max(1, size*0.1))
                .frame(width: size*0.5, height: size*0.5)
                .offset(y: size*0.18)
            RoundedRectangle(cornerRadius: size*0.12).fill(color)
                .frame(width: size*0.7, height: size*0.55)
        }.frame(width: size, height: size)
    }
}

struct SwordGlyph: View {
    var size: CGFloat = 18
    var color: Color = Theme.gold
    var body: some View {
        SwordShape().fill(color).frame(width: size, height: size)
    }
}
struct SwordShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX + r.width*0.1, y: r.maxY - r.height*0.35))
        p.addLine(to: CGPoint(x: r.midX - r.width*0.1, y: r.maxY - r.height*0.35))
        p.closeSubpath()
        p.addRect(CGRect(x: r.minX + r.width*0.2, y: r.maxY - r.height*0.35, width: r.width*0.6, height: r.height*0.1))
        p.addRect(CGRect(x: r.midX - r.width*0.06, y: r.maxY - r.height*0.25, width: r.width*0.12, height: r.height*0.25))
        return p
    }
}

struct ShieldGlyph: View {
    var size: CGFloat = 18
    var color: Color = Theme.aqua
    var body: some View {
        ShieldShape().fill(color.opacity(0.9))
            .overlay(ShieldShape().stroke(Theme.gold.opacity(0.6), lineWidth: 1))
            .frame(width: size, height: size)
    }
}
struct ShieldShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY + r.height*0.2))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.maxY),
                       control: CGPoint(x: r.maxX, y: r.maxY - r.height*0.1))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.midY),
                       control: CGPoint(x: r.minX, y: r.maxY - r.height*0.1))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + r.height*0.2))
        p.closeSubpath()
        return p
    }
}
