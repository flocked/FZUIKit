//
//  NSUIView+PinEdges.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public protocol LayoutItem { // `NSView`, `UILayoutGuide`
    var superview: NSUIView? { get }
}

extension NSUIView: LayoutItem {}
extension NSUILayoutGuide: LayoutItem {
    public var superview: NSUIView? { owningView }
}

public extension NSUIView {
    struct Alignment {
        public enum Horizontal {
            case fill, center, leading, trailing
        }

        public enum Vertical {
            case fill, center, top, bottom
        }

        public let horizontal: Horizontal
        public let vertical: Vertical

        public init(horizontal: Horizontal, vertical: Vertical) {
            (self.horizontal, self.vertical) = (horizontal, vertical)
        }

        public static let fill = Alignment(horizontal: .fill, vertical: .fill)
        public static let center = Alignment(horizontal: .center, vertical: .center)
        public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
        public static let leading = Alignment(horizontal: .leading, vertical: .fill)
        public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
        public static let bottom = Alignment(horizontal: .fill, vertical: .bottom)
        public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
        public static let trailing = Alignment(horizontal: .trailing, vertical: .fill)
        public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
        public static let top = Alignment(horizontal: .fill, vertical: .top)
    }
}

#if os(macOS)
public extension LayoutItem {
    @discardableResult
    func pinEdgesToSuperview(insets: NSUIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), alignment: NSUIView.Alignment = .fill, priority: NSLayoutConstraint.Priority? = nil) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }
        return pinEdges(to: superview, insets: insets, alignment: alignment, priority: priority)
    }

    @discardableResult
    func pinEdges(to item2: LayoutItem? = nil, insets: NSUIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), alignment: NSUIView.Alignment = .fill, priority: NSLayoutConstraint.Priority? = nil) -> [NSLayoutConstraint] {
        assert(Thread.isMainThread, "Align APIs can only be used from the main thread")

        (self as? NSUIView)?.translatesAutoresizingMaskIntoConstraints = false
        guard let item2 = item2 ?? superview else {
            assertionFailure("View is not part of the view hierarhcy")
            return []
        }
        var constraints = [NSLayoutConstraint]()

        func constrain(attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item2, attribute: attribute, multiplier: 1, constant: constant)
            if let priority = priority {
                constraint.priority = priority
            }
            constraints.append(constraint)
        }

        constrain(attribute: .leading, relation: alignment.horizontal == .fill || alignment.horizontal == .leading ? .equal : .greaterThanOrEqual, constant: insets.left)
        constrain(attribute: .trailing, relation: alignment.horizontal == .fill || alignment.horizontal == .trailing ? .equal : .lessThanOrEqual, constant: -insets.right)
        if alignment.horizontal == .center {
            constrain(attribute: .centerX, relation: .equal, constant: 0)
        }

        constrain(attribute: .top, relation: alignment.vertical == .fill || alignment.vertical == .top ? .equal : .greaterThanOrEqual, constant: insets.top)
        constrain(attribute: .bottom, relation: alignment.vertical == .fill || alignment.vertical == .bottom ? .equal : .lessThanOrEqual, constant: -insets.bottom)
        if alignment.vertical == .center {
            constrain(attribute: .centerY, relation: .equal, constant: 0)
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func pinEdges(to item2: LayoutItem? = nil, inset: CGFloat, alignment: NSUIView.Alignment = .fill, priority: NSLayoutConstraint.Priority? = nil) -> [NSLayoutConstraint] {
        return pinEdges(to: item2, insets: .init(top: inset, left: inset, bottom: inset, right: inset), alignment: alignment, priority: priority)
    }
}

#elseif canImport(UIKit)
public extension LayoutItem {
    @discardableResult
    func pinEdgesToSuperview(insets: NSUIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), alignment: NSUIView.Alignment = .fill) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }
        return pinEdges(to: superview, insets: insets, alignment: alignment)
    }

    @discardableResult
    func pinEdges(to item2: LayoutItem? = nil, insets: NSUIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0), alignment: NSUIView.Alignment = .fill) -> [NSLayoutConstraint] {
        assert(Thread.isMainThread, "Align APIs can only be used from the main thread")

        (self as? NSUIView)?.translatesAutoresizingMaskIntoConstraints = false
        guard let item2 = item2 ?? superview else {
            assertionFailure("View is not part of the view hierarhcy")
            return []
        }
        var constraints = [NSLayoutConstraint]()

        func constrain(attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item2, attribute: attribute, multiplier: 1, constant: constant)
            constraints.append(constraint)
        }

        constrain(attribute: .leading, relation: alignment.horizontal == .fill || alignment.horizontal == .leading ? .equal : .greaterThanOrEqual, constant: insets.left)
        constrain(attribute: .trailing, relation: alignment.horizontal == .fill || alignment.horizontal == .trailing ? .equal : .lessThanOrEqual, constant: -insets.right)
        if alignment.horizontal == .center {
            constrain(attribute: .centerX, relation: .equal, constant: 0)
        }

        constrain(attribute: .top, relation: alignment.vertical == .fill || alignment.vertical == .top ? .equal : .greaterThanOrEqual, constant: insets.top)
        constrain(attribute: .bottom, relation: alignment.vertical == .fill || alignment.vertical == .bottom ? .equal : .lessThanOrEqual, constant: -insets.bottom)
        if alignment.vertical == .center {
            constrain(attribute: .centerY, relation: .equal, constant: 0)
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func pinEdges(to item2: LayoutItem? = nil, inset: CGFloat, alignment: NSUIView.Alignment = .fill) -> [NSLayoutConstraint] {
        return pinEdges(to: item2, insets: .init(top: inset, left: inset, bottom: inset, right: inset), alignment: alignment)
    }
}
#endif
#endif
