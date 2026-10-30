#if DEBUG
import Foundation
import TileEngine

/// Ready-made game states for trying things without playing up to them. Debug builds only.
/// Launch straight into one with the argument `-scenario <rawValue>`, e.g. `-scenario readyToFinish`.
enum Scenario: String, CaseIterable, Identifiable {
    case readyToFinish
    case oneTileLeft
    case invalidGrid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .readyToFinish: "Ready to finish"
        case .oneTileLeft: "One tile left (N)"
        case .invalidGrid: "Invalid grid"
        }
    }

    static var fromLaunchArguments: Scenario? {
        UserDefaults.standard.string(forKey: "scenario").flatMap(Scenario.init(rawValue:))
    }

    func makeGame() -> SoloGame {
        switch self {
        case .readyToFinish:
            // CRATE across, CODE and EARN down.
            ScenarioBuilder(board: [
                "CRATE",
                "O   A",
                "D   R",
                "E   N",
            ]).game()
        case .oneTileLeft:
            // Dropping the N under EAR makes EARN, then Finish.
            ScenarioBuilder(board: [
                "CRATE",
                "O   A",
                "D   R",
                "E    ",
            ], rack: "N").game()
        case .invalidGrid:
            // CRATX isn't a word, and AT is cut off from the rest.
            ScenarioBuilder(board: [
                "CRATX",
                "O    ",
                "D    ",
                "E  AT",
            ], bag: "EEEAAIOU").game()
        }
    }
}

/// Builds a SoloGame from letters, giving every tile a unique id.
private struct ScenarioBuilder {
    var board: [String]
    var rack = ""
    var bag = ""

    private var nextID = 0

    init(board: [String], rack: String = "", bag: String = "") {
        self.board = board
        self.rack = rack
        self.bag = bag
    }

    func game() -> SoloGame {
        var builder = self
        var player = PlayerTiles(rack: builder.tiles(rack))
        for (row, line) in board.enumerated() {
            for (column, letter) in line.enumerated() where letter != " " {
                let tile = builder.tile(letter)
                player.addToRack([tile])
                try! player.put(tile.id, at: GridPosition(row: row, column: column))
            }
        }
        return SoloGame(bag: TileBag(tiles: builder.tiles(bag)), player: player)
    }

    private mutating func tiles(_ letters: String) -> [Tile] {
        letters.map { tile($0) }
    }

    private mutating func tile(_ letter: Character) -> Tile {
        defer { nextID += 1 }
        return Tile(id: nextID, letter: letter)
    }
}
#endif
