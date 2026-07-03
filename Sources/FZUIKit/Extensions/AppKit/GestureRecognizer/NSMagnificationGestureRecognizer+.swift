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
    @objc public private(set) dynamic var velocity: CGFloat {
        get {
            swizzleGestureState()
            return getAssociatedValue("velocity") ?? 1.0
        }
        set { setAssociatedValue(newValue, key: "velocity") }
    }
    
    private func updateVelocity() {
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
    
    private var time: CFTimeInterval {
        get { getAssociatedValue("time") ?? CACurrentMediaTime() }
        set { setAssociatedValue(newValue, key: "time") }
    }
    
    private var prevMagnification: CGFloat {
        get { getAssociatedValue("prevMagnification") ?? magnification }
        set { setAssociatedValue(newValue, key: "prevMagnification") }
    }
    
    private func swizzleGestureState() {
        guard stateHook == nil else { return }
        do {
            stateHook = try hook(#selector(setter: NSGestureRecognizer.state), closure: { original, gestureRecognizer, selector, state in
                gestureRecognizer.updateVelocity()
                original(gestureRecognizer, selector, state)
            } as @convention(block) ((NSMagnificationGestureRecognizer, Selector, State) -> Void, NSMagnificationGestureRecognizer, Selector, State) -> Void)
            updateVelocity()
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    private var stateHook: Hook? {
        get { getAssociatedValue("stateHook") }
        set { setAssociatedValue(newValue, key: "stateHook") }
    }
}
#endif
