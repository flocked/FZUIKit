//
//  NSRotationGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSRotationGestureRecognizer: VelocityGestureRecognizer {
    
    /// The velocity of the rotation gesture in radians per second.
    @objc dynamic public internal(set) var velocity: CGFloat {
        get{
            swizzleGestureState()
            return getAssociatedValue("velocity") ?? 1.0
        }
        set{ setAssociatedValue(newValue, key: "velocity") }
    }
    
    var prevRotation: CGFloat {
        get{ getAssociatedValue("prevRotation") ?? rotation }
        set{ setAssociatedValue(newValue, key: "prevRotation") }
    }
    
    func updateVelocity() {
        let prevTime = time
        time = CACurrentMediaTime()
        switch state {
        case .began:
            velocity = 1.0
        case .changed:
            velocity = (rotation - prevRotation) / (time - prevTime)
        default: break
        }
        prevRotation = rotation
    }
}

#endif
