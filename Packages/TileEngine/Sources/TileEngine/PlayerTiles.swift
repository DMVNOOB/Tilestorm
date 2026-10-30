public enum PlayerTilesError: Error, Equatable {
    case unknownTile(Tile.ID)
}

/// The tiles one player holds: unplaced ones on the rack and placed ones on their board.
public struct PlayerTiles: Sendable {
    public private(set) var rack: [Tile]
    public private(set) var board: Board

    public init(rack: [Tile] = [], board: Board = Board()) {
        self.rack = rack
        self.board = board
    }

    public mutating func addToRack(_ tiles: [Tile]) {
        rack.append(contentsOf: tiles)
    }

    /// Puts a tile on `cell`, whether it's coming from the rack or elsewhere on the board.
    /// A tile already on `cell` trades places with it: back to the rack or to the moving tile's old cell.
    public mutating func put(_ tileID: Tile.ID, at cell: GridPosition) throws(PlayerTilesError) {
        // The Board calls below can't fail: each cell was checked just before.
        if let source = board.position(of: tileID) {
            if board.tile(at: cell) == nil {
                try! board.move(from: source, to: cell)
            } else if source != cell {
                try! board.swap(source, cell)
            }
        } else if let index = rack.firstIndex(where: { $0.id == tileID }) {
            let tile = rack.remove(at: index)
            if let displaced = board.remove(at: cell) {
                rack.insert(displaced, at: index)
            }
            try! board.place(tile, at: cell)
        } else {
            throw .unknownTile(tileID)
        }
    }

    /// Takes a tile off the board and puts it at the end of the rack. Does nothing if it's already on the rack.
    public mutating func returnToRack(_ tileID: Tile.ID) throws(PlayerTilesError) {
        guard let cell = board.position(of: tileID) else {
            guard rack.contains(where: { $0.id == tileID }) else { throw .unknownTile(tileID) }
            return
        }
        rack.append(board.remove(at: cell)!)
    }
}
