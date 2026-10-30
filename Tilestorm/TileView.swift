import SwiftUI
import TileEngine

struct TileView: View {
    let tile: Tile
    var size: CGFloat = 44
    var isSelected = false
    /// Part of a word that isn't in the word list.
    var isInvalid = false

    var body: some View {
        Text(String(tile.letter))
            .font(.system(size: size * 0.55, weight: .semibold, design: .rounded))
            .frame(width: size, height: size)
            .background(Color.tileFace, in: .rect(cornerRadius: size * 0.18))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.18)
                    .strokeBorder(borderColor, lineWidth: isSelected || isInvalid ? 3 : 1)
            }
            .foregroundStyle(.black)
            .accessibilityLabel("Tile \(String(tile.letter))")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityValue(isInvalid ? "Not in a valid word" : "")
    }

    private var borderColor: Color {
        if isSelected { return .accentColor }
        if isInvalid { return .red }
        return .black.opacity(0.15)
    }
}

extension Color {
    static let tileFace = Color(red: 0.96, green: 0.93, blue: 0.86)
}
