//
//  ActionBlock+Init.swift
//  
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)

import AppKit
import Foundation

fileprivate let TargetActionProtocolAssociatedObjectKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

public extension NSMenuItem {
    convenience init(_ title: String, action: @escaping ActionBlock) {
        self.init(title: title, action: action)
    }

    convenience init(title: String, action: @escaping ActionBlock) {
        self.init(title: title, keyEquivalent: "", action: action)
    }

    convenience init(title: String, keyEquivalent: String, action: @escaping ActionBlock) {
        self.init(title: title, action: nil, keyEquivalent: keyEquivalent)
        actionBlock = action
    }
}

public extension NSPanGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension NSMagnificationGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension NSClickGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension NSPressGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension NSRotationGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit

public extension UISwipeGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension UIPanGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension UILongPressGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

#if os(iOS)
public extension UIPinchGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension UIRotationGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

public extension UIHoverGestureRecognizer {
    convenience init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}
#endif

#endif
