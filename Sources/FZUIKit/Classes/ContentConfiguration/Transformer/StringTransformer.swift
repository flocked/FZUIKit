//
//  NSConfigurationStringTransformer.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

public extension ContentConfiguration {
    struct StringTransformer {
        /// The transform closure of the string transformer.
        public let transform: (String) -> String
        /// The identifier of the string transformer.
        public let id: String

        /**
         Calls the transform closure of the string transformer.

         Using this syntax, you can call the string transformer type as if it were a closure:
         ```
         let camelcaseStringTransformer: NSConfigurationStringTransformer = .camelcase
         let string = "A sample String"
         let modifiedString = camelcaseStringTransformer(string)
         ```
         */
        public func callAsFunction(_ input: String) -> String {
            return transform(input)
        }

        /// Creates a string transformer with the specified closure.
        public init(_ id: String, _ transform: @escaping (String) -> String) {
            self.transform = transform
            self.id = id
        }

        /// Creates a string transformer with the specified closure.
        public init(_ transform: @escaping (String) -> String) {
            self.transform = transform
            id = UUID().uuidString
        }

        /// Creates a color transformer that generates a capitalized version of the string.
        public static func capitalized() -> Self {
            return Self("capitalized") { $0.capitalized }
        }

        /// Creates a color transformer that generates a lowercased version of the string.
        public static func lowercased() -> Self {
            return Self("lowercased") { $0.lowercased() }
        }

        /// Creates a color transformer that generates a uppercased version of the string.
        public static func uppercased() -> Self {
            return Self("uppercased") { $0.uppercased() }
        }
    }
}

extension ContentConfiguration.StringTransformer: Hashable {
    public static func == (lhs: ContentConfiguration.StringTransformer, rhs: ContentConfiguration.StringTransformer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension ContentConfiguration {
    struct NSAttributedStringTransformer {
        /// The transform closure of the attributed string transformer.
        public let transform: (NSAttributedString) -> NSAttributedString
        /// The identifier of the attributed string transformer.
        public let id: String

        public func callAsFunction(_ input: NSAttributedString) -> NSAttributedString {
            return transform(input)
        }

        /// Creates a attributed string transformer with the specified closure.
        public init(_ transform: @escaping (NSAttributedString) -> NSAttributedString) {
            self.transform = transform
            id = UUID().uuidString
        }

        /// Creates a attributed string transformer with the specified closure.
        public init(_ id: String, _ transform: @escaping (NSAttributedString) -> NSAttributedString) {
            self.transform = transform
            self.id = id
        }

        /// Creates a color transformer that generates a capitalized version of the attributed string.
        public static func capitalized() -> Self {
            return Self("capitalized") { $0.capitalized() }
        }

        /// Creates a color transformer that generates a lowercased version of the attributed string.
        public static func lowercased() -> Self {
            return Self("lowercased") { $0.lowercased() }
        }

        /// Creates a color transformer that generates a uppercased version of the attributed string.
        public static func uppercased() -> Self {
            return Self("uppercased") { $0.uppercased() }
        }
    }
}

extension ContentConfiguration.NSAttributedStringTransformer: Hashable {
    public static func == (lhs: ContentConfiguration.NSAttributedStringTransformer, rhs: ContentConfiguration.NSAttributedStringTransformer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@available(macOS 12, iOS 15.0, *)
public extension ContentConfiguration {
    struct AttributedStringTransformer {
        /// The transform closure of the attributed string transformer.
        public let transform: (AttributedString) -> AttributedString
        /// The identifier of the attributed string transformer.
        public let id: String

        public func callAsFunction(_ input: AttributedString) -> AttributedString {
            return transform(input)
        }

        /// Creates a attributed string transformer with the specified closure.
        public init(_ transform: @escaping (AttributedString) -> AttributedString) {
            self.transform = transform
            id = UUID().uuidString
        }

        /// Creates a attributed string transformer with the specified closure.
        public init(_ id: String, _ transform: @escaping (AttributedString) -> AttributedString) {
            self.transform = transform
            self.id = id
        }

        /// Creates a color transformer that generates a capitalized version of the attributed string.
        public static func capitalized() -> Self {
            return Self("capitalized") { $0.capitalized() }
        }

        /// Creates a color transformer that generates a lowercased version of the attributed string.
        public static func lowercased() -> Self {
            return Self("lowercased") { $0.lowercased() }
        }

        /// Creates a color transformer that generates a uppercased version of the attributed string.
        public static func uppercased() -> Self {
            return Self("uppercased") { $0.uppercased() }
        }
    }
}

@available(macOS 12, iOS 15.0, *)
extension ContentConfiguration.AttributedStringTransformer: Hashable {
    public static func == (lhs: ContentConfiguration.AttributedStringTransformer, rhs: ContentConfiguration.AttributedStringTransformer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
