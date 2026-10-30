import SwiftUI
import TileEngine

struct ContentView: View {
    @State private var game = Game()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tilestorm")
                    .font(.title2.bold())
                Spacer()
                Text("\(game.bag.count) in bag")
                    .foregroundStyle(.secondary)
                Button("New Game", action: game.newGame)
                    .buttonStyle(.bordered)
            }
            .padding()

            BoardView(board: game.board, onTapCell: game.tapCell)

            RackView(tiles: game.rack, selectedTileID: game.selectedTileID, onTap: game.toggleSelection)
        }
    }
}

struct RackView: View {
    let tiles: [Tile]
    let selectedTileID: Tile.ID?
    let onTap: (Tile) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 6) {
            ForEach(tiles) { tile in
                TileView(tile: tile, size: 40, isSelected: tile.id == selectedTileID)
                    .onTapGesture { onTap(tile) }
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding()
        .frame(minHeight: 60)
        .background(.bar)
        .accessibilityLabel("Rack")
    }
}

#Preview {
    ContentView()
}
