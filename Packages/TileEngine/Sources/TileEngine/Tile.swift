/// A single physical letter tile. `id` is unique within a game so two tiles
/// with the same letter can still be told apart on the board.
public struct Tile: Identifiable, Hashable, Sendable {
    public let id: Int
    public let letter: Character

    public init(id: Int, letter: Character) {
        self.id = id
        self.letter = letter
    }
}

public enum TileDistribution {
    /// The traditional 144-tile set.
    public static let standard: [Character: Int] = [
        "A": 13, "B": 3, "C": 3, "D": 6, "E": 18, "F": 3, "G": 4, "H": 3, "I": 12,
        "J": 2, "K": 2, "L": 5, "M": 3, "N": 8, "O": 11, "P": 3, "Q": 2, "R": 9,
        "S": 6, "T": 9, "U": 6, "V": 3, "W": 3, "X": 2, "Y": 3, "Z": 2,
    ]
}

public enum StartingHand {
    /// Traditional starting tile counts: 21 for 1–4 players, 15 for 5–6, 11 for 7–8.
    public static func size(forPlayers players: Int) -> Int {
        precondition((1...8).contains(players), "Supported player counts are 1–8")
        switch players {
        case 1...4: return 21
        case 5...6: return 15
        default: return 11
        }
    }
}
