//
//  NSCursor+.swift
//
//
//  Created by Florian Zand on 14.11.22.
//

#if os(macOS)
import AppKit
import Foundation
import FZSwiftUtils

public extension NSCursor {
    /// Returns the resize-diagonal system cursor (from north-west to south-east).
    static var resizeDiagonal: NSCursor? {
        if let image = NSImage(byReferencingFile: "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/resizenorthwestsoutheast/cursor.pdf") {
            return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        }
        
        // let path = Bundle.module.path(forResource: "northWestSouthEastResizeCursor", ofType: "png")!
        // let image = NSImage(byReferencingFile: path)!
        // return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        return nil
    }

    /// Returns the resize-diagonal-alernative system cursor (from north-east to south-west).
    static var resizeDiagonalAlt: NSCursor? {
        if let image = NSImage(byReferencingFile: "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/resizenortheastsouthwest/cursor.pdf") {
            return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        }
        // le t path = Bundle.module.path(forResource: "northEastSouthWestResizeCursor", ofType: "png")!
        // let image = NSImage(byReferencingFile: path)!
        // return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        return nil
    }
    
    /**
     Initializes an animated cursor with the given images, frame duration and hot spot.
     
     - Parameters:
        - image: The animated image (e.g. a GIF) to assign to the cursor.
        - frameDuration: The duration each image is displayed.
        - hotSpot: The point to set as the cursor's hot spot.
     */
    convenience init(animated image: NSImage, frameDuration: TimeInterval? = nil, hotSpot: CGPoint) {
        if image.isAnimated, let imageFrames = try? image.frames?.collect() {
            var frameDuration = frameDuration ?? imageFrames.compactMap({$0.duration}).average()
            if frameDuration == 0.0 {
                frameDuration = 0.12
            }
            let images = imageFrames.compactMap({$0.image.nsImage})
            self.init(animated: images, frameDuration: frameDuration, hotSpot: hotSpot)
        } else {
            self.init(image: image, hotSpot: hotSpot)
        }
    }
    
    /**
     Initializes an animated cursor with the given images, frame duration and hot spot.
     
     - Parameters:
        - images: The images to assign to the cursor.
        - frameDuration: The duration each image is displayed.
        - hotSpot: The point to set as the cursor's hot spot.
     */
    convenience init(animated images: [NSImage], frameDuration: TimeInterval, hotSpot: CGPoint) {
        
        self.init(image: images.first ?? NSCursor.current.image, hotSpot: images.isEmpty ? NSCursor.current.hotSpot : hotSpot)
        do {
            try self.replaceMethod(
                #selector(NSCursor.set),
                methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in { object in
                    store.original(object, #selector(NSCursor.set))
                    NSCursorAnimator.shared.frameDuration = frameDuration
                    NSCursorAnimator.shared.hotSpot = hotSpot
                    NSCursorAnimator.shared.images = images
                    NSCursorAnimator.shared.restartAnimating()
                }
                }
        } catch {
            Swift.print(error)
        }
    }
    
    private class NSCursorAnimator {
        static let shared = NSCursorAnimator()
        var timer: Timer? = nil
        var images: [NSImage] = []
        var frameDuration: TimeInterval = 0.0
        var index: Int = 0
        var hotSpot: CGPoint = CGPoint(x: 8, y: 8)
        
        func restartAnimating() {
            stopAnimating()
            startAnimating()
        }
        
        func startAnimating() {
            guard frameDuration != 0.0 && images.count > 1 else {
                stopAnimating()
                return
            }
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { timer in
                self.advanceImage()
            })
        }
        
        func stopAnimating() {
            Swift.print("stopAnimating")
            timer?.invalidate()
            timer = nil
            index = 0
            if images.isEmpty == false {
                NSCursor(image: images[index], hotSpot: hotSpot).set()
            } else {
                NSCursor.arrow.set()
                return
            }
        }
        
        func advanceImage() {
            if self.images.contains(NSCursor.current.image) == false || images.isEmpty {
                if self.images.contains(NSCursor.current.image) == false {
                    Swift.print("imageContains 0", NSCursor.current.image)
                    if self.images[index] != NSCursor.current.image {
                        Swift.print("imageContains 1", self.images[index])
                    }
                } else if images.isEmpty {
                    Swift.print("images isEmpty")
                }
                self.timer?.invalidate()
               // stopAnimating()
            } else {
                index = index + 1
                if index >= images.count {
                    index = 0
                }
                NSCursor(image: images[index], hotSpot: hotSpot).set()
            }
        }
    }
}
#endif
