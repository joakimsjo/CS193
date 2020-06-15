//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Joakim Sjøhaug on 6/15/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//


import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: self.uiImage!)
            }
        }
    }
}
