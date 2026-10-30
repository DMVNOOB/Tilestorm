import SwiftUI
import TileEngine

struct TileView: View {
    let tile: Tile
    var size: CGFloat = 44
    var isSelected = false
    /// Part of a word that isn't in the word list.
    var isInvalid = false

    var body: some View {
        // Proportions match the 56pt tile in the Figma design.
        let unit = size / 56
        Text(String(tile.letter))
            .font(GameFont.tile(size * 0.54))
            .foregroundStyle(isInvalid ? Color.terracotta : .cocoa)
            .frame(width: size, height: size)
            .background {
                RaisedBackground(
                    face: isSelected ? .butter : .cream,
                    edge: isSelected ? .mustard : (isInvalid ? .tan : .tileEdge),
                    lift: (isSelected ? 7 : 4) * unit,
                    cornerRadius: 12 * unit,
                    outline: isSelected ? .mustard : (isInvalid ? .terracotta : .tileOutline),
                    outlineWidth: (isSelected || isInvalid ? 3 : 1.5) * unit
                )
            }
            // A selected tile sits higher, as if picked up.
            .offset(y: isSelected ? -3 * unit : 0)
            .accessibilityLabel("Tile \(String(tile.letter))")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityValue(isInvalid ? "Not in a valid word" : "")
    }
}
