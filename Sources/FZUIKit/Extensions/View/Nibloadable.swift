//
//  Nibloadable.swift
//
//
//  Created by Florian Zand on 05.03.23.
//

import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A type that can be loaded from a nib or storyboard.
public protocol Nibloadable: NSObject {
    /**
     Initalizes the object from the nib named as the object class.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib() -> Self?
    
    /**
     Initalizes the object from the specified nib.
     
     - Parameter nib: The nib which holds the object.
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib(_ nib: NSUINib) -> Self?
    
    /**
     Initalizes the object from a nib with the specified name.
     
     - Parameters:
        - name: The name of the nib file, without any leading path information.
        - bundle: The bundle containing the nib file.

     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib(named name: String, bundle: Bundle) -> Self?
    
    /**
     Initalizes the object from the main storyboard.
     
     - Parameters: identifier: The storyboard identifier of the object, or `nil` to use the object's class name as identifier.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromStoryboard(identifier: String?) -> Self?
    
    /**
     Initalizes the object from the specified storyboard.
     
     - Parameters:
        - storyboard: The storyboard which holds the object.
        - identifier: The storyboard identifier of the object, or `nil` to use the object's class name as identifier.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromStoryboard(_ storyboard: NSUIStoryboard, identifier: String?) -> Self?
    
    /**
     Initalizes the object from a storyboard with the specified name.
     
     - Parameters:
        - name: The name of the storyboard which holds the object, without any leading path information.
        - bundle: The bundle containing the storyboard file.
        - identifier: The storyboard identifier of the object, or `nil` to use the object's class name as identifier.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromStoryboard(named name: String, bundle: Bundle, identifier: String?) -> Self?
    
}

extension NSUIView: Nibloadable { }
extension NSUIViewController: Nibloadable { }

#if os(macOS)
extension NSWindow: Nibloadable { }
extension NSMenu: Nibloadable { }
extension NSWindowController: Nibloadable { }
#endif

public extension Nibloadable where Self: NSUIViewController {
    static func loadFromNib(_ nib: NSUINib) -> Self? {
        let controller = Self()
        nib.instantiate(withOwner: controller)
        return controller
    }
    
    static func loadFromNib(named nibName: String, bundle: Bundle? = nil) -> Self? {
        return Self(nibName: nibName, bundle: bundle)
    }
    
    static func loadFromNib() -> Self? {
        loadFromNib(named: String(describing: self))
    }
}

#if os(macOS)

public extension Nibloadable where Self: NSWindowController {
    static func loadFromNib(_ nib: NSUINib) -> Self? {
        let controller = Self()
        nib.instantiate(withOwner: controller)
        return controller
    }
    
    static func loadFromNib(named nibName: String, bundle: Bundle = .main) -> Self? {
        if bundle != .main {
            guard let nib = NSNib(nibNamed: nibName, bundle: bundle) else { return nil }
            return loadFromNib(nib)
        } else {
            return Self(windowNibName: nibName)
        }
    }
    
    static func loadFromNib() -> Self? {
        loadFromNib(named: String(describing: self))
    }
}
#endif

public extension Nibloadable {
    static func loadFromNib(_ nib: NSUINib) -> Self? {
        nib.instantiate(withOwner: self).first(where: { $0 is Self }) as? Self
    }
    
    static func loadFromNib() -> Self? {
        loadFromNib(named: String(describing: self))
    }
    
    static func loadFromNib(named name: String, bundle: Bundle = .main) -> Self? {
        #if os(macOS)
        guard let nib = NSNib(nibNamed: name, bundle: bundle) else { return nil }
        #elseif canImport(UIKit)
        let nib = UINib(nibName: name, bundle: bundle)
        #endif
        return loadFromNib(nib)
    }

    static func loadFromStoryboard(identifier: String? = nil) -> Self? {
        guard let storyboard = NSUIStoryboard.main else { return nil }
        return loadFromStoryboard(storyboard, identifier: identifier)
    }
    
    static func loadFromStoryboard(named name: String, bundle: Bundle = .main, identifier: String? = nil) -> Self? {
        guard bundle.path(forResource: name, ofType: "storyboardc") != nil else { return nil }
        return loadFromStoryboard(NSUIStoryboard(name: name, bundle: nil), identifier: identifier)
    }
    
    static func loadFromStoryboard(_ storyboard: NSUIStoryboard, identifier: String? = nil) -> Self? {
        let identifier = identifier ?? String(describing: self)
        #if os(macOS)
        return storyboard.instantiateController(withIdentifier: identifier) as? Self
        #elseif canImport(UIKit)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self
        #endif
    }
}
#endif
