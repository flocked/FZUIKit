//
//  NSStackView+.swift
//
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS)
import AppKit

extension NSStackView {
    /// Sets the horizontal or vertical layout direction of the stack view.
    @discardableResult
    @objc open func orientation(_ orientation: NSUserInterfaceLayoutOrientation) -> Self {
        self.orientation = orientation
        return self
    }
    
    /// Sets the view alignment within the stack view.
    @discardableResult
    @objc open func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// Sets the minimum spacing between adjacent views in the stack view.
    @discardableResult
    @objc open func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
    
    /// Sets the geometric padding, inside the stack view, surrounding its views.
    @discardableResult
    @objc open func edgeInsets(_ insets: NSEdgeInsets) -> Self {
        self.edgeInsets = insets
        return self
    }
    
    /// Sets the Boolean value that indicates whether the stack view removes hidden views from its view hierarchy.
    @discardableResult
    @objc open func detachesHiddenViews(_ detaches: Bool) -> Self {
        self.detachesHiddenViews = detaches
        return self
    }
    
    /// Sets the delegate object for the stack view.
    @discardableResult
    @objc open func delegate(_ delegate: NSStackViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}

#endif
