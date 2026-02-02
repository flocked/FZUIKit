//
//  AXUIElement+Description.swift
//
//
//  Created by Florian Zand on 08.11.25.
//

#if canImport(ApplicationServices) && os(macOS)
import AppKit
import ApplicationServices
import Combine
import FZSwiftUtils

extension AXUIElement: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    static var useShort = false
    
    public var description: String {
        if Self.useShort {
            return shortDescription
        }
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let pid = values.processIdentifier ?? 0
        if let description = values.description, description != "" {
            return "\(role) #\(id) \(description) (pid: \(pid))"
        }
        return "\(role) #\(id) (pid: \(pid))"
    }
    
    public var debugDescription: String {
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let pid = values.processIdentifier ?? 0
        var string = "\(role) #\(id) "
        if let subrole = values.subrole?.rawValue {
            string = "\(role)/\(subrole) #\(id) "
        }
        if let description = values.description, description != "" {
            string += "\(description) (pid: \(pid))"
        } else {
            string += "(pid: \(pid))"
        }
        return string
    }
    
    /**
     Returns a string with a visual description of the object.
     
     - Parameters:
        - options: Options for the description.
        - attributes: The attributes to include.
        - maxDepth: The maximum depth of children to include.
        - maxChildren: The maximum amount of children to include for each element.
     */
    public func visualDescription(options: DescriptionOptions = .detailed, attributes: [AXAttribute] = [], maxDepth: Int = .max, maxChildren: Int = .max) -> String {
        strings(maxDepth: maxDepth, maxChildren: maxChildren, options: options, attributes: attributes).joined(separator: "\n")
    }
    
    /// Options for a description of an accessibility object.
    public struct DescriptionOptions: OptionSet, Sendable {
        /// Role of the object.
        public static var role = Self(rawValue: 1 << 0)
        /// Subrole of the object.
        public static var subrole = Self(rawValue: 1 << 1)
        /// pid of the object.
        public static var pid = Self(rawValue: 1 << 2)
        /// Identifier of the object.
        public static var identifier = Self(rawValue: 1 << 3)
        /// Description of the object.
        public static var description = Self(rawValue: 1 << 4)
         /// Title of the object.
         public static var title = Self(rawValue: 1 << 5)
         /// Value of the object.
         public static var value = Self(rawValue: 1 << 6)
         /// Attributes of the object.
         public static var attributes = Self(rawValue: 1 << 7)
         /// Parameterized attributes of the object.
         public static var parameterizedAttributes = Self(rawValue: 1 << 8)
         /// Actions of the object.
         public static var actions = Self(rawValue: 1 << 9)
         
         /// Full description of the object.
         public static let all: Self = [.role, .subrole, .pid, .identifier, .description, .actions, .title, .value, .parameterizedAttributes, .attributes]
         /// Very detailed description of the object.
         public static let detailedLong: Self = [.role, .subrole, .pid, .identifier, .description, .actions, .title, .value]
         /// Detailed description of the object.
         public static let detailed: Self = [.role, .subrole, .description, .title, .value]
         /// Short description of the object.
         public static let short: Self = [.role, .subrole, .description]
        
        /// Info description of the object.
        public static let info: Self = [.role, .description, .title, .attributes, .value]
         
         var attributes: Set<AXAttribute> {
             var attributes: Set<AXAttribute> = [.children, .parent]
             if contains(.title) { attributes += .title }
             if contains(.description) { attributes += .description }
             if contains(.value) { attributes += .value }
             if contains(.role) { attributes += .role }
             if contains(.subrole) { attributes += .subrole }
             return attributes
         }
         
        /// Creates the print options.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public let rawValue: Int
    }
    
    func strings(level: Int = 0, maxDepth: Int, maxChildren: Int, options: DescriptionOptions, attributes: [AXAttribute]) -> [String] {
        var strings: [String] = []
        strings += (String(repeating: "  ", count: level) + string(level: level+1, maxDepth: maxDepth, options: options, attributes: attributes))
        if level+1 <= maxDepth {
            var childs = children.collect()
            childs = childs[safe: 0..<(maxChildren)]
            childs.forEach({ strings += $0.strings(level: level+1, maxDepth: maxDepth, maxChildren: maxChildren, options: options, attributes: attributes) })
        }
        return strings
    }
    
    func string(level: Int, maxDepth: Int = .max, options: DescriptionOptions, attributes: [AXAttribute]) -> String {
        Self.useShort = true
        let intendString = String(repeating: "  ", count: level) + "- "
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let subrole = values.subrole?.rawValue
        let pid = values.processIdentifier
        let title = values.title
        let description = values.description
        var strings: [String] = []
        if options.contains([.role, .subrole]), let subrole = subrole {
            strings.append("\(role)/\(subrole)")
        } else if options.contains(.subrole), let subrole = subrole {
            strings.append("\(subrole)")
        } else if options.contains(.role) {
            strings.append("\(role)")
        } else {
            strings.append("AXUIElement")
        }

        if options.contains([.title, .description]) {
            if let title = title, title != "", let description = description, description != "" {
                strings[0] = strings[0] + " \"\(description)\""
                if title != description {
                    strings.append(intendString + "title: \"\(title)\"")
                }
            } else if let title = title, title != "" {
                strings[0] = strings[0] + " \"\(title)\""
            } else if let description = description, description != "" {
                strings[0] = strings[0] + " \"\(description)\""
            }
        } else if options.contains(.description), let description = description, description != "" {
            strings[0] = strings[0] + " \"\(description)\""
        } else if options.contains(.title), let title = title, title != "" {
            strings[0] = strings[0] + " \"\(title)\""
        }
        
        if options.contains([.identifier, .pid]), let pid = pid {
            strings[0] = strings[0] + " (id: \(id), pid: \(pid))"
            //strings += (intendString + "id: \(id), pid: \(pid)")
        } else if options.contains(.identifier) {
            strings[0] = strings[0] + " (id: \(id))"
           // strings += (intendString + "id: \(id)")
        } else if options.contains(.pid), let pid = pid {
            strings[0] = strings[0] + " (pid: \(pid))"
         //   strings += (intendString + "pid: \(pid)")
        }
        
        if options.contains(.value), let value = values.value {
            strings.append(intendString + "value: \(value)\(isAttributeSettable(.value) ? " [Writable]" : "")")
        }
        
        let skipping = options.attributes
        var attributeValues = (options.contains(.attributes) ? attributeValues() : attributes.reduce(into: [AXAttribute: Any]()) {  dict, attribute in dict[attribute] = try? get(attribute) }).filter({ !skipping.contains($0.key) && ($0.value is Optional<AXValue>) })
        if !attributeValues.isEmpty {
            if attributeValues[.frame] != nil {
                attributeValues[.position] = nil
                attributeValues[.size] = nil
            }
          //  strings += (intendString + "attributes:")
        //    let intendString = "\(String(repeating: "  ", count: level+1))- "
            for attribute in attributeValues.sorted(by: \.key.rawValue) {
                let key = attribute.key.rawValue
              //  key = key.replacingOccurrences(of: "AX", with: "")
                var valueString = "\(attribute.value)"
                if let value = attribute.value as? [AXUIElement] {
                    valueString = "\(value.compactMap({ $0.shortDescription }))"
                }
                strings += (intendString + "\(key): \(valueString)\(isAttributeSettable(attribute.key) ? " [Writable]" : "")")
            }
           // strings += attributeValues.sorted(by: \.key.rawValue).compactMap({ intendString + "\($0.key): \($0.value)\(isSettable($0.key) ? " [Writable]" : "")" })
        }
        
        if options.contains(.parameterizedAttributes) {
            let attributes = parameterizedAttributes
            if !attributes.isEmpty {
                strings += (intendString + "parameterizedAttributes:")
                let intendString = "\(String(repeating: "  ", count: level+1))- "
                strings += attributes.compactMap({ intendString + $0.rawValue })
            }
        }
        
        if options.contains(.actions) {
            let actions = actions
            if !actions.isEmpty {
                strings += (intendString + "actions:")
                let intendString = "\(String(repeating: "  ", count: level+1))- "
                strings += actions.compactMap({ intendString + $0.description })
            }
        }
        Self.useShort = false
        return strings.joined(separator: "\n")
    }
    
    var shortDescription: String {
        let role = role?.rawValue ?? "AXUnknown"
        if let description = values.description, description != "" {
            return role + " \"\(description)\""
        } else if let title = values.title, title != "" {
            return role + " \"\(title)\""
        }
        return role
    }
}
#endif
