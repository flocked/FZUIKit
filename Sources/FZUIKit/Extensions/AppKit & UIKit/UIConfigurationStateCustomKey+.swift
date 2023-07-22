//
//  UIConfigurationStateCustomKey+.swift
//
//
//  Created by Florian Zand on 08.09.22.
//

#if canImport(UIKit)
import UIKit
@available(iOS 14.0, *)
extension UIConfigurationStateCustomKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#endif
