//
//  NSBitmapImageRep+.swift
//
//
//  Created by Florian Zand on 08.04.24.
//

#if os(macOS)
import Foundation
import FZSwiftUtils
import AppKit

public extension NSBitmapImageRep {
    /// A data object that contains the representation in JPEG format.
    func pngData() -> Data? { representation(using: .png, properties: [:]) }
    
    /**
     A data object that contains the representation in tiff format.
     
     - Parameter compression: The compression method to use.
     */
    func tiffData(compression: TIFFCompression = .none) -> Data? {
        representation(using: .tiff, properties: compression == .none ? [:] : [.compressionMethod: compression])
    }
        
    /**
     A data object that contains the representation in JPEG format with the specified compression factor.
     
     - Parameter compressionFactor: The compression factor between `0.0` and `1.0`, with `1.0` resulting in no compression and `0.0` resulting in the maximum compression possible.
     */
    func jpegData(compressionFactor: Double = 1.0) -> Data? {
        let factor = compressionFactor.clamped(to: 0...1)
        return representation(using: .jpeg, properties: factor == 1.0 ? [:] : [.compressionFactor: factor])
    }
    
    /// A data object that contains the representation in BMP format.
    func bmpData() -> Data? {  representation(using: .bmp, properties: [:]) }
    
    /// The property for the specified property key.
    subscript<V>(propertyKey: PropertyKey) -> V? {
        get { value(forProperty: propertyKey) as? V }
        set { setProperty(propertyKey, withValue: newValue) }
    }
    
    /// The color at the specified location.
    subscript(location: CGPoint) -> NSColor? {
        get { colorAt(x: Int(location.x), y: Int(location.y)) }
        set {
            guard let newValue = newValue else { return }
            setColor(newValue, atX: Int(location.x), y: Int(location.y))
          }
    }
    
    /// The compression mode.
    var compressionMode: TIFFCompression {
        get { self[.compressionMethod] ?? .none }
    }
    
    /// The compression factor.
    var compressionFactor: Double? {
        get { self[.compressionFactor] }
    }
    
    /**
     The background color to use when writing to an image format (such as JPEG) that doesn’t support alpha.
     
     The default value is `white`.
     */
    var fallbackBackgroundColor: NSColor {
        get { self[.fallbackBackgroundColor] ?? .white }
        set { self[.fallbackBackgroundColor] = newValue == .white ? nil : newValue }
    }
    
    /// The number of frames in an animated GIF image, or `0` if the image isn't a GIF.
    var frameCount: Int {
        self[.frameCount] ?? 0
    }
    
    /// Returns the image frame at the specified index.
    func frame(at index: Int) -> ImageFrame? {
        currentFrame = index
        guard let image = cgImage?.nsUIImage else { return nil }
        return ImageFrame(image, currentFrameDuration)
    }
    
    /// Returns the frame at the specified index.
    subscript(index: Int) -> ImageFrame? {
        frame(at: index)
    }
    
    /// The total duration (in seconds) of all frames for an animated GIF image, or `0` if the image isn't a GIF.
    var duration: TimeInterval {
        get {
            let current = currentFrame
            var duration: TimeInterval = 0.0
            (0..<frameCount).forEach({
                currentFrame = $0
                duration += currentFrameDuration
            })
            currentFrame = current
            return duration
        }
        set {
            let count = frameCount
            let duration = newValue / Double(count)
            let current = currentFrame
            (0..<count).forEach({
                currentFrame = $0
                currentFrameDuration = duration
            })
            currentFrame = current
        }
    }
    
    /// The current frame for an animated image, or `0` if the image isn't animated.
    var currentFrame: Int {
        get { self[.currentFrame] ?? 0 }
        set {
            guard newValue >= 0 && newValue < frameCount else { return }
            self[.currentFrame] = newValue
        }
    }
    
    /// The duration (in seconds) of the current frame for an animated image, or `0` if the image isn't an animated image.
    var currentFrameDuration: TimeInterval {
        get { self[.currentFrameDuration] ?? 0.0 }
        set {
            guard value(forProperty: .currentFrameDuration) != nil else { return }
            swizzleFrameDurationUpdate()
            self[.currentFrameDuration] = newValue
        }
    }
    
    /// The number of loops to make when animating an animated image, or `0` if the image isn't an animated image.
    var loopCount: Int {
        get { self[.loopCount] ?? 0 }
        set {
            guard value(forProperty: .loopCount) != nil else { return }
            self[.loopCount] = newValue
        }
    }
    
    /// A Boolean value indicating whether the image is animated.
    var isAnimated: Bool {
        let count = frameCount
        guard count > 1 else { return false }
        let previousFrame = currentFrame
        defer { currentFrame = previousFrame }
        for i in 0..<count {
            currentFrame = i
            if currentFrameDuration > 0.01 {
                return true
            }
        }
        return false
    }
    
    internal var cgImages: [CGImage] {
        guard frameCount > 1 else { return [cgImage].nonNil }
        let previousFrame = currentFrame
        defer { currentFrame = previousFrame }
        return (0..<frameCount).compactMap({
            currentFrame = $0
            return cgImage
        })
    }
    
    ///Changing the frame duration of a bitmap representation is normally not saved, which prevents changing the animation duration. This fixes it.
    private func swizzleFrameDurationUpdate() {
        guard !isMethodHooked(#selector(setProperty(_:withValue:))) else { return }
        let _currentFrame = currentFrame
        do {
            try hook(#selector(setProperty(_:withValue:)), closure: { original, object, sel, property, value in
                original(object, sel, property, value)
                if property == .currentFrameDuration, let value = value as? TimeInterval {
                    object._currentFrameDuration = value
                } else if property == .currentFrame {
                    original(object, sel, .currentFrameDuration, object._currentFrameDuration)
                } else {
                    original(object, sel, property, value)
                }
            } as @convention(block) (
                (NSBitmapImageRep, Selector, NSBitmapImageRep.PropertyKey, Any?) -> Void,
                NSBitmapImageRep, Selector, NSBitmapImageRep.PropertyKey, Any?) -> Void)
            currentFrame = 0
            _currentFrameDuration = currentFrameDuration
            currentFrame = _currentFrame
        } catch {
            debugPrint(error)
        }
    }
    
    private var _currentFrameDuration: TimeInterval {
        get { getAssociatedValue("currentFrameDuration", initialValue: 0.0) }
        set { setAssociatedValue(newValue, key: "currentFrameDuration") }
    }
    
    private var imageSource: ImageSource? {
        guard String(describing: value(forKeySafely: "_tiffData")) != "nil" else { return nil }
        return ImageSource(value(forKey: "_tiffData") as! CGImageSource)
    }
}

extension NSBitmapImageRep.TIFFCompression {
    /// Localized name of the compression type.
    var localizedName: String? {
        NSBitmapImageRep.localizedName(forTIFFCompressionType: self)
    }
}

#endif
