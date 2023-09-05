//
//  NSUIStackView+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIStackView {
    /// Reverses the order of the arranged subviews.
    func reverseArrangedSubviews() {
        let arrangedViews = arrangedSubviews.reversed()
        for arrangedView in arrangedViews {
            removeArrangedSubview(arrangedView)
            addArrangedSubview(arrangedView)
        }
    }
    
    /// Removes all arranged subviews.
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach({ self.removeArrangedSubview($0) })
    }
    
    /// The array of views arranged by the stack view.
    var arrangedViews: [NSView] {
        get { self.arrangedSubviews }
        set {
            guard arrangedSubviews != newValue else { return }
            self.removeAllArrangedSubviews()
            newValue.forEach({ self.addArrangedSubview($0) })
        }
    }
}
