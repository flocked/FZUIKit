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

/// Manages all `Wave` animations.
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

        animation.updateAnimation(deltaTime: .zero)
    }
    
    func stopPropertyAnimation(_ animation: AnimationProviding) {
        animation.reset()
        animations.removeValue(forKey: animation.id)
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
}

extension AnimationController {
    struct AnimationParameters {
        let groupUUID: UUID
        let delay: CGFloat
        let animationType: AnimationType
     //   let isUserInteractionEnabled: Bool
        
        /*
         let gestureVelocity: CGPoint?
         let repeats: Bool
         */
        enum AnimationType {
            case spring(spring: Spring, gestureVelocity: CGPoint?, repeats: Bool)
            case easing(timingFunction: TimingFunction, duration: TimeInterval, repeats: Bool)
            case decay(repeats: Bool)
            case nonAnimated
            
            var spring: Spring? {
                switch self {
                case.spring(let spring,_,_):
                    return spring
                default: return nil
                }
            }
            
            var timingFunction: TimingFunction? {
                switch self {
                case.easing(let timingFunction,_,_):
                    return timingFunction
                default: return nil
                }
            }
            
            var repeats: Bool {
                switch self {
                case .spring(_,_, let repeats), .easing(_,_, let repeats), .decay(let repeats):
                    return repeats
                default: return false
                }
            }
            
            var duration: TimeInterval? {
                switch self {
                case.easing(_, let duration, _):
                    return duration
                default: return nil
                }
            }
            
            var gestureVelocity: CGPoint? {
                switch self {
                case .spring(_, let gestureVelocity, _):
                    return gestureVelocity
                default: return nil
                }
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

/*
 var mouseDownDisabledViews: [UUID: [NSView]] = [:] {
     didSet { setupMouseDownMonitor() }
 }
 
 /// Monitors mouseDown events on views that are currently animated and that are disabled for user interactions while animating (`isUserInteractionEnabled`).
 private var mouseDownMonitor: NSEvent.Monitor? = nil
 
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
 
 if let groupUUID = animation.groupUUID, mouseDownDisabledViews[groupUUID] != nil, animations.contains(where: {$0.value.groupUUID == animation.groupUUID}) == false {
     mouseDownDisabledViews[groupUUID] = nil
 }
 */
