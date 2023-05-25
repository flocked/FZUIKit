//
//  ContentConfiguration+TextField.swift
//
//
//  Created by Florian Zand on 04.04.23.
//

#if os(macOS)
    import AppKit

    public extension ContentConfiguration {
        /// A configuration that specifies the appearance of a text.
        struct TextField: Hashable {
            public enum BezelStyle: Hashable {
                case rounded
                case square
            }

            public var textConfiguration: Text = .default()

            public var isSelectable: Bool = false
            public var isEditable: Bool = false

            public var bezelStyle: BezelStyle? = nil
        }
    }
#endif
