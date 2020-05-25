//
//  EmojiCardGame.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

let halloweenTheme = CardGame<String>.Theme(name: "🎃 Halloween ", emojis: ["🎃", "👻", "☠️", "💀", "🖤", "🌕", "🌚", "🩸", "⛓", "🧡", "💚"], color: .orange)
let sportTheme = CardGame<String>.Theme(name: "⚽️ Sports", emojis: ["🏓", "🎾", "🏀", "⛳️", "⚽️", "🎳", "🥎", "⚾️"], color: .blue)
let facesTheme = CardGame<String>.Theme(name: "🤣 Faces", emojis: ["☺️", "🤣", "🤓", "😋", "😊", "😜", "🤪"], color: .yellow)
let themes = [halloweenTheme, sportTheme, facesTheme]

class EmojiCardGame: ObservableObject {
    @Published
    private var cardGame: CardGame<String> = EmojiCardGame.createGame()
    
    static func createGame() -> CardGame<String> {
        let theme = themes.randomElement()!
        var emojiCandidates = Array<String>(theme.emojis)
        let emojis: [String] = Array(0..<emojiCandidates.count).map { _ in
            let removeAtIndex = Int.random(in: 0..<emojiCandidates.count)
            return emojiCandidates.remove(at: removeAtIndex)
        }
        return CardGame(numberOfPairs: theme.pairs, theme: theme) { pair in
            emojis[pair]
        }
    }
    
    // MARK: - Access to models
    var cards: [CardGame<String>.Card] {
        self.cardGame.cards
    }
    
    var score: Int {
        self.cardGame.score
    }
    
    var name: String {
        self.cardGame.theme.name
    }
    
    var color: Color {
        self.cardGame.theme.color
    }
    
    // MARK: - Intent(s)
    
    func cardPressed(card: CardGame<String>.Card) {
        self.cardGame.choose(card: card)
    }
    
    func newGamePressed() {
        self.cardGame = EmojiCardGame.createGame()
    }
}
