import SwiftUI
import TileEngine

/// An unbounded grid that pans with a drag on empty space and zooms with a pinch.
struct BoardView: View {
    let board: Board
    @Binding var camera: BoardCamera
    var selectedTileID: Tile.ID?
    var draggingTileID: Tile.ID?
    var invalidCells: Set<GridPosition> = []
    let dragHandlers: TileDragHandlers
    let onTapCell: (GridPosition) -> Void
    let onDoubleTapTile: (Tile) -> Void

    @GestureState private var panTranslation: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let live = camera.adjusted(pan: panTranslation, pinch: pinchScale)

            ZStack {
                GridDots(origin: live.origin(in: geometry.size), step: live.step)

                ForEach(Array(board.tiles), id: \.value.id) { cell, tile in
                    TileView(
                        tile: tile,
                        size: live.step - 2,
                        isSelected: tile.id == selectedTileID,
                        isInvalid: invalidCells.contains(cell)
                    )
                        .opacity(tile.id == draggingTileID ? 0.3 : 1)
                        // Double-tap must be declared before single-tap so SwiftUI tells them apart.
                        .onTapGesture(count: 2) { onDoubleTapTile(tile) }
                        .onTapGesture { onTapCell(cell) }
                        .draggableTile(tile, handlers: dragHandlers)
                        .accessibilityHint("Double-tap to return it to the rack")
                        .position(live.center(of: cell, in: geometry.size))
                }
            }
            .contentShape(.rect)
            .onTapGesture { location in
                onTapCell(live.cell(at: location, in: geometry.size))
            }
            .gesture(
                DragGesture()
                    .updating($panTranslation) { value, state, _ in state = value.translation }
                    .onEnded { value in camera = camera.adjusted(pan: value.translation, pinch: 1) }
                    .simultaneously(with:
                        MagnifyGesture()
                            .updating($pinchScale) { value, state, _ in state = value.magnification }
                            .onEnded { value in camera = camera.adjusted(pan: .zero, pinch: value.magnification) }
                    )
            )
        }
        .background(Color.sand.shadow(.inner(color: .toffee.opacity(0.25), radius: 8, y: 3)))
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .accessibilityLabel("Board")
    }
}

/// A dot at the centre of every cell, where tiles land.
private struct GridDots: View {
    let origin: CGPoint
    let step: CGFloat

    var body: some View {
        Canvas { context, size in
            let radius: CGFloat = 2
            var dots = Path()
            var x = origin.x.truncatingRemainder(dividingBy: step)
            if x < 0 { x += step }
            while x <= size.width {
                var y = origin.y.truncatingRemainder(dividingBy: step)
                if y < 0 { y += step }
                while y <= size.height {
                    dots.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                    y += step
                }
                x += step
            }
            context.fill(dots, with: .color(.tan.opacity(0.5)))
        }
    }
}
