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
    @objc public internal(set) dynamic var velocity: CGFloat {
        get {
            swizzleGestureState()
            return FZSwiftUtils.getAssociatedValue("velocity", of: self) ?? 1.0
        }
        set { setAssociatedValue(newValue, for: "velocity") }
    }
    
    private func updateVelocity() {
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
    
    private var time: CFTimeInterval {
        get { FZSwiftUtils.getAssociatedValue("time", of: self) ?? CACurrentMediaTime() }
        set { setAssociatedValue(newValue, for: "time") }
    }
    
    private var prevRotation: CGFloat {
        get { FZSwiftUtils.getAssociatedValue("prevRotation", of: self) ?? rotation }
        set { setAssociatedValue(newValue, for: "prevRotation") }
    }
    
    private func swizzleGestureState() {
        guard stateHook == nil else { return }
        do {
            stateHook = try hook(#selector(setter: NSGestureRecognizer.state), closure: { original, gestureRecognizer, selector, state in
                gestureRecognizer.updateVelocity()
                original(gestureRecognizer, selector, state)
            } as @convention(block) ((NSRotationGestureRecognizer, Selector, State) -> Void, NSRotationGestureRecognizer, Selector, State) -> Void)
            updateVelocity()
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    private var stateHook: Hook? {
        get { FZSwiftUtils.getAssociatedValue("stateHook", of: self) }
        set { setAssociatedValue(newValue, for: "stateHook") }
    }
}

#endif
