//
//  SimpleStackView.swift
//
//
//  Created by Florian Zand on 18.06.23.
//

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif
import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
    /**
     A view that arranges an array of views horizontally or vertically and updates their placement and sizing when the window size changes.

     It's a simplified stack view compared to `NSStackView` and `UIStackView`.
     */
    open class SimpleStackView: NSUIView {
        /// The distribution for an arranged subview.
        public enum ViewDistribution: Int {
            /// The view fills the total stack view orientation (default).
            case fill
            /// The view is centered at the stack view orientation.
            case center
            /// The view is leading at the stack view orientation.
            case leading
            /// The view is trailing the stack view orientation.
            case trailing
            /// The view is distributed to the first baseline, This distribution only works when the stack view orientation is set to horizontal.
            case firstBaseline
            /// The view is distributed to the last baseline, This distribution only works when the stack view orientation is set to horizontal.
            case lastBaseline
        }

        /// The array of views arranged by the stack view.
        open var arrangedSubviews: [NSUIView] = [] {
            didSet {
                guard oldValue != arrangedSubviews else { return }
                setupManagedViews(previous: oldValue)
            }
        }

        /// The horizontal or vertical layout direction of the stack view.
        open var orientation: NSUIUserInterfaceLayoutOrientation = .vertical {
            didSet {
                guard oldValue != orientation else { return }
                updateViewConstraints()
            }
        }

        /// The spacing between views in the stack view.
        open var spacing: CGFloat = 2.0 {
            didSet {
                guard oldValue != spacing else { return }
                updateSpacing()
            }
        }

        /// Sets the distribution for all arranged subviews. The default value is `fill`.
        open func setDistribution(_ distribution: ViewDistribution) {
            arrangedSubviews.forEach({ setDistribution(distribution, for: $0) })
        }

        /// Sets the distribution for an arranged subview. The default value is `fill`.
        open func setDistribution(_ distribution: ViewDistribution, for arrangedSubview: NSUIView) {
            guard arrangedSubviews.contains(arrangedSubview) else { return }
            let id = ObjectIdentifier(arrangedSubview).hashValue
            guard viewDistributions[id] != distribution else { return }
            viewDistributions[id] = distribution
            updateViewConstraints()
        }

        /**
         Creates and returns a stack view with a specified array of views.

         - Parameter views: The array of views for the new stack view.
         - Returns: A stack view initialized with the specified array of views.
         */
        public init(views: [NSUIView]) {
            super.init(frame: .zero)
            arrangedSubviews = views
            setupManagedViews()
        }
        
        /**
         Creates and returns a stack view with a specified array of views.

         - Parameter views: The array of views for the new stack view.
         - Returns: A stack view initialized with the specified array of views.
         */
        public convenience init(@Builder views: () -> [NSView]) {
            self.init(views: views())
        }

        
        /// A horizontal stack view with the specified views, spacing and distribution.
        public static func horizontal(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill) -> SimpleStackView {
            let stackView = SimpleStackView(views: views)
            stackView.orientation = .horizontal
            stackView.spacing = spacing
            if distribution != .fill {
                stackView.setDistribution(distribution)
            }
            return stackView
        }
        
        /// A horizontal stack view with the specified views, spacing and distribution.
        public static func horizontal(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, @Builder views: () -> [NSView]) -> SimpleStackView {
            horizontal(views: views(), spacing: spacing, distribution: distribution)
        }
        
        /// A vertical stack view with the specified views, spacing and distribution.
        public static func vertical(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill) -> SimpleStackView {
            let stackView = SimpleStackView(views: views)
            stackView.orientation = .vertical
            stackView.spacing = spacing
            if distribution != .fill {
                stackView.setDistribution(distribution)
            }
            return stackView
        }
        
        /// A vertical stack view with the specified views, spacing and distribution.
        public static func vertical(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, @Builder views: () -> [NSView]) -> SimpleStackView {
            vertical(views: views(), spacing: spacing, distribution: distribution)
        }

        @available(*, unavailable)
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        var viewObservers: [Int: KeyValueObservation] = [:]
        var viewDistributions: [Int: ViewDistribution] = [:]
        var viewConstraints: [NSLayoutConstraint] = []

        func setupManagedViews(previous: [NSUIView] = []) {
            var removedViews: [NSUIView] = []
            var newViews: [NSUIView] = []
            for oldView in previous {
                if arrangedSubviews.contains(oldView) == false {
                    removedViews.append(oldView)
                }
            }
            for managedView in arrangedSubviews {
                if previous.contains(managedView) == false {
                    newViews.append(managedView)
                }
            }
            removedViews.forEach {
                $0.removeFromSuperview()
                self.removeObserver(for: $0)
                self.viewDistributions[ObjectIdentifier($0).hashValue] = nil
            }

            newViews.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addObserver(for: $0)
                self.viewDistributions[ObjectIdentifier($0).hashValue] = .fill
                self.addSubview($0)
            }

            updateViewConstraints()
        }

        func addObserver(for view: NSUIView) {
            let id = ObjectIdentifier(view).hashValue
            viewObservers[id] = view.observeChanges(for: \.isHidden, handler: { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.updateViewConstraints()
            })
        }

        func removeObserver(for view: NSUIView) {
            let id = ObjectIdentifier(view).hashValue
            viewObservers[id] = nil
        }

        func updateSpacing() {
            var constraints = viewConstraints.filter {
                $0.firstAttribute == (orientation == .vertical ? .top : .leading)
            }
            if !includeLeadingAndTrailing { 
                constraints = constraints.filter({$0.secondItem !== self})
            }
            constraints.constant(spacing)

            constraints = viewConstraints.filter {
                $0.firstAttribute == (orientation == .vertical ? .bottom : .trailing)
            }
            if !includeLeadingAndTrailing {
                constraints = constraints.filter({$0.secondItem !== self})
            }
            constraints.constant(-spacing)
        }
        
        #if os(macOS)
        open func sizeToFit() {
            frame.size = fittingSize
        }
        
        open func sizeThatFits(_ size: CGSize) -> CGSize {
            fittingSize.clamped(minSize: size.clamped(minSize: .zero))
        }
        #endif

        /*
        override public var intrinsicContentSize: CGSize {
            sizeThatFits(CGSize(width: NSUIView.noIntrinsicMetric, height: NSUIView.noIntrinsicMetric))
        }

        func _sizeThatFits(_ size: CGSize) -> CGSize {
            var fittingSize: CGSize?
            if orientation == .vertical, size.width != .zero {
                let originalWidthConstraint: NSLayoutConstraint? = constraints.first(where: { $0.firstAttribute == .width
                        || $0.secondAttribute == .width
                })
                originalWidthConstraint?.isActive = false
                let widthConstraint = widthAnchor.constraint(equalToConstant: (size.width == .infinity || size.width == NSUIView.noIntrinsicMetric) ? 10000 : size.width)
                widthConstraint.isActive = true
                #if os(macOS)
                fittingSize = self.fittingSize
                #else
                fittingSize = super.sizeThatFits(size)
                #endif
                widthConstraint.isActive = false
                originalWidthConstraint?.isActive = true
            } else if orientation == .horizontal, size.height != .zero {
                let originalHeightConstraint: NSLayoutConstraint? = constraints.first(where: { $0.firstAttribute == .height
                        || $0.secondAttribute == .height
                })
                originalHeightConstraint?.isActive = false
                let heightConstraint = heightAnchor.constraint(equalToConstant: (size.height == .infinity || size.height == NSUIView.noIntrinsicMetric) ? 10000 : size.height)
                heightConstraint.isActive = true
                #if os(macOS)
                fittingSize = self.fittingSize
                #else
                fittingSize = super.sizeThatFits(size)
                #endif
                heightConstraint.isActive = false
                originalHeightConstraint?.isActive = true
            }
            #if os(macOS)
            return fittingSize ?? self.fittingSize
            #else
            return fittingSize ?? super.sizeThatFits(size)
            #endif
        }

        #if os(macOS)
            public func sizeThatFits(_ size: CGSize) -> CGSize {
                _sizeThatFits(size)
            }

        #elseif canImport(UIKit)
            override public func sizeThatFits(_ size: CGSize) -> CGSize {
                _sizeThatFits(size)
            }
        #endif
         */

        var includeLeadingAndTrailing: Bool = false
        func updateViewConstraints() {
            viewConstraints.activate(false)
            viewConstraints.removeAll()
            var nextAnchorView: NSUIView = self
            let nonHiddenViews = arrangedSubviews.filter { $0.isHidden == false }
            for (index, managedView) in nonHiddenViews.enumerated() {
                let distribution = viewDistributions[ObjectIdentifier(managedView).hashValue] ?? .fill
                if orientation == .vertical {
                    var constraints = [
                        managedView.topAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.topAnchor : nextAnchorView.bottomAnchor, constant: (nextAnchorView == self || includeLeadingAndTrailing) ? 0 : spacing),
                    ]
                    switch distribution {
                    case .fill:
                        constraints.append(managedView.leadingAnchor.constraint(equalTo: leadingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(equalTo: widthAnchor))
                    case .leading:
                        constraints.append(managedView.leadingAnchor.constraint(equalTo: leadingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    case .trailing:
                        constraints.append(managedView.trailingAnchor.constraint(equalTo: trailingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    case .center:
                        constraints.append(managedView.centerXAnchor.constraint(equalTo: centerXAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    default:
                        break
                    }
                    if index == nonHiddenViews.count - 1 {
                        constraints.append(managedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: includeLeadingAndTrailing ? -spacing : 0))
                    }
                    nextAnchorView = managedView
                    viewConstraints.append(contentsOf: constraints)
                } else {
                    var constraints = [
                        managedView.leadingAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.leadingAnchor : nextAnchorView.trailingAnchor, constant: (nextAnchorView == self || includeLeadingAndTrailing) ? 0 : spacing),
                    ]
                    switch distribution {
                    case .fill:
                        constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        constraints.append(managedView.heightAnchor.constraint(equalTo: heightAnchor))
                    case .leading:
                        constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .trailing:
                        constraints.append(managedView.bottomAnchor.constraint(equalTo: bottomAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .center:
                        constraints.append(managedView.centerYAnchor.constraint(equalTo: centerYAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .firstBaseline:
                        if index < nonHiddenViews.count - 1 {
                            let otherManagedView = nonHiddenViews[index + 1]
                            constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                        } else if index > 0 {
                            let otherManagedView = nonHiddenViews[index - 1]
                            constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                        } else {
                            constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        }
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .lastBaseline:
                        if index < nonHiddenViews.count - 1 {
                            let otherManagedView = nonHiddenViews[index + 1]
                            constraints.append(managedView.lastBaselineAnchor.constraint(equalTo: otherManagedView.lastBaselineAnchor))
                        } else if index > 0 {
                            let otherManagedView = nonHiddenViews[index - 1]
                            constraints.append(managedView.lastBaselineAnchor.constraint(equalTo: otherManagedView.lastBaselineAnchor))
                        } else {
                            constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        }
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    }
                    if index == nonHiddenViews.count - 1 {
                        constraints.append(managedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: includeLeadingAndTrailing ? -spacing : 0))
                    }
                    nextAnchorView = managedView
                    viewConstraints.append(contentsOf: constraints)
                }
            }
            viewConstraints.activate()
        }
    }

extension SimpleStackView {
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

/// A flexible spacer view for ``SimpleStackView`` that expands along the major axis of its containing stack view.
open class SpacerView: NSUIView {

}
#endif
