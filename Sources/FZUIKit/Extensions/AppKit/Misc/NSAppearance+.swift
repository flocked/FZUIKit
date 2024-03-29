//
//  NSAppearance+.swift
//
//
//  Created by Florian Zand on 06.08.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSAppearance {
        /// Returns a aqua appearance.
        static var aqua: NSAppearance {
            NSAppearance(named: .aqua)!
        }

        /// Returns a dark aqua appearance.
        static var darkAqua: NSAppearance {
            NSAppearance(named: .darkAqua)!
        }

        /// Returns a vibrant light appearance.
        static var vibrantLight: NSAppearance {
            NSAppearance(named: .vibrantLight)!
        }

        /// Returns a vibrant dark appearance.
        static var vibrantDark: NSAppearance {
            NSAppearance(named: .vibrantDark)!
        }

        /// Returns a high-contrast version of the standard light system appearance.
        static var accessibilityHighContrastAqua: NSAppearance {
            NSAppearance(named: .accessibilityHighContrastAqua)!
        }

        /// Returns a high-contrast version of the standard dark system appearance.
        static var accessibilityHighContrastDarkAqua: NSAppearance {
            NSAppearance(named: .accessibilityHighContrastDarkAqua)!
        }

        /// Returns a high-contrast version of the dark vibrant system appearance.
        static var accessibilityHighContrastVibrantDark: NSAppearance {
            NSAppearance(named: .accessibilityHighContrastVibrantDark)!
        }

        /// Returns a high-contrast version of the light vibrant system appearance.
        static var accessibilityHighContrastVibrantLight: NSAppearance {
            NSAppearance(named: .accessibilityHighContrastVibrantLight)!
        }

        /**
         A Boolean value that indicates whether the appearance is light.

         The following appearances are light: `aqua`, `vibrantLight`, `accessibilityHighContrastAqua` and `accessibilityHighContrastVibrantLight`.
         */
        var isLight: Bool {
            isDark == false
        }

        /**
         A Boolean value that indicates whether the appearance is dark.

         The following appearances are dark: `darkAqua`, `vibrantDark`, `accessibilityHighContrastDarkAqua` and `accessibilityHighContrastVibrantDark`.
         */
        var isDark: Bool {
            [.vibrantDark, .darkAqua, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark].contains(name)
        }
    }

#endif
