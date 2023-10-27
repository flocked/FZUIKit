//
//  File.swift
//  
//
//  Created by Florian Zand on 27.10.23.
//

import AppKit



extension String {
    /**
     Returns a
     
     
     */
    func bezierPath(withFont font: NSUIFont) -> NSUIBezierPath {
        // create CTFont with NSUIFont
        let ctFont = CTFontCreateWithName(font.fontName as CFString,
                                          font.pointSize, nil)
        // create a container CGMutablePath for letter paths
        let letters = CGMutablePath()
        // create a NSAttributedString from self
        let attrString = NSAttributedString(string: self,
                                            attributes: [.font: font])
        // get CTLines from attributed string
        let line = CTLineCreateWithAttributedString(attrString)
        // get CTRuns from line
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        for run in runs {
            // number of gylph available
            let  glyphCount = CTRunGetGlyphCount(run)
            for i in 0 ..< glyphCount {
                // take one glyph from run
                let range = CFRangeMake(i, 1)
                // create array to hold glyphs, this should have array with one item
                var glyphs = [CGGlyph](repeating: 0,
                                       count: range.length)
                // create position holder
                var position = CGPoint()
                // get glyph
                CTRunGetGlyphs(run,
                               range,
                               &glyphs)
                // glyph postion
                CTRunGetPositions(run,
                                  range,
                                  &position)
                // append glyph path to letters
                for glyph in glyphs {
                    if let letter = CTFontCreatePathForGlyph(ctFont,
                                                             glyph, nil) {
                        letters.addPath(letter,
                                        transform: CGAffineTransform(translationX: position.x,
                                                                     y: position.y))
                    }
                }

            }
        }
        // following lines normalize path. this path is created with textMatrix so it should first be normalized to nomral matrix
        let lettersRotated = CGMutablePath()
        lettersRotated.addPath(letters,
                               transform: CGAffineTransform(scaleX: 1,
                                                            y: -1))
        let lettersMoved = CGMutablePath()
        lettersMoved.addPath(lettersRotated,
                             transform: CGAffineTransform(translationX: 0,
                                                          y: lettersRotated
                                                            .boundingBoxOfPath
                                                            .size
                                                            .height))
        // create NSUIBezierPath
        let bezier = NSUIBezierPath(cgPath: lettersMoved)
        return bezier
    }
}

extension NSUIBezierPath {
    
    convenience init(attributedString: NSAttributedString) {
        let cgPath = CGPath.attributedStringPath(attributedString)
        self.init(cgPath: cgPath)
    }
    
}

public protocol FunProt { }

extension CGPath: FunProt { }

extension FunProt where Self: CGPath {
    public init(attributedString: NSAttributedString) {
         self = CGPath.attributedStringPath(attributedString) as! Self
      //  let cgPath = CGPath.attributedStringPath(attributedString)
      //  self.init(cgPath: cgPath)
    }
}

extension CGPath {

    
    public static func attributedStringPath(_ attributedString: NSAttributedString) -> CGPath {
        let letters = CGMutablePath()
        
        let line = CTLineCreateWithAttributedString(attributedString)
        
        let anyArray = CTLineGetGlyphRuns(line) as [AnyObject]
        
        if let runArray = anyArray as? Array<CTRun>
        {
            for run in runArray
            {
                // for each glyph in run
                
                for runGlyphIndex in 0..<run.glyphCount //CTRunGetGlyphCount(run)
                {
                    // get glyph and position
                    let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                    var glyph : CGGlyph = 0
                    var position : CGPoint = CGPoint.zero
                    
                    CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                    
                    CTRunGetPositions(run, thisGlyphRange, &position)
                    
                    // Get PATH of outline
                    
                    if let letter = CTFontCreatePathForGlyph(run.font, glyph, nil)
                    {
                        let t = CGAffineTransform(translationX: position.x, y: position.y)
                        
                        letters.addPath(letter, transform: t)
                    }

                    
    //                CGPathAddPath(letters, &t, letter)
                }
            }
        }
        
        return letters.copy() ?? letters
    }
    
  
}

public extension CTRun
{
    var font : CTFont
        {
            let key = Unmanaged.passUnretained(kCTFontAttributeName).toOpaque()
            
            let attributes = CTRunGetAttributes(self)
            
            let value = CFDictionaryGetValue(attributes, key)
            
            let font:CTFont = unsafeBitCast(value, to: CTFont.self)
            
            return font
    }
    
    var glyphCount : Int
        {
            return CTRunGetGlyphCount(self)
    }
    
    func getGlyphs(_ range: CFRange, _ buffer: UnsafeMutablePointer<CGGlyph>) -> Array<CGGlyph>
    {
        var glyphs = Array<CGGlyph>(repeating: CGGlyph(), count: range.length)
        
        CTRunGetGlyphs(self, range, &glyphs)
        
        return glyphs
    }
}
