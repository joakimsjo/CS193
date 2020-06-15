//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Joakim Sjøhaug on 6/14/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    static let palette: String = "☀️👋🏻🎉🤓✅🌍"
    
    // @Published // Workaround for property observer problem with property wrappers
    private var emojiArt: EmojiArt = EmojiArt() {
        willSet {
            objectWillChange.send()
        }
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    
    private static var untitled = "EmojiArtDocument.Untitled"
    
    init () {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var eomjis: [EmojiArt.Emoji] { emojiArt.emojis}
    
    // MARK: - Intents
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func removeEmoji(_ emoji: EmojiArt.Emoji) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis.remove(at: index)
        }
    }
    
    func setBackgroundUrl(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    func reset() {
        self.emojiArt = EmojiArt()
        fetchBackgroundImageData()
    }
    
    // MARK: - Helper functions
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        
        if let url = self.emojiArt.backgroundURL {
            /// Fetch the data of a url on the global dispatch queue with Qos set to "user initiated"
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    /// When we have the image data, we can update the background image. But since we are updating the UI we dispatch the closure on the
                    /// main queue.
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat (self.size) }
    var location: CGPoint { CGPoint (x: self.x, y: self.y)}
}
