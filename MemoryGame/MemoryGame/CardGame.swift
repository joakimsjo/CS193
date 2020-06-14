//
//  CardGame.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation
import SwiftUI

struct CardGame<CardContent> where CardContent: Hashable {
    var cards: Array<Card>
    var seenCards: Set<Int>
    var score: Int = 0
    let theme: Theme
    var indexOfFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp }.only }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    init(numberOfPairs: Int, theme: Theme, cardContentFactory: (Int) -> CardContent) {
        self.cards = []
        self.seenCards = []
        // Generate pairs of cards
        for pair in 0..<numberOfPairs {
            let content = cardContentFactory(pair)
            let card1 = Card(content: content, id: 2*pair)
            let card2 = Card(content: content, id: 2*pair + 1)
            self.cards.append(card1)
            self.cards.append(card2)
        }
        
        // Use the built in function to shuffle the cards
        self.cards.shuffle()
        self.theme = theme
    }
    
    mutating func choose(card: Card) {
        if let i = cards.firstIndex(matching: card), !cards[i].isFaceUp, !cards[i].isMatched {
            if let potentialMatchIndex = indexOfFaceUpCard {
                if cards[i].content == cards[potentialMatchIndex].content {
                    cards[i].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    self.score += 2
                } else {
                    reduceIfHasSeenCard(self.cards[i])
                    reduceIfHasSeenCard(self.cards[potentialMatchIndex])
                    self.seenCards.insert(potentialMatchIndex)
                    self.seenCards.insert(i)
                }
                self.cards[i].isFaceUp = true
                
            } else {
                indexOfFaceUpCard = i
            }
        }
    }
    
    mutating func reduceIfHasSeenCard(_ card: Card) {
        if let index = self.cards.firstIndex(matching: card), self.seenCards.contains(index) {
            self.score -= 1
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
    
    struct Theme {
        let name: String
        let emojis: Set<CardContent>
        let color: Color
        var cards: Int?
        
        var pairs: Int {
            self.cards ?? Int.random(in: 2..<emojis.count)
        }
    }
}
