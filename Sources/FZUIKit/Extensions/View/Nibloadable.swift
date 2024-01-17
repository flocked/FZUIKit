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
        static func loadFromNib(_ nib: NSUINib) -> Self?
    }

    extension NSUIView: Nibloadable {}
    extension NSUIViewController: Nibloadable {}

    #if os(macOS)
        extension NSWindow: Nibloadable {}
        extension NSWindowController: Nibloadable {}
    #endif

#if os(macOS)
public extension Nibloadable where Self: NSViewController {
    /**
     Initalizes the object from a nib with the specified name.

     - Parameters:
        - nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
        - bundle: The bundle in which to search for the nib file. If you specify `nil`, this method looks for the nib file in the main bundle.

     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib(named nibName: String, bundle: Bundle? = nil) -> Self? {
        guard NSNib(nibNamed: nibName, bundle: bundle) != nil else { return nil }
        return Self(nibName: nibName, bundle: bundle)
    }
    
    /**
     Initalizes the object from the nib named as the object class.

     - Returns: The initalized object, or `nil` if it couldn't be initalized.
     */
    static func loadFromNib() -> Self? {
        let nibName = String(describing: self)
        guard NSNib(nibNamed: nibName, bundle: nil) != nil else { return nil }
        return Self(nibName: nibName, bundle: nil )
    }
}
#endif

    public extension Nibloadable {
        /**
         Initalizes the object from the specified nib.

         - Parameter nib: The nib which holds the object.
         - Returns: The initalized object, or `nil` if it couldn't be initalized.
         */
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

        /**
         Initalizes the object from the nib named as the object class.

         - Returns: The initalized object, or `nil` if it couldn't be initalized.
         */
        static func loadFromNib() -> Self? {
            let nibName = String(describing: self)
            #if os(macOS)
                guard let nib = NSUINib(nibNamed: nibName) else { return nil }
            #elseif canImport(UIKit)
                let nib = NSUINib(nibName: nibName)
            #endif
            return loadFromNib(nib)
        }

        /**
         Initalizes the object from a nib with the specified name.

         - Parameters:
            - nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
            - bundle: The bundle in which to search for the nib file. If you specify `nil`, this method looks for the nib file in the main bundle.

         - Returns: The initalized object, or `nil` if it couldn't be initalized.
         */
        static func loadFromNib(named nibName: String, bundle: Bundle? = nil) -> Self? {
            #if os(macOS)
                guard let nib = NSUINib(nibNamed: nibName, bundle: bundle) else { return nil }
            #elseif canImport(UIKit)
                let nib = NSUINib(nibName: nibName)
            #endif
            return loadFromNib(nib)
        }

        /**
         Initalizes the object from the storyboard.

         - Parameters:
            - name: The name of the storyboard which holds the object. The default value is `main`.
            - identifier: The storyboard identifier of the object. If you specify `nil` (the default value), the object's class name is used as identifier.

         - Returns: The initalized object, or `nil` if it couldn't be initalized.
         */
        static func loadFromStoryboard(name: String = "Main", identifier: String? = nil) -> Self? {
            let identifier = identifier ?? String(describing: self)
            let storyboard = NSUIStoryboard(name: name, bundle: nil)
            return loadFromStoryboard(storyboard, identifier: identifier)
        }

        /**
         Initalizes the object from the specified storyboard.

         - Parameters:
            - storyboard: The storyboard which holds the object.
            - identifier: The storyboard identifier of the object. If you specify `nil` (the default value), the object's class name is used as identifier.

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
