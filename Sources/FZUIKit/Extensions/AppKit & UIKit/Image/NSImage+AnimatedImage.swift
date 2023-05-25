//
//  NSImage+GIF.swift
//  FZExtensions
//
//  Created by Florian Zand on 05.06.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSImage {
    class func animatedImageNamed(_ name: String, duration: TimeInterval) -> NSImage? {
        var images: [NSImage] = []
        var count = 0
        while let image = NSImage(named: "\(name)\(count)") {
            images.append(image)
            count += 1
        }
        return animatedImage(with: images, duration: duration)
    }

    class func animatedImage(with images: [NSUIImage], duration: TimeInterval) -> NSUIImage? {
        if let gifData = NSUIImage.gifData(from: images, duration: duration) {
            return NSUIImage(data: gifData)
        }
        return nil
    }

    var isAnimatable: Bool {
        return (framesCount > 1)
    }

    var framesCount: Int {
        guard let imageSource = ImageSource(image: self) else { return 1 }
        return imageSource.count
    }

    var images: [NSUIImage]? {
        guard let source = ImageSource(image: self) else { return nil }
        if let cgImages = try? source.images().collect() {
            return cgImages.compactMap { NSUIImage(cgImage: $0) }
        }
        return nil
    }

    var duration: TimeInterval {
        guard let source = ImageSource(image: self) else { return 0.0 }
        return source.animationDuration
    }

    var frames: ImageFrameSequence? {
        return ImageSource(image: self)?.imageFrames()
    }
}
#endif

/*
  public extension NSImage {
  func frames() -> [ImageFrame]? {
      guard let bitmapRep = self.representations[0] as? NSBitmapImageRep,
            let frameCount = (bitmapRep.value(forProperty: .frameCount) as? NSNumber)?.intValue, frameCount > 1 else { return nil }

      var frames = [ImageFrame]()
        for n in 0 ..< frameCount {
            bitmapRep.setProperty(.currentFrame, withValue: NSNumber(value: n))
            if let data = bitmapRep.representation(using: .gif, properties: [:]),
               let image = NSImage(data: data) {
                var frame = ImageFrame(image, ImageSource.defaultFrameDuration)
                if let frameDuration = (bitmapRep.value(forProperty: .currentFrameDuration) as? NSNumber)?.doubleValue {
                    frame.duration = frameDuration
                }
                frames.append(frame)
            }
        }
      return frames
     }
  }

  public extension UIImage {
  func frames() async -> [ImageFrame] {
      var frames = [ImageFrame]()
      if let imageSource = ImageSource(image: self) {
          let count = imageSource.count
          for index in 0..<count {
              if let cgImage = imageSource.getImage(at: index, options: nil) {
                  let frame = ImageFrame(NSUIImage(cgImage: cgImage),  imageSource.properties(at: index)?.delayTime ?? ImageSource.defaultFrameDuration)
                  frames.append(frame)
              }
          }
      }
      return frames
     }
 }
  */
