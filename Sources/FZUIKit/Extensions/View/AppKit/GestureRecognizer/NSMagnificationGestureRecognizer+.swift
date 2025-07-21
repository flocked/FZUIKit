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
    @objc dynamic public private(set) var velocity: CGFloat {
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

extension VelocityGestureRecognizer {
    func swizzleGestureState() {
        guard !isMethodHooked(#selector(setter: NSGestureRecognizer.state)) else { return }
        do {
            try hook(#selector(setter: NSGestureRecognizer.state), closure: { original, object, sel, state in
                (object as? VelocityGestureRecognizer)?.updateVelocity()
                original(object, sel, state)
            } as @convention(block) (
                (AnyObject, Selector, State) -> Void,
                AnyObject, Selector, State) -> Void)
            updateVelocity()
        } catch {
            Swift.debugPrint(error)
        }
    }
}

protocol VelocityGestureRecognizer: NSGestureRecognizer {
    func updateVelocity()
}

#endif
