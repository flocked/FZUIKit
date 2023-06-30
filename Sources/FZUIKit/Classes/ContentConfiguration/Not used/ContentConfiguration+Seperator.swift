//
//  ContentConfiguration+Seperator.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
import AppKit

public extension ContentConfiguration {
    struct Seperator: Hashable {
        public var color: NSColor = .separatorColor
        public var insets: NSDirectionalEdgeInsets = .zero
        public var opacity: CGFloat = 1.0
        public var height: CGFloat = 1.0
        public var visibility: Visibility = .hidden

        public enum Visibility: Int, Hashable {
            case hidden
            case visible
        }

        public init(visibility: Visibility = .hidden,
                    color: NSColor = .black,
                    height: CGFloat = 1.0,
                    opacity: CGFloat = 1.0,
                    insets: NSDirectionalEdgeInsets = .zero)
        {
            self.visibility = visibility
            self.color = color
            self.height = height
            self.opacity = opacity
            self.insets = insets
        }

        public static func visible() -> Self { return Self(visibility: .visible) }
        public static func hidden() -> Self { return Self(visibility: .hidden) }
    }
}

#endif
