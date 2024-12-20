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

fileprivate extension NSCursor {
    convenience init(named name: String) {
        let imageURL = Bundle.module.url(forResource: name, withExtension: "pdf")!
        var image = NSImage(contentsOf: imageURL)!
        
        let plistURL = Bundle.module.url(forResource: name, withExtension: "plist")!
        
        let data = try! Data(contentsOf: plistURL)
        let info = try! PropertyListDecoder().decode(CursorInfo.self, from: data)
        image = image.retinaReadyCursorImage()
        if let shadow = info.shadow {
            let shadowImage = image.withShadow(shadow)
            image = shadowImage ?? image
            if shadowImage == nil {
                Swift.print("ShadowImageFailed")
            }
        }
        self.init(image: image, hotSpot: info.hotSpot)
    }
    
    struct CursorInfo: Codable {
        var hotSpot: CGPoint {
            CGPoint(hotSpotX, hotSpotY)
        }
        
        var hotSpotScaled: CGPoint {
            CGPoint(hotSpotXScaled, hotSpotYScaled)
        }
        
        var shadow: ShadowConfiguration? {
            guard rendersShadow else { return nil }
            let color = NSColor(red: shadowColor[safe: 0] ?? 0.0, green: shadowColor[safe: 1] ?? 0.0, blue: shadowColor[safe: 2] ?? 0.0, alpha: shadowColor[safe: 3] ?? 0.0)
            return ShadowConfiguration(color: color, opacity: 1.0, radius: shadowBlur, offset: CGPoint(shadowOffsetX, shadowOffsetY))
        }
        
        private let hotSpotX: CGFloat
        private let hotSpotY: CGFloat
        private let hotSpotXScaled: CGFloat
        private let hotSpotYScaled: CGFloat
        private let rendersShadow: Bool
        private let shadowColor: [CGFloat]
        private let shadowOffsetX: CGFloat
        private let shadowOffsetY: CGFloat
        private let shadowBlur: CGFloat
        
        enum CodingKeys : String, CodingKey {
            case shadowColor = "shadowcolor"
            case rendersShadow = "rendershadow"
            case shadowOffsetX = "shadowoffsetx"
            case shadowOffsetY = "shadowoffsety"
            case hotSpotXScaled = "hotx-scaled"
            case hotSpotYScaled = "hoty-scaled"
            case shadowBlur = "blur"
            case hotSpotX = "hotx"
            case hotSpotY = "hoty"
        }
    }
}

fileprivate extension NSImage {
    func retinaReadyCursorImage() -> NSImage {
        let resultImage = NSImage(size: size)
        for scale in 1..<4 {
            let transform = NSAffineTransform()
            transform.scale(by: CGFloat(scale))
            if let rasterCGImage = self.cgImage(forProposedRect: nil, context: nil, hints: [NSImageRep.HintKey.ctm: transform]) {
                let rep = NSBitmapImageRep(cgImage: rasterCGImage)
                rep.size = size
                resultImage.addRepresentation(rep)
            }
        }
        return resultImage
    }
}

extension NSCursor {
    /**
     Returns the resize-diagonal system cursor (from north-west to south-east).
     
     Use this cursor for resizing of a bottom right or top left corner.
     */
    public static var resizeDiagonal: NSCursor {
        NSCursor(named: "resizenorthwestsoutheast")
    }
    
    /// Returns the resize-bottom-right system cursor.
    public static var resizeBottomRight: NSCursor {
        resizeDiagonal
    }
    
    /// Returns the resize-top-left system cursor.
    public static var resizeTopLeft: NSCursor {
        resizeDiagonal
    }
    
    /// Returns the resize top-left corner system cursor.
    public static var resizeTopLeftCorner: NSCursor? {
        guard let image = NSImage(named: "NSTruthTopLeftResizeCursor") else { return nil }
        return NSCursor(image: image, hotSpot: CGPoint(4.0, 4.0))
    }
    
    /// Returns the resize top-right corner system cursor.
    public static var resizeTopRightCorner: NSCursor? {
        guard let image = NSImage(named: "NSTruthTopRightResizeCursor") else { return nil }
        return NSCursor(image: image, hotSpot: CGPoint(12.0, 4.0))
    }
    
    /// Returns the resize bottom-left corner system cursor.
    public static var resizeBottomLeftCorner: NSCursor? {
        guard let image = NSImage(named: "NSTruthBottomLeftResizeCursor") else { return nil }
        return NSCursor(image: image, hotSpot: CGPoint(4.0, 12.0))
    }
    
    /// Returns the resize bottom-right corner system cursor.
    public static var resizeBottomRightCorner: NSCursor? {
        guard let image = NSImage(named: "NSTruthBottomRightResizeCursor") else { return nil }
        return NSCursor(image: image, hotSpot: CGPoint(12.0, 12.0))
    }
    
    /**
     Returns the resize-diagonal-alernative system cursor (from north-east to south-west).
     
     This cursor is used when moving or resizing an object and the object can be moved of a bottom-left or top-right corner.
     Use this cursor for resizing of a bottom left or top right corner.
     */
    public static var resizeDiagonalAlt: NSCursor {
        NSCursor(named: "resizenortheastsouthwest")
    }
    
    /**
     Returns the resize-top-right system cursor.
     */
    public static var resizeTopRight: NSCursor {
        resizeDiagonalAlt
    }
    
    /// Returns the resize-bottom-left system cursor.
    public static var resizeBottomLeft: NSCursor {
        resizeDiagonalAlt
    }
    
    /// Returns the resize-up-and-down system cursor without center line.
    public static var resizeUpAlt: NSCursor {
        NSCursor(named: "resizenorth")
    }
    
    /// Returns the resize-up-and-down system cursor without center line.
    public static var resizeDownAlt: NSCursor {
        NSCursor(named: "resizesouth")
    }
    
    /// Returns the resize-up-and-down system cursor without center line.
    public static var resizeUpDownAlt: NSCursor {
        NSCursor(named: "resizenorthsouth")
    }
    
    /// Returns the resize-left-and-right system cursor without center line.
    public static var resizeLeftAlt: NSCursor {
        NSCursor(named: "resizewest")
    }
    
    /// Returns the resize-right system cursor without center line.
    public static var resizeRightAlt: NSCursor {
        NSCursor(named: "resizeeast")
    }
    
    /// Returns the resize-left-and-right system cursor without center line.
    public static var resizeLeftRightAlt: NSCursor {
        NSCursor(named: "resizeeastwest")
    }
    
    /**
     Returns the move system cursor.
     
     This cursor is used to indicate that an object can be moved.
     */
    public static var move: NSCursor {
        NSCursor(named: "move")
    }
    
    static func cursor(named name: String) -> NSCursor? {
        guard let object = NSCursor.perform(NSSelectorFromString(name)) else { return nil }
        return object.takeUnretainedValue() as? NSCursor
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
                    NSCursorAnimator.shared.start()
                }
                }
            } catch {
                Swift.debugPrint(error)
            }
        }

        private class NSCursorAnimator {
            static let shared = NSCursorAnimator()
            
            var lastFrameTime = CFAbsoluteTimeGetCurrent()
            var frames: [ImageFrame] = [] {
                willSet {  stop() } }
            var index: Int = 0
            var hotSpot: CGPoint = .zero
            var timer: DisplayLinkTimer?
            
            func start() {
                guard !frames.isEmpty else {
                    stop()
                    return
                }
                index = 0
                guard timer == nil else { return }
                if index > frames.count - 1 {
                    index = 0
                }
                timer = .init(timeInterval: .seconds(self.frames[safe: self.index]?.duration ?? 0.12), repeating: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.advanceImage()
                }
            }

            func stop() {
                timer = nil
                index = 0
            }
            
            func advanceImage() {
                guard let timer = timer, (frames.contains(where: {$0.image == NSCursor.current.image}) == false || frames.isEmpty) else {
                    stop()
                    frames = []
                    return
                }
                index = index + 1
                if index >= frames.count {
                    index = 0
                }
                NSCursor(image: frames[index].image, hotSpot: hotSpot).set()
                timer.timeInterval = .seconds(self.frames[safe: self.index]?.duration ?? 0.12)
            }
        }
    }

extension NSImage {
    /// Returns a new image with the specified shadow configuraton.
    /// This will increase the size of the image to fit the shadow and the original image.
    func withShadow(_ shadow: ShadowConfiguration) -> NSImage? {
        guard let color = shadow.resolvedColor()?.cgColor, color.alpha >= 0.0 else { return self }
        
        let shadowRect = CGRect(
            x: shadow.offset.x - shadow.radius,
            y: shadow.offset.y - shadow.radius,
            width: size.width + shadow.radius * 2,
            height: size.height + shadow.radius * 2
        )

        let newSize = CGSize(width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0), height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
        )

        let newImage = NSImage(size: newSize)
        newImage.lockFocus()

        let context = NSGraphicsContext.current?.cgContext
        context?.setShadow(offset: shadow.offset.size, blur: shadow.radius, color: color)

        let drawingRect = CGRect(
            x: max(0, -shadowRect.origin.x),
            y: max(0, -shadowRect.origin.y),
            width: size.width,
            height: size.height
        )
        draw(in: drawingRect, from: .zero, operation: .sourceOver, fraction: 1.0)

        newImage.unlockFocus()
        return newImage
    }
}

#endif
