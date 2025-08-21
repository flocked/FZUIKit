//
//  UIImageView+.swift
//  FZUIKit
//
//  Created by Florian Zand on 21.08.25.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIImageView {
    /// Sets the image displayed in the image view.
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the highlighted image displayed in the image view.
    @discardableResult
    public func highlightedImage(_ image: UIImage?) -> Self {
        self.highlightedImage = image
        return self
    }
    
    /// Sets an array of `UIImage` objects to use for an animation.
    @discardableResult
    public func animationImages(_ images: [UIImage]?) -> Self {
        self.animationImages = images
        return self
    }
    
    /// Sets an array of `UIImage` objects to use for an animation when the view is highlighted.
    @discardableResult
    public func highlightedAnimationImages(_ images: [UIImage]?) -> Self {
        self.highlightedAnimationImages = images
        return self
    }
    
    /// Sets the amount of time it takes to go through one cycle of the images.
    @discardableResult
    public func animationDuration(_ animationDuration: TimeInterval) -> Self {
        self.animationDuration = animationDuration
        return self
    }
    
    /// Sets the number of times to repeat the animation.
    @discardableResult
    public func animationRepeatCount(_ repeatCount: Int) -> Self {
        self.animationRepeatCount = repeatCount
        return self
    }
    
    /// Sets the Boolean value that determines whether the image is highlighted.
    @discardableResult
    public func isHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
    
    /// Sets the Boolean value that determines whether user events are ignored and removed from the event queue.
    @discardableResult
    public func isUserInteractionEnabled(_ isEnabled: Bool) -> Self {
        self.isUserInteractionEnabled = isEnabled
        return self
    }
    
    /// Sets the configuration values to use when rendering the image.
    @discardableResult
    public func symbolConfiguration(_ configuration: UIImage.SymbolConfiguration?) -> Self {
        self.preferredSymbolConfiguration = configuration
        return self
    }
}

#endif
