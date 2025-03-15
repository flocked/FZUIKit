//
//  NSDragOperation+.swift
//  
//
//  Created by Florian Zand on 15.03.25.
//

#if os(macOS)
import AppKit

extension NSDragOperation: CustomStringConvertible {
    public var description: String {
        "[\((self == .every ? NSDragOperation(rawValue: 63) : self).elements().compactMap({$0.string}).joined(separator: ", "))]"
    }
    
    fileprivate var string: String {
        switch self {
        case .copy: return "copy"
        case .delete: return "delete"
        case .generic: return "generic"
        case .link: return "link"
        case .every: return "every"
        case .move: return "move"
        case .private: return "private"
        default: return "other(\(rawValue)"
        }
    }
}

#endif
