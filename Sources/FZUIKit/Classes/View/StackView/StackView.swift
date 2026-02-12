//
//  StackView.swift
//
//  Parts taken from:
//  Maximilian Mackh
//
//  Created by Florian Zand on 18.04.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import FZSwiftUtils

/**
 A view that arranges an array of views horizontally or vertically and updates their placement and sizing when the window size changes.

 It's a simplified stack view compared to `NSStackView` and `UIStackView`.
 */
open class StackView: NSUIView {

    /// The distribution for an arranged subview.
    public enum Distribution: Int {
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
    
    /// The sizing for an arranged subview.
    public enum Sizing: Hashable {
        /// The size is calculated automatically.
        case automatic
        /// The view has a fixed size.
        case fixed(CGFloat)
        /// The size is equally distributed between the view and other views set to equal.
        case equal
        /// The view is sized to the percentage amount.
        case percentage(CGFloat)
    }
        
    /// The array of views arranged by the stack view.
    open var arrangedSubviews: [NSUIView] = [] {
        didSet {
            guard oldValue != arrangedSubviews else { return }
            setupArrangedSubviews(previous: oldValue)
        }
    }
        
    /// The spacing between views in the stack view.
    open var spacing: CGFloat = 6 {
        didSet {
            guard oldValue != spacing else { return }
            layoutArrangedSubviews()
        }
    }
    
    /// The horizontal or vertical layout direction of the stack view.
    open var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal {
        didSet {
            guard oldValue != orientation else { return }
            layoutArrangedSubviews()
        }
    }
    
    open var distribution: Distribution = .fill {
        didSet {
            guard oldValue != distribution else { return }
            layoutArrangedSubviews()
        }
    }

    
    /// Sets the distribution for all arranged subviews. The default value is `fill`.
    open func setDistribution(_ distribution: Distribution) {
        // arrangedSubviews.filter({$0 as? SpacerView == nil}).forEach({ setDistribution(distribution, for: $0) })
        self.distribution = distribution
    }

    /// Sets the distribution for an arranged subview. The default value is `fill`.
    open func setDistribution(_ distribution: Distribution, for arrangedSubview: NSUIView) {
        guard arrangedSubviews.contains(arrangedSubview) else { return }
        guard arrangedViewOptions[arrangedSubview.objectID]?.distribution != distribution else { return }
        arrangedViewOptions[arrangedSubview.objectID]?.distribution = distribution
        layoutArrangedSubviews()
    }
    
    /// Sets the distribution for all arranged subviews. The default value is `fill`.
    open func setSizing(_ sizing: Sizing) {
        arrangedSubviews.forEach({ setSizing(sizing, for: $0) })
    }
    
    /// Sets the sizing for an arranged subview. The default value resizes the view is `automatic`.
    open func setSizing(_ sizing: Sizing, for  arrangedSubview: NSUIView) {
        guard arrangedSubviews.contains(arrangedSubview) else { return }
        guard !(arrangedSubview is SpacerView) else { return }
        guard arrangedViewOptions[arrangedSubview.objectID]?.sizing != sizing else { return }
        arrangedViewOptions[arrangedSubview.objectID]?.sizing = sizing
        layoutArrangedSubviews()
    }
    
    /// Applies custom spacing after the specified view.
    open func setCustomSpacing(_ spacing: CGFloat?, after view: NSUIView) {
        arrangedViewOptions[view.objectID]?.spacing = spacing
    }
    
    #if os(macOS)
    /// The default spacing to use when laying out the arranged subviews in the view.
    open var layoutMargins: NSUIEdgeInsets = .zero {
        didSet {
            guard oldValue != layoutMargins else { return }
            layoutArrangedSubviews()
        }
    }
    #else
    /// The default spacing to use when laying out the arranged subviews in the view.
    open override var layoutMargins: NSUIEdgeInsets {
        didSet {
            guard oldValue != layoutMargins else { return }
            layoutArrangedSubviews()
        }
    }
    #endif
    
    /**
     Creates and returns a stack view with a specified array of views.

     - Parameter views: The array of views for the new stack view.
     - Returns: A stack view initialized with the specified array of views.
     */
    public init(views: [NSUIView]) {
        super.init(frame: .zero)
        layoutMargins = .zero
        arrangedSubviews = views
        setupArrangedSubviews()
    }
    
    /**
     Creates and returns a stack view with a specified array of views.

     - Parameter views: The array of views for the new stack view.
     - Returns: A stack view initialized with the specified array of views.
     */
    public convenience init(@Builder views: () -> [NSUIView]) {
        self.init(views: views())
    }
    
    /// Creates and returns a stack view.
    public init() {
        super.init(frame: .zero)
    }
    
    /// A horizontal stack view with the specified views, spacing and distribution.
    public static func horizontal(views: [NSUIView], spacing: CGFloat = 2, distribution: Distribution = .fill, sizing: Sizing = .automatic) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .horizontal
        stackView.spacing = spacing
        stackView.setSizing(sizing)
        stackView.setDistribution(distribution)
        return stackView
    }
    
    /// A horizontal stack view with the specified views, spacing and distribution.
    public static func horizontal(spacing: CGFloat = 2, distribution: Distribution = .fill, sizing: Sizing = .automatic, @Builder views: () -> [NSUIView]) -> StackView {
        horizontal(views: views(), spacing: spacing, distribution: distribution, sizing: sizing)
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(views: [NSUIView], spacing: CGFloat = 2, distribution: Distribution = .fill, sizing: Sizing = .automatic) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .vertical
        stackView.spacing = spacing
        stackView.setSizing(sizing)
        stackView.setDistribution(distribution)
        return stackView
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(spacing: CGFloat = 2, distribution: Distribution = .fill, sizing: Sizing = .automatic, @Builder views: () -> [NSUIView]) -> StackView {
        vertical(views: views(), spacing: spacing, distribution: distribution, sizing: sizing)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    open override func layout() {
        super.layout()
        layoutArrangedSubviews()
    }
    
    open func sizeToFit() {
        frame.size = fittingSize
    }
    
    open override var fittingSize: NSSize {
        let views = arrangedSubviews.filter({ !$0.isHidden })
        var sizes: [CGSize] = []
        var baselineOffsets: [CGFloat] = []
        for view in views {
            let distribution = arrangedViewOptions[view.objectID]?.distribution ?? .fill
            if orientation == .horizontal, distribution == .firstBaseline {
                baselineOffsets.append(0-view.firstBaselineOffset.y)
            }
            if let spacer = view as? SpacerView {
                if let length = spacer.length {
                    sizes.append(CGSize(length, length))
                }
            } else {
                var fittingSize = view.fittingSize
                fittingSize = fittingSize.width <= 0 || fittingSize.height <= 0 ? view.bounds.size : fittingSize
                sizes.append(fittingSize)
            }
        }
        if orientation == .horizontal {
            let width = sizes.compactMap({$0.width}).sum() + (CGFloat(views.count-1) * spacing)
            let height = sizes.compactMap({$0.height}).max() ?? 0.0
            return CGSize(width, height)
        }
        let width = sizes.compactMap({$0.width}).max() ?? 0.0
        let height = sizes.compactMap({$0.height}).sum() + (CGFloat(views.count-1) * spacing) + (0 - (baselineOffsets.min() ?? 0))
        return CGSize(width, height)
    }
    #else
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutArrangedSubviews()
    }
    #endif
    
    private var arrangedViewOptions: [ObjectIdentifier: ArrangedView] = [:]
    
    private func setupArrangedSubviews(previous: [NSUIView] = []) {
        let diff = previous.difference(to: arrangedSubviews)
        diff.removed.forEach { view in
            view.removeFromSuperview()
            arrangedViewOptions[view.objectID] = nil
        }
        diff.added.forEach { view in
            let observation = view.observeChanges(for: \.isHidden) { [weak self] old, new in
                guard let self = self else { return }
                self.layoutArrangedSubviews()
            }
            arrangedViewOptions[view.objectID] = .init(view, observation: observation)
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        layoutArrangedSubviews()
    }
        
    private struct LayoutCalculation {
        var fixedValueSum: CGFloat = 0
        var percentageLossSum: CGFloat = 0
        var equalSizeCount: CGFloat = 0
    }
        
    private func layoutArrangedSubviews() {
        let arrangedSubviews = arrangedSubviews.filter({!$0.isHidden})
        guard !arrangedSubviews.isEmpty, let calculation = calculateSizes() else { return }
        var offsetTracker: CGFloat = orientation == .horizontal ? layoutMargins.left : layoutMargins.bottom
        let totalSpacing = arrangedSubviews[safe: 0..<arrangedSubviews.count-1].compactMap({ arrangedViewOptions[$0.objectID]?.spacing ?? spacing }).sum()
        let total = calculation.fixedValueSum + totalSpacing
        var width = bounds.size.width
        if orientation == .horizontal {
            width = width - total - layoutMargins.width
        }
        var height = bounds.size.height
        if orientation == .vertical {
            height = height - total - layoutMargins.height
        }

        for arrangedSubview in arrangedSubviews {
            let layoutValue: CGFloat = orientation == .horizontal ? width : height
            var ratio: CGFloat = 1
            var size: CGSize?
            switch arrangedViewOptions[arrangedSubview.objectID]!.sizing {
            case .percentage(let percentage):
                ratio = percentage / 100
            case .equal:
                ratio = (1.0 - calculation.percentageLossSum) / calculation.equalSizeCount
            case .fixed, .automatic:
                size = arrangedViewOptions[arrangedSubview.objectID]!.calculatedSize
            }
            var viewFrame: CGRect = .zero
            viewFrame.origin.x = orientation == .horizontal ? offsetTracker : 0
            viewFrame.origin.y = orientation == .horizontal ? 0 : offsetTracker
            if let size = size {
                viewFrame.size = size
            } else {
                viewFrame.size.width = orientation == .horizontal ? layoutValue * ratio : arrangedSubview.frame.width.clamped(max: width)
                viewFrame.size.height = orientation == .horizontal ? arrangedSubview.frame.height.clamped(max: height) : layoutValue * ratio
            }
            arrangedSubview.frame = viewFrame
            offsetTracker += (orientation == .horizontal ? viewFrame.width : viewFrame.height) + (arrangedViewOptions[arrangedSubview.objectID]!.spacing ?? spacing)
        }
        layoutDistributions()
    }
    
    private func calculateSizes() -> LayoutCalculation? {
        arrangedViewOptions.values.forEach({$0.calculatedSize = .zero})
        let arrangedSubviews = arrangedSubviews.filter({!$0.isHidden})
        guard !arrangedSubviews.isEmpty else { return nil }
        let availableSpace = bounds.inset(by: layoutMargins).size
        var calculation = LayoutCalculation()
        for arrangedSubview in arrangedSubviews {
            switch arrangedViewOptions[arrangedSubview.objectID]!.sizing {
            case .equal:
                calculation.equalSizeCount += 1
            case .fixed(let value):
                calculation.fixedValueSum += value
                let isSpacer = arrangedSubview as? SpacerView != nil
                arrangedViewOptions[arrangedSubview.objectID]!.calculatedSize = orientation == .horizontal ? CGSize(value, isSpacer ? 0 : arrangedSubview.frame.height) : CGSize(isSpacer ? 0 : arrangedSubview.frame.width, value)
            case .automatic:
                var fittingSize = arrangedSubview.systemLayoutSizeFitting(availableSpace)
                fittingSize = fittingSize.width <= 0 || fittingSize.height <= 0 ? arrangedSubview.bounds.size : fittingSize
                calculation.fixedValueSum += orientation == .horizontal ? fittingSize.width : fittingSize.height
                arrangedViewOptions[arrangedSubview.objectID]!.calculatedSize = fittingSize
            case .percentage(let percentage):
                calculation.percentageLossSum += percentage
            }
        }
        return calculation
    }
    
    private func layoutDistributions() {
        if orientation == .horizontal {
            var baselineOffsets: [CGFloat] = []
            for arrangedSubview in arrangedSubviews {
                switch arrangedViewOptions[arrangedSubview.objectID]!.distribution ?? distribution {
                case .center:
                    arrangedSubview.center.y = bounds.center.y
                case .leading:
                    arrangedSubview.frame.top = bounds.top - layoutMargins.top
                case .trailing:
                    arrangedSubview.frame.bottom = bounds.bottom + layoutMargins.bottom
                case .fill:
                    arrangedSubview.frame.bottom = bounds.bottom + layoutMargins.bottom
                    arrangedSubview.frame.size.height = bounds.height - layoutMargins.height
                case .firstBaseline:
                    arrangedSubview.frame.origin.y = 0
                    arrangedSubview.frame.origin.y = 0-arrangedSubview.firstBaselineOffset.y
                    baselineOffsets.append(arrangedSubview.frame.origin.y)
                case .lastBaseline:
                    arrangedSubview.frame.origin.y = 0
                    #if os(macOS)
                    arrangedSubview.frame.origin.y = 0-arrangedSubview.lastBaselineOffsetFromBottom
                    #else
                    arrangedSubview.frame.origin.y = 0-(arrangedSubview.lastBaselineOffsetFromBottom ?? 0.0)
                    #endif
                    baselineOffsets.append(arrangedSubview.frame.origin.y)
                }
            }
            let baselineOffset = 0.0 - (baselineOffsets.min() ?? 0)
            for arrangedSubview in arrangedSubviews {
                if arrangedViewOptions[arrangedSubview.objectID]?.distribution == .firstBaseline {
                    arrangedSubview.frame.origin.y += baselineOffset + layoutMargins.bottom
                }
            }
        } else {
            for arrangedSubview in arrangedSubviews {
                switch arrangedViewOptions[arrangedSubview.objectID]!.distribution ?? distribution {
                case .center:
                    arrangedSubview.center.x = bounds.center.x
                case .leading:
                    arrangedSubview.frame.left = bounds.left + layoutMargins.left
                case .trailing:
                    arrangedSubview.frame.right = bounds.right - layoutMargins.right
                case .fill, .firstBaseline, .lastBaseline:
                    arrangedSubview.frame.left = bounds.left + layoutMargins.left
                    arrangedSubview.frame.size.width = bounds.width - layoutMargins.width
                }
            }
        }
    }
    
    private class ArrangedView {
        let observation: KeyValueObservation?
        var sizing: Sizing
        var distribution: Distribution?
        var spacing: CGFloat? = nil
        var calculatedSize: CGSize = .zero
        
        init(_ view: NSUIView, observation: KeyValueObservation?) {
            if let spacer = view as? SpacerView {
                if let length = spacer.length {
                    sizing = .fixed(length)
                } else {
                    sizing = .equal
                }
            } else {
                sizing = .automatic
            }
            self.observation = observation
        }
    }
}

extension StackView {
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
#endif
