//
//  NSTextContainer+.swift
//
//
//  Created by Florian Zand on 22.07.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSTextContainer {
    /// Sets the size of the text container’s bounding rectangle.
    @discardableResult
    public func size(_ size: CGSize) -> Self {
        self.size = size
        return self
    }
    
    /// Sets the bezier paths that represents the regions where text doesn’t display in the text container.
    @discardableResult
    public func exclusionPaths(_ exclusionPaths: [NSUIBezierPath]) -> Self {
        self.exclusionPaths = exclusionPaths
        return self
    }
        
    /// Sets the Boolean that controls whether the text container adjusts the width of its bounding rectangle when its text view resizes.
    @discardableResult
    public func widthTracksTextView(_ shouldTrack: Bool) -> Self {
        widthTracksTextView = shouldTrack
        return self
    }
    
    /// Sets the Boolean that controls whether the text container adjusts the height of its bounding rectangle when its text view resizes.
    @discardableResult
    public func heightTracksTextView(_ shouldTrack: Bool) -> Self {
        heightTracksTextView = shouldTrack
        return self
    }
    
    /// Sets the behavior of the last line inside the text container.
    @discardableResult
    public func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        self.lineBreakMode = lineBreakMode
        return self
    }
    
    /// Sets the maximum number of lines that the text container can store.
    @discardableResult
    public func maximumNumberOfLines(_ maximum: Int) -> Self {
        maximumNumberOfLines = maximum
        return self
    }
    
    /// Sets the value for the text inset within line fragment rectangles.
    @discardableResult
    public func lineFragmentPadding(_ padding: CGFloat) -> Self {
        lineFragmentPadding = padding
        return self
    }
}


#endif
