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
    
    /// A data object that contains the representation in tiff format.
    func tiffData(compression: TIFFCompression) -> Data? { representation(using: .tiff, properties: [.compressionMethod:compression]) }
    
    /// A data object that contains the representation in JPEG format.
    var jpegData: Data? { representation(using: .jpeg, properties: [:]) }
        
    /// A data object that contains the representation in JPEG format with the specified compressio factor.
    func jpegData(compressionFactor: Double) -> Data? { representation(using: .jpeg, properties: [.compressionFactor: compressionFactor]) }
    
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
        guard !isMethodReplaced(#selector(self.setProperty(_:withValue:))) else { return }
        let _currentFrame = currentFrame
        do {
            try replaceMethod(
                #selector(self.setProperty(_:withValue:)),
                methodSignature: (@convention(c)  (AnyObject, Selector, NSBitmapImageRep.PropertyKey, Any?) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, NSBitmapImageRep.PropertyKey, Any?) -> ()).self) { store in {
                    object, property, value in
                    store.original(object, #selector(self.setProperty(_:withValue:)), property, value)
                    guard let object = object as? NSBitmapImageRep else { return }
                    if property == .currentFrameDuration, let value = value as? TimeInterval {
                        object._currentFrameDuration = value
                    } else if property == .currentFrame {
                        store.original(object, #selector(self.setProperty(_:withValue:)), .currentFrameDuration, object._currentFrameDuration)
                    }
                }
                }
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
        guard String(describing: value(forKey: "_tiffData")) != "nil" else { return nil }
        return ImageSource(value(forKey: "_tiffData") as! CGImageSource)
    }
}


#endif
