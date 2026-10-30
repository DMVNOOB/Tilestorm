public enum SoloGameError: Error, Equatable {
    case tilesStillOnRack
    case boardInvalid([BoardProblem])
    case notEnoughTilesToSwap
    case unknownTile(Tile.ID)
    case gameFinished
}

public enum DrawResult: Equatable, Sendable {
    case drew(Tile)
    /// The bag was empty and every tile formed a valid grid: the game is won.
    case finished
}

/// A single-player practice game: one bag, one player.
public struct SoloGame: Sendable {
    /// Tiles drawn in exchange for the one returned by a swap.
    public static let swapDrawCount = 3

    public private(set) var bag: TileBag
    public private(set) var player: PlayerTiles
    public private(set) var isFinished = false
    public let wordList: WordList

    public init<G: RandomNumberGenerator>(
        distribution: [Character: Int] = TileDistribution.standard,
        wordList: WordList = .enable,
        using generator: inout G
    ) {
        var bag = TileBag(distribution: distribution, using: &generator)
        let handSize = min(StartingHand.size(forPlayers: 1), bag.count)
        player = PlayerTiles(rack: try! bag.draw(handSize))
        self.bag = bag
        self.wordList = wordList
    }

    public init(distribution: [Character: Int] = TileDistribution.standard, wordList: WordList = .enable) {
        var generator = SystemRandomNumberGenerator()
        self.init(distribution: distribution, wordList: wordList, using: &generator)
    }

    public var boardProblems: [BoardProblem] {
        player.board.problems(using: wordList)
    }

    /// Drawing (or finishing, once the bag is empty) needs every tile placed in a valid grid.
    public var canDraw: Bool {
        !isFinished && player.rack.isEmpty && boardProblems.isEmpty
    }

    public var canSwap: Bool {
        !isFinished && bag.count >= Self.swapDrawCount
    }

    public mutating func put(_ tileID: Tile.ID, at cell: GridPosition) throws(SoloGameError) {
        guard !isFinished else { throw .gameFinished }
        do {
            try player.put(tileID, at: cell)
        } catch {
            throw .unknownTile(tileID)
        }
    }

    public mutating func returnToRack(_ tileID: Tile.ID) throws(SoloGameError) {
        guard !isFinished else { throw .gameFinished }
        do {
            try player.returnToRack(tileID)
        } catch {
            throw .unknownTile(tileID)
        }
    }

    /// Takes one tile from the bag onto the rack, or finishes the game if the bag is empty.
    @discardableResult
    public mutating func draw() throws(SoloGameError) -> DrawResult {
        guard !isFinished else { throw .gameFinished }
        guard player.rack.isEmpty else { throw .tilesStillOnRack }
        let problems = boardProblems
        guard problems.isEmpty else { throw .boardInvalid(problems) }
        guard let drawn = try? bag.draw(1) else {
            isFinished = true
            return .finished
        }
        player.addToRack(drawn)
        return .drew(drawn[0])
    }

    /// Returns a tile to the bag, reshuffles, and draws three onto the rack. Returns the tiles drawn.
    @discardableResult
    public mutating func swap<G: RandomNumberGenerator>(
        _ tileID: Tile.ID,
        using generator: inout G
    ) throws(SoloGameError) -> [Tile] {
        guard !isFinished else { throw .gameFinished }
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
