//
//  NSView+Animate.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSView {
    /**
     Animate changes to the view using the specified duration, timing function, options, and completion handler.
     
     - Parameters:
        - duration:The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
        - timingFunction: The timing function of the animations.
        - animations: A block object containing the changes to commit to the view. This is where you programmatically change any animatable properties of the view.
        - completion: A block to be executed when the animation sequence ends.
     */
    func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: @escaping (Self) -> Void, completion: (() -> Void)? = nil) {
        Self.animate(duration: duration, timingFunction: timingFunction, animations: {
            animations(self.animator() as! Self)
        }, completion: completion)
    }

    /**
     Animate changes to one or more views using the specified duration, timingFunction, options, and completion handler.

     - Parameters:
        - duration:The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
        - timingFunction: The timing function of the animations.
        - animations: A block object containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy. This block takes no parameters and has no return value.
        - completion: A block to be executed when the animation sequence ends.
     */
    static func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup {
            context in
            context.duration = duration
            context.timingFunction = timingFunction ?? context.timingFunction
            context.allowsImplicitAnimation = true
            context.completionHandler = completion
            animations()
        }
    }
    
    /**
     Adds a view animated to the end of the receiver’s list of subviews.
     
     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - animated: A Boolean value that indicates whether the view should be added animated.
     */
    func addSubview(_ view: NSView, animated: Bool) {
        if animated {
            view.alphaValue = 0.0
            self.addSubview(view)
            NSAnimationContext.runAnimationGroup({context in
                view.animator().alphaValue = 1.0
            })
        } else {
            self.addSubview(view)
        }
    }
    
    @discardableResult
    /**
     Adds a view animated to the end of the receiver’s list of subviews and constraits it's frame to the receiver.
     
     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - animated: A Boolean value that indicates whether the view should be added animated.
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    func addSubview(withConstraint view: NSView, animated: Bool) -> [NSLayoutConstraint] {
        if animated {
            view.alphaValue = 0.0
           let constraints = self.addSubview(withConstraint: view)
            NSAnimationContext.runAnimationGroup({context in
                view.animator().alphaValue = 1.0
            })
            return constraints
        } else {
           return self.addSubview(withConstraint: view)
        }
    }
    
    /**
     Removes the view from it's superview animated.
     
     - Parameters animated: A Boolean value that indicates whether the view should be removed animated.
     */
    func removeFromSuperview(animated: Bool) {
        if animated {
            NSAnimationContext.runAnimationGroup({context in
                self.animator().alphaValue = 0.0
            }, completionHandler: {
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
}

#endif
