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
    
    var mouseDownDisabledViews: [UUID: [NSView]] = [:] {
        didSet { setupMouseDownMonitor() }
    }
    
    /// Monitors mouseDown events on views that are currently animated and that are disabled for user interactions while animating (`isUserInteractionEnabled`).
    private var mouseDownMonitor: NSEvent.Monitor? = nil

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

        animation.updateAnimation(deltaTime: .zero)
    }
    
    func stopPropertyAnimation(_ animation: AnimationProviding) {
        animation.reset()
        animations.removeValue(forKey: animation.id)
        
        if let groupUUID = animation.groupUUID, mouseDownDisabledViews[groupUUID] != nil, animations.contains(where: {$0.value.groupUUID == animation.groupUUID}) == false {
            mouseDownDisabledViews[groupUUID] = nil
        }
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
                self.stopPropertyAnimation(animation)
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
    
    private func setupMouseDownMonitor() {
        if mouseDownDisabledViews.isEmpty == false {
            Swift.print("setupMouseDownMonitor", mouseDownDisabledViews.flatMap({$0.value}).uniqued().count)
            if mouseDownMonitor == nil {
                mouseDownMonitor = .local(for: [.leftMouseDown]) { [weak self] event in
                    guard let self = self else { return event }
                    if let contentView = NSApp.keyWindow?.contentView {
                        let mouseLocation = event.location(in: contentView)
                        if let hitView = contentView.hitTest(mouseLocation) {
                            let allMouseDownDisabledViews = mouseDownDisabledViews.flatMap({$0.value}).uniqued()
                            for view in allMouseDownDisabledViews {
                                if hitView == view || hitView.isDescendant(of: view) {
                                    Swift.print("mouseDownMonitor nil")
                                    return nil
                                }
                            }
                        }
                    }
                    Swift.print("mouseDownMonitor event")
                    return event
                }
            }
        } else {
            Swift.print("setupMouseDownMonitor disable")
            mouseDownMonitor = nil
        }
    }
}

extension AnimationController {
    struct AnimationParameters {
        let groupUUID: UUID
        let delay: CGFloat
        let type: AnimationType
        let isUserInteractionEnabled: Bool
                
        enum AnimationType {
            case spring(SpringParameters)
            case easing(EasingParameters)
            case decay(DecayParameters)
            case nonAnimated
            
            var spring: Spring? {
                switch self {
                case.spring(let parameters):
                    return parameters.spring
                default: return nil
                }
            }
            
            var timingFunction: TimingFunction? {
                switch self {
                case.easing(let parameters):
                    return parameters.timingFunction
                default: return nil
                }
            }
            
            var easingDuration: TimeInterval? {
                switch self {
                case.easing(let parameters):
                    return parameters.duration
                default: return nil
                }
            }
            
            var gestureVelocity: CGPoint? {
                switch self {
                case .decay(let parameters):
                    return parameters.gestureVelocity
                case.spring(let parameters):
                    return parameters.gestureVelocity
                default: return nil
                }
            }
            
            struct SpringParameters {
                let spring: Spring
                let gestureVelocity: CGPoint?
                init(spring: Spring, gestureVelocity: CGPoint?) {
                    self.spring = spring
                    self.gestureVelocity = gestureVelocity
                }
            }
                    
            struct EasingParameters {
                let timingFunction: TimingFunction
                let duration: TimeInterval
            }
            
            struct DecayParameters {
                let gestureVelocity: CGPoint?
            }
        }

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
