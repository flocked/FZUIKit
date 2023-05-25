//
//  NSApper.swift
//  NewImageViewer
//
//  Created by Florian Zand on 06.08.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSAppearance {
        /// Returns a vibrant dark appearance.
        static var vibrantDark: NSAppearance {
            return NSAppearance(named: .vibrantDark)!
        }

        /// Returns a vibrant light appearance.
        static var vibrantLight: NSAppearance {
            return NSAppearance(named: .vibrantLight)!
        }

        /// Returns a aqua appearance.
        static var aqua: NSAppearance {
            return NSAppearance(named: .aqua)!
        }

        /// Returns a dark aqua appearance.
        static var darkAqua: NSAppearance {
            return NSAppearance(named: .darkAqua)!
        }
    }

#endif
