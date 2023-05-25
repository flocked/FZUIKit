//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

#if os(macOS)
import AppKit

public extension NSStoryboard {
    convenience init(name: NSStoryboard.Name) {
        self.init(name: name, bundle: nil)
    }
}

#endif
