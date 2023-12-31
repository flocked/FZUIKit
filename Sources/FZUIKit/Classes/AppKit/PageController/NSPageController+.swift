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
    /**
     Selects the page at the specified index.
     
     - Parameters:
        - index: The index of the page.
        - animationDuration: The animation duration for transitioning to the new page. A value of `0.0` won't animate the transition. The default value is `0.2`.
     */
    func selectPage(at index: Int, animationDuration: CGFloat = 0.0) {
        if arrangedObjects.isEmpty == false, index >= 0, index < arrangedObjects.count, index != selectedIndex {
            if animationDuration > 0.0 {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = animationDuration
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

    /**
     Advances to the page for the specified advance option.
     
     - Parameters:
        - option: The value that specifies the advance option.
        - animationDuration: The animation duration for transitioning to the new page. A value of `0.0` won't animate the transition. The default value is `0.2`.
     */
    func advancePage(to type: AdvanceOption, animationDuration: CGFloat = 0.0) {
        if arrangedObjects.isEmpty == false {
            var newIndex = selectedIndex
            switch type {
            case .next:
                newIndex += 1
                if newIndex >= arrangedObjects.count {
                    newIndex = arrangedObjects.count - 1
                }
            case .previous:
                newIndex -= 1
                if newIndex < 0 {
                    newIndex = 0
                }
            case .nextLooping:
                newIndex += 1
                if newIndex >= arrangedObjects.count {
                    newIndex = 0
                }
            case .previousLooping:
                newIndex -= 1
                if newIndex < 0 {
                    newIndex = arrangedObjects.count - 1
                }
            case .first:
                newIndex = 0
            case .last:
                newIndex = arrangedObjects.count - 1
            case .random:
                newIndex = (0..<arrangedObjects.count).randomElement() ?? newIndex
            }
            selectPage(at: newIndex, animationDuration: animationDuration)
        }
    }
}

public extension NSPageController {
    /// A value that specifies if the displayed page is controllable by keyboard input.
    enum KeyboardControlOption: Hashable {
        /// The displayed page can be changed via keyboard.
        case enabled(transitionDuration: TimeInterval = 0.0, looping: Bool = false)
        /// The displayed page can't be changed via keyboard.
        case disabled
        
        /// The displayed page can be changed via keyboard.
        public static var enabled: Self { return .enabled(transitionDuration: 0.0, looping: false) }
        
        internal var transitionDuration: TimeInterval {
            switch self {
            case let .enabled(value, _):
                return value
            case .disabled:
                return 0.0
            }
        }
        
        internal var isLooping: Bool {
            switch self {
            case .enabled(_, let looping): return looping
            default: return false
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
