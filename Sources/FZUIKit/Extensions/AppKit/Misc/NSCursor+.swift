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
                self.init(animated: imageFrames.compactMap({ImageFrame($0.image.nsImage, $0.duration ?? 0.12)}), hotSpot: hotSpot)
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
            self.init(animated: images.compactMap({ImageFrame($0, frameDuration)}), hotSpot: hotSpot)
        }
        
        convenience init(animated frames: [ImageFrame], hotSpot: CGPoint = .zero) {
            self.init(image: frames.first?.image ?? NSCursor.current.image, hotSpot: frames.isEmpty ? NSCursor.current.hotSpot : hotSpot)
            do {
                try replaceMethod(
                    #selector(NSCursor.set),
                    methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                    hookSignature: (@convention(block) (AnyObject) -> Void).self
                ) { store in { object in
                    store.original(object, #selector(NSCursor.set))
                    NSCursorAnimator.shared.frames = frames
                    NSCursorAnimator.shared.hotSpot = hotSpot
                    NSCursorAnimator.shared.restart()
                }
                }
            } catch {
                Swift.debugPrint(error)
            }
        }

        private class NSCursorAnimator {
            static let shared = NSCursorAnimator()
            
            var displayLink: AnyCancellable? = nil
            var lastFrameTime = CFAbsoluteTimeGetCurrent()
            var frames: [ImageFrame] = []
            var index: Int = 0
            var hotSpot: CGPoint = .zero

            func restart() {
                stop()
                start()
            }
            
            func start() {
                guard frames.count >= 1 else {
                    stop()
                    return
                }
                guard displayLink == nil else { return }
                lastFrameTime = CFAbsoluteTimeGetCurrent()

                displayLink = DisplayLink.shared.sink { [weak self] frame in
                    guard let self = self else { return }
                    let current = CFAbsoluteTimeGetCurrent()
                    if current - self.lastFrameTime > self.frames[self.index].duration! {
                        self.lastFrameTime = current
                        self.advanceImage()
                    }

                }
            }

            func stop() {
                displayLink?.cancel()
                displayLink = nil
                index = 0
            }

            func advanceImage() {
                if frames.contains(where: {$0.image == NSCursor.current.image}) == false || frames.isEmpty {
                    stop()
                } else {
                    index = index + 1
                    if index >= frames.count {
                        index = 0
                    }
                    NSCursor(image: frames[index].image, hotSpot: hotSpot).set()
                }
            }
        }
    }
#endif
