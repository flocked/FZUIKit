//
//  NSViewAnimatorController.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS)
import Combine
import AppKit

/*
internal class NSViewAnimatorController {
    static let shared = NSViewAnimatorController()

    private var displayLink: AnyCancellable?

    private var animatorStack = AnimatorStack()


    var currentAnimator: NSViewPropertyAnimator? {
        animatorStack.currentAnimator
    }

    func runAnimationBlock(
        settings: AnimationParameters,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        // Register the handler
        groupAnimationCompletionBlocks[settings.groupUUID] = completion

        animationSettingsStack.push(settings: settings)
        animations()
        animationSettingsStack.pop()
    }

    func runPropertyAnimation(_ animation: AnimationProviding) {
        if animations.isEmpty {
            startDisplayLink()
        }

        animations[animation.id] = animation

        animation.updateAnimation(deltaTime: .zero)
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLink != nil else {
            fatalError("Can't update animations without a display link")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let dt = frame.duration
        
        let sortedAnimations = animations.values.sorted { lhs, rhs in
            lhs.relativePriority > rhs.relativePriority
        }

        for animation in sortedAnimations {
            if animation.state == .ended {
                animation.reset()
                animations.removeValue(forKey: animation.id)
            } else {
                animation.updateAnimation(deltaTime: dt)
            }
        }

        CATransaction.commit()

        if animations.isEmpty {
            stopDisplayLink()
        }
    }

    private func startDisplayLink() {
        if displayLink == nil {
            displayLink = DisplayLink.shared.sink { [weak self] frame in
                if let self = self {
                    self.updateAnimations(frame)
                }
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.cancel()
        displayLink = nil
    }

    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid = uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }

        block(finished, retargeted)

        if retargeted == false, finished {
            groupAnimationCompletionBlocks.removeValue(forKey: uuid)
        }
    }
}

extension NSViewAnimatorController {
    struct AnimationParameters {
        let groupUUID: UUID
        let spring: Spring
      //   let mode: Wave.AnimationMode
        let delay: CGFloat
        let gestureVelocity: CGPoint?

        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
    }

    private class AnimatorStack {
        private var stack: [NSViewPropertyAnimator] = []

        var currentAnimator: NSViewPropertyAnimator? {
            stack.last
        }

        func push(animator: NSViewPropertyAnimator) {
            stack.append(animator)
        }

        func pop() {
            stack.removeLast()
        }
    }
}
 */
#endif
