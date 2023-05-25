//
//  NSMenu+.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)
    import AppKit
    public extension NSNib {
        convenience init?(nibNamed nibName: NSNib.Name) {
            self.init(nibNamed: nibName, bundle: nil)
        }
    }

#elseif canImport(UIKit)
    import UIKit
    public extension UINib {
        convenience init(nibName: String) {
            self.init(nibName: nibName, bundle: nil)
        }
    }
#endif
