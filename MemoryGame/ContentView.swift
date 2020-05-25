//
//  ContentView.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject
    var emojiGameViewModel: EmojiCardGame
    
    var body: some View {
        HStack {
            ForEach(emojiGameViewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    self.emojiGameViewModel.cardPressed(card: card)
                }
                .font(self.emojiGameViewModel.cards.count >= 10 ? .headline : .largeTitle)
                .aspectRatio(2/3, contentMode: .fit)
                .animation(.linear)
            }
        }
        .padding()
    }
}

struct CardView: View {
    let card: CardGame<String>.Card
    let cornerRadius: CGFloat = 5.0
    var body: some View {
        ZStack {
            if (self.card.isMatched || self.card.isFaceUp) {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(Color.red, lineWidth: 2)
                Text(card.content)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            } else {
                Rectangle()
                    .foregroundColor(Color.red)
                    .cornerRadius(self.cornerRadius)
                
                Text("E")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let debugCard = CardGame<String>.Card(isFaceUp: false, content: "🍑", id: 1)
        
        return Group {
            ContentView(emojiGameViewModel: EmojiCardGame())
            CardView(card: debugCard).aspectRatio(2/3,contentMode: .fit)
        }
    }
}
