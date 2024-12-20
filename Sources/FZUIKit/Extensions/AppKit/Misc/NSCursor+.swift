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
        let plistURL = Bundle.module.url(forResource: name, withExtension: "plist")!

        let info = try! CursorInfo(url: Bundle.module.url(forResource: name, withExtension: "plist")!)
        var image = NSImage(contentsOf: Bundle.module.url(forResource: name, withExtension: "pdf")!)!
        if let frames = info.frames, frames > 0, let tiff = image.tiffRepresentation, let pdfImage = NSImage(data: tiff) {
            let representations = pdfImage.representations.compactMap({($0 as? NSBitmapImageRep)?.cgImage})
            let frameImgs = pdfImage.representations.compactMap({ ($0 as? NSBitmapImageRep)?.cgImage?.splitToTiles(horizontalCount: 1, verticalCount: frames) })
            let groupedArray = (0..<frameImgs[0].count).map { index in
                frameImgs.map { $0[index] }
            }
            var frameImages: [NSImage] = []
            for group in groupedArray {
                let newImage = NSImage(size: group.first!.size)
                for image in group {
                    let image = image.withShadow(info.shadow ?? .none()) ?? image
                    let rep = NSBitmapImageRep(cgImage: image)
                    rep.size = newImage.size
                    newImage.addRepresentation(rep)
                }
                frameImages.append(newImage)
            }
            Swift.print("frameImgs", frameImgs.count, groupedArray.count, frameImages.first ?? "nil")
            self.init(animated: frameImages, frameDuration: info.delay ?? 0.12, hotSpot: info.hotSpot)
        } else {
            image = image.retinaScaled.withShadow(info.shadow ?? .none()) ?? image
            self.init(image: image, hotSpot: info.hotSpot)
        }
    }
    
    struct CursorInfo: Codable {
        init(url: URL) throws {
            self = try PropertyListDecoder().decode(CursorInfo.self, from: try Data(contentsOf: url))
        }
        
        var hotSpot: CGPoint {
            CGPoint(hotSpotX, hotSpotY)
        }
        
        var hotSpotScaled: CGPoint {
            CGPoint(hotSpotXScaled, hotSpotYScaled)
        }
        
        var shadow: ShadowConfiguration? {
            guard rendersShadow != false else { return nil }
            let color = NSColor(red: shadowColor[safe: 0] ?? 0.0, green: shadowColor[safe: 1] ?? 0.0, blue: shadowColor[safe: 2] ?? 0.0, alpha: shadowColor[safe: 3] ?? 0.0)
            return ShadowConfiguration(color: color, opacity: 1.0, radius: shadowBlur, offset: CGPoint(shadowOffsetX, shadowOffsetY))
        }
        
        private let hotSpotX: CGFloat
        private let hotSpotY: CGFloat
        private let hotSpotXScaled: CGFloat
        private let hotSpotYScaled: CGFloat
        private let rendersShadow: Bool?
        private let shadowColor: [CGFloat]
        private let shadowOffsetX: CGFloat
        private let shadowOffsetY: CGFloat
        private let shadowBlur: CGFloat
        let delay: CGFloat?
        let frames: Int?
        
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
            case delay = "delay"
            case frames = "frames"
        }
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
    
    /// Returns a cursor with an animated hand that counts up.
    public static var countingUpHand: NSCursor {
        NSCursor(named: "countinguphand")
    }
    
    /// Returns a cursor with an animated hand that counts down.
    public static var countingDownHand: NSCursor {
        NSCursor(named: "countingdownhand")
    }
    
    /// Returns a cursor with an animated hand that counts up and down.
    public static var countingUpAnDownHand: NSCursor {
        NSCursor(named: "countingupandownhand")
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
            self.init(image: frames.first?.image ?? NSCursor.current.image, hotSpot: !frames.isEmpty ? hotSpot : NSCursor.current.hotSpot)
            guard frames.count > 1 else { return }
            Swift.print("animated", frames.count)
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
                    Swift.print("cursorSET")
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
            var index: Int = 0 {
                didSet {
                    if index >= frames.count { index = 0 }
                    guard let frame = frames[safe: index] else { return }
                    timer?.timeInterval = .seconds(frame.duration ?? 0.12)
                    cursor = NSCursor(image: frame.image, hotSpot: hotSpot)
                    cursor?.set()
                }
            }
            var hotSpot: CGPoint = .zero
            var timer: DisplayLinkTimer?
            var cursor: NSCursor?
            
            func start() {
                Swift.print("animatorStart", frames.count, timer == nil)
                guard !frames.isEmpty else {
                    stop()
                    return
                }
                index = 0
                guard timer == nil else { return }
                timer = .init(timeInterval: .seconds(frames[index].duration ?? 0.12), repeating: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.advanceImage()
                }
            }

            func stop() {
                timer = nil
                cursor = nil
                index = 0
            }
            
            func advanceImage() {
                Swift.print("advanceImage", index, NSCursor.current == cursor)
                if NSCursor.current == cursor {
                    index = index + 1
                } else {
                    frames = []
                }
            }
        }
    }

fileprivate extension NSImage {
    var retinaScaled: NSImage {
        let resultImage = NSImage(size: size)
        for scale in 1..<4 {
            let transform = NSAffineTransform()
            transform.scale(by: CGFloat(scale))
            if let rasterCGImage = cgImage(forProposedRect: nil, context: nil, hints: [NSImageRep.HintKey.ctm: transform]) {
                let rep = NSBitmapImageRep(cgImage: rasterCGImage)
                rep.size = size
                resultImage.addRepresentation(rep)
            }
        }
        return resultImage
    }
}
#endif
