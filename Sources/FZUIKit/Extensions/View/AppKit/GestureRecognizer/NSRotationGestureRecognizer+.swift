//
//  NSRotationGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSRotationGestureRecognizer {
    
    /// The velocity of the rotation gesture in radians per second.
    @objc dynamic public var velocity: CGFloat {
        get{
            swizzleGestureState()
            return getAssociatedValue("velocity", initialValue: 1.0)
        }
        set{ setAssociatedValue(newValue, key: "velocity") }
    }
    
    var prevRotation: CGFloat {
        get{ return getAssociatedValue("prevRotation", initialValue: rotation) }
        set{ setAssociatedValue(newValue, key: "prevRotation") }
    }
    
    var time: CFTimeInterval {
        get{ return getAssociatedValue("time", initialValue: CACurrentMediaTime()) }
        set{ setAssociatedValue(newValue, key: "time") }
    }
    
    func updateVelocity() {
        let previousTime = time
        time = CACurrentMediaTime()
        switch state {
        case .began:
            velocity = 1.0
        case .ended, .cancelled:
            break
        default:
            let timeInterval = time - previousTime
            let velocityDiff = rotation - prevRotation
            velocity = (velocityDiff / timeInterval)
        }
        prevRotation = rotation
    }
}

#endif
