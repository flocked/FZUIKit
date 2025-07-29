//
//  NSNSUIView+PinEdges.swift
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

public protocol LayoutItem { // `NSUIView`, `NSUILayoutGuide`
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

public extension LayoutItem {
    /**
     Pins the edges to the edges of the given item. By default, it uses the superview.

     - Parameters:
        - target: The target item, or `nil` to use the superview.
        - insets: Insets the edges by the given insets.
        - axis: If provided, only constraints along the axis are created. For example, if you pass axis `.horizontal`, only the `.leading`, `.trailing` (and `.centerX` if needed) attributes are used.
        - alignment:The alignment of the view inside the target item.
        - priority:The priority of the constraints.

     - Returns: The layout constraints.
     */
    @discardableResult
    func pinEdges(to target: LayoutItem? = nil, insets: NSUIEdgeInsets = .zero, axis: NSUIUserInterfaceLayoutOrientation? = nil, alignment: NSUIView.Alignment = .fill, priority: NSUILayoutPriority? = nil) -> [NSLayoutConstraint] {
        assert(Thread.isMainThread, "Align APIs can only be used from the main thread")

        (self as? NSUIView)?.translatesAutoresizingMaskIntoConstraints = false
        guard let target = target ?? self.superview else {
            assertionFailure("View is not part of the view hierarhcy")
            return []
        }
        var constraints = [NSLayoutConstraint]()

        func constrain(attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: target, attribute: attribute, multiplier: 1, constant: constant)
            if let priority = priority {
                constraint.priority = priority
            }
            constraints.append(constraint)
        }

        if axis == nil || axis == .horizontal {
            constrain(attribute: .leading, relation: alignment.horizontal == .fill || alignment.horizontal == .leading ? .equal : .greaterThanOrEqual, constant: insets.left)
            constrain(attribute: .trailing, relation: alignment.horizontal == .fill || alignment.horizontal == .trailing ? .equal : .lessThanOrEqual, constant: -insets.right)
            if alignment.horizontal == .center {
                constrain(attribute: .centerX, relation: .equal, constant: 0)
            }
        }
        if axis == nil || axis == .vertical {
            constrain(attribute: .top, relation: alignment.vertical == .fill || alignment.vertical == .top ? .equal : .greaterThanOrEqual, constant: insets.top)
            constrain(attribute: .bottom, relation: alignment.vertical == .fill || alignment.vertical == .bottom ? .equal : .lessThanOrEqual, constant: -insets.bottom)
            if alignment.vertical == .center {
                constrain(attribute: .centerY, relation: .equal, constant: 0)
            }
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}
#endif
