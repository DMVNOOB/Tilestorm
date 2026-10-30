import CoreGraphics
import TileEngine

/// Maps between board cells and points in the board view.
/// The pan offset is kept in unscaled board points so zooming stays centred on the middle of the view.
struct BoardCamera {
    static let cellSize: CGFloat = 44
    static let scaleRange: ClosedRange<CGFloat> = 0.4...2.5

    var offset: CGSize = .zero
    /// Starts zoomed out so there's room to see where words could go.
    var scale: CGFloat = 0.6

    var step: CGFloat { Self.cellSize * scale }

    /// The camera with an in-progress drag (in screen points) and pinch applied.
    func adjusted(pan translation: CGSize, pinch magnification: CGFloat) -> BoardCamera {
        let newScale = min(max(scale * magnification, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
        return BoardCamera(
            offset: CGSize(
                width: offset.width + translation.width / newScale,
                height: offset.height + translation.height / newScale
            ),
            scale: newScale
        )
    }

    func center(of cell: GridPosition, in size: CGSize) -> CGPoint {
        let origin = origin(in: size)
        return CGPoint(x: origin.x + CGFloat(cell.column) * step, y: origin.y + CGFloat(cell.row) * step)
    }

    func cell(at point: CGPoint, in size: CGSize) -> GridPosition {
        let origin = origin(in: size)
        return GridPosition(
            row: Int(((point.y - origin.y) / step).rounded()),
            column: Int(((point.x - origin.x) / step).rounded())
        )
    }

    /// Where the centre of cell (0, 0) sits in the view.
    func origin(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2 + offset.width * scale, y: size.height / 2 + offset.height * scale)
    }
}
