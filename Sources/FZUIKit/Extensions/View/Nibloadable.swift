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
        - nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
        - bundle: The bundle in which to search for the nib file. If you specify `nil`, this method looks for the nib file in the main bundle.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib(named nibName: String, bundle: Bundle?) -> Self?
    static func loadFromStoryboard(_ storyboard: NSUIStoryboard, identifier: String?) -> Self?
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
}

#if os(macOS)

public extension Nibloadable where Self: NSWindowController {
    static func loadFromNib(_ nib: NSUINib) -> Self? {
        let controller = Self()
        nib.instantiate(withOwner: controller)
        return controller
    }
    
    static func loadFromNib(named nibName: String, bundle: Bundle? = nil) -> Self? {
        if let bundle = bundle {
            guard let nib = NSNib(nibNamed: nibName, bundle: bundle) else { return nil }
            return loadFromNib(nib)
        } else {
            return Self(windowNibName: nibName)
        }
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
    
    static func loadFromNib(named name: String, bundle: Bundle? = nil) -> Self? {
        #if os(macOS)
        guard let nib = NSNib(nibNamed: name, bundle: bundle) else { return nil }
        #elseif canImport(UIKit)
        let nib = UINib(nibName: name, bundle: bundle)
        #endif
        return loadFromNib(nib)
    }

    /**
     Initalizes the object from the storyboard.
     
     - Parameters:
        - name: The name of the storyboard which holds the object.
        - identifier: The storyboard identifier of the object, or `nil` to use the object's class name as identifier.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromStoryboard(name: String = "Main", identifier: String? = nil) -> Self? {
        loadFromStoryboard(NSUIStoryboard(name: name, bundle: nil), identifier: identifier)
    }
    
    /**
     Initalizes the object from the specified storyboard.
     
     - Parameters:
        - storyboard: The storyboard which holds the object.
        - identifier: The storyboard identifier of the object, or `nil` to use the object's class name as identifier.
     
     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
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
