//
//  VelocityMagnificationGestureRecognizer.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
    import AppKit
    public class VelocityMagnificationGestureRecognizer: NSMagnificationGestureRecognizer {
        public var velocity: CGFloat = 1.0
        internal var prevDate: Date = .init()
        internal var prevMagnification = 1.0

        internal func calculateVelocity() -> CGFloat {
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
