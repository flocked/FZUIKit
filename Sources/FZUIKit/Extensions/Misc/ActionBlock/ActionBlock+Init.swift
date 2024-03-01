//
//  ActionBlock+Init.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit


extension TargetActionProtocol where Self: NSGestureRecognizer {
    /// Initializes the gesture recognizer with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

extension TargetActionProtocol where Self: NSControl {
    /// Initializes the control with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}

extension TargetActionProtocol where Self: NSCell {
    /// Initializes the cell with the specified action handler.
    init(action: @escaping ActionBlock) {
        self.init()
        actionBlock = action
    }
}
#endif
