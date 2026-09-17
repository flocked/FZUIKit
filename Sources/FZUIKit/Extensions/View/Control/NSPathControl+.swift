//
//  NSPathControl+.swift
//  FZUIKit
//
//  Created by Florian Zand on 17.09.26.
//

#if os(macOS)
import AppKit

public extension NSPathControl {
    @discardableResult
    func url(_ url: URL?) -> Self {
        self.url = url
        actionBlock
        return self
    }
    
    /// Creates a path control with the specified path items.
    convenience init(@Builder _ pathItems: () -> [NSPathControlItem]) {
        self.init()
        self.pathItems = pathItems()
    }

    /// A result builder that produces an array of path control items.
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ components: [NSPathControlItem]...) -> [NSPathControlItem] {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: [NSPathControlItem]?) -> [NSPathControlItem] {
            component ?? []
        }

        public static func buildEither(first component: [NSPathControlItem]) -> [NSPathControlItem] {
            component
        }

        public static func buildEither(second component: [NSPathControlItem]) -> [NSPathControlItem] {
            component
        }

        public static func buildArray(_ components: [[NSPathControlItem]]) -> [NSPathControlItem] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ item: NSPathControlItem) -> [NSPathControlItem] {
            [item]
        }

        public static func buildExpression(_ item: NSPathControlItem?) -> [NSPathControlItem] {
            item.map { [$0] } ?? []
        }

        public static func buildExpression(_ items: [NSPathControlItem]) -> [NSPathControlItem] {
            items
        }

        public static func buildExpression(_ items: [NSPathControlItem]?) -> [NSPathControlItem] {
            items ?? []
        }

        public static func buildExpression(_ string: String) -> [NSPathControlItem] {
            [NSPathControlItem(title: string)]
        }

        public static func buildExpression(_ string: String?) -> [NSPathControlItem] {
            string.map { [NSPathControlItem(title: $0)] } ?? []
        }

        public static func buildExpression(_ strings: [String]) -> [NSPathControlItem] {
            strings.map { NSPathControlItem(title: $0) }
        }

        public static func buildExpression(_ strings: [String]?) -> [NSPathControlItem] {
            strings?.map { NSPathControlItem(title: $0) } ?? []
        }
        
        public static func buildExpression(_ attributedString: NSAttributedString) -> [NSPathControlItem] {
            [NSPathControlItem(attributedTitle: attributedString)]
        }

        public static func buildExpression(_ attributedString: NSAttributedString?) -> [NSPathControlItem] {
            attributedString.map { [NSPathControlItem(attributedTitle: $0)] } ?? []
        }

        public static func buildExpression(_ attributedStrings: [NSAttributedString]) -> [NSPathControlItem] {
            attributedStrings.map { NSPathControlItem(attributedTitle: $0) }
        }

        public static func buildExpression(_ attributedStrings: [NSAttributedString]?) -> [NSPathControlItem] {
            attributedStrings?.map { NSPathControlItem(attributedTitle: $0) } ?? []
        }
        
        public static func buildExpression(_ attributedString: AttributedString) -> [NSPathControlItem] {
            [NSPathControlItem(attributedTitle: attributedString)]
        }

        public static func buildExpression(_ attributedString: AttributedString?) -> [NSPathControlItem] {
            attributedString.map { [NSPathControlItem(attributedTitle: $0)] } ?? []
        }

        public static func buildExpression(_ attributedStrings: [AttributedString]) -> [NSPathControlItem] {
            attributedStrings.map { NSPathControlItem(attributedTitle: $0) }
        }

        public static func buildExpression(_ attributedStrings: [AttributedString]?) -> [NSPathControlItem] {
            attributedStrings?.map { NSPathControlItem(attributedTitle: $0) } ?? []
        }
    }
}

public extension NSPathControlItem {
    /// Creates a path control item with the specified title and image.
    convenience init(title: String, image: NSImage? = nil) {
        self.init()
        self.title = title
        self.image = image
    }

    /// Creates a path control item with the specified attributed title and image.
    convenience init(attributedTitle: NSAttributedString, image: NSImage? = nil) {
        self.init()
        self.attributedTitle = attributedTitle
        self.image = image
    }

    /// Creates a path control item with the specified attributed title and image.
    convenience init(attributedTitle: AttributedString, image: NSImage? = nil) {
        self.init()
        self.attributedTitle = NSAttributedString(attributedTitle)
        self.image = image
    }
}
#endif
