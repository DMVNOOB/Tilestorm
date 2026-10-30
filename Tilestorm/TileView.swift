import SwiftUI
import TileEngine

struct TileView: View {
    let tile: Tile
    var size: CGFloat = 44
    var isSelected = false

    var body: some View {
        Text(String(tile.letter))
            .font(.system(size: size * 0.55, weight: .semibold, design: .rounded))
            .frame(width: size, height: size)
            .background(Color.tileFace, in: .rect(cornerRadius: size * 0.18))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.18)
                    .strokeBorder(isSelected ? Color.accentColor : .black.opacity(0.15), lineWidth: isSelected ? 3 : 1)
            }
            .foregroundStyle(.black)
            .accessibilityLabel("Tile \(String(tile.letter))")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension Color {
    static let tileFace = Color(red: 0.96, green: 0.93, blue: 0.86)
}
