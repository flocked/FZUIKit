//
//  NSSegmentedControl+Builder.swift
//
//
//  Created by Florian Zand on 19.04.23.
//
#if os(macOS)
import AppKit

public extension NSSegmentedControl {
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ block: [Segment]...) -> [Segment] {
            block.flatMap { $0 }
        }
        
        public static func buildOptional(_ item: Segment?) -> [Segment] {
            if let item = item {
                return [item]
            }
           return []
        }

        public static func buildOptional(_ item: [Segment]?) -> [Segment] {
            item ?? []
        }

        public static func buildEither(first: [Segment]?) -> [Segment] {
            first ?? []
        }

        public static func buildEither(second: [Segment]?) -> [Segment] {
            second ?? []
        }

        public static func buildArray(_ components: [[Segment]]) -> [Segment] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [Segment]?) -> [Segment] {
            expr ?? []
        }

        public static func buildExpression(_ expr: Segment?) -> [Segment] {
            expr.map { [$0] } ?? []
        }

        public static func buildExpression(_ expr: [NSImage]?) -> [Segment] {
            return expr?.map { Segment($0) } ?? []
        }

        public static func buildExpression(_ expr: NSImage?) -> [Segment] {
            if let image = expr {
                return [Segment(image)]
            }
            return []
        }

        public static func buildExpression(_ expr: [String]?) -> [Segment] {
            return expr?.map { Segment($0) } ?? []
        }

        public static func buildExpression(_ expr: String?) -> [Segment] {
            if let string = expr {
                return [Segment(string)]
            }
            return []
        }
    }
}

#endif
