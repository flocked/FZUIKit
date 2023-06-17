//
//  NSView+Nib.swift
//
//
//  Created by Florian Zand on 05.03.23.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public protocol Nibloadable {
    static func loadFromNib(nibName: String?) -> Self?
    static func loadFromNib(_ nib: NSUINib) -> Self?
}

extension NSUIView: Nibloadable {}
extension NSUIViewController: Nibloadable {}

#if os(macOS)
extension NSWindow: Nibloadable {}
extension NSWindowController: Nibloadable {}
#endif

public extension Nibloadable {
    static func loadFromStoryboard(name: String = "Main", identifier: String? = nil) -> Self? {
        let identifier = identifier ?? String(describing: self)
        let storyboard = NSUIStoryboard(name: name, bundle: nil)
        return loadFromStoryboard(storyboard, identifier: identifier)
    }

    static func loadFromStoryboard(_ storyboard: NSUIStoryboard, identifier: String? = nil) -> Self? {
        let identifier = identifier ?? String(describing: self)
        #if os(macOS)
        return storyboard.instantiateController(withIdentifier: identifier) as? Self
        #elseif canImport(UIKit)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self
        #endif
    }

    static func loadFromNib(_ nib: NSUINib) -> Self? {
        #if os(macOS)
        var topLevelObjects: NSArray?
        nib.instantiate(withOwner: nil, topLevelObjects: &topLevelObjects)
        guard let topLevelObjects else { return nil }
        for object in topLevelObjects {
            if let object = object as? Self {
                return object
            }
        }
        #elseif canImport(UIKit)
        if let object = nib.instantiate(withOwner: self, options: nil).first as? Self {
            return object
        }
        #endif
        return nil
    }

    static func loadFromNib(nibName: String? = nil) -> Self? {
        let nibName = nibName ?? String(describing: self)
        #if os(macOS)
        guard let nib = NSUINib(nibNamed: nibName) else { return nil }
        #elseif canImport(UIKit)
        let nib = NSUINib(nibName: nibName)
        #endif
        return loadFromNib(nib)
    }
}
