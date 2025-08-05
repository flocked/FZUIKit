//
//  TextLine.swift
//
//
//  Created by Florian Zand on 15.10.24.
//

import Foundation

/// A representation of a text line.
public struct TextLine {
    /// The frame of the text line.
    public let frame: CGRect
    
    /// The text of the line.
    public let text: String
    
    /// The frame of the text.
    public let textFrame: CGRect
    
    /// The range of the string.
    public let textRange: Range<String.Index>
    
    /// The range of the string.
    public let textNSRange: NSRange
    
    init(frame: CGRect, textFrame: CGRect, text: String, textRange: Range<String.Index>, textNSRange: NSRange) {
        self.frame = frame
        self.textFrame = textFrame
        self.text = text
        self.textRange = textRange
        self.textNSRange = textNSRange
    }
}
