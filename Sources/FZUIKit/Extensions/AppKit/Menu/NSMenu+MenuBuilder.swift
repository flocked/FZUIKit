//
//  NSMenu+MenuBuilder.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import AppKit

public extension NSMenu {
    /// Create a new menu with the given title and items.
    convenience init(_ title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init(title: title)
        self.items(items)
    }

    /// Create a new menu with the given title and items.
    convenience init(title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init(title: title)
        self.items(items)
    }

    /// Create a new menu with the given items.
    convenience init(@MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init()
        self.items(items)
    }
}

public extension NSMenu {
    /// A container that increases the `indentationLevel` of its content by one.
    struct IndentGroup {
        fileprivate let children: () -> [NSMenuItem?]

        public init(@MenuBuilder children: @escaping () -> [NSMenuItem?]) {
            self.children = children
        }
    }
}

/// A function builder type that produces an array of menu items.
@resultBuilder
public enum MenuBuilder {
    public static func buildBlock(_ block: [NSMenuItem]...) -> [NSMenuItem] {
        block.flatMap { $0 }
    }

    public static func buildOptional(_ item: [NSMenuItem]?) -> [NSMenuItem] {
        item ?? []
    }

    public static func buildEither(first: [NSMenuItem]?) -> [NSMenuItem] {
        first ?? []
    }

    public static func buildEither(second: [NSMenuItem]?) -> [NSMenuItem] {
        second ?? []
    }

    public static func buildArray(_ components: [[NSMenuItem]]) -> [NSMenuItem] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expr: [NSMenuItem]?) -> [NSMenuItem] {
        expr ?? []
    }

    public static func buildExpression(_ expr: NSMenuItem?) -> [NSMenuItem] {
        expr.map { [$0] } ?? []
    }

    public static func buildExpression(_ string: String?) -> [NSMenuItem] {
        if let string = string {
            return [NSMenuItem(string)]
        }
        return []
    }

    public static func buildExpression(_ strings: [String]?) -> [NSMenuItem] {
        strings?.compactMap({NSMenuItem($0)}) ?? []
    }

    public static func buildExpression(_ view: NSView?) -> [NSMenuItem] {
        if let view = view {
            return [NSMenuItem(view: view)]
        }
        return []
    }

    public static func buildExpression(_ views: [NSView]?) -> [NSMenuItem] {
        views?.compactMap({NSMenuItem(view: $0)}) ?? []
    }
    
    public static func buildExpression(_ expr: NSMenu.IndentGroup?) -> [NSMenuItem] {
        guard let items = expr?.children().compactMap({ $0 }) else { return [] }
        items.forEach({ $0.indentationLevel += 1 })
        return items
    }
}
#endif
