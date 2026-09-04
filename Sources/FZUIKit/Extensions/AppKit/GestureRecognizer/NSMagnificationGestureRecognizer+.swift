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
            velocity = (magnification - prevMagnification) / (time - prevTime)
        default: break
        }
        prevMagnification = magnification
    }
    
    private var time: CFTimeInterval {
        get { FZSwiftUtils.getAssociatedValue("time", of: self) ?? CACurrentMediaTime() }
        set { setAssociatedValue(newValue, for: "time") }
    }
    
    private var prevMagnification: CGFloat {
        get { FZSwiftUtils.getAssociatedValue("prevMagnification", of: self) ?? magnification }
        set { setAssociatedValue(newValue, for: "prevMagnification") }
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
        get { FZSwiftUtils.getAssociatedValue("stateHook", of: self) }
        set { setAssociatedValue(newValue, for: "stateHook") }
    }
}
#endif
