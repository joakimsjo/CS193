//
//  EmojiCardGameTheme.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/25/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation
import SwiftUI

struct EmojiCardGameTheme {
    let name: String
    let emojis: Set<String>
    let color: Color
    var cards: Int?
    
    var pairs: Int {
        self.cards ?? Int.random(in: 2..<emojis.count)
    }
}
