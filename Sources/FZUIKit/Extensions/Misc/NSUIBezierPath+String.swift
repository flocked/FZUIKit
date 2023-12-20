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
    
}

public protocol AttributedStringPath { }

extension CGPath: AttributedStringPath { }

extension AttributedStringPath where Self: CGPath {
    /// Creates and returns a path for the specified string and font.
    public init(string: String, font: NSUIFont) {
        let attributedString = NSAttributedString(string: string, attributes: [.font: font])
        self.init(attributedString: attributedString)
    }
    
    /// Creates and returns a new path for the specified attributed string.
    public init(attributedString: NSAttributedString) {
        let letters = CGMutablePath()
        let line = CTLineCreateWithAttributedString(attributedString)
        let anyArray = CTLineGetGlyphRuns(line) as [AnyObject]
        if let runArray = anyArray as? Array<CTRun> {
            for run in runArray {
                for runGlyphIndex in 0..<run.glyphCount {
                    let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                    var glyph : CGGlyph = 0
                    var position : CGPoint = CGPoint.zero
                    
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
    var font : CTFont {
            let key = Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()
            let attributes = CTRunGetAttributes(self)
            let value = CFDictionaryGetValue(attributes, key)
            let font:CTFont = unsafeBitCast(value, to: CTFont.self)
            return font
    }
    
    var glyphCount : Int {
        return CTRunGetGlyphCount(self)
    }
    
    func getGlyphs(_ range: CFRange, _ buffer: UnsafeMutablePointer<CGGlyph>) -> Array<CGGlyph> {
        var glyphs = Array<CGGlyph>(repeating: CGGlyph(), count: range.length)
        CTRunGetGlyphs(self, range, &glyphs)
        return glyphs
    }
}

#endif
