import SwiftUI
import TileEngine

/// An unbounded grid that pans with a drag on empty space and zooms with a pinch.
struct BoardView: View {
    let board: Board
    @Binding var camera: BoardCamera
    var draggingTileID: Tile.ID?
    var invalidCells: Set<GridPosition> = []
    let dragHandlers: TileDragHandlers
    let onTapCell: (GridPosition) -> Void

    @GestureState private var panTranslation: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let live = camera.adjusted(pan: panTranslation, pinch: pinchScale)

            ZStack {
                GridLines(origin: live.origin(in: geometry.size), step: live.step)

                ForEach(Array(board.tiles), id: \.value.id) { cell, tile in
                    TileView(tile: tile, size: live.step - 2, isInvalid: invalidCells.contains(cell))
                        .opacity(tile.id == draggingTileID ? 0.3 : 1)
                        .draggableTile(tile, handlers: dragHandlers)
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
        .background(Color(.secondarySystemBackground))
        .clipped()
        .accessibilityLabel("Board")
    }
}

private struct GridLines: View {
    let origin: CGPoint
    let step: CGFloat

    var body: some View {
        Canvas { context, size in
            var path = Path()
            // Lines sit half a cell either side of each cell centre.
            var x = (origin.x - step / 2).truncatingRemainder(dividingBy: step)
            if x < 0 { x += step }
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y = (origin.y - step / 2).truncatingRemainder(dividingBy: step)
            if y < 0 { y += step }
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(path, with: .color(.primary.opacity(0.08)), lineWidth: 1)
        }
    }
}
