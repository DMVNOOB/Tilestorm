import SwiftUI
import TileEngine

struct GameView: View {
    let game: Game
    let onStart: (SoloGame) -> Void
    let onQuit: () -> Void

    @State private var camera = BoardCamera()
    @State private var draggedTile: (tile: Tile, location: CGPoint)?
    @State private var boardFrame: CGRect = .zero
    @State private var rackFrame: CGRect = .zero
    @State private var showMenu = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(spacing: 0) {
            hud
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 14)

            BoardView(
                board: game.board,
                camera: $camera,
                selectedTileID: game.selectedTileID,
                draggingTileID: draggedTile?.tile.id,
                invalidCells: game.invalidCells,
                dragHandlers: dragHandlers,
                onTapCell: { cell in withAnimation(.snappy(duration: 0.2)) { game.tapCell(cell) } },
                onDoubleTapTile: { tile in withAnimation(.snappy(duration: 0.2)) { game.returnToRack(tile) } }
            )
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(GameSpace.name)) } action: { boardFrame = $0 }
            .padding(.horizontal, 12)

            actionBar
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

            RackTray(
                tiles: game.rack,
                selectedTileID: game.selectedTileID,
                draggingTileID: draggedTile?.tile.id,
                dragHandlers: dragHandlers,
                onTap: { tile in withAnimation(.snappy(duration: 0.15)) { game.toggleSelection(tile) } },
                onTapEmptySpace: { withAnimation(.snappy(duration: 0.2)) { game.returnSelectionToRack() } }
            )
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(GameSpace.name)) } action: { rackFrame = $0 }
        }
        .background(Color.parchment.ignoresSafeArea())
        .coordinateSpace(.named(GameSpace.name))
        .overlay {
            if let draggedTile {
                TileView(tile: draggedTile.tile, size: min(max(camera.step, 40), 64), isSelected: true)
                    .position(draggedTile.location)
                    .allowsHitTesting(false)
            }
        }
        .overlay {
            if game.showFinished {
                FinishedCard(
                    tiles: game.board.tiles.count,
                    words: game.board.words.count,
                    duration: game.duration,
                    onNewGame: { start(SoloGame()) },
                    onBackToTitle: onQuit
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(duration: 0.35), value: game.showFinished)
        .onAppear { camera = freshCamera }
        .sensoryFeedback(.impact(weight: .light), trigger: game.board.tiles.count)
        .sensoryFeedback(.success, trigger: game.showFinished) { _, finished in finished }
        .confirmationDialog("Paused", isPresented: $showMenu, titleVisibility: .visible) {
            Button("New Game") { start(SoloGame()) }
            Button("Back to Title", action: onQuit)
            #if DEBUG
            ForEach(Scenario.allCases) { scenario in
                Button("Scenario: \(scenario.title)") {
                    start(scenario.makeGame())
                    if scenario.finishesImmediately { game.draw() }
                }
            }
            #endif
            Button("Resume", role: .cancel) {}
        }
    }

    private var hud: some View {
        HStack {
            Button("Pause", systemImage: "pause.fill") { showMenu = true }
                .labelStyle(.iconOnly)
                .buttonStyle(IconButtonStyle())
            Spacer()
            Text("TILESTORM")
                .font(GameFont.display(26, relativeTo: .title2))
                .kerning(1)
                .foregroundStyle(Color.cocoa)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            BagCounter(count: game.bag.count)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 8) {
            Button("Swap") { withAnimation(.snappy(duration: 0.2)) { game.swapSelection() } }
                .buttonStyle(GameButtonStyle(kind: .secondary))
                .disabled(!game.canSwapSelection)
                .accessibilityHint("Returns the selected tile to the bag and draws three")
            Text(game.status)
                .font(GameFont.ui(15, relativeTo: .subheadline))
                .foregroundStyle(Color.cocoa.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
            Button(game.drawTitle) { withAnimation(.snappy(duration: 0.2)) { game.draw() } }
                .buttonStyle(GameButtonStyle(kind: .primary))
                .disabled(!game.canDraw)
                .accessibilityHint("Available when every tile is on the board in valid, connected words")
        }
    }

    private func start(_ state: SoloGame) {
        onStart(state)
        camera = freshCamera
    }

    /// Wide screens (iPad) have room to start at full tile size.
    private var freshCamera: BoardCamera {
        BoardCamera(scale: sizeClass == .regular ? 1 : BoardCamera().scale)
    }

    private var dragHandlers: TileDragHandlers {
        TileDragHandlers(
            changed: { tile, location in draggedTile = (tile, location) },
            ended: { tile, location in
                withAnimation(.snappy(duration: 0.2)) { drop(tile, at: location) }
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

/// Tiles left in the bag, on a butter-yellow raised pill.
private struct BagCounter: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(Color.parchment)
                    .overlay { RoundedRectangle(cornerRadius: 3).strokeBorder(Color.toffee, lineWidth: 1.5) }
                    .frame(width: 13, height: 13)
                    .offset(x: 2, y: -2.5)
                RoundedRectangle(cornerRadius: 3).fill(Color.cream)
                    .overlay { RoundedRectangle(cornerRadius: 3).strokeBorder(Color.cocoa, lineWidth: 1.5) }
                    .frame(width: 13, height: 13)
                    .offset(x: -1.5, y: 2.5)
            }
            .frame(width: 22, height: 22)
            Text("\(count)")
                .font(GameFont.ui(20, .bold, relativeTo: .headline))
                .foregroundStyle(Color.cocoa)
                .contentTransition(.numericText())
                .animation(.snappy, value: count)
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 8)
        .background { RaisedBackground(face: .butter, edge: .mustard, lift: 4, cornerRadius: 14) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) tiles in the bag")
    }
}

/// The wooden tray at the bottom that holds unplaced tiles.
private struct RackTray: View {
    let tiles: [Tile]
    let selectedTileID: Tile.ID?
    var draggingTileID: Tile.ID?
    let dragHandlers: TileDragHandlers
    let onTap: (Tile) -> Void
    let onTapEmptySpace: () -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 6)], spacing: 10) {
            ForEach(tiles) { tile in
                TileView(tile: tile, size: 40, isSelected: tile.id == selectedTileID)
                    .opacity(tile.id == draggingTileID ? 0.3 : 1)
                    .onTapGesture { onTap(tile) }
                    .draggableTile(tile, handlers: dragHandlers)
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 66)
        .background(
            Color.toffee.opacity(0.35).shadow(.inner(color: .cocoa.opacity(0.35), radius: 6, y: 3)),
            in: .rect(cornerRadius: 22, style: .continuous)
        )
        .contentShape(.rect)
        .onTapGesture(perform: onTapEmptySpace)
        .padding(.horizontal, 14)
        .padding(.top, 22)
        .padding(.bottom, 6)
        .background(alignment: .top) {
            let tray = UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
            ZStack(alignment: .top) {
                tray.fill(Color.toffee).offset(y: -5)
                tray.fill(Color.tan.shadow(.inner(color: .white.opacity(0.35), radius: 0, y: 3)))
            }
            .shadow(color: .cocoa.opacity(0.18), radius: 9, y: -6)
            .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Rack")
    }
}

/// End-of-game results over a dimmed board.
struct FinishedCard: View {
    let tiles: Int
    let words: Int
    let duration: Duration?
    let onNewGame: () -> Void
    let onBackToTitle: () -> Void

    var body: some View {
        ZStack {
            Color.cocoa.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack(spacing: 6) {
                    ForEach(Array("DONE".enumerated()), id: \.offset) { index, letter in
                        TileView(tile: Tile(id: index, letter: letter), size: 46)
                    }
                }
                .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Storm cleared!")
                        .font(GameFont.display(36, relativeTo: .largeTitle))
                        .accessibilityAddTraits(.isHeader)
                    Text("You used every tile in the bag.")
                        .font(GameFont.ui(16, .medium))
                        .opacity(0.7)
                }
                .foregroundStyle(Color.cocoa)
                .multilineTextAlignment(.center)

                HStack(spacing: 10) {
                    stat("\(tiles)", label: "tiles")
                    stat("\(words)", label: "words")
                    stat(duration?.formatted(.time(pattern: .minuteSecond)) ?? "–", label: "time")
                }

                VStack(spacing: 14) {
                    Button(action: onNewGame) { Text("New Game").frame(maxWidth: .infinity) }
                        .buttonStyle(GameButtonStyle(kind: .primary))
                    Button(action: onBackToTitle) { Text("Back to Title").frame(maxWidth: .infinity) }
                        .buttonStyle(GameButtonStyle(kind: .secondary))
                }
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background { RaisedBackground(face: .parchment, edge: .tan, lift: 8, cornerRadius: 32) }
            .padding(24)
        }
    }

    private func stat(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(GameFont.display(26, relativeTo: .title2))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(GameFont.ui(13, relativeTo: .caption))
                .opacity(0.6)
        }
        .foregroundStyle(Color.cocoa)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background { RaisedBackground(face: .sand, edge: .tan, lift: 3, cornerRadius: 18, castsShadow: false) }
        .accessibilityElement(children: .combine)
    }
}
