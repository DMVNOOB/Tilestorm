import Observation
import TileEngine

/// Local solo game state. Rules live in TileEngine's SoloGame; this adds UI concerns like selection.
@Observable
final class Game {
    private(set) var state = SoloGame()
    private(set) var selectedTileID: Tile.ID?
    var showFinished = false

    var bag: TileBag { state.bag }
    var rack: [Tile] { state.player.rack }
    var board: Board { state.player.board }
    var canDraw: Bool { state.canDraw }
    var canSwapSelection: Bool { selectedTileID != nil && state.canSwap }
    var drawTitle: String { bag.isEmpty ? "Finish" : "Draw" }

    /// Board problems only matter once the rack is empty and the player is trying to draw.
    private var activeProblems: [BoardProblem] {
        rack.isEmpty && !state.isFinished ? state.boardProblems : []
    }

    var invalidCells: Set<GridPosition> {
        var cells: Set<GridPosition> = []
        for case .invalidWords(let words) in activeProblems {
            for word in words { cells.formUnion(word.cells) }
        }
        return cells
    }

    var status: String {
        if state.isFinished { return "Finished!" }
        if isBoardTileSelected { return "Tap a cell to move it, or the rack to put it back" }
        if !rack.isEmpty { return rack.count == 1 ? "1 tile to place" : "\(rack.count) tiles to place" }
        guard let problem = activeProblems.first else {
            return bag.isEmpty ? "All valid. Tap Finish" : "All valid. Draw a tile"
        }
        switch problem {
        case .noWords: return "Make a word"
        case .notConnected: return "Connect all your words"
        case .invalidWords(let words): return "Not words: " + words.map(\.text).joined(separator: ", ")
        }
    }

    init() {
        #if DEBUG
        if let scenario = Scenario.fromLaunchArguments {
            state = scenario.makeGame()
        }
        #endif
    }

    func start(_ state: SoloGame) {
        self.state = state
        selectedTileID = nil
        showFinished = false
    }

    func toggleSelection(_ tile: Tile) {
        selectedTileID = selectedTileID == tile.id ? nil : tile.id
    }

    /// With a tile selected, tapping a cell moves it there (swapping with any tile already there).
    /// With nothing selected, tapping a board tile selects it.
    func tapCell(_ cell: GridPosition) {
        let tapped = board.tile(at: cell)
        if let selectedTileID {
            if tapped?.id != selectedTileID {
                try? state.put(selectedTileID, at: cell)
            }
            self.selectedTileID = nil
        } else if let tapped {
            selectedTileID = tapped.id
        }
    }

    /// Sends the selected tile back to the rack if it's on the board.
    func returnSelectionToRack() {
        guard let selectedTileID, board.position(of: selectedTileID) != nil else { return }
        try? state.returnToRack(selectedTileID)
        self.selectedTileID = nil
    }

    private var isBoardTileSelected: Bool {
        selectedTileID.map { board.position(of: $0) != nil } ?? false
    }

    func put(_ tile: Tile, at cell: GridPosition) {
        try? state.put(tile.id, at: cell)
        selectedTileID = nil
    }

    func returnToRack(_ tile: Tile) {
        try? state.returnToRack(tile.id)
        if selectedTileID == tile.id {
            selectedTileID = nil
        }
    }

    func draw() {
        if (try? state.draw()) == .finished {
            showFinished = true
        }
    }

    func swapSelection() {
        guard let selectedTileID else { return }
        try? state.swap(selectedTileID)
        self.selectedTileID = nil
    }
}
