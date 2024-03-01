//
//  ActionBlock+Init.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension TargetActionProtocol where Self: NSUIGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

extension TargetActionProtocol where Self: NSUIControl {
    /// Initializes the control with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

#if os(macOS)
extension TargetActionProtocol where Self: NSCell {
    /// Initializes the cell with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}
#endif
#endif
