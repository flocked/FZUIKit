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
            return getAssociatedValue(key: "velocity", object: self, initialValue: 1.0)
        }
        set{ set(associatedValue: newValue, key: "velocity", object: self) }
    }
    
    var prevRotation: CGFloat {
        get{ return getAssociatedValue(key: "prevRotation", object: self, initialValue: rotation) }
        set{ set(associatedValue: newValue, key: "prevRotation", object: self) }
    }
    
    var time: CFTimeInterval {
        get{ return getAssociatedValue(key: "time", object: self, initialValue: CACurrentMediaTime()) }
        set{ set(associatedValue: newValue, key: "time", object: self) }
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
