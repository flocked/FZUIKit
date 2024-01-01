//
//  KeyFrameAnimation.swift
//  
//
//  Created by Florian Zand on 15.12.23.
//

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
    
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``target`` value changes.
    public var autoStarts: Bool = false
    
    /// The keyframe of the animation.
    public var keyFrames: [KeyFrame] = []
    
    var currentKeyFrameIndex = 0
    
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
    
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?
        
    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    var runningTime: TimeInterval = 0.0
    
    var delayedStart: DispatchWorkItem?
    
    var animationType: AnimationController.AnimationParameters.AnimationType {
        .decay
    }
    
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupID
        integralizeValues = settings.integralizeValues
    }
    
    func reset() {
        keyFrameAnimation?.stop()
        keyFrameAnimation = nil
        currentKeyFrameIndex = 0
        didSetKeyframeDelay = false
    }
    
    var currentKeyFrame: KeyFrame? {
        keyFrames[safe: currentKeyFrameIndex]
    }
    
    func keyFrameAnimationCompleted(_ event: AnimationEvent<Value>) {
        Swift.debugPrint("keyFrameAnimationCompleted", currentKeyFrameIndex, event.isFinished, event.isRetargeted, keyFrameAnimation ?? "nil", keyFrameAnimation?.id ?? "nil")
        if event.isFinished {
            currentKeyFrameIndex += 1
            keyFrameAnimation = nil
        }
    }
    
    var didSetKeyframeDelay = false
    func setupKeyframeAnimation(_ animation: some ConfigurableAnimationProviding<Value>, updateVelocity: Bool = false, delay: TimeInterval) {
        var animation = animation
        animation.completion = keyFrameAnimationCompleted
        animation.valueChanged = { newValue in
            self.value = newValue
            self._velocity = animation._velocity
            self.valueChanged?(newValue)
        }
        if updateVelocity {
            animation._velocity = _velocity
        }
        animation.integralizeValues = integralizeValues
        animation.start(afterDelay: delay)
        keyFrameAnimation = animation
    }
    
    /**
     Updates the progress of the animation with the specified delta time.
     
     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running
                
        guard deltaTime > 0.0 else { return }
        
        let isAnimated = !keyFrames.isEmpty && currentKeyFrameIndex < keyFrames.count
        
        if let keyFrame = currentKeyFrame {
            if keyFrameAnimation == nil {
                switch keyFrame.mode {
                case .spring(let spring):
                    let animation = SpringAnimation(spring: spring, value: value, target: keyFrame.target)
                    setupKeyframeAnimation(animation, updateVelocity: true, delay: keyFrame.delay)
                case .easing(let timingFunction, let duration):
                    let animation = EasingAnimation(timingFunction: timingFunction, duration: duration, value: value, target: target)
                    setupKeyframeAnimation(animation, delay: keyFrame.delay)
                case .decay(let decelerationRate):
                    let animation = DecayAnimation(value: value, target: keyFrame.target, decelerationRate: decelerationRate)
                    setupKeyframeAnimation(animation, delay: keyFrame.delay)
                case .move:
                    let move = {
                        self.didSetKeyframeDelay = false
                        self.value = keyFrame.target
                        self.currentKeyFrameIndex += 1
                    }
                    
                    delayedStart?.cancel()

                    if keyFrame.delay == .zero {
                        move()
                    } else if didSetKeyframeDelay == false {
                        didSetKeyframeDelay = true
                        let task = DispatchWorkItem {
                            move()
                        }
                        delayedStart = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
                    }
                }
            } else {
                /*
                if let keyFrameAnimation = keyFrameAnimation {
                 //   keyFrameAnimation.updateAnimation(deltaTime: deltaTime)
                }
                 */
            }
        }
        
        let animationFinished = (keyFrames[safe: currentKeyFrameIndex] == nil) || !isAnimated

        if animationFinished {
            _value = isReversed ? _fromValue : _target
            
            let callbackValue = integralizeValues ? value.scaledIntegral : value
            valueChanged?(callbackValue)
        }
        
   //     let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
   //     valueChanged?(callbackValue)

        if animationFinished || !isAnimated {
            stop(at: .current)
        }
    }
    
    var keyFrameAnimation: (any ConfigurableAnimationProviding)? = nil
    
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
        keyFrameAnimation?.pause()
        AnimationController.shared.stopAnimation(self)
        state = .inactive
        delayedStart?.cancel()
        delay = 0.0
    }
        
    public func stop(at position: AnimationPosition, immediately: Bool = true) {
        delayedStart?.cancel()
        keyFrameAnimation?.stop()
        delay = 0.0
        if immediately == false {
            switch position {
            case .start:
                (keyFrameAnimation as? DecayAnimation<Value>)?.target = fromValue
                (keyFrameAnimation as? EasingAnimation<Value>)?.target = fromValue
                (keyFrameAnimation as? SpringAnimation<Value>)?.target = fromValue
            case .current:
                (keyFrameAnimation as? DecayAnimation<Value>)?.target = value
                (keyFrameAnimation as? EasingAnimation<Value>)?.target = value
                (keyFrameAnimation as? SpringAnimation<Value>)?.target = value
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
        enum Mode {
            case spring(Spring)
            case easing(TimingFunction, TimeInterval)
            case decay(Double)
            case move
            
            var decelerationRate: Double? {
                switch self {
                case .decay(let decelerationRate): return decelerationRate
                default: return nil
                }
            }
            
            var spring: Spring? {
                switch self {
                case .spring(let spring): return spring
                default: return nil
                }
            }
            
            var timingFunction: TimingFunction? {
                switch self {
                case .easing(let timingFunction, _): return timingFunction
                default: return nil
                }
            }
            
            var duration: TimeInterval? {
                switch self {
                case .easing(_, let duration): return duration
                default: return nil
                }
            }
        }
        
        /// A spring animated keyframe.
        public init(withSpring spring: Spring, target: Value, delay: TimeInterval = 0.0) {
            _target = target.animatableData
            mode = .spring(spring)
            self.delay = delay
        }
        
        /// An easing animated keyframe.
        public init(withEasing timingFunction: TimingFunction, duration: TimeInterval, target: Value, delay: TimeInterval = 0.0) {
            _target = target.animatableData
            mode = .easing(timingFunction, duration)
            self.delay = delay
        }
        
        /// A decay animated keyframe.
        public init(withDecay target: Value, decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate, delay: TimeInterval = 0.0) {
            _target = target.animatableData
            self.mode = .decay(decelerationRate)
            self.delay = delay
        }
        
        /// A  keyframe that moves immediately to the target.
        public init(target: Value, delay: TimeInterval = 0.0) {
            _target = target.animatableData
            self.mode = .move
            self.delay = delay
        }
        
        /// The delay (in seconds) after which the keyframe begin.
        public let delay: TimeInterval
        
        /// The target value of the keyframe.
        public var target: Value {
            get { Value(_target) }
        }
        
        let _target: Value.AnimatableData

        let mode: Mode
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

            isReversed: \(isReversed)
            integralizeValues: \(integralizeValues)
            autoStarts: \(autoStarts)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}

#endif
