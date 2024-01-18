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
import Combine

    extension NSCursor {
        /**
         Returns the resize-diagonal system cursor (from north-west to south-east).
         
         Use this cursor for resizing of a bottom right or top left corner.
         */
        public static var resizeDiagonal: NSCursor? {
            if let url = Bundle.module.url(forResource: "resizenorthwestsoutheast", withExtension: "pdf"), let image = NSImage(contentsOf: url) {
                return NSCursor(image: image, hotSpot: NSCursor.arrow.hotSpot)
            }
            return nil
        }

        /**
         Returns the resize-diagonal-alernative system cursor (from north-east to south-west).
         
         Use this cursor for resizing of a bottom left or top right corner.
         */
        public static var resizeDiagonalAlt: NSCursor? {
            if let url = Bundle.module.url(forResource: "resizenortheastsouthwest", withExtension: "pdf"), let image = NSImage(contentsOf: url) {
                return NSCursor(image: image, hotSpot: NSCursor.arrow.hotSpot)
            }
            return nil
        }
        
        /**
         Returns an animated cursor for the specified animated image.

         - Parameters:
            - image: The animated image (e.g. a GIF) to assign to the cursor.
            - frameDuration: The duration each image is displayed. The default value is `nil` which uses the frame duration of the animated image.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public static func animated(_ image: NSImage, frameDuration: TimeInterval? = nil, hotSpot: CGPoint = .zero) -> NSCursor {
            return NSCursor(animated: image, frameDuration: frameDuration, hotSpot: hotSpot)
        }
        
        /**
         Returns an animated cursor for the specified images.

         - Parameters:
            - images: The images to assign to the cursor.
            - frameDuration: The duration each image is displayed.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public static func animated(_ images: [NSImage], frameDuration: TimeInterval, hotSpot: CGPoint = .zero) -> NSCursor {
            return NSCursor(animated: images, frameDuration: frameDuration, hotSpot: hotSpot)
        }

        /**
         Initializes an animated cursor with the given images, frame duration and hot spot.

         - Parameters:
            - image: The animated image (e.g. a GIF) to assign to the cursor.
            - frameDuration: The duration each image is displayed. The default value is `nil` which uses the frame duration of the animated image.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public convenience init(animated image: NSImage, frameDuration: TimeInterval? = nil, hotSpot: CGPoint = .zero) {
            if image.isAnimated, let imageFrames = try? image.frames?.collect() {
                var frameDurations: [TimeInterval] = []
                var images: [NSImage] = []
                for imageFrame in imageFrames {
                    frameDurations.append(imageFrame.duration ?? 0.12)
                    images.append(imageFrame.image.nsImage)
                }
                self.init(animated: images, frameDurations: frameDurations, hotSpot: hotSpot)
            } else {
                self.init(image: image, hotSpot: hotSpot)
            }
        }

        /**
         Initializes an animated cursor with the given images, frame duration and hot spot.

         - Parameters:
            - images: The images to assign to the cursor.
            - frameDuration: The duration each image is displayed.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public convenience init(animated images: [NSImage], frameDuration: TimeInterval, hotSpot: CGPoint = .zero) {
            self.init(animated: images, frameDurations: Array(repeating: frameDuration, count: images.count), hotSpot: hotSpot)
        }
        
        convenience init(animated images: [NSImage], frameDurations: [TimeInterval], hotSpot: CGPoint = .zero) {
            self.init(image: images.first ?? NSCursor.current.image, hotSpot: images.isEmpty ? NSCursor.current.hotSpot : hotSpot)
            do {
                try replaceMethod(
                    #selector(NSCursor.set),
                    methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                    hookSignature: (@convention(block) (AnyObject) -> Void).self
                ) { store in { object in
                    store.original(object, #selector(NSCursor.set))
                    NSCursorAnimator.shared.frameDurations = frameDurations
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
            var frameDurations: [TimeInterval] = []
            var index: Int = 0
            var hotSpot: CGPoint = .init(x: 8, y: 8)

            func restart() {
                stop()
                start()
            }

            var displayLink: AnyCancellable? = nil
            var lastFrameTime = CFAbsoluteTimeGetCurrent()
 
            
            func start() {

                guard images.count > 1 else {
                    stop()
                    return
                }
                guard displayLink == nil else { return }
                lastFrameTime = CFAbsoluteTimeGetCurrent()

                displayLink = DisplayLink.shared.sink { [weak self] frame in
                    Swift.print("fff")
                    guard let self = self else { return }
                    let current = CFAbsoluteTimeGetCurrent()
                    Swift.print(self.lastFrameTime - current,  self.frameDurations[self.index])
                    if current - self.lastFrameTime > self.frameDurations[self.index] {
                        self.lastFrameTime = current
                        self.advanceImage()
                    }

                }
                
                /*
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true, block: { _ in
                    self.advanceImage()
                })
                 */
                
            }

            func stop() {
                displayLink?.cancel()
                displayLink = nil
                
                /*
                timer?.invalidate()
                timer = nil
                 */
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
