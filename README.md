# Tilestorm

A native iPhone and iPad word-tile game. Build your own crossword from a hand of letter tiles, draw more as you go, and use every tile in the bag to finish.

<p align="center">
  <img src="docs/screenshots/iphone-title.png" width="240" alt="The title screen: TILE and STORM spelled in tilted cream tiles on a warm yellow background, with Play and How to Play buttons">
  <img src="docs/screenshots/iphone-invalid.png" width="240" alt="A game in progress: the non-word CRATX is outlined in terracotta on a sand board, and the status asks you to connect all your words">
  <img src="docs/screenshots/iphone-finished.png" width="240" alt="The results card: DONE in tiles, Storm cleared!, and tiles, words and time stats with New Game and Back to Title buttons">
</p>

<p align="center">
  <img src="docs/screenshots/ipad-game.png" width="520" alt="A game on iPad with one tile left on the wooden rack">
</p>

## How to play

- **Place tiles** by dragging them from the rack, or tap a rack tile and then a cell.
- **Move tiles** by dragging, or tap one to select it and tap where it should go. Dropping on another tile swaps them.
- **Return a tile** by double-tapping it, or dragging it back to the rack.
- **Draw** a tile once every tile is on the board in real, connected words.
- **Swap** a selected tile for three from the bag.
- **Finish** when the bag is empty and your grid is valid.

## Project layout

- `Tilestorm.xcodeproj`: the SwiftUI app (iOS 18+, iPhone and iPad)
- `Packages/TileEngine`: the UI-independent rules engine. Run its tests with `swift test`.

Words are checked against the [ENABLE word list](https://github.com/dolph/dictionary) (public domain). The app uses the [Lilita One](https://fonts.google.com/specimen/Lilita+One) and [Fredoka](https://fonts.google.com/specimen/Fredoka) fonts under the SIL Open Font License.

Debug builds list test scenarios in the pause menu for jumping straight to set-up game states. You can also launch into one with `-scenario readyToFinish`, `oneTileLeft`, `invalidGrid`, or `finished`.
