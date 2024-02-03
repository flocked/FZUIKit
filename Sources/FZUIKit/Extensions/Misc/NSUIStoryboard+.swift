//
//  NSUIStoryboard+.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
    import AppKit
    #else
    import UIKit
    #endif

    public extension NSUIStoryboard {
        /**
         Creates a storyboard based on the specified name in the main bundle.

         - Parameter name: The name of the storyboard file, without the filename extension.
         - Returns: A new storyboard object.
         */
        convenience init(name: String) {
            self.init(name: name, bundle: nil)
        }
        
        /**
         Creates a storyboard based on the specified name in the main bundle.

         - Parameter name: The name of the storyboard file, without the filename extension.
         - Returns: A new storyboard object.
         */
        convenience init(_ name: String) {
            self.init(name: name, bundle: nil)
        }
    }

#endif
