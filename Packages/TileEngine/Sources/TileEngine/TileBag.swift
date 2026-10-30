public enum TileBagError: Error, Equatable {
    case notEnoughTiles(requested: Int, available: Int)
}

/// The shuffled pool of face-down tiles players draw from.
public struct TileBag: Sendable {
    public private(set) var tiles: [Tile]

    public init<G: RandomNumberGenerator>(
        distribution: [Character: Int] = TileDistribution.standard,
        using generator: inout G
    ) {
        var tiles: [Tile] = []
        // Sort so tile ids are stable for a given distribution, independent of dictionary order.
        for (letter, count) in distribution.sorted(by: { $0.key < $1.key }) {
            for _ in 0..<count {
                tiles.append(Tile(id: tiles.count, letter: letter))
            }
        }
        tiles.shuffle(using: &generator)
        self.tiles = tiles
    }

    /// A bag holding exactly these tiles, drawn from the end. Useful for set-up game states.
    public init(tiles: [Tile]) {
        self.tiles = tiles
    }

    public init(distribution: [Character: Int] = TileDistribution.standard) {
        var generator = SystemRandomNumberGenerator()
        self.init(distribution: distribution, using: &generator)
    }

    public var count: Int { tiles.count }
    public var isEmpty: Bool { tiles.isEmpty }

    /// Removes `count` tiles from the bag. Draws nothing if the bag can't cover the request.
    public mutating func draw(_ count: Int) throws(TileBagError) -> [Tile] {
        guard count <= tiles.count else {
            throw .notEnoughTiles(requested: count, available: tiles.count)
        }
        let drawn = Array(tiles.suffix(count))
        tiles.removeLast(count)
        return drawn
    }

    /// Puts tiles back and reshuffles, as when a player dumps a tile.
    public mutating func putBack<G: RandomNumberGenerator>(_ returned: [Tile], using generator: inout G) {
        tiles.append(contentsOf: returned)
        tiles.shuffle(using: &generator)
    }

    public mutating func putBack(_ returned: [Tile]) {
        var generator = SystemRandomNumberGenerator()
        putBack(returned, using: &generator)
    }
}
