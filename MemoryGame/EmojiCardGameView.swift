//
//  EmojiCardGameView.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/20/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import SwiftUI
import Combine

struct EmojiCardGameView: View {
    @ObservedObject
    var emojiGameViewModel: EmojiCardGame
    
    var body: some View {
        HStack {
            ForEach(emojiGameViewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    self.emojiGameViewModel.cardPressed(card: card)
                }
                .aspectRatio(2/3, contentMode: .fit)
                .animation(.linear)
            }
        }
        .padding()
    }
}

struct CardView: View {
    let card: CardGame<String>.Card
    var body: some View {
        GeometryReader { geo in
            self.body(for: geo.size)
        }
    }
    
    func body(for size: CGSize) -> some View {
        ZStack {
            if (card.isMatched || card.isFaceUp) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.red, lineWidth: edgeLineWidth)
                Text(card.content)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            } else {
                Rectangle()
                    .foregroundColor(Color.red)
                    .cornerRadius(cornerRadius)
                
                Text("E")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }.font(Font.system(size: fontSize(for: size)))
    }

    // MARK: - Drawing Constants
    let cornerRadius: CGFloat = 5.0
    let edgeLineWidth: CGFloat = 3
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let debugCard = CardGame<String>.Card(isFaceUp: true, content: "🍑", id: 1)
        
        return Group {
            EmojiCardGameView(emojiGameViewModel: EmojiCardGame())
            CardView(card: debugCard).aspectRatio(2/3,contentMode: .fit)
        }
    }
}
