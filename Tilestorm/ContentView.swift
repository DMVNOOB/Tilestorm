import SwiftUI
import TileEngine

struct ContentView: View {
    @State private var game = Game()
    @State private var camera = BoardCamera()
    @State private var draggedTile: (tile: Tile, location: CGPoint)?
    @State private var boardFrame: CGRect = .zero
    @State private var rackFrame: CGRect = .zero

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tilestorm")
                    .font(.title2.bold())
                Spacer()
                Text("\(game.bag.count) in bag")
                    .foregroundStyle(.secondary)
                Button("New Game", action: newGame)
                    .buttonStyle(.bordered)
            }
            .padding()

            BoardView(
                board: game.board,
                camera: $camera,
                draggingTileID: draggedTile?.tile.id,
                invalidCells: game.invalidCells,
                dragHandlers: dragHandlers,
                onTapCell: game.tapCell
            )
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(GameSpace.name)) } action: { boardFrame = $0 }

            HStack {
                Button("Swap", systemImage: "arrow.triangle.2.circlepath", action: game.swapSelection)
                    .disabled(!game.canSwapSelection)
                    .accessibilityHint("Returns the selected tile to the bag and draws three")
                Spacer()
                Text(game.status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(game.drawTitle, systemImage: game.bag.isEmpty ? "flag.checkered" : "plus", action: game.draw)
                    .buttonStyle(.borderedProminent)
                    .disabled(!game.canDraw)
                    .accessibilityHint("Available when every tile is on the board in valid, connected words")
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.top, 10)
            .background(.bar)

            RackView(
                tiles: game.rack,
                selectedTileID: game.selectedTileID,
                draggingTileID: draggedTile?.tile.id,
                dragHandlers: dragHandlers,
                onTap: game.toggleSelection
            )
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(GameSpace.name)) } action: { rackFrame = $0 }
        }
        .coordinateSpace(.named(GameSpace.name))
        .overlay {
            if let draggedTile {
                TileView(tile: draggedTile.tile, size: min(camera.step, 64), isSelected: true)
                    .shadow(radius: 6)
                    .position(draggedTile.location)
                    .allowsHitTesting(false)
            }
        }
        .alert("You used every tile!", isPresented: $game.showFinished) {
            Button("New Game", action: newGame)
            Button("Keep Looking", role: .cancel) {}
        }
    }

    private func newGame() {
        game.newGame()
        camera = BoardCamera()
    }

    private var dragHandlers: TileDragHandlers {
        TileDragHandlers(
            changed: { tile, location in draggedTile = (tile, location) },
            ended: { tile, location in
                drop(tile, at: location)
                draggedTile = nil
            }
        )
    }

    private func drop(_ tile: Tile, at location: CGPoint) {
        if rackFrame.contains(location) {
            game.returnToRack(tile)
        } else if boardFrame.contains(location) {
            let point = CGPoint(x: location.x - boardFrame.minX, y: location.y - boardFrame.minY)
            game.put(tile, at: camera.cell(at: point, in: boardFrame.size))
        }
    }
}

struct RackView: View {
    let tiles: [Tile]
    let selectedTileID: Tile.ID?
    var draggingTileID: Tile.ID?
    let dragHandlers: TileDragHandlers
    let onTap: (Tile) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 6) {
            ForEach(tiles) { tile in
                TileView(tile: tile, size: 40, isSelected: tile.id == selectedTileID)
                    .opacity(tile.id == draggingTileID ? 0.3 : 1)
                    .onTapGesture { onTap(tile) }
                    .draggableTile(tile, handlers: dragHandlers)
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
