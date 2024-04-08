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
 
        /// A Boolean value that indicates whether the image is animated (e.g. a GIF).
        var isAnimated: Bool {
            framesCount > 1 && bitmapImageRep?.value(forProperty: .currentFrameDuration) != nil
        }

        /// The number of frames of an animated (e.g. GIF) image.
        var framesCount: Int {
            bitmapImageRep?.frameCount ?? ImageSource(image: self)?.count ?? 1
        }

        /// The animation duration of an animated (e.g. GIF) image.
        var animationDuration: TimeInterval {
            get { bitmapImageRep?.duration ?? 0.0 }
            set { bitmapImageRep?.duration = newValue }
        }

        /**
         The number of times that an animated image should play through its frames before stopping.

         A value of `0` means the animated image repeats forever.
         */
        var animationLoopCount: Int {
            get { bitmapImageRep?.loopCount ?? 0 }
            set { bitmapImageRep?.loopCount = newValue }
        }

        /// The images of an animated (e.g. GIF) image asynchronously.
        var images: ImageSequence? {
            bitmapImageRep?.images
        }
        
        /// The images of an animated (e.g. GIF) image.
        func getImages() -> [NSUIImage] {
            bitmapImageRep?.getImages().compactMap({$0.nsImage}) ?? []
        }

        /// The frames of an animated (e.g. GIF) image asynchronously.
        var frames: ImageFrameSequence? {
            bitmapImageRep?.frames
        }
        
        /// The frames of an animated (e.g. GIF) image.
        func getFrames() -> [CGImageFrame] {
            bitmapImageRep?.getFrames() ?? []
        }
    }
#endif
