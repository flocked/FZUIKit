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
        
        var prevDate: Date = .init()
        var prevMagnification = 1.0

        func calculateVelocity() -> CGFloat {
            let timeInterval = Date().timeIntervalSince(prevDate)
            let velocityDiff = magnification - prevMagnification
            let velocity = (velocityDiff / timeInterval)
            return (velocity < -0) ? -velocity : velocity
        }

        override public var state: NSGestureRecognizer.State {
            didSet {
                switch state {
                case .began:
                    velocity = 1.0
                case .ended:
                    break
                default:
                    velocity = calculateVelocity()
                }
                prevDate = Date()
                prevMagnification = magnification
            }
        }
    }
#endif
