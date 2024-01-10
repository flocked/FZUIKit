//
//  KeyFrameAnimation_old.swift
//
//
//  Created by Florian Zand on 03.12.23.
//

/*
 #if os(macOS) || os(iOS) || os(tvOS)

 import Foundation
 import FZSwiftUtils

 public class KeyFrameAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
     /// A unique identifier for the animation.
     public let id = UUID()

     /// A unique identifier that associates an animation with an grouped animation block.
     public internal(set) var groupUUID: UUID?

     /// The relative priority of the animation.
     public var relativePriority: Int = 0

     /// The current state of the animation (`inactive`, `running`, or `ended`).
     public internal(set) var state: AnimationState = .inactive

     /// The delay (in seconds) after which the animations begin.
     public internal(set) var delay: TimeInterval = 0.0

     /// A Boolean value indicating whether the animation repeats indefinitely.
     public var repeats: Bool = false

     /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
     public var autoreverse: Bool = false

     /// A Boolean value indicating whether the animation is running in the reverse direction.
     public var isReversed: Bool = false

     /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries when the animation finishes. This helps prevent drawing frames between pixels, causing aliasing issues.
     public var integralizeValues: Bool = false

     /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
     public var autoStarts: Bool = false

     /// The keyframe of the animation.
     public var keyFrames: [KeyFrame]

     /// The total duration of the animation.
     public var duration: TimeInterval {
         self.keyFrames.compactMap({$0.totalDuration}).sum()
     }

     public var value: Value {
         get { Value(_value) }
         set { _value = newValue.animatableData }
     }

     var _value: Value.AnimatableData

     var fromValue: Value {
         get { Value(_fromValue) }
         set { _fromValue = newValue.animatableData }
     }

     var _fromValue: Value.AnimatableData

     internal var velocity: Value {
         get { Value(_velocity) }
         set { _velocity = newValue.animatableData }
     }

     internal var _velocity: Value.AnimatableData = .zero

     internal var target: Value {
         get { Value(_target) }
         set { }
     }

     internal var _target: Value.AnimatableData {
         get { keyFrames.last?._target ?? _value }
     }

     internal var fractionComplete: Double {
        runningTime / duration
     }

     /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
     public var valueChanged: ((_ currentValue: Value) -> Void)?

     /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     public var completion: ((_ event: AnimationEvent<Value>) -> Void)?

     var runningTime: TimeInterval = 0.0

     var delayedStart: DispatchWorkItem?

     var animationType: AnimationController.AnimationParameters.AnimationType {
         .decay
     }

     func keyFrame(for time: TimeInterval) -> (Value.AnimatableData, KeyFrame)? {
         var current: TimeInterval = 0.0
         for (index, keyFrame) in keyFrames.enumerated() {
             current += keyFrame.totalDuration
             if current > time {
                 if let keyFrame = keyFrames[safe: index-1] {
                     return  (keyFrames[safe: index-2]?._target ?? _fromValue, keyFrame)
                 }
             }
         }
         return nil
     }

     /// Configurates the animation with the specified settings.
     func configure(withSettings settings: AnimationController.AnimationParameters) {
         groupUUID = settings.groupID
         integralizeValues = settings.integralizeValues
         repeats = settings.repeats
         autoreverse = settings.autoreverse
     }

     func reset() {

     }

     var keyFrameFractionComplete = 0.0
     var currentKeyFrameIndex = 0

     /**
      Updates the progress of the animation with the specified delta time.

      - parameter deltaTime: The delta time.
      */
     public func updateAnimation(deltaTime: TimeInterval) {
         state = .running

         let isAnimated = !keyFrames.isEmpty

         guard deltaTime > 0.0 else { return }

         runningTime += deltaTime

         let previousValue = _value
         runningTime += deltaTime
         var startValue = isReversed ? _target :  _fromValue
         if let currentKeyFrame = keyFrames[safe: currentKeyFrameIndex], runningTime > currentKeyFrame.totalDuration {
             currentKeyFrameIndex = isReversed ? currentKeyFrameIndex - 1 : currentKeyFrameIndex - 1
             runningTime = currentKeyFrame.totalDuration - runningTime
             startValue = currentKeyFrame._target
             Swift.debugPrint("next", currentKeyFrameIndex, runningTime, startValue)
         }

         if let currentKeyFrame = keyFrames[safe: currentKeyFrameIndex] {
             if runningTime > currentKeyFrame.delay {
                 var fractionComplete = runningTime-currentKeyFrame.delay / currentKeyFrame.duration
                 if isReversed {
                     fractionComplete = 1.0 - fractionComplete
                 }
                 let resolvedFractionComplete = currentKeyFrame.timingFunction.solve(at: fractionComplete, duration: currentKeyFrame.duration)
               _value = startValue.interpolated(towards: currentKeyFrame._target, amount: resolvedFractionComplete)
             }
         }

         _velocity = (_value - previousValue).scaled(by: 1.0/deltaTime)

         let animationFinished = (keyFrames[safe: currentKeyFrameIndex] == nil) || !isAnimated

         if animationFinished {
             if repeats, isAnimated {
                 if autoreverse {
                     isReversed = !isReversed
                 }
                 runningTime = 0.0
                 currentKeyFrameIndex = isReversed ? keyFrames.count - 1 : 0
                 _value = isReversed ? _target : _fromValue
             } else {
                 _value = isReversed ? _fromValue : _target
             }
         }

         let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
         valueChanged?(callbackValue)

         if (animationFinished && !repeats) || !isAnimated {
             stop(at: .current)
         }

         /*
         let duration = self.duration
         let remainingTime = duration - runningTime

         var startValue: Value.AnimatableData? = nil
         var currentKeyFrame = keyFrames.first

             var time: TimeInterval = 0.0
             for (index, keyFrame) in keyFrames.enumerated() {
                 time += keyFrame.totalDuration

                 if time < runningTime {
                     currentKeyFrame = keyFrame
                 } else {

                 }
         }

         if isAnimated {
             let secondsElapsed = deltaTime/duration
             fractionComplete = isReversed ? (fractionComplete - secondsElapsed) : (fractionComplete + secondsElapsed)
             _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
         } else {
             fractionComplete = isReversed ? 0.0 : 1.0
             _value = isReversed ? _fromValue : _target
         }

         _velocity = (_value - previousValue).scaled(by: 1.0/deltaTime)

         let animationFinished = (isReversed ? runningTime <= 0.0 : runningTime >= duration) || !isAnimated

         if animationFinished {
             if repeats, isAnimated {
                 if autoreverse {
                     isReversed = !isReversed
                 }
                 runningTime = isReversed ? duration : 0.0
                 _value = _fromValue.interpolated(towards: _target, amount: resolvedFractionComplete)
             } else {
                 _value = isReversed ? _fromValue : _target
             }
         }

         let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
         valueChanged?(callbackValue)

         if (animationFinished && !repeats) || !isAnimated {
             stop(at: .current)
         }
          */
     }

     /**
      Creates a new animation with the specified initial value and keyframes.

      - Parameters:
         - value: The start value of the animation.
         - keyFrames: The keyFrames of the animation.
      */
     public init(value: Value, @KeyFrameBuilder _ keyFrames: () -> [KeyFrame]) {
         self._value = value.animatableData
         self._fromValue = _value
         self.keyFrames = keyFrames()
     }

     public func start(afterDelay delay: TimeInterval = 0.0) {
         precondition(delay >= 0, "Animation start delay must be greater or equal to zero.")
         guard state != .running else { return }

         let start = {
             AnimationController.shared.runAnimation(self)
         }

         delayedStart?.cancel()
         self.delay = delay

         if delay == .zero {
             start()
         } else {
             let task = DispatchWorkItem {
                 start()
             }
             delayedStart = task
             DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
         }
     }

     public func pause() {
         guard state == .running else { return }
         AnimationController.shared.stopAnimation(self)
         state = .inactive
         delayedStart?.cancel()
         delay = 0.0
     }

     public func stop(at position: AnimationPosition, immediately: Bool = true) {
         delayedStart?.cancel()
         delay = 0.0
         if immediately == false {
             switch position {
             case .start:
                 target = fromValue
             case .current:
                 target = value
             default: break
             }
         } else {
             AnimationController.shared.stopAnimation(self)
             state = .inactive
             switch position {
             case .start:
                 value = fromValue
                 valueChanged?(value)
             case .end:
                 value = target
                 valueChanged?(value)
             default: break
             }
             reset()
             velocity = .zero
             completion?(.finished(at: value))
         }
     }
 }

 public extension KeyFrameAnimation {
     struct KeyFrame {
         /// The target value of the keyframe.
         public var target: Value {
             get { Value(_target) }
         }

         let _target: Value.AnimatableData

         /// The total duration (in seconds) of the keyframe.
         public let duration: TimeInterval

         /// The timing function of the keyframe.
         public let timingFunction: TimingFunction

         /// The delay (in seconds) after which the keyframe begin.
         public let delay: TimeInterval

         internal var totalDuration: TimeInterval {
             duration + delay
         }

         public init(target: Value, duration: TimeInterval, timingFunction: TimingFunction, delay: TimeInterval = 0.0) {
             self._target = target.animatableData
             self.duration = duration
             self.timingFunction = timingFunction
             self.delay = delay
         }
     }
 }

 extension KeyFrameAnimation {
     /// A function builder type that produces an array of `NSMenuItem`s.
     @resultBuilder
     public enum KeyFrameBuilder {
         public static func buildBlock(_ block: [KeyFrame]...) -> [KeyFrame] {
             block.flatMap { $0 }
         }

         public static func buildExpression(_ expr: KeyFrame) -> [KeyFrame] {
             [expr]
         }
     }
 }

 extension KeyFrameAnimation.KeyFrame: CustomStringConvertible {
     public var description: String {
         """
         KeyFrame(
             target: \(target)
             duration: \(duration)
             timingFunction: \(timingFunction.name)
             delay: \(delay)
         )
         """
     }
 }

 extension KeyFrameAnimation: CustomStringConvertible {
     public var description: String {
         """
         KeyFrameAnimation<\(Value.self)>(
             uuid: \(id)
             groupUUID: \(groupUUID?.description ?? "nil")
             priority: \(relativePriority)
             state: \(state)

             value: \(value)
             target: \(target)
             keyFrames: \(keyFrames)

             fromValue: \(fromValue)
             fractionComplete: \(fractionComplete)

             duration: \(duration)
             isReversed: \(isReversed)
             repeats: \(repeats)
             autoreverse: \(autoreverse)
             integralizeValues: \(integralizeValues)
             autoStarts: \(autoStarts)

             callback: \(String(describing: valueChanged))
             completion: \(String(describing: completion))
         )
         """
     }
 }

 #endif

 */
