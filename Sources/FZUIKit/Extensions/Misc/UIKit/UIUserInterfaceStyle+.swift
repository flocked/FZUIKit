//
//  UIUserInterfaceStyle+.swift
//
//
//  Created by Florian Zand on 08.02.26.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIUserInterfaceStyle {
    var isLight: Bool { self != .dark }
    var isDark: Bool { self == .dark }
}
#endif
