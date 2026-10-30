import Observation
import TileEngine

/// Local solo game state. Rules live in TileEngine's SoloGame; this adds UI concerns like selection.
@Observable
final class Game {
    private(set) var state = SoloGame()
    private(set) var selectedTileID: Tile.ID?

    var bag: TileBag { state.bag }
    var rack: [Tile] { state.player.rack }
    var board: Board { state.player.board }
    var canDraw: Bool { state.canDraw }
    var canSwapSelection: Bool { selectedTileID != nil && state.canSwap }

    func newGame() {
        state = SoloGame()
        selectedTileID = nil
    }

    func toggleSelection(_ tile: Tile) {
        selectedTileID = selectedTileID == tile.id ? nil : tile.id
    }

    /// Tapping a cell places the selected rack tile there, or sends an existing board tile back to the rack.
    func tapCell(_ cell: GridPosition) {
        if let selectedTileID {
            try? state.put(selectedTileID, at: cell)
            self.selectedTileID = nil
        } else if let tile = board.tile(at: cell) {
            try? state.returnToRack(tile.id)
        }
    }

    func put(_ tile: Tile, at cell: GridPosition) {
        try? state.put(tile.id, at: cell)
        selectedTileID = nil
    }

    func returnToRack(_ tile: Tile) {
        try? state.returnToRack(tile.id)
    }

    func draw() {
        try? state.draw()
    }

    func swapSelection() {
        guard let selectedTileID else { return }
        try? state.swap(selectedTileID)
        self.selectedTileID = nil
    }
}
