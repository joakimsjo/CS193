//
//  Array+Only.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/25/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
