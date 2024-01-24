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
    public var velocity: CGFloat {
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
                    if let recognizer = object as? NSMagnificationGestureRecognizer {
                        let previousTime = recognizer.time
                        recognizer.time = CACurrentMediaTime()
                        switch state {
                        case .began, .cancelled:
                            recognizer.velocity = 1.0
                        case .ended:
                            break
                        default:
                            let timeInterval = recognizer.time - previousTime
                            let velocityDiff = recognizer.magnification - recognizer.prevMagnification
                            let velocity = (velocityDiff / timeInterval)
                            recognizer.velocity = (velocity < -0) ? -velocity : velocity
                        }
                        recognizer.prevMagnification = recognizer.magnification
                    }
                    Swift.print("ssss")
                   store.original(object, #selector(setter: NSGestureRecognizer.state), state)
                }
           }
        } catch {
        // handle error
        }
    }
}

/*
    /// A `NSMagnificationGestureRecognizer` that includes the velocity.
    open class VelocityMagnificationGestureRecognizer: NSMagnificationGestureRecognizer {
        
        /// The velocity of the magnification in scale factor per second.
        open var velocity: CGFloat = 1.0
        
        var prevMagnification = 1.0
        var time = CACurrentMediaTime()

        override open var state: NSGestureRecognizer.State {
            didSet {
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
    }
 */
#endif
