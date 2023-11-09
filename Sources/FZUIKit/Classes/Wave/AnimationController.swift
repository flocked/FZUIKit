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
    
    var mouseDownMonitor: NSEvent.Monitor? = nil
        
    func setupMouseDownMonitor() {
        if mouseDownDisabledViews.isEmpty == false {
            Swift.print("setupMouseDownMonitor", allMouseDownDisabledViews.count)
            if mouseDownMonitor == nil {
                mouseDownMonitor = .local(for: [.leftMouseDown]) { [weak self] event in
                    guard let self = self else { return event }
                    if let contentView = NSApp.keyWindow?.contentView {
                        let mouseLocation = event.location(in: contentView)
                        if let hitView = contentView.hitTest(mouseLocation) {
                            Swift.print("hitView", hitView)
                            for view in self.allMouseDownDisabledViews {
                                if hitView == view || hitView.isDescendant(of: view) {
                                    Swift.print("mouseDownMonitor nil")
                                    return nil
                                }
                            }
                        }
                    }
                    /*
                    for view in self.allMouseDownDisabledViews {
                        let mouseLocation = event.location(in: view)
                        if view.bounds.contains(mouseLocation), let superview = view.window?.contentView {
                            let location = event.location(in: superview)
                            if let hitView = superview.hitTest(location), hitView == view || hitView.isDescendant(of: view) {
                                return nil
                            }
                        }
                    }
                     */
                    Swift.print("mouseDownMonitor event")
                    return event
                }
            }
        } else {
            Swift.print("setupMouseDownMonitor disable")
            mouseDownMonitor = nil
        }
    }

    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]
    
    var mouseDownDisabledViews: [UUID: [NSView]] = [:] {
        didSet { setupMouseDownMonitor() }
    }
    
    var allMouseDownDisabledViews: [NSView] {
        mouseDownDisabledViews.flatMap({$0.value}).uniqued()
    }

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

        animation.updateAnimation(deltaTime: .zero)
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
                if animations.contains(where: {$0.value.groupUUID == animation.groupUUID}) == false {
                    
                }
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
    
    internal func removeMouseDownDisabledViews(uuid: UUID?) {
        guard let uuid = uuid else { return }
        mouseDownDisabledViews.removeValue(forKey: uuid)
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
        let isUserInteractionEnabled: Bool

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
