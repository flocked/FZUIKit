//
//  File.swift
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
    func reverseArrancedSubviews() {
        let arrangedViews = arrangedSubviews.reversed()
        for arrangedView in arrangedViews {
            removeArrangedSubview(arrangedView)
            addArrangedSubview(arrangedView)
        }
    }
}
