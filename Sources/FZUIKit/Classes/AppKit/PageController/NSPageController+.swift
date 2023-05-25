//
//  NSPageController+.swift
//  PageController
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation
    import FZSwiftUtils

    public extension NSPageController {
        typealias AdvanceType = Int.NextValueType

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

        func advance(to type: AdvanceType, duration: CGFloat = 0.0) {
            if arrangedObjects.isEmpty == false {
                let newIndex = selectedIndex.advanced(by: type, in: 0 ... arrangedObjects.count - 1)
                select(newIndex, duration: duration)
            }
        }
    }

    extension NSPageController {
        enum KeyboardControl {
            case on(CGFloat = 0.0)
            case onLooping(CGFloat = 0.0)
            case off

            func values(for type: AdvanceType) -> (AdvanceType, CGFloat)? {
                if type == .first || type == .last {
                    switch self {
                    case let .on(value):
                        return (type, value)
                    case let .onLooping(value):
                        return (type, value)
                    case .off:
                        return nil
                    }
                }
                switch self {
                case let .on(value):
                    return ((type == .previous) ? .previous : .next, value)
                case let .onLooping(value):
                    return ((type == .previous) ? .previousLooping : .nextLooping, value)
                case .off:
                    return nil
                }
            }

            var isOn: Bool {
                switch self {
                case .off:
                    return false
                default:
                    return true
                }
            }
        }
    }
#endif
