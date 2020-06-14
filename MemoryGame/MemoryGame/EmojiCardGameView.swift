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
        VStack {
            VStack {
                Text("\(emojiGameViewModel.name.uppercased())")
                    .font(.largeTitle)
                Text("score: \(emojiGameViewModel.score)")
                    .font(.body)
            }
            .padding(.vertical)

            Grid(emojiGameViewModel.cards) { card in
                CardView(card: card, color: self.emojiGameViewModel.color).onTapGesture {
                    self.emojiGameViewModel.cardPressed(card: card)
                }
                .aspectRatio(2/3, contentMode: .fit)
                .padding(5)
            }
            
            Button(action: { self.emojiGameViewModel.newGamePressed() }) {
                Text("New Game")
            }.padding(.vertical)
        }
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
            if (card.isFaceUp) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: edgeLineWidth)
                Text(card.content)
                    .animation(Animation.easeIn.delay(200))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            } else {
                if !card.isMatched {
                    Rectangle()
                        .foregroundColor(color)
                        .cornerRadius(cornerRadius)
                }
            }
        }
        .font(Font.system(size: fontSize(for: size)))
        .rotation3DEffect(card.isFaceUp ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(15), z: CGFloat(0)))
            .animation(.spring())
    }
    
    // MARK: - Drawing Constants
    let cornerRadius: CGFloat = 5.0
    let edgeLineWidth: CGFloat = 3
    var color: Color = .red
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var debugCard = CardGame<String>.Card(isFaceUp: true, content: "🍑", id: 1)
        
        return Group {
            EmojiCardGameView(emojiGameViewModel: EmojiCardGame())
            CardView(card: debugCard).aspectRatio(2/3,contentMode: .fit).onTapGesture {
                debugCard.isFaceUp = !debugCard.isFaceUp
            }
        }
    }
}
