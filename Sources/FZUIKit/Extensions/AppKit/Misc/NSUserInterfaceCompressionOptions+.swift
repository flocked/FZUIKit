//
//  NSUserInterfaceCompressionOptions+.swift
//  
//
//  Created by Florian Zand on 05.04.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSUserInterfaceCompressionOptions {
    /// The options of the compression.
    @objc open var options: Set<NSUserInterfaceCompressionOptions> {
        get { Set(identifers.map({ NSUserInterfaceCompressionOptions(identifier: $0) }))}
        set { identifers = Set(newValue.flatMap({ $0.identifers })) }
    }
    
    private var identifers: Set<String> {
        get { value(forKeySafely: "identifiers") as? Set<String> ?? .init() }
        set { setValue(safely: newValue, forKey: "identifiers")}
    }
    
    /// Inserts the specified options.
    @objc open func insert(_ options: NSUserInterfaceCompressionOptions) {
        identifers.insert(options.identifers)
    }
    
    /// Removes the specified options.
    @objc open func remove(_ options: NSUserInterfaceCompressionOptions) {
        identifers.remove(options.identifers)
    }
    
    @objc open subscript (options: NSUserInterfaceCompressionOptions) -> Bool {
        get { contains(options) }
        set {
            if newValue {
                insert(options)
            } else {
                remove(options)
            }
        }
    }
    
    open override var description: String {
        "[\(identifers.map({"." + $0.replacingOccurrences(of: "NSUserInterfaceCompressionOption", with: "").lowercasedFirst()}).sorted().joined(separator: ", "))]"
    }
}

#endif
