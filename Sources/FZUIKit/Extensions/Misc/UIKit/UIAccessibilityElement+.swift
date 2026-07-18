//
//  UIAccessibilityElement+.swift
//
//
//  Created by Florian Zand on 18.07.26.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UIAccessibilityElement {
    /// Sets the string that succinctly identifies the accessibility element.
    @discardableResult
    func accessibilityLabel(_ label: String?) -> Self {
        accessibilityLabel = label
        return self
    }
    
    /// Sets the string that briefly describes the result of performing an action on the accessibility element.
    @discardableResult
    func accessibilityHint(_ hint: String?) -> Self {
        accessibilityHint = hint
        return self
    }
    
    /// Sets the string that represents the current value of the accessibility element.
    @discardableResult
    func accessibilityValue(_ value: String?) -> Self {
        accessibilityValue = value
        return self
    }
    
    /// Sets the frame of the accessibility element, in screen coordinates.
    @discardableResult
    func accessibilityFrame(_ frame: CGRect) -> Self {
        accessibilityFrame = frame
        return self
    }
    
    /// Sets the frame of the accessibility element, in the coordinate space of its container view.
    @discardableResult
    func accessibilityFrameInContainerSpace(_ containerSpace: CGRect) -> Self {
        accessibilityFrameInContainerSpace = containerSpace
        return self
    }
    
    /// Sets the Boolean value indicating whether the item is an accessibility element an assistive application can access.
    @discardableResult
    func isAccessibilityElement(_ isAccessibilityElement: Bool) -> Self {
        self.isAccessibilityElement = isAccessibilityElement
        return self
    }
    
    /// Sets the combination of traits that best characterize the accessibility element.
    @discardableResult
    func accessibilityTraits(_ traits: UIAccessibilityTraits) -> Self {
        accessibilityTraits = traits
        return self
    }
}

public extension UIView {
    /// Sets the string that succinctly identifies the view.
    @discardableResult
    func accessibilityLabel(_ label: String?) -> Self {
        accessibilityLabel = label
        return self
    }
    
    /// Sets the string that briefly describes the result of performing an action on the view.
    @discardableResult
    func accessibilityHint(_ hint: String?) -> Self {
        accessibilityHint = hint
        return self
    }
    
    /// Sets the string that represents the current value of the view.
    @discardableResult
    func accessibilityValue(_ value: String?) -> Self {
        accessibilityValue = value
        return self
    }
    
    /// Sets the frame of the view, in screen coordinates.
    @discardableResult
    func accessibilityFrame(_ frame: CGRect) -> Self {
        accessibilityFrame = frame
        return self
    }
    
    /// Sets the Boolean value indicating whether the view is an accessibility element an assistive application can access.
    @discardableResult
    func isAccessibilityElement(_ isAccessibilityElement: Bool) -> Self {
        self.isAccessibilityElement = isAccessibilityElement
        return self
    }
    
    /// Sets the combination of traits that best characterize the view.
    @discardableResult
    func accessibilityTraits(_ traits: UIAccessibilityTraits) -> Self {
        accessibilityTraits = traits
        return self
    }
}

public extension UIBarItem {
    /// Sets the string that succinctly identifies the bar item.
    @discardableResult
    func accessibilityLabel(_ label: String?) -> Self {
        accessibilityLabel = label
        return self
    }
    
    /// Sets the string that briefly describes the result of performing an action on the bar item.
    @discardableResult
    func accessibilityHint(_ hint: String?) -> Self {
        accessibilityHint = hint
        return self
    }
    
    /// Sets the string that represents the current value of the bar item.
    @discardableResult
    func accessibilityValue(_ value: String?) -> Self {
        accessibilityValue = value
        return self
    }
    
    /// Sets the frame of the bar item, in screen coordinates.
    @discardableResult
    func accessibilityFrame(_ frame: CGRect) -> Self {
        accessibilityFrame = frame
        return self
    }
    
    /// Sets the Boolean value indicating whether the bar item is an accessibility element an assistive application can access.
    @discardableResult
    func isAccessibilityElement(_ isAccessibilityElement: Bool) -> Self {
        self.isAccessibilityElement = isAccessibilityElement
        return self
    }
    
    /// Sets the combination of traits that best characterize the bar item.
    @discardableResult
    func accessibilityTraits(_ traits: UIAccessibilityTraits) -> Self {
        accessibilityTraits = traits
        return self
    }
}
#endif
