//
//  NSUserInterfaceItemIdentifier+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
import AppKit

extension NSUserInterfaceItemIdentifier: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByIntegerLiteral, Swift.ExpressibleByFloatLiteral, Swift.CustomStringConvertible {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    public init(integerLiteral value: Int) {
        self.init(rawValue: String(value))
    }

    public init(floatLiteral value: Float) {
        self.init(rawValue: String(value))
    }

    public init(_ anyClass: AnyClass) {
        self.init(String(describing: anyClass))
    }
    
    public var description: String {
        rawValue
    }
}
#endif
