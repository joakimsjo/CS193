//
//  EmojiCardGame.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation
import Combine

class EmojiCardGame: ObservableObject {
    @Published
    private var cardGame: CardGame<String> = EmojiCardGame.createGame()
    
    @Published
    var cards: Array<CardGame<String>.Card>
    
    init() {
        self.cards = self.cardGame.cards
    }
    
    static func createGame() -> CardGame<String> {
        var emojiCandidates = ["🤓", "🤫", "😎", "😄", "🤩", "😂", "❤️", "💦", "🕶", "🙈", "👋🏻", "☕️"]
        let numberOfPairs = Int.random(in: 2...5)
        let emojis: [String] = Array(0...numberOfPairs).map { _ in
            let removeAtIndex = Int.random(in: 0..<emojiCandidates.count)
            return emojiCandidates.remove(at: removeAtIndex)
        }
        return CardGame(numberOfPairs: numberOfPairs) { pair in
            emojis[pair]
        }

    }
    
    // MARK: - Intent(s)
    
    func cardPressed(card: CardGame<String>.Card) {
        self.cardGame.choose(card: card)
        self.cards = self.cardGame.cards
    }
}
