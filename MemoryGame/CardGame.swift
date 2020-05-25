//
//  CardGame.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation

struct CardGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    
    var indexOfFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp }.only }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }
    
    init(numberOfPairs: Int, cardContentFactory: (Int) -> CardContent) {
        self.cards = []
        
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
    }
    
    mutating func choose(card: Card) {
        if let i = cards.firstIndex(matching: card), !cards[i].isFaceUp, !cards[i].isMatched {
            if let potentialMatchIndex = indexOfFaceUpCard {
                if cards[i].content == cards[potentialMatchIndex].content {
                    cards[i].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                self.cards[i].isFaceUp = true
            } else {
                indexOfFaceUpCard = i
            }
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}
