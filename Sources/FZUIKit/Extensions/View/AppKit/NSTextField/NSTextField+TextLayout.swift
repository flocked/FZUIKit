//
//  NSTextField+TextLayout.swift
//
//
//  Created by Florian Zand on 02.06.23.
//

#if os(macOS)
    import AppKit

    public extension NSTextField {
        /**
         Initializes a text field with the specified layout.
         - Parameter layout: The text layout of the text field.
         - Returns: An initialized `NSTextField`.
         */
        convenience init(layout: TextLayout) {
            self.init(frame: .zero)
            textLayout = layout
            maximumNumberOfLines = 0
        }

        /// The text layout of the text field.
        var textLayout: TextLayout? {
            get {
                switch (lineBreakMode, cell?.wraps, cell?.isScrollable) {
                case (.byWordWrapping, true, false):
                    return .wraps
                case (.byTruncatingTail, false, false):
                    return .truncates
                case (.byClipping, false, true):
                    return .scrolls
                default:
                    return nil
                }
            }
            set {
                if let newValue = newValue {
                    lineBreakMode = newValue.lineBreakMode
                    usesSingleLineMode = false
                    cell?.wraps = newValue.wraps
                    truncatesLastVisibleLine = true
                    cell?.isScrollable = newValue.isScrollable
                    setContentCompressionResistancePriority(newValue.layoutPriority, for: .horizontal)
                }
            }
        }

        /// The text layout of a text field.
        enum TextLayout: Int, CaseIterable {
            /// The text field truncates the tail of text that exceeds it's bounds.
            case truncates = 0
            /// The text field wraps text that exceeds it's bounds.
            case wraps = 1
            /// The text scrolls past the text field cell.
            case scrolls = 2

            init?(lineBreakMode: NSLineBreakMode) {
                guard let found = Self.allCases.first(where: { $0.lineBreakMode == lineBreakMode }) else { return nil }
                self = found
            }

            var isScrollable: Bool {
                self == .scrolls
            }

            var wraps: Bool {
                self == .wraps
            }

            var layoutPriority: NSLayoutConstraint.Priority {
                (self == .wraps) ? .fittingSizeCompression : .defaultLow
            }

            var lineBreakMode: NSLineBreakMode {
                switch self {
                case .wraps:
                    return .byWordWrapping
                case .truncates:
                    return .byTruncatingTail
                case .scrolls:
                    return .byClipping
                }
            }
        }
    }

#endif
