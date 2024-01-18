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
            - maximumSize: The maximum size of the animated image. The default value is `zero`. A width or height of `0` means that the system doesn’t constrain the size for that dimension. If the image exceeds this size on either dimension, the system reduces the size proportionately, maintaining the aspect ratio.
            - frameDuration: The duration each image is displayed. The default value is `nil` which uses the frame duration of the animated image.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public static func animated(_ image: NSImage, maximumSize: CGSize = .zero, frameDuration: TimeInterval? = nil, hotSpot: CGPoint = .zero) -> NSCursor {
            return NSCursor(animated: image, maximumSize: maximumSize, frameDuration: frameDuration, hotSpot: hotSpot)
        }
        
        /**
         Returns an animated cursor for the specified images.

         - Parameters:
            - images: The images to assign to the cursor.
            - maximumSize: The maximum size of the animated images. The default value is `zero`. A width or height of `0` means that the system doesn’t constrain the size for that dimension. If the images exceeds this size on either dimension, the system reduces the size proportionately, maintaining the aspect ratio.
            - frameDuration: The duration each image is displayed.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public static func animated(_ images: [NSImage], maximumSize: CGSize = .zero, frameDuration: TimeInterval, hotSpot: CGPoint = .zero) -> NSCursor {
            return NSCursor(animated: images, maximumSize: maximumSize, frameDuration: frameDuration, hotSpot: hotSpot)
        }

        /**
         Initializes an animated cursor with the given images, frame duration and hot spot.

         - Parameters:
            - image: The animated image (e.g. a GIF) to assign to the cursor.
            - maximumSize: The maximum size of the animated image. The default value is `zero`. A width or height of `0` means that the system doesn’t constrain the size for that dimension. If the image exceeds this size on either dimension, the system reduces the size proportionately, maintaining the aspect ratio.
            - frameDuration: The duration each image is displayed. The default value is `nil` which uses the frame duration of the animated image.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public convenience init(animated image: NSImage, maximumSize: CGSize = .zero, frameDuration: TimeInterval? = nil, hotSpot: CGPoint = .zero) {
            if image.isAnimated, let imageFrames = try? image.frames?.collect() {
                self.init(animated: imageFrames.compactMap({
                    if maximumSize.width > 0, maximumSize.height > 0 {
                        return ImageFrame($0.image.nsImage.resized(toFit: maximumSize), $0.duration ?? 0.12)
                    } else if maximumSize.width > 0 {
                        return ImageFrame($0.image.nsImage.resized(toWidth: maximumSize.width), $0.duration ?? 0.12)
                    } else if maximumSize.height > 0 {
                        return ImageFrame($0.image.nsImage.resized(toHeight: maximumSize.height), $0.duration ?? 0.12)
                    } else {
                        return ImageFrame($0.image.nsImage, $0.duration ?? 0.12)
                    }
                }), hotSpot: hotSpot)
            } else {
                self.init(image: image, hotSpot: hotSpot)
            }
        }

        /**
         Initializes an animated cursor with the given images, frame duration and hot spot.

         - Parameters:
            - images: The images to assign to the cursor.
            - maximumSize: The maximum size of the animated images. The default value is `zero`. A width or height of `0` means that the system doesn’t constrain the size for that dimension. If the images exceeds this size on either dimension, the system reduces the size proportionately, maintaining the aspect ratio.
            - frameDuration: The duration each image is displayed.
            - hotSpot: The point to set as the cursor's hot spot. The default value is `zero`.
         */
        public convenience init(animated images: [NSImage], maximumSize: CGSize = .zero, frameDuration: TimeInterval, hotSpot: CGPoint = .zero) {
            var images = images
            if maximumSize.width > 0, maximumSize.height > 0 {
                images = images.compactMap({$0.resized(toFit: maximumSize)})
            } else if maximumSize.width > 0 {
                images = images.compactMap({$0.resized(toWidth: maximumSize.width)})
            } else if maximumSize.height > 0 {
                images = images.compactMap({$0.resized(toHeight: maximumSize.height)})
            }
            self.init(animated: images.compactMap({ImageFrame($0, frameDuration)}), hotSpot: hotSpot)
        }
        
        convenience init(animated frames: [ImageFrame], hotSpot: CGPoint = .zero) {
            self.init(image: frames.first?.image ?? NSCursor.current.image, hotSpot: frames.count >= 1 ? NSCursor.current.hotSpot : hotSpot)
            guard frames.count > 1 else { return }
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
            var frames: [ImageFrame] = [] {
                willSet {  stop() } }
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
                    Swift.print(current - self.lastFrameTime, self.frames[self.index].duration!)
                    if current - self.lastFrameTime > self.frames[self.index].duration ?? 0.12 {
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
                    frames = []
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
