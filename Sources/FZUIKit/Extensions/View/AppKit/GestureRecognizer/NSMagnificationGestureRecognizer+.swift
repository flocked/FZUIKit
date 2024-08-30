//
//  NSMagnificationGestureRecognizer+Velocity.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSMagnificationGestureRecognizer: VelocityGestureRecognizer {
    
    /// The velocity of the magnification in scale factor per second.
    @objc dynamic public var velocity: CGFloat {
        get{
            swizzleGestureState()
            return getAssociatedValue("velocity") ?? 1.0
        }
        set{ setAssociatedValue(newValue, key: "velocity") }
    }
    
    var prevMagnification: CGFloat {
        get{ getAssociatedValue("prevMagnification") ?? magnification }
        set{ setAssociatedValue(newValue, key: "prevMagnification") }
    }
    
    var time: CFTimeInterval {
        get{ getAssociatedValue("time") ?? CACurrentMediaTime() }
        set{ setAssociatedValue(newValue, key: "time") }
    }
    
    func updateVelocity() {
        let prevTime = time
        time = CACurrentMediaTime()
        switch state {
        case .began: 
            velocity = 1.0
        case .changed:
            velocity = (magnification - prevMagnification) / (time - prevTime)
        default: break
        }
        prevMagnification = magnification
    }
}

extension NSGestureRecognizer {
    func swizzleGestureState() {
        guard !isMethodReplaced(#selector(setter: NSGestureRecognizer.state)) else { return }
        do {
            try replaceMethod(
                #selector(setter: NSGestureRecognizer.state),
                methodSignature: (@convention(c)  (AnyObject, Selector, State) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, State) -> ()).self) { store in {
                   object, state in
                    (object as? VelocityGestureRecognizer)?.updateVelocity()
                   store.original(object, #selector(setter: NSGestureRecognizer.state), state)
                }
           }
            (self as? VelocityGestureRecognizer)?.updateVelocity()
        } catch {
            Swift.debugPrint(error)
        }
    }
}

protocol VelocityGestureRecognizer: NSGestureRecognizer {
    func updateVelocity()
}

#endif
