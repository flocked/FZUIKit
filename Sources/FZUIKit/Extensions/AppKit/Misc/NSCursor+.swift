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
    
    /// Returns the move system cursor.
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
    public static var countingUpAndDownHand: NSCursor {
        NSCursor(named: "countingupandownhand")
    }
    
    /// Returns the zoom-in system cursor.
    public static var zoomIn: NSCursor {
        NSCursor(named: "zoomin")
    }
    
    /// Returns the zoom-out system cursor.
    public static var zoomOut: NSCursor {
        NSCursor(named: "zoomout")
    }
    
    static func cursor(named name: String) -> NSCursor? {
        guard let object = NSCursor.perform(NSSelectorFromString(name)) else { return nil }
        return object.takeUnretainedValue() as? NSCursor
    }
}

extension NSCursor {
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
        do {
            try hook(#selector(NSCursor.set), closure: { original, object, sel in
                original(object, sel)
                NSCursorAnimator.shared.frames = frames
                NSCursorAnimator.shared.hotSpot = hotSpot
                NSCursorAnimator.shared.start()
            } as @convention(block) (
                (AnyObject, Selector) -> Void,
                AnyObject, Selector) -> Void)
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    private class NSCursorAnimator {
        static let shared = NSCursorAnimator()
        
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
            guard !frames.isEmpty else { return }
            index = 0
            guard timer == nil else { return }
            timer = .init(timeInterval: .seconds(frames[index].duration ?? 0.12), repeats: true) { [weak self] _ in
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
            if NSCursor.current == cursor {
                index = index + 1
            } else {
                frames = []
            }
        }
    }
}

fileprivate extension NSCursor {
    convenience init(named name: String) {
        let info = try! CursorInfo(url: Bundle.module.url(forResource: name, withExtension: "plist")!)
        var image = NSImage(contentsOf: Bundle.module.url(forResource: name, withExtension: "pdf")!)!
        if let frames = info.frames, frames > 1, let tiff = image.tiffRepresentation, let pdfImage = NSImage(data: tiff) {
            var images = pdfImage.representations.compactMap({ ($0 as? NSBitmapImageRep)?.cgImage?.splitToTiles(horizontalCount: 1, verticalCount: frames) })
            images = (0..<images[0].count).map { index in images.map { $0[index] } }
            var frameImages: [NSImage] = []
            for group in images {
                let newImage = NSImage(size: group.first!.size)
                for image in group {
                    let image = image.withShadow(info.shadow ?? .none()) ?? image
                    let rep = NSBitmapImageRep(cgImage: image)
                    rep.size = newImage.size
                    newImage.addRepresentation(rep)
                }
                frameImages.append(newImage)
            }
            self.init(animated: frameImages, frameDuration: info.frameDuration ?? 0.12, hotSpot: info.hotSpot)
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
        
        let frameDuration: CGFloat?
        
        let frames: Int?
        
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
            case frameDuration = "delay"
            case frames = "frames"
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
