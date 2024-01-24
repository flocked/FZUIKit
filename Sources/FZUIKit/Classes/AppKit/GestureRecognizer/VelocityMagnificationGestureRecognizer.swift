//
//  VelocityMagnificationGestureRecognizer.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

    /// A `NSMagnificationGestureRecognizer` that includes the velocity.
    open class VelocityMagnificationGestureRecognizer: NSMagnificationGestureRecognizer {
        
        /// The velocity of the magnification in scale factor per second.
        open var velocity: CGFloat = 1.0
        
        var prevMagnification = 1.0
        var time = CACurrentMediaTime()

        override open var state: NSGestureRecognizer.State {
            didSet {
                let previousTime = time
                time = CACurrentMediaTime()
                switch state {
                case .began, .cancelled:
                    velocity = 1.0
                case .ended:
                    break
                default:
                    let timeInterval = time - previousTime
                    let velocityDiff = magnification - prevMagnification
                    let velocity = (velocityDiff / timeInterval)
                    self.velocity = (velocity < -0) ? -velocity : velocity
                }
                prevMagnification = magnification
            }
        }
    }
#endif
