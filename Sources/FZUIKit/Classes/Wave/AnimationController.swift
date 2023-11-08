//
//  AnimationController.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Combine
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

internal class AnimationController {
    static let shared = AnimationController()

    private var displayLink: AnyCancellable?

    private var animations: [UUID: AnimationProviding] = [:]
    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
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

        animation.updateAnimation(dt: .zero)
    }
    
    func stopPropertyAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLink != nil else {
            fatalError("Can't update animations without a display link")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let dt = frame.duration
        
        let sortedAnimations = animations.values.sorted(by: \.relativePriority, .descending)

        for animation in sortedAnimations {
            if animation.state == .ended {
                animation.reset()
                animations.removeValue(forKey: animation.id)
            } else {
                animation.updateAnimation(dt: dt)
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

extension AnimationController {
    struct AnimationParameters {
        let groupUUID: UUID
        let spring: Spring
        let delay: CGFloat
        let gestureVelocity: CGPoint?

        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
    }

    private class SettingsStack {
        private var stack: [AnimationParameters] = []

        var currentSettings: AnimationParameters? {
            stack.last
        }

        func push(settings: AnimationParameters) {
            stack.append(settings)
        }

        func pop() {
            stack.removeLast()
        }
    }
}
#endif
