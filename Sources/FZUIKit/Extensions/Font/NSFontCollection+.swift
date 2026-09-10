//
//  NSFontCollection+.swift
//
//
//  Created by Florian Zand on 04.09.26.
//

#if os(macOS)
import AppKit

extension NSFontCollection.ActionTypeKey: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .hidden: "hidden"
        case .renamed: "renamed"
        case .shown: "shown"
        default: "\(rawValue)"
        }
    }
}

extension NSFontCollection.Visibility: Swift.CustomStringConvertible {
    public var description: String {
        let strings = elements().map {
            switch $0 {
            case .computer: (".computer", UInt.zero)
            case .user: (".user", UInt.zero)
            case .process: (".process", UInt.zero)
            default: (".init(rawValue: \($0.rawValue))", $0.rawValue)
            }
        }.sorted(by: \.1).map(\.0)
        return strings.count == 1 ? strings[0] : "[\(strings.joined(separator: ", "))]"
    }
}

#endif
