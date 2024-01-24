//
//  VelocityMagnificationGestureRecognizer.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSMagnificationGestureRecognizer {
    /// The velocity of the magnification in scale factor per second.
    public var _velocity: CGFloat {
        get { getAssociatedValue(key: "velocity", object: self, initialValue: 1.0) }
        set { set(associatedValue: newValue, key: "velocity", object: self)}
    }
    
    var didSwizzleState: Bool {
        get { 
            swizzleGestureState()
            return getAssociatedValue(key: "didSwizzleState", object: self, initialValue: false)
        }
        set { set(associatedValue: newValue, key: "didSwizzleState", object: self)}
    }
    
    func swizzleGestureState() {
        guard didSwizzleState == false else { return }
        didSwizzleState = true
        do {
            try replaceMethod(
                #selector(setter: NSGestureRecognizer.state),
                methodSignature: (@convention(c)  (AnyObject, Selector, State) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, State) -> ()).self) { store in {
                   object, state in
                    Swift.print("hhh")
                    if let gestureRecognizer = object as? NSMagnificationGestureRecognizer {
                        Swift.print("bbb")
                        let previousTime = gestureRecognizer.time
                        gestureRecognizer.time = CACurrentMediaTime()
                        switch state {
                        case .began, .cancelled:
                            gestureRecognizer._velocity = 1.0
                        case .ended:
                            break
                        default:
                            gestureRecognizer._velocity = gestureRecognizer.calculateVelocity(previousTime: previousTime)
                        }
                        gestureRecognizer.prevMagnification = gestureRecognizer.magnification
                    }
                   store.original(object, #selector(setter: NSGestureRecognizer.state), state)
                }
           }
        } catch {
            Swift.print(error)
        // handle error
        }
    }
    
    func calculateVelocity(previousTime: CFTimeInterval) -> CGFloat {
        let timeInterval = time - previousTime
        let velocityDiff = magnification - prevMagnification
        let velocity = (velocityDiff / timeInterval)
        return (velocity < -0) ? -velocity : velocity
    }
    
    var prevMagnification: CGFloat {
        get { getAssociatedValue(key: "prevMagnification", object: self, initialValue: 0.0) }
        set { set(associatedValue: newValue, key: "prevMagnification", object: self)}
    }
    
    
    var time: CFTimeInterval {
        get { getAssociatedValue(key: "time", object: self, initialValue: CACurrentMediaTime()) }
        set { set(associatedValue: newValue, key: "time", object: self)}
    }
    
    
}
    /// A `NSMagnificationGestureRecognizer` that includes the velocity.
    open class VelocityMagnificationGestureRecognizer: NSMagnificationGestureRecognizer {
        
        /// The velocity of the magnification in scale factor per second.
        open var velocity: CGFloat = 1.0
        
        var _prevMagnification = 1.0
        var _time = CACurrentMediaTime()

        override open var state: NSGestureRecognizer.State {
            didSet {
                let previousTime = _time
                _time = CACurrentMediaTime()
                switch state {
                case .began, .cancelled:
                    velocity = 1.0
                case .ended:
                    break
                default:
                    velocity = _calculateVelocity(previousTime: previousTime)
                }
                _prevMagnification = magnification
            }
        }
        
        func _calculateVelocity(previousTime: CFTimeInterval) -> CGFloat {
            let timeInterval = _time - previousTime
            let velocityDiff = magnification - _prevMagnification
            let velocity = (velocityDiff / timeInterval)
            return (velocity < -0) ? -velocity : velocity
        }
    }
#endif
