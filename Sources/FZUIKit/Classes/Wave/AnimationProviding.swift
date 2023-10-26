//
//  AnimationProviding.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

internal protocol AnimationProviding {
    var id: UUID { get }
    var groupUUID: UUID? { get }
    var relativePriority: Int { get set }
    var state: AnimationState { get }

    func updateAnimation(dt: TimeInterval)
    func start(afterDelay delay: TimeInterval)
    func stop(immediately: Bool)
    func reset()
}

public enum AnimationEvent<T> {
    /**
     Indicates the animation has fully completed.
     */
    case finished(at: T)

    /**
     Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).

     - parameter from: The previous `target` value of the animation.
     - parameter to: The new `target` value of the animation.
     */
    case retargeted(from: T, to: T)
}
#endif
