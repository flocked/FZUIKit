//
//  TextLine.swift
//
//
//  Created by Florian Zand on 15.10.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/*
/// A representation of a text line.
public struct TextLine {
    /// The frame of the text line.
    public let frame: CGRect
    
    /// The text of the line.
    public let text: String
    
    /// The frame of the text.
    public let textFrame: CGRect
    
    /// The range of the text.
    public let textRange: NSRange
    
    /// The frames of each character in the line.
    public let characterFrames: [CGRect]
    
    init?(frame: CGRect, textFrame: CGRect, text: String, range: NSRange, characterFrames: [CGRect] = []) {
        guard frame != .zero else { return nil }
        self.frame = frame
        self.textFrame = textFrame
        self.text = text
        self.textRange = range
        self.characterFrames = characterFrames
    }
}
*/

/// A representation of a text line.
public struct TextLine {
    /// The frame of the text line.
    public let frame: CGRect
    
    /// The text of the line.
    public let text: String
    
    /// The characters of the line.
    public let characters: [LineCharacter]
    
    /// The frame of the text.
    public let textFrame: CGRect
    
    /// The range of the text.
    public let textRange: NSRange
    
    /**
     The bezier path of the text.
     
     It only returns a bezier path for the text if the text line includes ``characters``.
     
     To include characters for text lines, set `includeCharacters` of  ``TextProvider/textLines(includeCharacters:onlyVisible:useMaximumNumberOfLines:)``
     
     */
    public var textBezierPath: NSUIBezierPath {
        characters.reduce(into: .init()) { $0.append($1.bezierPath) }
    }
    
    /// A character in a text line.
    public struct LineCharacter {
        /// The character.
        let character: Character
        /// The frame of the character.
        let frame: CGRect
        /// The bezier path of the character.
        let bezierPath: NSUIBezierPath
        /// The range of the character.
        let range: NSRange
        
        init(_ character: Character, frame: CGRect, bezierPath: NSUIBezierPath, index: Int) {
            self.character = character
            self.frame = frame
            self.bezierPath = bezierPath
            self.range = NSRange(location: index, length: 1)
        }
    }
    
    init(frame: CGRect, textFrame: CGRect, textRange: NSRange, text: String, characters: [LineCharacter]) {
        self.frame = frame
        self.textFrame = textFrame
        self.text = text
        self.textRange = textRange
        self.characters = characters
    }
}

extension Sequence where Element == TextLine {
    /// The bezier path of the text lines.
    public var bezierPath: NSUIBezierPath {
        reduce(into: .init()) { $0.append($1.textBezierPath) }
    }
}
#endif
