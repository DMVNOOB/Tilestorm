/// A cell on the unbounded board. (0, 0) is where the first word usually goes;
/// rows grow downward and columns grow rightward, and both can go negative.
public struct GridPosition: Hashable, Sendable {
    public var row: Int
    public var column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

public enum BoardError: Error, Equatable {
    case cellOccupied(GridPosition)
    case cellEmpty(GridPosition)
    case tileAlreadyOnBoard(Tile.ID)
}

/// One player's personal crossword grid.
public struct Board: Sendable {
    public private(set) var tiles: [GridPosition: Tile] = [:]

    public init() {}

    public var isEmpty: Bool { tiles.isEmpty }

    public func tile(at position: GridPosition) -> Tile? {
        tiles[position]
    }

    public func position(of tileID: Tile.ID) -> GridPosition? {
        tiles.first { $0.value.id == tileID }?.key
    }

    public mutating func place(_ tile: Tile, at cell: GridPosition) throws(BoardError) {
        guard tiles[cell] == nil else { throw .cellOccupied(cell) }
        guard position(of: tile.id) == nil else { throw .tileAlreadyOnBoard(tile.id) }
        tiles[cell] = tile
    }

    @discardableResult
    public mutating func remove(at position: GridPosition) -> Tile? {
        tiles.removeValue(forKey: position)
    }

    public mutating func move(from source: GridPosition, to destination: GridPosition) throws(BoardError) {
        guard source != destination else { return }
        guard let tile = tiles[source] else { throw .cellEmpty(source) }
        guard tiles[destination] == nil else { throw .cellOccupied(destination) }
        tiles[source] = nil
        tiles[destination] = tile
    }

    public mutating func swap(_ first: GridPosition, _ second: GridPosition) throws(BoardError) {
        guard let firstTile = tiles[first] else { throw .cellEmpty(first) }
        guard let secondTile = tiles[second] else { throw .cellEmpty(second) }
        tiles[first] = secondTile
        tiles[second] = firstTile
    }
}
