//
//  NSViewPropertyAnimator.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

#if os(macOS)
/*
import AppKit

public class NSViewPropertyAnimator {
    /// Initializes the animator with a timing function.
    public init(duration: TimeInterval, timingFunction: TimingFunction, animations: (() -> Void)?) {
        self.duration = duration
        self.timingFunction = timingFunction
        if let animations = animations {
            self.animations.append(animations)
        }
    }
    
    /// Initializes the animator object with a cubic Bézier timing curve.
    public init(duration: TimeInterval, controlPoint1: UnitBezier.ControlPoint, controlPoint2: UnitBezier.ControlPoint, animations: (() -> Void)?) {
        self.duration = duration
        self.timingFunction = .bezier(.init(first: controlPoint1, second: controlPoint2))
        if let animations = animations {
            self.animations.append(animations)
        }
    }
    
    ///  The total duration (in seconds) of the main animations.
    public internal(set) var duration: TimeInterval
    
    /// The delay (in seconds) after which the animations begin.
    public internal(set) var delay: TimeInterval = 0.0
    
    /// The information used to determine the timing curve for the animation.
    public internal(set) var timingFunction: TimingFunction? = nil
    
    /// A Boolean value indicating whether the animator is interruptible and can be paused or stopped.
    public var isInterruptible: Bool = true
    
    /// A Boolean value indicating whether views receive touch events while animations are running.
    public var isUserInteractionEnabled: Bool = false
    
    /// A Boolean value indicating whether a paused animation scrubs linearly or uses its specified timing information.
    public var scrubsLinearly: Bool = true

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool = false
    
    /// Adds the specified animation block to the animator.
    func addAnimations(_ animation: @escaping () -> Void) {
        
    }
    
    /**
     Adds the specified animation block with a delay.
     
     - Parameters:
        - animations: A block containing the animations you want to add to the animator object. This block has no return value and takes no parameters. This parameter must not be nil.
        - delayFactor: The factor to use for delaying the start of the animations. The value you specify must be between 0.0 and 1.0. This value is multiplied by the animator’s remaining duration to determine the actual delay in seconds. For example, specifying the value 0.5 when the duration is 2.0 results in a one second delay for the start of the animations.
     
     Use this method to add new animation blocks to the animator. The animations in the new block run alongside any previously configured animations after the specified delay. Blocks added while the animator’s state is NSViewAnimatingState.inactive are executed over the time specified by the duration property minus any delay. Blocks added while the animator’s state is NSViewAnimatingState.active are executed over the remaining portion of the total run time minus the delay. For example, if the duration is 2.0 and you add an animation block with a delay factor of 0.25 to a running animator whose fractionComplete property is 0.25, the animations run for 1.0 second.
     */
    func addAnimations(_ animation: @escaping () -> Void, delayFactor: CGFloat) {
        
    }
    
    /// Adds the specified completion block to the animator.
    func addCompletion(_ completion: @escaping (NSViewAnimatingPosition) -> Void) {
        completionHandlers.append(completion)
    }
    
    /// Starts the animation from its current position.
    func startAnimation() {
        guard state != .stopped, isRunning == false, animations.isEmpty == false else { return }
        isRunning = true
        if state == .inactive {
            state = .active
        }
    }
    
    func test() {
        var fun: [NSView: String] = [:]
    }
    
    /// Starts the animation after the specified delay.
    func startAnimation(afterDelay delay: TimeInterval) {
        guard state != .stopped, isRunning == false, animations.isEmpty == false else { return }
        let task = DispatchWorkItem {
            self.startAnimation()
        }
        delayTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }
    
    /// Pauses a running animation at its current position.
    func pauseAnimation() {
        guard state != .stopped else { return }
        delayTask?.cancel()
        if state == .inactive {
            state = .active
        }
        isRunning = false
    }
    
    /// Stops the animations at their current positions.
    func stopAnimation(_ withoutFinishing: Bool) {
        guard state != .stopped else { return }
        isRunning = false
        fractionComplete = 0.0
        isReversed = false
        animations.removeAll()
        if withoutFinishing == true {
            completionHandlers.removeAll()
            state = .inactive
        } else {
            state = .stopped
        }
    }
    
    /// Finishes the animations and returns the animator to the inactive state.
    public func finishAnimation(at finalPosition: NSViewAnimatingPosition) {
        guard state == .stopped else { return }
        completionHandlers.forEach({$0(finalPosition)})
        completionHandlers.removeAll()
        self.state = .inactive
    }
    
    /// The completion percentage of the animation.
    public var fractionComplete: CGFloat = 0.0
    
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false {
        didSet { guard oldValue != isReversed else { return }
            fractionComplete = 1.0 - fractionComplete
        }
    }
    
    /// The current state of the animation.
    public internal(set) var state: NSViewAnimatingState = .inactive
    
    /// A Boolean value indicating whether the animation is currently running.
    public internal(set) var isRunning: Bool = false
    
    internal var delayTask: DispatchWorkItem? = nil
    internal var animations: [(() -> Void)] = []
    internal var completionHandlers: [(NSViewAnimatingPosition) -> Void] = []
    internal var remainingAnimationTime: TimeInterval {
        return fractionComplete * duration
    }
}

public enum NSViewAnimatingPosition {
    /// The end point of the animation. Use this constant when you want the final values for any animatable properties—that is, you want to refer to the values you specified in your animation blocks.
    case end
    /// The beginning of the animation. Use this constant when you want the starting values for any animatable properties—that is, the values of the properties before you applied any animations.
    case start
    /// The current position. Use this constant when you want the most recent value set by an animator object.
    case current
}

public enum NSViewAnimatingState {
    /// The animations have not yet started executing. This is the initial state of the animator object.
    case inactive
    
    /// The animator object is active and animations are either running or paused. An animator moves to this state after the first call to startAnimation() or pauseAnimation(). It stays in the active state until the animations finish naturally or until you call the stopAnimation(_:) method.
    case active
    
    /// The animation is stopped. Putting an animation into this state ends the animation and leaves any animatable properties at their current values, instead of updating them to their intended final values. An animation cannot be started while in this state.
    case stopped
}
/*
 UnitBezier
 init(duration: TimeInterval, controlPoint1: CGPoint, controlPoint2: CGPoint, animations: (() -> Void)?)
 Initializes the animator object with a cubic Bézier timing curve.
 init(duration: TimeInterval, dampingRatio: CGFloat, animations: (() -> Void)?)
 Initializes the animator object with spring-based timing information.
 init(duration: TimeInterval, timingParameters: UITimingCurveProvider)
 Initializes the animator object with a custom timing curve object.
 class func runningPropertyAnimator(withDuration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, animations: () -> Void, completion: ((UIViewAnimatingPosition) -> Void)?) -> Self
 Creates and returns an animator object that begins running its animations immediately.

 */

/*



 var isManualHitTestingEnabled: Bool
 A Boolean value indicating whether your app manages hit-testing while animations are in progress.


 */
*/
#endif
