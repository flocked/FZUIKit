//
//  UIStackView+.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIStackView {
    /// Sets the axis along which the arranged views lay out.
    @discardableResult
    @objc open func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }
    
    /// Sets the alignment of the arranged subviews perpendicular to the stack view’s axis.
    @discardableResult
    @objc open func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// Sets the distribution of the arranged views along the stack view’s axis.
    @discardableResult
    @objc open func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }
    
    /// Sets the distance in points between the adjacent edges of the stack view’s arranged views.
    @discardableResult
    @objc open func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
    
    /// Sets the Boolean value that determines whether the vertical spacing between views is measured from their baselines.
    @discardableResult
    @objc open func isBaselineRelativeArrangement(_ isBaselineRelativeArrangement: Bool) -> Self {
        self.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        return self
    }
    
    /// Sets the Boolean value that determines whether the stack view lays out its arranged views relative to its layout margins.
    @discardableResult
    @objc open func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement: Bool) -> Self {
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        return self
    }
}

#endif
