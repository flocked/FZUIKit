//
//  UITraitCollection+.swift
//
//
//  Created by Florian Zand on 14.11.25.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UITraitCollection {
    /// A new trait collection containing only the `light` interface style trait.
    public static var light: UITraitCollection {
        .init(userInterfaceStyle: .light)
    }
    
    /// A new trait collection containing only the `dark` interface style trait.
    public static var dark: UITraitCollection {
        .init(userInterfaceStyle: .dark)
    }
}
#endif
