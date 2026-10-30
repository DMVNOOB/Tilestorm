import SwiftUI
import TileEngine

/// An unbounded grid that pans with a drag and zooms with a pinch.
/// Pan offset is kept in unscaled board points so zooming stays centred on the middle of the view.
struct BoardView: View {
    let board: Board
    let onTapCell: (GridPosition) -> Void

    static let cellSize: CGFloat = 44
    private static let scaleRange: ClosedRange<CGFloat> = 0.4...2.5

    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let currentScale = Self.clamp(scale * pinchScale)
            let currentOffset = CGSize(
                width: offset.width + dragTranslation.width / currentScale,
                height: offset.height + dragTranslation.height / currentScale
            )
            let step = Self.cellSize * currentScale
            // Screen location of the centre of cell (0, 0).
            let origin = CGPoint(
                x: geometry.size.width / 2 + currentOffset.width * currentScale,
                y: geometry.size.height / 2 + currentOffset.height * currentScale
            )

            ZStack {
                GridLines(origin: origin, step: step)

                ForEach(Array(board.tiles), id: \.value.id) { cell, tile in
                    TileView(tile: tile, size: step - 2)
                        .position(
                            x: origin.x + CGFloat(cell.column) * step,
                            y: origin.y + CGFloat(cell.row) * step
                        )
                }
            }
            .contentShape(.rect)
            .onTapGesture { location in
                onTapCell(GridPosition(
                    row: Int(((location.y - origin.y) / step).rounded()),
                    column: Int(((location.x - origin.x) / step).rounded())
                ))
            }
            .gesture(
                DragGesture()
                    .updating($dragTranslation) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        offset.width += value.translation.width / currentScale
                        offset.height += value.translation.height / currentScale
                    }
                    .simultaneously(with:
                        MagnifyGesture()
                            .updating($pinchScale) { value, state, _ in state = value.magnification }
                            .onEnded { value in scale = Self.clamp(scale * value.magnification) }
                    )
            )
        }
        .background(Color(.secondarySystemBackground))
        .clipped()
        .accessibilityLabel("Board")
    }

    private static func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, scaleRange.lowerBound), scaleRange.upperBound)
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
