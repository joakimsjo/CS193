//
//  Array+Identifiable.swift
//  MemoryGame
//
//  Created by Joakim Sjøhaug on 5/25/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
