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
    var pngData: Data? { representation(using: .png, properties: [:]) }
    
    /// A data object that contains the representation in tiff format.
    var tiffData: Data? { representation(using: .tiff, properties: [:]) }
    
    /**
     A data object that contains the representation in tiff format.
     
     - Parameter compression: The compression method to use.
     */
    func tiffData(compression: TIFFCompression) -> Data? { representation(using: .tiff, properties: [.compressionMethod: compression]) }
    
    /// A data object that contains the representation in JPEG format.
    var jpegData: Data? { representation(using: .jpeg, properties: [:]) }
        
    /**
     A data object that contains the representation in JPEG format with the specified compression factor.
     
     - Parameter compressionFactor: The value between `0.0` and `1.0`, with `1.0` resulting in no compression and `0.0` resulting in the maximum compression possible.
     */
    func jpegData(compressionFactor: Double) -> Data? {
        representation(using: .jpeg, properties: [.compressionFactor: compressionFactor.clamped(to: 0...1.0)])
    }
    
    /// The number of frames in an animated GIF image, or `0` if the image isn't a GIF.
    var frameCount: Int {
        value(forProperty: .frameCount) as? Int ?? 0
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
    
    /// The current frame for an animated GIF image, or `0` if the image isn't a GIF.
    var currentFrame: Int {
        get { (value(forProperty: .currentFrame) as? Int) ?? 0 }
        set { setProperty(.currentFrame, withValue: newValue.clamped(to: 0...frameCount-1)) }
    }
    
    /// The duration (in seconds) of the current frame for an animated GIF image, or `0` if the image isn't a GIF.
    var currentFrameDuration: TimeInterval {
        get { value(forProperty: .currentFrameDuration) as? TimeInterval ?? 0.0 }
        set {
            guard value(forProperty: .currentFrameDuration) != nil else { return }
            swizzleFrameDurationUpdate()
            setProperty(.currentFrameDuration, withValue: newValue)
        }
    }
    
    /// The number of loops to make when animating a GIF image, or `0` if the image isn't a GIF.
    var loopCount: Int {
        get { value(forProperty: .loopCount) as? Int ?? 0 }
        set {
            guard value(forProperty: .loopCount) != nil else { return }
            setProperty(.loopCount, withValue: newValue)
        }
    }
    
    ///Changing the frame duration of a bitmap representation is normally not saved, which prevents changing the animation duration. This fixes it.
    private func swizzleFrameDurationUpdate() {
        guard !isMethodHooked(#selector(self.setProperty(_:withValue:))) else { return }
        let _currentFrame = currentFrame
        do {
            try hook(#selector(self.setProperty(_:withValue:)), closure: { original, object, sel, property, value in
                original(object, sel, property, value)
                if property == .currentFrameDuration, let value = value as? TimeInterval {
                    object._currentFrameDuration = value
                } else if property == .currentFrame {
                    original(object, sel, .currentFrameDuration, object._currentFrameDuration)
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


#endif
