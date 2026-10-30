public enum SoloGameError: Error, Equatable {
    case tilesStillOnRack
    case bagEmpty
    case notEnoughTilesToSwap
    case unknownTile(Tile.ID)
}

/// A single-player practice game: one bag, one player.
public struct SoloGame: Sendable {
    /// Tiles drawn in exchange for the one returned by a swap.
    public static let swapDrawCount = 3

    public private(set) var bag: TileBag
    public private(set) var player: PlayerTiles

    public init<G: RandomNumberGenerator>(
        distribution: [Character: Int] = TileDistribution.standard,
        using generator: inout G
    ) {
        var bag = TileBag(distribution: distribution, using: &generator)
        let handSize = min(StartingHand.size(forPlayers: 1), bag.count)
        player = PlayerTiles(rack: try! bag.draw(handSize))
        self.bag = bag
    }

    public init(distribution: [Character: Int] = TileDistribution.standard) {
        var generator = SystemRandomNumberGenerator()
        self.init(distribution: distribution, using: &generator)
    }

    /// Drawing is only allowed once every tile in hand is on the board.
    public var canDraw: Bool { player.rack.isEmpty && !bag.isEmpty }
    public var canSwap: Bool { bag.count >= Self.swapDrawCount }

    public mutating func put(_ tileID: Tile.ID, at cell: GridPosition) throws(PlayerTilesError) {
        try player.put(tileID, at: cell)
    }

    public mutating func returnToRack(_ tileID: Tile.ID) throws(PlayerTilesError) {
        try player.returnToRack(tileID)
    }

    /// Takes one tile from the bag onto the rack. Returns the tile drawn.
    @discardableResult
    public mutating func draw() throws(SoloGameError) -> Tile {
        guard player.rack.isEmpty else { throw .tilesStillOnRack }
        guard let drawn = try? bag.draw(1) else { throw .bagEmpty }
        player.addToRack(drawn)
        return drawn[0]
    }

    /// Returns a tile to the bag, reshuffles, and draws three onto the rack. Returns the tiles drawn.
    @discardableResult
    public mutating func swap<G: RandomNumberGenerator>(
        _ tileID: Tile.ID,
        using generator: inout G
    ) throws(SoloGameError) -> [Tile] {
        guard canSwap else { throw .notEnoughTilesToSwap }
        let returned: Tile
        do {
            returned = try player.remove(tileID)
        } catch {
            throw .unknownTile(tileID)
        }
        bag.putBack([returned], using: &generator)
        let drawn = try! bag.draw(Self.swapDrawCount)
        player.addToRack(drawn)
        return drawn
    }

    @discardableResult
    public mutating func swap(_ tileID: Tile.ID) throws(SoloGameError) -> [Tile] {
        var generator = SystemRandomNumberGenerator()
        return try swap(tileID, using: &generator)
    }
}
