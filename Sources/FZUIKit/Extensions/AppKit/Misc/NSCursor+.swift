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
        /**
         Returns the resize-diagonal system cursor (from north-west to south-east).
         
         Use this cursor for resizing of a bottom right or top left corner.
         */
        static var resizeDiagonal: NSCursor? {
            if let url = Bundle.module.url(forResource: "resizenorthwestsoutheast", withExtension: "pdf"), let image = NSImage(contentsOf: url) {
                return NSCursor(image: image, hotSpot: NSCursor.arrow.hotSpot)
            }
            return nil
        }

        /**
         Returns the resize-diagonal-alernative system cursor (from north-east to south-west).
         
         Use this cursor for resizing of a bottom left or top right corner.
         */
        static var resizeDiagonalAlt: NSCursor? {
            if let url = Bundle.module.url(forResource: "resizenortheastsouthwest", withExtension: "pdf"), let image = NSImage(contentsOf: url) {
                return NSCursor(image: image, hotSpot: NSCursor.arrow.hotSpot)
            }
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
                var frameDuration = frameDuration ?? imageFrames.compactMap(\.duration).average()
                if frameDuration == 0.0 {
                    frameDuration = 0.12
                }
                let images = imageFrames.compactMap(\.image.nsImage)
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
                try replaceMethod(
                    #selector(NSCursor.set),
                    methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                    hookSignature: (@convention(block) (AnyObject) -> Void).self
                ) { store in { object in
                    store.original(object, #selector(NSCursor.set))
                    NSCursorAnimator.shared.frameDuration = frameDuration
                    NSCursorAnimator.shared.hotSpot = hotSpot
                    NSCursorAnimator.shared.images = images
                    NSCursorAnimator.shared.restart()
                }
                }
            } catch {
                Swift.debugPrint(error)
            }
        }

        private class NSCursorAnimator {
            static let shared = NSCursorAnimator()
            var timer: Timer?
            var images: [NSImage] = []
            var frameDuration: TimeInterval = 0.0
            var index: Int = 0
            var hotSpot: CGPoint = .init(x: 8, y: 8)

            func restart() {
                stop()
                start()
            }

            func start() {
                guard frameDuration != 0.0, images.count > 1 else {
                    stop()
                    return
                }
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { _ in
                    self.advanceImage()
                })
            }

            func stop() {
                timer?.invalidate()
                timer = nil
                index = 0
            }

            func advanceImage() {
                if images.contains(NSCursor.current.image) == false || images.isEmpty {
                    stop()
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
