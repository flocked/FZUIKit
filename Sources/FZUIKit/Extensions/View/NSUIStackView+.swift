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
            newValue.difference(from: arrangedSubviews).forEach {
                switch $0 {
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

    /// Sets the views arranged by the stack view.
    @discardableResult
    @objc open func arrangedSubviews(@Builder views: () -> [NSUIView]) -> Self {
        arrangedViews = views()
        return self
    }

    /// Removes the custom spacing for all arranged subviews.
    @objc open func removeCustomSpacings() -> Void {
        arrangedSubviews.forEach({ removeCustomSpacing(after: $0) })
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

    #if os(macOS)
    /**
     Creates and returns a stack view with the specified views.

     - Parameter views: The views for the new stack view.
     */
    public convenience init(@Builder views: () -> [NSUIView]) {
        self.init(views: views())
    }
    #else
    /**
     Returns a new stack view object that manages the provided views.

     - Parameter arrangedSubviews: The views to be arranged by the stack view.
     */
    public convenience init(@Builder arrangedSubviews views: () -> [NSUIView]) {
        self.init(arrangedSubviews: views())
    }
    #endif

    /// A function builder type that produces an array of views.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ block: [NSUIView]...) -> [NSUIView] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [NSUIView]?) -> [NSUIView] {
            item ?? []
        }

        public static func buildEither(first: [NSUIView]?) -> [NSUIView] {
            first ?? []
        }

        public static func buildEither(second: [NSUIView]?) -> [NSUIView] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSUIView]]) -> [NSUIView] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [NSUIView]?) -> [NSUIView] {
            expr ?? []
        }

        public static func buildExpression(_ expr: NSUIView?) -> [NSUIView] {
            expr.map { [$0] } ?? []
        }
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
        /// The handler that gets called when the stack view is about to automatically detach one or more of its views.
        public var willDetach: (([NSUIView])->())?
        
        /// The handler that gets called when the stack view has automatically reattached one or more previously-detached views.
        public var didReattach: (([NSUIView])->())?

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
            delegateObservation = stackView.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.stackView?.delegate = self
            }
        }
    }
}
#endif
#endif
