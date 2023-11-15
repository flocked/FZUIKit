//
//  AnimationEvent.swift
//  
//
//  Created by Florian Zand on 15.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public enum AnimationEvent<Value> {
    /// Indicates the animation has fully completed.
    case finished(at: Value)

    /**
     Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).

     - parameter from: The previous `target` value of the animation.
     - parameter to: The new `target` value of the animation.
     */
    case retargeted(from: Value, to: Value)
}

#endif
