//
//  UIConfigurationStateCustomKey+.swift
//
//
//  Created by Florian Zand on 08.09.22.
//

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
extension UIConfigurationStateCustomKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
#endif
