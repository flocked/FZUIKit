//
//  NSUIImage+SymbolConfiguration.swift
//
//
//  Created by Florian Zand on 08.03.24.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import FZSwiftUtils
import SwiftUI

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *)
extension NSUIImageSymbolConfiguration {
    /// Returns a configuration object that applies the right configuration values on top of the left object’s values.
    static func + (lhs: NSUIImageSymbolConfiguration, rhs: NSUIImageSymbolConfiguration) -> NSUIImageSymbolConfiguration {
        lhs.applying(rhs)
    }
    
    /// Applies the right configuration values on top of the left object’s values.
    static func += (lhs: inout NSUIImageSymbolConfiguration, rhs: NSUIImageSymbolConfiguration) {
        lhs = lhs.applying(rhs)
    }
}
