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
            return getAssociatedValue(key: "velocity", object: self, initialValue: 1.0)
        }
        set{ set(associatedValue: newValue, key: "velocity", object: self) }
    }
    
    var prevMagnification: CGFloat {
        get{ return getAssociatedValue(key: "prevMagnification", object: self, initialValue: 0.0) }
        set{ set(associatedValue: newValue, key: "prevMagnification", object: self) }
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
            let velocityDiff = magnification - prevMagnification
            self.velocity = (velocityDiff / timeInterval)
        }
        prevMagnification = magnification
    }
}

extension NSGestureRecognizer {
    var didSwizzleGestureState: Bool {
        get{ getAssociatedValue(key: "didSwizzleGestureState", object: self, initialValue: false) }
        set{ set(associatedValue: newValue, key: "didSwizzleGestureState", object: self) }
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
