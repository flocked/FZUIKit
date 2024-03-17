//
//  NSMagnificationGestureRecognizer+Velocity.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSMagnificationGestureRecognizer {
    
    /// The velocity of the magnification in scale factor per second.
    @objc dynamic public var velocity: CGFloat {
        get{
            swizzleGestureState()
            return getAssociatedValue("velocity", initialValue: 1.0)
        }
        set{ setAssociatedValue(newValue, key: "velocity") }
    }
    
    var prevMagnification: CGFloat {
        get{ return getAssociatedValue("prevMagnification", initialValue: magnification) }
        set{ setAssociatedValue(newValue, key: "prevMagnification") }
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
            let velocityDiff = magnification - prevMagnification
            velocity = (velocityDiff / timeInterval)
        }
        prevMagnification = magnification
    }
}

extension NSGestureRecognizer {
    var didSwizzleGestureState: Bool {
        get{ getAssociatedValue("didSwizzleGestureState", initialValue: false) }
        set{ setAssociatedValue(newValue, key: "didSwizzleGestureState") }
    }
    
    func swizzleGestureState() {
        guard didSwizzleGestureState == false else { return }
        didSwizzleGestureState = true
        do {
            try replaceMethod(
                #selector(setter: NSGestureRecognizer.state),
                methodSignature: (@convention(c)  (AnyObject, Selector, State) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, State) -> ()).self) { store in {
                   object, state in
                    (object as? NSMagnificationGestureRecognizer)?.updateVelocity()
                    (object as? NSRotationGestureRecognizer)?.updateVelocity()
                   store.original(object, #selector(setter: NSGestureRecognizer.state), state)
                }
           }
            (self as? NSMagnificationGestureRecognizer)?.updateVelocity()
        } catch {
            Swift.debugPrint(error)
        }
    }
}
#endif
