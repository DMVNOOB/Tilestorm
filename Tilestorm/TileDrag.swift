import SwiftUI
import TileEngine

/// Tiles are dragged across both the board and the rack, so drag locations are reported in one shared space.
enum GameSpace {
    static let name = "game"
}

struct TileDragHandlers {
    var changed: (Tile, CGPoint) -> Void
    var ended: (Tile, CGPoint) -> Void
}

extension View {
    func draggableTile(_ tile: Tile, handlers: TileDragHandlers) -> some View {
        gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .named(GameSpace.name))
                .onChanged { handlers.changed(tile, $0.location) }
                .onEnded { handlers.ended(tile, $0.location) }
        )
    }
}
