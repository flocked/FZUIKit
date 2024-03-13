//
//  NSImage+AnimatedImage.swift
//
//
//  Created by Florian Zand on 05.06.22.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSImage {
        /**
         Creates and returns an animated image.

         This method loads a series of files by appending a series of numbers to the base file name provided in the name parameter. For example, if the name parameter had ‘image’ as its contents, this method would attempt to load images from files with the names ‘image0’, ‘image1’ and so on all the way up to ‘image1024’. All images included in the animated image should share the same size and scale.

         - Parameters:
            - name: The full or partial path to the file (sans suffix).
            - duration: The duration of the animation.

         - Returns: A new image object.
         */
        class func animatedImageNamed(_ name: String, duration: TimeInterval) -> NSImage? {
            var images: [NSImage] = []
            var count = 0
            while let image = NSImage(named: "\(name)\(count)") {
                images.append(image)
                count += 1
            }
            return animatedImage(with: images, duration: duration)
        }

        /// A Boolean value that indicates whether the image is animated (e.g. a GIF).
        var isAnimated: Bool {
            guard framesCount > 1 else { return false }
            return bitmapImageRep?.value(forProperty: .currentFrameDuration) != nil
        }

        internal var isAnimatable: Bool {
            framesCount > 1
        }

        /// The number of frames of an animated (e.g. GIF) image.
        var framesCount: Int {
            #if os(macOS)
            return bitmapImageRep?.value(forProperty: .frameCount) as? Int ?? ImageSource(image: self)?.count ?? 1
            #else
            return ImageSource(image: self)?.count ?? 1
            #endif
        }

        /// The animation duration of an animated (e.g. GIF) image.
        var animationDuration: TimeInterval? {
            guard let source = ImageSource(image: self) else { return nil }
            return source.animationDuration
        }

        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of 0 means the animated image repeats forever.
         */
        var animationLoopCount: Int? {
            guard let source = ImageSource(image: self), source.count > 1 else { return nil }
            return source.properties()?.loopCount ?? source.properties(at: 0)?.loopCount
        }

        /// The images of an animated (e.g. GIF) image.
        var images: [NSUIImage]? {
            if let images = (try? frames?.collect())?.compactMap(\.image.nsUIImage) {
                return images
            }
            return nil
        }

        /// The frames of an animated (e.g. GIF) image.
        var frames: ImageFrameSequence? {
            if representations.count == 1, let representation = representations.first as? NSBitmapImageRep, representation.frameCount > 1 {
                return ImageFrameSequence(representation)
            }
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
