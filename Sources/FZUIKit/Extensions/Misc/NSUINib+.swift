//
//  NSUINib+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)
    import AppKit
    public extension NSNib {
        /**
         Returns a nib object from the nib file in the main bundle.

         The `NSNib` object looks for the nib file in the main bundle's language-specific project directories first, followed by the Resources directory.

         - Parameter nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
         - Returns: The initialized `NSNib` object or `nil` if there were errors during initialization or the nib file could not be located.
         */
        convenience init?(nibNamed nibName: NSNib.Name) {
            self.init(nibNamed: nibName, bundle: nil)
        }
        
        /**
         Returns a nib object from the nib file in the main bundle.

         The `NSNib` object looks for the nib file in the main bundle's language-specific project directories first, followed by the Resources directory.

         - Parameter nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
         - Returns: The initialized `NSNib` object or `nil` if there were errors during initialization or the nib file could not be located.
         */
        convenience init?(_ nibName: NSNib.Name) {
            self.init(nibNamed: nibName, bundle: nil)
        }
    }

#elseif os(iOS) || os(tvOS)
    import UIKit
    public extension UINib {
        /**
         Returns a nib object from the nib file in the main bundle.

         The`UINib` object looks for the nib file in the main bundle’s language-specific project directories first, followed by the Resources directory.

         - Parameter nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
         - Returns: The initialized `UINib` object. An exception is thrown if there were errors during initialization or the nib file could not be located.
         */
        convenience init(nibName: String) {
            self.init(nibName: nibName, bundle: nil)
        }
        
        /**
         Returns a nib object from the nib file in the main bundle.

         The`UINib` object looks for the nib file in the main bundle’s language-specific project directories first, followed by the Resources directory.

         - Parameter nibName: The name of the nib file, without any leading path information. Inclusion of the .nib extension on the nib file name is optional.
         - Returns: The initialized `UINib` object. An exception is thrown if there were errors during initialization or the nib file could not be located.
         */
        convenience init(_ nibName: String) {
            self.init(nibName: nibName, bundle: nil)
        }
    }
#endif
