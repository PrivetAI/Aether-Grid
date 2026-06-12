import SwiftUI

enum Theme {
    static let indigoDeep = Color(red: 0.09, green: 0.07, blue: 0.20)
    static let indigo     = Color(red: 0.13, green: 0.10, blue: 0.27)
    static let obsidian   = Color(red: 0.03, green: 0.03, blue: 0.07)
    static let panel      = Color(red: 0.11, green: 0.10, blue: 0.21)
    static let panelHi    = Color(red: 0.17, green: 0.15, blue: 0.30)
    static let gold       = Color(red: 0.86, green: 0.72, blue: 0.36)
    static let goldDim    = Color(red: 0.55, green: 0.46, blue: 0.24)
    static let text       = Color(red: 0.93, green: 0.92, blue: 0.98)
    static let textDim    = Color(red: 0.62, green: 0.60, blue: 0.74)

    // Element colors
    static let ember   = Color(red: 1.00, green: 0.45, blue: 0.14)
    static let aqua    = Color(red: 0.22, green: 0.74, blue: 0.95)
    static let frost   = Color(red: 0.60, green: 0.93, blue: 0.96)
    static let storm   = Color(red: 0.98, green: 0.86, blue: 0.30)
    static let poison  = Color(red: 0.64, green: 0.34, blue: 0.86)
    static let vine    = Color(red: 0.36, green: 0.78, blue: 0.42)
    static let earth   = Color(red: 0.66, green: 0.52, blue: 0.34)
    static let steam   = Color(red: 0.78, green: 0.82, blue: 0.86)
    static let voidc   = Color(red: 0.42, green: 0.30, blue: 0.58)

    static let danger  = Color(red: 0.90, green: 0.32, blue: 0.36)
    static let success = Color(red: 0.42, green: 0.82, blue: 0.50)

    static func panelStroke(_ opacity: Double = 0.45) -> Color { gold.opacity(opacity) }
}

struct PanelBackground: ViewModifier {
    var corner: CGFloat = 16
    var stroke: Double = 0.4
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: corner)
                    .fill(Theme.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner)
                    .stroke(Theme.gold.opacity(stroke), lineWidth: 1)
            )
    }
}

extension View {
    func runePanel(corner: CGFloat = 16, stroke: Double = 0.4) -> some View {
        modifier(PanelBackground(corner: corner, stroke: stroke))
    }
    func clampedWidth() -> some View {
        modifier(ClampWidth())
    }
}

// Clamps content width so iPad never reports a width wider than the visible area,
// preventing right-edge cropping (Guideline 4.0).
struct ClampWidth: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geo in
            let w = min(geo.size.width, UIScreen.main.bounds.width)
            HStack {
                Spacer(minLength: 0)
                content.frame(width: w)
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct GoldButtonStyle: ButtonStyle {
    var filled: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .serif))
            .foregroundColor(filled ? Theme.obsidian : Theme.gold)
            .padding(.vertical, 12)
            .padding(.horizontal, 22)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(filled ? Theme.gold : Theme.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.gold, lineWidth: filled ? 0 : 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
