import Foundation

/// The set of words accepted on the board. Lookups are case-insensitive.
public struct WordList: Sendable {
    private let words: Set<String>

    public init(_ words: some Sequence<String>) {
        self.words = Set(words.map { $0.uppercased() })
    }

    public func contains(_ word: String) -> Bool {
        words.contains(word.uppercased())
    }

    public var count: Int { words.count }

    /// The bundled ENABLE word list (public domain, ~173k words). Loaded on first use.
    public static let enable: WordList = {
        guard let url = Bundle.module.url(forResource: "enable1", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else {
            preconditionFailure("enable1.txt is missing from the TileEngine bundle")
        }
        return WordList(text.split(whereSeparator: \.isNewline).map(String.init))
    }()
}
