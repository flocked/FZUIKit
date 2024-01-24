//
//  VelocityMagnificationGestureRecognizer.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
    import AppKit
    /// A continuous gesture recognizer that tracks a pinch gesture that magnifies content including the velocity of the magnification gesture.
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
                    velocity = calculateVelocity(previousTime: previousTime)
                }
                prevMagnification = magnification
            }
        }
        
        func calculateVelocity(previousTime: CFTimeInterval) -> CGFloat {
            let timeInterval = time - previousTime
            let velocityDiff = magnification - prevMagnification
            let velocity = (velocityDiff / timeInterval)
            return (velocity < -0) ? -velocity : velocity
        }
    }
#endif
