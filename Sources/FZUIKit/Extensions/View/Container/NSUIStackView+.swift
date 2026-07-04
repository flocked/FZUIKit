//
//  NSUIStackView+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIStackView {
    /// Sets the distribution of the stack view.
    @discardableResult
    @objc open func distribution(_ distribution: Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    /// Sets the minimum spacing between adjacent views in the stack view.
    @discardableResult
    @objc open func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    #if os(macOS)
    /// Sets the horizontal or vertical layout direction of the stack view.
    @discardableResult
    @objc open func orientation(_ orientation: NSUserInterfaceLayoutOrientation) -> Self {
        self.orientation = orientation
        return self
    }

    /// Sets the view alignment within the stack view.
    @discardableResult
    @objc open func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
        self.alignment = alignment
        return self
    }

    /// Sets the geometric padding, inside the stack view, surrounding its views.
    @discardableResult
    @objc open func edgeInsets(_ insets: NSEdgeInsets) -> Self {
        self.edgeInsets = insets
        return self
    }

    /// Sets the Boolean value indicating whether the stack view removes hidden views from its view hierarchy.
    @discardableResult
    @objc open func detachesHiddenViews(_ detaches: Bool) -> Self {
        self.detachesHiddenViews = detaches
        return self
    }
    #else
    /// Sets the axis along which the arranged views lay out.
    @discardableResult
    @objc open func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }

    /// Sets the view alignment within the stack view.
    @discardableResult
    @objc open func alignment(_ alignment: Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    /// Sets the Boolean value that determines whether the stack view lays out its arranged views relative to its layout margins.
    @discardableResult
    @objc open func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement: Bool) -> Self {
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        return self
    }

    /// Sets the Boolean value that determines whether the vertical spacing between views is measured from their baselines.
    @discardableResult
    @objc open func isBaselineRelativeArrangement(_ isBaselineRelativeArrangement: Bool) -> Self {
        self.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        return self
    }
    #endif

    /// The array of views arranged by the stack view.
    @objc open var arrangedViews: [NSUIView] {
        get { arrangedSubviews }
        set {
            let newValue = newValue.uniqued()
            guard newValue != arrangedSubviews else { return }
            for item in newValue.difference(from: arrangedSubviews) {
                switch item {
                case .insert(offset: let index, element: let view, associatedWith: _):
                    insertArrangedSubview(view, at: index)
                case .remove(offset: _, element: let view, associatedWith: _):
                    removeArrangedSubview(view)
                }
            }
        }
    }

    /// Sets the views arranged by the stack view.
    @discardableResult
    @objc open func arrangedSubviews(_ views: [NSUIView]) -> Self {
        arrangedViews = views
        return self
    }

    /// Removes the custom spacing for all arranged subviews.
    @objc open func removeCustomSpacings() {
        arrangedSubviews.forEach { removeCustomSpacing(after: $0) }
    }

    /// Removes the custom spacing for the specified arranged subview.
    @objc open func removeCustomSpacing(after view: NSUIView) {
        guard arrangedSubviews.contains(view) else { return }
        #if os(macOS)
        setCustomSpacing(NSStackView.useDefaultSpacing, after: view)
        #else
        setCustomSpacing(UIStackView.spacingUseDefault, after: view)
        #endif
    }
}

#if os(macOS)
extension NSStackView {
    /// Sets the delegate object for the stack view.
    @discardableResult
    @objc open func delegate(_ delegate: NSStackViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    /// The handlers of the stack view.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if newValue.willDetach == nil && newValue.didReattach == nil {
                handlersDelegate?.delegateObservation = nil
                delegate = handlersDelegate?.delegate
                handlersDelegate = nil
            } else if handlersDelegate == nil {
                handlersDelegate = .init(for: self)
            }
        }
    }

    /// Handlers of a stack view.
    public struct Handlers {
        /// The handler that is called when the stack view is about to automatically detach one or more of its views.
        public var willDetach: (([NSUIView]) -> ())?

        /// The handler that is called when the stack view has automatically reattached one or more previously-detached views.
        public var didReattach: (([NSUIView]) -> ())?
    }

    private var handlersDelegate: Delegate? {
        get { getAssociatedValue("handlersDelegate") }
        set { setAssociatedValue(newValue, key: "handlersDelegate") }
    }

    private class Delegate: NSObject, NSStackViewDelegate {
        var delegateObservation: KeyValueObservation?
        weak var delegate: NSStackViewDelegate?
        weak var stackView: NSUIStackView?

        func stackView(_ stackView: NSStackView, didReattach views: [NSView]) {
            delegate?.stackView?(stackView, didReattach: views)
            stackView.handlers.didReattach?(views)
        }

        func stackView(_ stackView: NSStackView, willDetach views: [NSView]) {
            delegate?.stackView?(stackView, willDetach: views)
            stackView.handlers.willDetach?(views)
        }

        init(for stackView: NSUIStackView) {
            super.init()
            delegate = stackView.delegate
            self.stackView = stackView
            stackView.delegate = self
            delegateObservation = stackView.observeChanges(for: \.delegate) { [weak self] _, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.stackView?.delegate = self
            }
        }
    }
}

public extension NSStackView {
    /**
     Creates and returns a horizontally oriented stack view.

     - Parameters:
        - alignment: The vertical alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured horizontal stack view.
     */
    static func horizontal(_ alignment: HorizontalAlignment = .center, distribution: Distribution = .gravityAreas, spacing: CGFloat = NSStackView.useDefaultSpacing, views: [NSView] = []) -> Self {
        Self(views: views).distribution(distribution).orientation(.horizontal).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a horizontally oriented stack view.

     - Parameters:
        - alignment: The vertical alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured horizontal stack view.
     */
    static func horizontal(_ alignment: HorizontalAlignment = .center, distribution: Distribution = .gravityAreas, spacing: CGFloat = NSStackView.useDefaultSpacing, @Builder views: () -> [any StackViewItem]) -> Self {
        Self(views: views).distribution(distribution).orientation(.horizontal).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a vertically oriented stack view.

     - Parameters:
        - alignment: The horizontal alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured vertical stack view.
     */
    static func vertical(_ alignment: VerticalAlignment = .center, distribution: Distribution = .gravityAreas, spacing: CGFloat = NSStackView.useDefaultSpacing, views: [NSView] = []) -> Self {
        Self(views: views).distribution(distribution).orientation(.vertical).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a vertically oriented stack view.

     - Parameters:
        - alignment: The horizontal alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured vertical stack view.
     */
    static func vertical(_ alignment: VerticalAlignment = .center, distribution: Distribution = .gravityAreas, spacing: CGFloat = NSStackView.useDefaultSpacing, @Builder views: () -> [any StackViewItem]) -> Self {
        Self(views: views).distribution(distribution).orientation(.vertical).spacing(spacing).alignment(alignment.alignment)
    }
}
#else
public extension UIStackView {
    /**
     Creates and returns a horizontally oriented stack view.

     - Parameters:
        - alignment: The vertical alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured horizontal stack view.
     */
    static func horizontal(_ alignment: HorizontalAlignment = .center, distribution: Distribution = .fill, spacing: CGFloat = UIStackView.spacingUseDefault, views: [UIView] = []) -> Self {
        Self(arrangedSubviews: views).distribution(distribution).axis(.horizontal).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a horizontally oriented stack view.

     - Parameters:
        - alignment: The vertical alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured horizontal stack view.
     */
    static func horizontal(_ alignment: HorizontalAlignment = .center, distribution: Distribution = .fill, spacing: CGFloat = UIStackView.spacingUseDefault, @Builder views: () -> [any StackViewItem]) -> Self {
        Self(arrangedSubviews: views).distribution(distribution).axis(.horizontal).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a vertically oriented stack view.

     - Parameters:
        - alignment: The horizontal alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured vertical stack view.
     */
    static func vertical(_ alignment: VerticalAlignment = .center, distribution: Distribution = .fill, spacing: CGFloat = UIStackView.spacingUseDefault, views: [UIView] = []) -> Self {
        return Self(arrangedSubviews: views).distribution(distribution).axis(.vertical).spacing(spacing).alignment(alignment.alignment)
    }

    /**
     Creates and returns a vertically oriented stack view.

     - Parameters:
        - alignment: The horizontal alignment of the arranged subviews.
        - distribution: The distribution used to lay out the arranged subviews along the stack's axis.
        - spacing: The spacing between adjacent arranged subviews.
        - views: The views to be arranged by the stack view.
     - Returns: A configured vertical stack view.
     */
    static func vertical(_ alignment: VerticalAlignment = .center, distribution: Distribution = .fill, spacing: CGFloat = UIStackView.spacingUseDefault, @Builder views: () -> [any StackViewItem]) -> Self {
        Self(arrangedSubviews: views).distribution(distribution).axis(.vertical).spacing(spacing).alignment(alignment.alignment)
    }
}
#endif

public extension NSUIStackView {
    /**
     Sets the stack view's orientation to horizontal and configures the vertical alignment of its arranged subviews.

     - Parameter alignment: The vertical alignment of the arranged subviews.
     - Returns: The stack view.
     */
    @discardableResult
    func horizontalAlignment(_ alignment: HorizontalAlignment) -> Self {
        orientation = .horizontal
        self.alignment = alignment.alignment
        return self
    }

    /**
     Sets the stack view's orientation to vertical and configures the horizontal alignment of its arranged subviews.

     - Parameter alignment: The horizontal alignment of the arranged subviews.
     - Returns: The stack view.
     */
    @discardableResult
    func verticalAlignment(_ alignment: VerticalAlignment) -> Self {
        orientation = .vertical
        self.alignment = alignment.alignment
        return self
    }
    
    /// The vertical alignment of arranged subviews in a horizontal stack view.
    enum HorizontalAlignment {
        /// Aligns arranged subviews along their top edges.
        case top
        /// Centers arranged subviews vertically.
        case center
        /// Aligns arranged subviews along their bottom edges.
        case bottom
        /// Aligns arranged subviews using their first text baseline.
        case firstBaseline
        /// Aligns arranged subviews using their last text baseline.
        case lastBaseline

        #if os(macOS)
        var alignment: NSLayoutConstraint.Attribute {
            switch self {
            case .top: .top
            case .center: .centerY
            case .bottom: .bottom
            case .firstBaseline: .firstBaseline
            case .lastBaseline: .lastBaseline
            }
        }
        #else
        var alignment: Alignment {
            switch self {
            case .top: .top
            case .center: .center
            case .bottom: .bottom
            case .firstBaseline: .firstBaseline
            case .lastBaseline: .lastBaseline
            }
        }
        #endif
    }

    /// The horizontal alignment of arranged subviews in a vertical stack view.
    enum VerticalAlignment {
        /// Aligns arranged subviews along their leading edges.
        case leading
        /// Centers arranged subviews horizontally.
        case center
        /// Aligns arranged subviews along their trailing edges.
        case trailing
        #if os(macOS)
        /// Aligns arranged subviews along their left edges.
        case left
        /// Aligns arranged subviews along their right edges.
        case right

        var alignment: NSLayoutConstraint.Attribute {
            switch self {
            case .leading: .leading
            case .center: .centerX
            case .trailing: .trailing
            case .left: .left
            case .right: .right
            }
        }
        #else
        var alignment: Alignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
        #endif
    }
}

/// A view or spacing for a `NSStackView`/`UIStackView`.
public protocol StackViewItem { }

extension NSUIView: StackViewItem { }
extension CGFloat: StackViewItem { }
extension Double: StackViewItem { }
extension Int: StackViewItem { }

private protocol StackViewSpacing {
    var stackViewSpacing: CGFloat { get }
}

extension CGFloat: StackViewSpacing {
    var stackViewSpacing: CGFloat { self }
}

extension Double: StackViewSpacing {
    var stackViewSpacing: CGFloat { CGFloat(self) }
}

extension Int: StackViewSpacing {
    var stackViewSpacing: CGFloat { CGFloat(self) }
}

public extension NSObjectProtocol where Self: NSUIStackView {
    #if os(macOS)
    /**
     Creates a stack view with the specified views and custom spacings.
     
     - Parameter views: The views and spacings for the new stack view.

     Custom spacing values specify the spacing after the preceding arranged subview.
     
     Example usage:
     
     ```swift
     UIStackView {
        NSTextField(labelWithString: "Title")
        12
        NSImageView(image: image)
        24
        NSButton(title: "OK", target: nil, action: nil)
     }
     ```
     */
    init(@Builder views: () -> [any StackViewItem]) {
        self.init(views: [])
        addItems(views())
    }
    #else
    /**
     Creates a stack view with the specified views and custom spacings.
     
     - Parameter arrangedSubviews: The views and spacings for the new stack view.

     Custom spacing values specify the spacing after the preceding arranged subview.
     
     Example usage:
     
     ```swift
     UIStackView {
        NSTextField(labelWithString: "Title")
        12
        NSImageView(image: image)
        24
        NSButton(title: "OK", target: nil, action: nil)
     }
     ```
     */
    init(@Builder arrangedSubviews: () -> [any StackViewItem]) {
        self.init(arrangedSubviews: [])
        addItems(arrangedSubviews())
    }
    #endif
    
    private func addItems(_ items:  [any StackViewItem]) {
        var previousView: NSUIView?
        for item in items {
            if let view = item as? NSUIView {
                addArrangedSubview(view)
                previousView = view
            } else if let previousView, let spacing = (item as? StackViewSpacing)?.stackViewSpacing {
                setCustomSpacing(spacing, after: previousView)
            }
        }
    }
}

public extension NSUIStackView {
    /// Sets the views arranged by the stack view.
    @discardableResult
    func arrangedSubviews(@Builder views: () -> [any StackViewItem]) -> Self {
        let resolved = views().resolvedItems()
        arrangedViews = resolved.map(\.view)
        for (view, spacing) in resolved {
            #if os(macOS)
            setCustomSpacing(spacing ?? NSUIStackView.useDefaultSpacing, after: view)
            #else
            setCustomSpacing(spacing ?? NSUIStackView.spacingUseDefault, after: view)
            #endif
        }
        return self
    }
    
    /// A function builder type that produces an array of views and spacings.
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ components: [any StackViewItem]...) -> [any StackViewItem] {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: [any StackViewItem]?) -> [any StackViewItem] {
            component ?? []
        }

        public static func buildEither(first component: [any StackViewItem]) -> [any StackViewItem] {
            component
        }

        public static func buildEither(second component: [any StackViewItem]) -> [any StackViewItem] {
            component
        }

        public static func buildArray(_ components: [[any StackViewItem]]) -> [any StackViewItem] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expression: StackViewItem) -> [any StackViewItem] {
            [expression]
        }

        public static func buildExpression(_ expression: StackViewItem?) -> [any StackViewItem] {
            expression.map({ [$0] }) ?? []
        }

        public static func buildExpression(_ expression: [any StackViewItem]) -> [any StackViewItem] {
            expression
        }

        public static func buildExpression(_ expression: [any StackViewItem]?) -> [any StackViewItem] {
            expression ?? []
        }
    }
}

private extension [any StackViewItem] {
    func resolvedItems() -> [(view: NSUIView, spacing: CGFloat?)] {
        var result: [(view: NSUIView, spacing: CGFloat?)] = []
        var pendingView: NSUIView?
        var pendingSpacing: CGFloat?
        for item in self {
            if let view = item as? NSUIView {
                if let pendingView {
                    result += (pendingView, pendingSpacing)
                }
                pendingView = view
                pendingSpacing = nil
            } else if pendingView != nil, let spacing = item as? StackViewSpacing {
                pendingSpacing = spacing.stackViewSpacing
            }
        }

        if let pendingView {
            result.append((pendingView, pendingSpacing))
        }

        return result
    }
}
#endif
