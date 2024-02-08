//
//  NSUIBezierPath+String.swift
//
//
//  Created by Florian Zand on 27.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

public extension String {
    /// Creates a bezier path for the string with the specified font.
    func bezierPath(withFont font: NSUIFont) -> NSUIBezierPath {
        let attributedString = NSAttributedString(string: self, attributes: [.font: font])
        return NSUIBezierPath(attributedString: attributedString)
    }
}

public extension NSAttributedString {
    /// Creates a bezier path for the attributed string.
    func bezierPath() -> NSUIBezierPath {
        let cgPath = CGPath(attributedString: self)
        return NSUIBezierPath(cgPath: cgPath)
    }
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AttributedString {
    /// Creates a bezier path for the attributed string.
    func bezierPath() -> NSUIBezierPath {
        let cgPath = CGPath(attributedString: NSAttributedString(self))
        return NSUIBezierPath(cgPath: cgPath)
    }
}

    public extension NSUIBezierPath {
        /// Creates and returns a new bezier path for the specified string and font.
        convenience init(string: String, font: NSUIFont) {
            let attributedString = NSAttributedString(string: string, attributes: [.font: font])
            self.init(attributedString: attributedString)
        }

        /// Creates and returns a new bezier path for the specified attributed string.
        convenience init(attributedString: NSAttributedString) {
            let cgPath = CGPath(attributedString: attributedString)
            self.init(cgPath: cgPath)
        }
        
        /// Creates and returns a new bezier path for the specified attributed string.
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        convenience init(attributedString: AttributedString) {
            let cgPath = CGPath(attributedString: NSAttributedString(attributedString))
            self.init(cgPath: cgPath)
        }
    }

    /// A Core Graphics type.
    public protocol CoreGraphicsType { }

    extension CGPath: CoreGraphicsType { }

    public extension CoreGraphicsType where Self: CGPath {
        /// Creates and returns a path for the specified string and font.
        init(string: String, font: NSUIFont) {
            let attributedString = NSAttributedString(string: string, attributes: [.font: font])
            self.init(attributedString: attributedString)
        }
        
        /// Creates and returns a new path for the specified attributed string.
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
        init(attributedString: AttributedString) {
            self.init(attributedString: NSAttributedString(attributedString))
        }

        /// Creates and returns a new path for the specified attributed string.
        init(attributedString: NSAttributedString) {
            let letters = CGMutablePath()
            let line = CTLineCreateWithAttributedString(attributedString)
            let anyArray = CTLineGetGlyphRuns(line) as [AnyObject]
            if let runArray = anyArray as? [CTRun] {
                for run in runArray {
                    for runGlyphIndex in 0 ..< run.glyphCount {
                        let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                        var glyph: CGGlyph = 0
                        var position: CGPoint = .zero

                        CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                        CTRunGetPositions(run, thisGlyphRange, &position)

                        if let letter = CTFontCreatePathForGlyph(run.font, glyph, nil) {
                            let t = CGAffineTransform(translationX: position.x, y: position.y)
                            letters.addPath(letter, transform: t)
                        }
                        //                CGPathAddPath(letters, &t, letter)
                    }
                }
            }
            self = (letters.copy() ?? letters) as! Self
        }
    }

    public extension CTRun {
        var font: CTFont {
            let key = Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()
            let attributes = CTRunGetAttributes(self)
            let value = CFDictionaryGetValue(attributes, key)
            let font: CTFont = unsafeBitCast(value, to: CTFont.self)
            return font
        }

        var glyphCount: Int {
            CTRunGetGlyphCount(self)
        }

        func getGlyphs(_ range: CFRange, _: UnsafeMutablePointer<CGGlyph>) -> [CGGlyph] {
            var glyphs = [CGGlyph](repeating: CGGlyph(), count: range.length)
            CTRunGetGlyphs(self, range, &glyphs)
            return glyphs
        }
    }

#endif
