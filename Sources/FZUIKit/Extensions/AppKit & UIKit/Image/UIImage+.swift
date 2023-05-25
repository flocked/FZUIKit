//
//  File.swift
//
//
//  Created by Florian Zand on 05.05.23.
//

#if canImport(UIKit)
    import UIKit

    public extension NSUIImage {
        var dataSize: DataSize? {
            if let bytes = self.pngData()?.count {
                return DataSize(bytes)
            }
            return nil
        }

        convenience init(color: NSUIColor, size: CGSize = .init(width: 1.0, height: 1.0)) {
            let image = UIGraphicsImageRenderer(size: size).image { context in
                color.setFill()
                context.fill(context.format.bounds)
            }.resizableImage(withCapInsets: .zero)
            self.init(cgImage: image.cgImage!)
        }

        func opacity(_ value: CGFloat) -> NSUIImage {
            return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
                draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: value)
            }
        }

        func resized(to size: CGSize) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
            return UIGraphicsGetImageFromCurrentImageContext()
        }

        func resized(toFit size: CGSize) -> UIImage? {
            let size = self.size.scaled(toFit: size)
            return resized(to: size)
        }

        func resized(toFill size: CGSize) -> UIImage? {
            let size = self.size.scaled(toFill: size)
            return resized(to: size)
        }

        func rotated(degrees: Float) -> UIImage {
            var newSize = CGRect(origin: CGPoint.zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(degrees))).size
            // Trim off the extremely small float value to prevent core graphics from rounding it up
            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
            let context = UIGraphicsGetCurrentContext()!

            // Move origin to middle
            context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            // Rotate around middle
            context.rotate(by: CGFloat(degrees))
            // Draw the image at its center
            draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage!
        }

        func rounded() -> UIImage {
            let maxRadius = min(size.width, size.height)
            return roundedCorners(radius: maxRadius)
        }

        func roundedCorners(radius: CGFloat) -> UIImage {
            // First, determine the scale factor that preserves aspect ratio
            let widthRatio: CGFloat = 1.0
            let heightRatio: CGFloat = 1.0

            let scaleFactor = min(widthRatio, heightRatio)

            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            let cornerRadius: CGFloat = radius

            let newRect = CGRect(origin: .zero, size: scaledImageSize)

            let renderer = UIGraphicsImageRenderer(size: newRect.size)

            let scaledImage = renderer.image { _ in
                UIBezierPath(roundedRect: newRect, cornerRadius: cornerRadius).addClip()
                self.draw(in: newRect)
            }
            return scaledImage
        }
    }

#endif
