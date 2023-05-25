//
//  CGColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import FZSwiftUtils

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension CGColor {
    func alpha(_ alpha: CGFloat) -> CGColor {
        return copy(alpha: alpha) ?? self
    }

    static func fromImage(_ image: NSUIImage) -> CGColor {
        let drawPattern: CGPatternDrawPatternCallback = { info, context in
            let image = Unmanaged<NSUIImage>.fromOpaque(info!).takeUnretainedValue()
            guard let cgImage = image.cgImage else { return }
            context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        }

        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)

        let pattern = CGPattern(info: Unmanaged.passRetained(image).toOpaque(),
                                bounds: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                                matrix: CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0),
                                xStep: image.size.width,
                                yStep: image.size.height,
                                tiling: .constantSpacing,
                                isColored: true,
                                callbacks: &callbacks)!

        let space = CGColorSpace(patternBaseSpace: nil)
        let color = CGColor(patternSpace: space!, pattern: pattern, components: [1.0])!
        return color
    }

    #if os(macOS)
        var nsColor: NSColor? {
            return NSColor(cgColor: self)
        }

    #elseif canImport(UIKit)
        var uiColor: UIColor? {
            return UIColor(cgColor: self)
        }
    #endif
}

extension CGColor: CustomStringConvertible {
    public var description: String {
        return CFCopyDescription(self) as String
    }
}

#if canImport(UIKit)
    public extension CGColor {
        static var clear: CGColor {
            return UIColor.clear.cgColor
        }
    }
#endif
