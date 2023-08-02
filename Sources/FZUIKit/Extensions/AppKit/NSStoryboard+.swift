//
//  NSStoryboard+.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

#if os(macOS)
import AppKit

public extension NSStoryboard {
    /**
     Creates a storyboard based on the named storyboard file in the specified bundle.

     - Parameters name: The name of the storyboard file, without the filename extension. This method raises an exception if this parameter’s value is nil.
     - Returns: A new storyboard object.
     */
    convenience init(name: NSStoryboard.Name) {
        self.init(name: name, bundle: nil)
    }
}

#endif
