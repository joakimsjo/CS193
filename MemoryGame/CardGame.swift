//
//  CardGame.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation

struct CardGame<CardContent> {
    var cards: Array<Card>
    var selectedCard: Card?
    
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
        if let i = cards.firstIndex(where: {$0.id == card.id}) {
            self.cards[i].isFaceUp = !self.cards[i].isFaceUp
            
            if let selectedCard = self.selectedCard {
                print(selectedCard)
                print(self.cards[i])
            } else {
                self.selectedCard = self.cards[i]
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
