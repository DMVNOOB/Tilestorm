import SwiftUI

/// Raised game buttons from the design. The face presses down onto its edge when tapped.
struct GameButtonStyle: ButtonStyle {
    enum Kind {
        case primary, secondary
    }

    var kind: Kind = .primary

    func makeBody(configuration: Configuration) -> some View {
        GameButtonBody(configuration: configuration, kind: kind)
    }
}

private struct GameButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: GameButtonStyle.Kind
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(GameFont.display(22, relativeTo: .title3))
            .kerning(0.4)
            .foregroundStyle(Color.cocoa.opacity(isEnabled ? 1 : 0.4))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background {
                RaisedBackground(
                    face: face,
                    edge: isEnabled ? edge : .disabledEdge,
                    lift: pressed ? 1 : (isEnabled ? 5 : 4),
                    cornerRadius: 20,
                    castsShadow: isEnabled
                )
            }
            .offset(y: pressed ? 4 : 0)
            .animation(.snappy(duration: 0.12), value: pressed)
    }

    private var face: Color {
        guard isEnabled else { return Color.sand.opacity(0.55) }
        return kind == .primary ? .honey : .sand
    }

    private var edge: Color {
        kind == .primary ? .honeyEdge : .tan
    }
}

/// Small square raised button for icons, like Pause.
struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .black))
            .foregroundStyle(Color.cocoa)
            .frame(width: 44, height: 44)
            .background {
                RaisedBackground(face: .sand, edge: .tan, lift: configuration.isPressed ? 1 : 4, cornerRadius: 14)
            }
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
    }
}
