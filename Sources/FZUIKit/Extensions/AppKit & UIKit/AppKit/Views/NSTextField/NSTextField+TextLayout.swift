//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

#if os(macOS)
import AppKit

public extension NSTextField {
    convenience init(layout: TextLayout) {
        self.init(frame: .zero)
        textLayout = layout
    }
    
    convenience init(frame: CGRect, layout: TextLayout) {
        self.init(frame: frame)
        textLayout = layout
    }
    
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

    enum TextLayout: Int, CaseIterable {
        case truncates = 0
        case wraps = 1
        case scrolls = 2

        public init?(lineBreakMode: NSLineBreakMode) {
            guard let found = Self.allCases.first(where: { $0.lineBreakMode == lineBreakMode }) else { return nil }
            self = found
        }

        internal var isScrollable: Bool {
            return (self == .scrolls)
        }

        internal var wraps: Bool {
            return (self == .wraps)
        }

        internal var layoutPriority: NSLayoutConstraint.Priority {
            return (self == .wraps) ? .fittingSizeCompression : .defaultLow
        }

        internal var lineBreakMode: NSLineBreakMode {
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
