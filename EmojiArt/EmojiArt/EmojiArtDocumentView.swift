//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Joakim Sjøhaug on 6/14/20.
//  Copyright © 2020 Joakim Sjøhaug. All rights reserved.
//

import SwiftUI
import Combine

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString)}
                        }
                        
                        Button(action: {self.document.reset()}) {
                            Text("Reset")
                        }
                        
                        Spacer()
                        Button(action: {
                            self.selectedEmojis.forEach { self.document.removeEmoji($0) }
                            self.selectedEmojis = .init()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete selected emojis")
                            }.foregroundColor(.red)
                        }.opacity(self.selectedEmojis.isEmpty ? 0.0 : 1.0)
                            .animation(.interactiveSpring())
                    }
                    .padding(.horizontal)
                    .frame(minWidth: geometry.size.width, maxWidth: .infinity)    
                }
                
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.selectedEmojis.isEmpty ? self.zoomScale : self.steadyStateZoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    ForEach(self.document.eomjis) { emoji in
                        Text(emoji.text)
                            .overlay(self.isEmojiSelected(emoji) ? RoundedRectangle(cornerRadius: 3).stroke(Color.blue, lineWidth: 2) : nil)
                            .font(animatableWithSize: self.getEmojiFontSize(emoji))
                            .position(self.position(for: emoji, in: geometry.size))
                            .gesture(!self.isEmojiSelected(emoji) ? self.dragNotSelectedEmojiGesture(emoji) : nil)
                            .gesture(self.isEmojiSelected(emoji) ? self.zoomGesture().simultaneously(with: self.dragEmojiGesture()): nil)
                            .onTapGesture { self.tappedOnEmoji(emoji) }
                    }
                }
                .clipped()
                .gesture(self.zoomGesture().exclusively(before: self.panGesture()))
                .onTapGesture {
                    self.selectedEmojis = .init()
                }
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { (providers, location) -> Bool in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    @State private var selectedEmojis: Set<EmojiArt.Emoji> = Set()
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating(self.$gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
        }
        .onEnded { finalGestureScale in
            if self.selectedEmojis.isEmpty {
                self.steadyStateZoomScale *= finalGestureScale
            } else {
                self.selectedEmojis.forEach { self.document.scaleEmoji($0, by: self.steadyStateZoomScale * finalGestureScale)}
            }
        }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * (self.selectedEmojis.isEmpty ? zoomScale : 1.0)
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating(self.$gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }.onEnded { finalDragGestureValue in
            self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
        
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        
        if let draggingEmoji = self.draggingEmoji, draggingEmoji == emoji {
            location = CGPoint(x: location.x + emojiDragOffset.width, y: location.y + emojiDragOffset.height)
        } else if draggingEmoji == nil, self.isEmojiSelected(emoji) {
            location = CGPoint(x: location.x + emojiDragOffset.width, y: location.y + emojiDragOffset.height)
        }
        
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.setBackgroundUrl(url)
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
    //MARK: - Emoji Actions
    private func tappedOnEmoji(_ emoji: EmojiArt.Emoji) {
        if let emoji = self.selectedEmojis.first(matching: emoji) {
            self.selectedEmojis.remove(emoji)
        } else {
            self.selectedEmojis.insert(emoji)
        }
    }
    
    private func isEmojiSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        self.selectedEmojis.contains(matching: emoji)
    }
    
    private func getEmojiFontSize(_ emoji: EmojiArt.Emoji) -> CGFloat {
        if self.selectedEmojis.isEmpty {
            return zoomScale * emoji.fontSize
        }
        
        if self.selectedEmojis.contains(emoji) {
            return zoomScale * emoji.fontSize
        } else {
            return self.steadyStateZoomScale * emoji.fontSize
        }
    }
    
    @State private var steadyEmojiOffset: CGSize = .zero
    @State private var draggingEmoji: EmojiArt.Emoji? = nil
    @GestureState private var emojiDragOffset: CGSize = .zero
    
    private func dragEmojiGesture() -> some Gesture {
        DragGesture()
            .updating(self.$emojiDragOffset) { latestDragGestureValue, emojiDragOffset, transaction in
                emojiDragOffset = latestDragGestureValue.translation
        }.onEnded { finalDragGestureValue in
            self.selectedEmojis.forEach {
                self.document.moveEmoji($0, by: finalDragGestureValue.translation)
            }
        }
    }
    
    private func dragNotSelectedEmojiGesture(_ emoji: EmojiArt.Emoji) -> some Gesture {
        DragGesture()
            .onChanged { _ in self.draggingEmoji = emoji }
            .updating(self.$emojiDragOffset) { latestDragGestureValue, emojiDragOffset, transaction in
                emojiDragOffset = latestDragGestureValue.translation
        }.onEnded { finalDragGestureValue in
            self.document.moveEmoji(emoji, by: finalDragGestureValue.translation)
            self.draggingEmoji = nil
        }
    }
}

extension DragGesture.Value {
    public var distance: CGSize {
        return self.location - self.startLocation
    }
}
