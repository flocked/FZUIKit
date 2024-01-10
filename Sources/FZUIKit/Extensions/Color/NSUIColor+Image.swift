//
//  NSUIColor+Image.swift
//
// Parts taken from:
//  https://github.com/jathu/UIImageColors
//  Created by Jathu Satkunarajah (@jathu) on 2015-06-11 - Toronto
//
//  Created by Florian Zand on 06.10.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIImage {
    /// The colors of an image.
    struct ImageColors {
        /// The background color of the image.
        public let background: NSUIColor
        /// The primary color of the image.
        public let primary: NSUIColor
        /// The secondary color of the image.
        public let secondary: NSUIColor
        /// The detail color of the image.
        public let detail: NSUIColor
    }

    /// The quality at which the main colors of an image should be analysed. A higher value takes longer to analyse.
    enum ImageColorsQuality: CGFloat {
        case lowest = 50 // 50px
        case low = 100 // 100px
        case high = 250 // 250px
        case highest = 0 // No scale
    }

    fileprivate struct ImageColorsCounter {
        let color: Double
        let count: Int
    }
}

public extension CGImage {
    /**
     Returns the main colors of the image.
     
     - Parameter quality: The quality at which the colors should be analysed. A higher value takes longer to analyse.
     */
    func getColors(quality: NSUIImage.ImageColorsQuality = .high) -> NSUIImage.ImageColors? {
        return NSUIImage(cgImage: self).getColors(quality: quality)
    }

    /**
     Analysis the main colors of the image asynchronously on a background thread.
     
     - Parameters:
        - quality: The quality at which the colors should be analysed. A higher value takes longer to analyse.
        - completion: The completion handler to call when the analysation is ready. The completion handler takes the following parameters:
        -  colors: The main colors of the image.
     */
    func getColors(quality: NSUIImage.ImageColorsQuality = .high, _ completion: @escaping (_ colors: NSUIImage.ImageColors?) -> Void) {
        NSUIImage(cgImage: self).getColors(quality: quality, completion)
    }
}

extension NSUIImage {
    /**
     Returns the main colors of the image.
     
     - Parameter quality: The quality at which the colors should be analysed. A higher value takes longer to analyse.
     */
    public func getColors(quality: ImageColorsQuality = .high) -> ImageColors? {
        var scaleDownSize: CGSize = size
        if quality != .highest {
            if size.width < size.height {
                let ratio = size.height / size.width
                scaleDownSize = CGSize(width: quality.rawValue / ratio, height: quality.rawValue)
            } else {
                let ratio = size.width / size.height
                scaleDownSize = CGSize(width: quality.rawValue, height: quality.rawValue / ratio)
            }
        }

        guard let resizedImage = resizeForImageColors(newSize: scaleDownSize) else { return nil }

        #if os(OSX)
        guard let cgImage = resizedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        #else
        guard let cgImage = resizedImage.cgImage else { return nil }
        #endif

        let width: Int = cgImage.width
        let height: Int = cgImage.height

        let threshold = Int(CGFloat(height) * 0.01)
        var proposed: [Double] = [-1, -1, -1, -1]

        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else {
            fatalError("UIImageColors.getColors failed: could not get cgImage data.")
        }

        let imageColors = NSCountedSet(capacity: width * height)
        for x in 0 ..< width {
            for y in 0 ..< height {
                let pixel: Int = (y * cgImage.bytesPerRow) + (x * 4)
                if data[pixel + 3] >= 127 {
                    imageColors.add((Double(data[pixel + 2]) * 1_000_000) + (Double(data[pixel + 1]) * 1000) + Double(data[pixel]))
                }
            }
        }

        let sortedColorComparator: Comparator = { main, other -> ComparisonResult in
            let m = main as! ImageColorsCounter, o = other as! ImageColorsCounter
            if m.count < o.count {
                return .orderedDescending
            } else if m.count == o.count {
                return .orderedSame
            } else {
                return .orderedAscending
            }
        }

        var enumerator = imageColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: imageColors.count)
        while let K = enumerator.nextObject() as? Double {
            let C = imageColors.count(for: K)
            if threshold < C {
                sortedColors.add(ImageColorsCounter(color: K, count: C))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)

        var proposedEdgeColor: ImageColorsCounter
        if sortedColors.count > 0 {
            proposedEdgeColor = sortedColors.object(at: 0) as! ImageColorsCounter
        } else {
            proposedEdgeColor = ImageColorsCounter(color: 0, count: 1)
        }

        if proposedEdgeColor.color.isBlackOrWhite, sortedColors.count > 0 {
            for i in 1 ..< sortedColors.count {
                let nextProposedEdgeColor = sortedColors.object(at: i) as! ImageColorsCounter
                if Double(nextProposedEdgeColor.count) / Double(proposedEdgeColor.count) > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        proposed[0] = proposedEdgeColor.color

        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !proposed[0].isDarkColor

        while var K = enumerator.nextObject() as? Double {
            K = K.with(minSaturation: 0.15)
            if K.isDarkColor == findDarkTextColor {
                let C = imageColors.count(for: K)
                sortedColors.add(ImageColorsCounter(color: K, count: C))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)

        for color in sortedColors {
            let color = (color as! ImageColorsCounter).color

            if proposed[1] == -1 {
                if color.isContrasting(proposed[0]) {
                    proposed[1] = color
                }
            } else if proposed[2] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[2] = color
            } else if proposed[3] == -1 {
                if !color.isContrasting(proposed[0]) || !proposed[2].isDistinct(color) || !proposed[1].isDistinct(color) {
                    continue
                }
                proposed[3] = color
                break
            }
        }

        let isDarkBackground = proposed[0].isDarkColor
        for i in 1 ... 3 {
            if proposed[i] == -1 {
                proposed[i] = isDarkBackground ? 255_255_255 : 0
            }
        }

        return ImageColors(
            background: proposed[0].uicolor,
            primary: proposed[1].uicolor,
            secondary: proposed[2].uicolor,
            detail: proposed[3].uicolor
        )
    }

    /**
     Analysis the main colors of the image asynchronously on a background thread.
     
     - Parameters:
        - quality: The quality at which the colors should be analysed. A higher value takes longer to analyse.
        - completion: The completion handler to call when the analysation is ready. The completion handler takes the following parameters:
        -  colors: The main colors of the image.
     */
    public func getColors(quality: ImageColorsQuality = .high, _ completion: @escaping (ImageColors?) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors(quality: quality)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    #if os(OSX)
    internal func resizeForImageColors(newSize: CGSize) -> NSUIImage? {
        let frame = CGRect(origin: .zero, size: newSize)
        guard let representation = bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let result = NSImage(size: newSize, flipped: false, drawingHandler: { _ -> Bool in
            representation.draw(in: frame)
        })

        return result
    }
    #else
    internal func resizeForImageColors(newSize: CGSize) -> NSUIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("UIImageColors.resizeForUIImageColors failed: UIGraphicsGetImageFromCurrentImageContext returned nil.")
        }

        return result
    }
    #endif
}

/*
 Extension on double that replicates NSUIColor methods. We DO NOT want these
 exposed outside of the library because they don't make sense outside of the
 context of UIImageColors.
 */
private extension Double {
    private var r: Double {
        return fmod(floor(self / 1_000_000), 1_000_000)
    }

    private var g: Double {
        return fmod(floor(self / 1000), 1000)
    }

    private var b: Double {
        return fmod(self, 1000)
    }

    var isDarkColor: Bool {
        return (r * 0.2126) + (g * 0.7152) + (b * 0.0722) < 127.5
    }

    var isBlackOrWhite: Bool {
        return (r > 232 && g > 232 && b > 232) || (r < 23 && g < 23 && b < 23)
    }

    func isDistinct(_ other: Double) -> Bool {
        let _r = r
        let _g = g
        let _b = b
        let o_r = other.r
        let o_g = other.g
        let o_b = other.b

        return (fabs(_r - o_r) > 63.75 || fabs(_g - o_g) > 63.75 || fabs(_b - o_b) > 63.75)
            && !(fabs(_r - _g) < 7.65 && fabs(_r - _b) < 7.65 && fabs(o_r - o_g) < 7.65 && fabs(o_r - o_b) < 7.65)
    }

    func with(minSaturation: Double) -> Double {
        // Ref: https://en.wikipedia.org/wiki/HSL_and_HSV

        // Convert RGB to HSV

        let _r = r / 255
        let _g = g / 255
        let _b = b / 255
        var H, S, V: Double
        let M = fmax(_r, fmax(_g, _b))
        var C = M - fmin(_r, fmin(_g, _b))

        V = M
        S = V == 0 ? 0 : C / V

        if minSaturation <= S {
            return self
        }

        if C == 0 {
            H = 0
        } else if _r == M {
            H = fmod((_g - _b) / C, 6)
        } else if _g == M {
            H = 2 + ((_b - _r) / C)
        } else {
            H = 4 + ((_r - _g) / C)
        }

        if H < 0 {
            H += 6
        }

        // Back to RGB

        C = V * minSaturation
        let X = C * (1 - fabs(fmod(H, 2) - 1))
        var R, G, B: Double

        switch H {
        case 0 ... 1:
            R = C
            G = X
            B = 0
        case 1 ... 2:
            R = X
            G = C
            B = 0
        case 2 ... 3:
            R = 0
            G = C
            B = X
        case 3 ... 4:
            R = 0
            G = X
            B = C
        case 4 ... 5:
            R = X
            G = 0
            B = C
        case 5 ..< 6:
            R = C
            G = 0
            B = X
        default:
            R = 0
            G = 0
            B = 0
        }

        let m = V - C

        return (floor((R + m) * 255) * 1_000_000) + (floor((G + m) * 255) * 1000) + floor((B + m) * 255)
    }

    func isContrasting(_ color: Double) -> Bool {
        let bgLum = (0.2126 * r) + (0.7152 * g) + (0.0722 * b) + 12.75
        let fgLum = (0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b) + 12.75
        if bgLum > fgLum {
            return bgLum / fgLum > 1.6
        } else {
            return fgLum / bgLum > 1.6
        }
    }

    var uicolor: NSUIColor {
        return NSUIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }

    var pretty: String {
        return "\(Int(r)), \(Int(g)), \(Int(b))"
    }
}
