//
//  NSPageController+.swift
//  
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
import AppKit
import Foundation
import FZSwiftUtils

public extension NSPageController {
    func select(_ index: Int, duration: CGFloat = 0.0) {
        if arrangedObjects.isEmpty == false, index < arrangedObjects.count, index != selectedIndex {
            if duration > 0.0 {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = duration
                    self.animator().selectedIndex = index
                }, completionHandler: {
                    self.completeTransition()
                })
            } else {
                selectedIndex = index
                completeTransition()
            }
        }
    }

    func advance(to type: AdvanceOption, duration: CGFloat = 0.0) {
        if arrangedObjects.isEmpty == false {
            let newIndex = selectedIndex.advanced(by: type, in: 0 ... arrangedObjects.count - 1)
            select(newIndex, duration: duration)
        }
    }
}

extension NSPageController {
    public enum KeyboardControl {
        case enabled(transitionDuration: TimeInterval = 0.0)
        case enabledLooping(transitionDuration: TimeInterval = 0.0)
        case disabled
        
        internal var transitionDuration: TimeInterval {
            switch self {
            case let .enabled(value), let .enabledLooping(value):
                return value
            case .disabled:
                return 0.0
            }
        }

        internal var isEnabled: Bool {
            switch self {
            case .disabled:
                return false
            default:
                return true
            }
        }
    }
}
#endif
