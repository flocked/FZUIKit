//
//  VelocityMagnificationGestureRecognizer.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSObjectProtocol where Self: NSObject {
    /**
     Informs the observed object that the value of a given property is about to change.
     
     Use this method when implementing key-value observer compliance manually to inform the observed object that the value at key is about to change.
     The change type of this method is `NSKeyValueChangeSetting`.
     
     - Note: After the values have been changed, a corresponding ``didChangeValue(for:)`` must be invoked with the same parameter.
     
     - Parameter keyPath:The keypath of the property that will change.
     */
    public func willChangeValue(for keyPath: PartialKeyPath<Self>) {
        guard let key = keyPath._kvcKeyPathString else { return }
        willChangeValue(forKey: key)
    }
    
    /**
     Informs the observed object that the value of a given property has changed.
     
     Use this method when implementing key-value observer compliance manually to inform the observed object that the value at key has just changed. Calls to this method are always paired with a matching call to ``willChangeValue(for:)``.
     
     - Parameter keyPath:The keypath of the property that changed.
     */
    public func didChangeValue(for keyPath: PartialKeyPath<Self>) {
        guard let key = keyPath._kvcKeyPathString else { return }
        didChangeValue(forKey: key)
    }
}

extension NSMagnificationGestureRecognizer {
    
    /// The velocity of the magnification in scale factor per second.
    @objc dynamic public var velocity: CGFloat {
        get{
            swizzleGestureState()
            return getAssociatedValue(key: "velocity", object: self, initialValue: 1.0)
        }
        set{
            let keyPath: PartialKeyPath<Self> = \.velocity

            willChangeValue(for: \.velocity)
            willChangeValue(forKey: keyPath._kvcKeyPathString!)
            
            set(associatedValue: newValue, key: "velocity", object: self)

        }
     //   didChangeValue(forKey: self.)

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
        case .began, .cancelled:
            velocity = 1.0
        case .ended:
            break
        default:
            let timeInterval = time - previousTime
            let velocityDiff = magnification - prevMagnification
            let velocity = (velocityDiff / timeInterval)
            self.velocity = (velocity < -0) ? -velocity : velocity
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
