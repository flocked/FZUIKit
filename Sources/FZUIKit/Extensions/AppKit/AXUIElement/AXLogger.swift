//
//  AXLogger.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import Foundation

/// Logs errors for `AXUIElement`.
public struct AXLogger {
    /// A Boolean value indicating whether logging of errors using `AXUIElement` is enabled.
    public static var isEnabled: Bool = false
    
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        Swift.print(items.compactMap({String(describing: $0)}).joined(separator: " ") + terminator)
    }
    
    static func print(items: [Any], separator: String = " ", terminator: String = "\n") {
        guard isEnabled else { return }
        Swift.print(items.compactMap({String(describing: $0)}).joined(separator: " ") + terminator)
    }
}
#endif
