//
//  AnimationProviding+Property.swift
//
//
//  Created by Florian Zand on 26.11.23.
//

/*
 #if os(macOS) || os(iOS) || os(tvOS)

 import Foundation
 import FZSwiftUtils

 /**
  An animation that animates an animatable property conforming to ``AnimatableProperty``.

  It provides default implementations for ``start(afterDelay:)``, ``pause()`` and ``stop(at:immediately:)``. They manage the ``state``  and add/remove the animation from the shared `AnimationController`.

  If you don't use the default implementations, you have to manually mange the ``state`` of the animation and:
  - Start the animation via `AnimationController.shared.runAnimation(yourAnimation)`.
  - Pause or stop the animation via  `AnimationController.shared.stopAnimation(yourAnimation)`.
  */
 public protocol PropertyAnimationProviding<Value>: AnyObject, AnimationProviding {
     associatedtype Value: AnimatableProperty
     var state: AnimationState { get set }
     /// The current value of the animation. This value will change as the animation executes.
     var value: Value { get set }
     /// The start value of the animation.
     var fromValue: Value { get set }
     /// The target value of the animation.
     var toValue: Value { get set }
     /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     var completion: ((_ event: AnimationEvent<Value>) -> Void)? { get set }
     /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
     var valueChanged: ((_ currentValue: Value) -> Void)? { get set }
     /// Resets the animation.
     func reset()
 }

 public extension PropertyAnimationProviding {
     func start(afterDelay delay: TimeInterval = 0.0) {
         precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
         guard state != .running else { return }

         let start = {
             AnimationController.shared.runAnimation(self)
         }

         self.delayedStart?.cancel()

         if delay == .zero {
             start()
         } else {
             let task = DispatchWorkItem {
                 start()
             }
             self.delayedStart = task
             DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
         }
     }

     func pause() {
         guard state == .running else { return }
         self.state = .inactive
         self.delayedStart?.cancel()
         AnimationController.shared.stopAnimation(self)
     }

     func stop(at position: AnimationPosition = .current, immediately: Bool = true) {
         guard state == .running else { return }
         self.delayedStart?.cancel()
         if immediately == false {
             switch position {
             case .start:
                 self.toValue = fromValue
             case .current:
                 self.toValue = value
             default: break
             }
         } else {
             self.state = .ended
             switch position {
             case .start:
                 self.value = fromValue
                 self.valueChanged?(value)
             case .end:
                 self.value = toValue
                 self.valueChanged?(value)
             default: break
             }
             self.toValue = value
            // (self as? (any AnimationVelocityProviding))?.setVelocity(Value.zero)
             self.completion?(.finished(at: value))
             AnimationController.shared.stopAnimation(self)
         }
     }

     func reset() {

     }

     internal var delayedStart: DispatchWorkItem? {
         get { getAssociatedValue(key: "delayedStart", object: self, initialValue: nil) }
         set { set(associatedValue: newValue, key: "delayedStart", object: self) }
     }
 }

 #endif
 */
