//
//  StackView.swift
//
//  Parts taken from:
//  Taken from Maximilian Mackh
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
    
    /// The sizing for an arranged subview.
    public enum ViewSizing: Hashable {
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
            setupManagedViews(previous: oldValue)
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
    
    /// Sets the distribution for all arranged subviews. The default value is `fill`.
    open func setDistribution(_ distribution: ViewDistribution) {
        // arrangedSubviews.filter({$0 as? SpacerView == nil}).forEach({ setDistribution(distribution, for: $0) })
        arrangedSubviews.forEach({ setDistribution(distribution, for: $0) })
    }

    /// Sets the distribution for an arranged subview. The default value is `fill`.
    open func setDistribution(_ distribution: ViewDistribution, for arrangedSubview: NSUIView) {
        guard arrangedSubviews.contains(arrangedSubview) else { return }
        let id = ObjectIdentifier(arrangedSubview).hashValue
        guard viewDistributions[id] != distribution else { return }
        viewDistributions[id] = distribution
        layoutArrangedSubviews()
    }
    
    /// Sets the distribution for all arranged subviews. The default value is `fill`.
    open func setSizing(_ sizing: ViewSizing) {
        arrangedSubviews.forEach({ setSizing(sizing, for: $0) })
    }
    
    /// Sets the sizing for an arranged subview. The default value resizes the view is `automatic`.
    open func setSizing(_ sizing: ViewSizing, for  arrangedSubview: NSUIView) {
        guard arrangedSubviews.contains(arrangedSubview) else { return }
        guard !(arrangedSubview is SpacerView) else { return }
        let id = ObjectIdentifier(arrangedSubview).hashValue
        guard viewSizing[id] != sizing else { return }
        viewSizing[id] = sizing
        layoutArrangedSubviews()
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
        setupManagedViews()
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
    public static func horizontal(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill, sizing: ViewSizing = .automatic) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .horizontal
        stackView.spacing = spacing
        stackView.setSizing(sizing)
        stackView.setDistribution(distribution)
        return stackView
    }
    
    /// A horizontal stack view with the specified views, spacing and distribution.
    public static func horizontal(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, sizing: ViewSizing = .automatic, @Builder views: () -> [NSUIView]) -> StackView {
        horizontal(views: views(), spacing: spacing, distribution: distribution, sizing: sizing)
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill, sizing: ViewSizing = .automatic) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .vertical
        stackView.spacing = spacing
        stackView.setSizing(sizing)
        stackView.setDistribution(distribution)
        return stackView
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, sizing: ViewSizing = .automatic, @Builder views: () -> [NSUIView]) -> StackView {
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
            let distribution = distribution(for: view) ?? .fill
            if orientation == .horizontal, distribution == .firstBaseline {
                baselineOffsets.append(0-view.firstBaselineOffsetY)
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
    
    private var viewObservers: [Int: KeyValueObservation] = [:]
    private var viewDistributions: [Int: ViewDistribution] = [:]
    private var viewSizing: [Int: ViewSizing] = [:]
    private var viewCalculatedValues: [Int: CGSize] = [:]

    private func setupManagedViews(previous: [NSUIView] = []) {
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
            removeObserver(for: $0)
            viewDistributions[ObjectIdentifier($0).hashValue] = nil
            viewSizing[ObjectIdentifier($0).hashValue] = nil
        }

        newViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addObserver(for: $0)
            viewDistributions[ObjectIdentifier($0).hashValue] = .fill
            if let spacer = $0 as? SpacerView {
                if let length = spacer.length {
                    viewSizing[ObjectIdentifier($0).hashValue] = .fixed(length)
                } else {
                    viewSizing[ObjectIdentifier($0).hashValue] = .equal
                }
            } else {
                viewSizing[ObjectIdentifier($0).hashValue] = .automatic
            }
            addSubview($0)
        }
        layoutArrangedSubviews()
    }
    
    private func addObserver(for view: NSUIView) {
        let id = ObjectIdentifier(view).hashValue
        viewObservers[id] = view.observeChanges(for: \.isHidden, handler: { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.layoutArrangedSubviews()
        })
    }

    private func removeObserver(for view: NSUIView) {
        let id = ObjectIdentifier(view).hashValue
        viewObservers[id] = nil
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
        let total = calculation.fixedValueSum + spacing * CGFloat(arrangedSubviews.count - 1)
        let width = bounds.size.width - (orientation == .horizontal ? total - layoutMargins.width : 0.0)
        let height = bounds.size.height - (orientation == .horizontal ? 0.0 : total - layoutMargins.height)
        for arrangedSubview in arrangedSubviews {
            let id = ObjectIdentifier(arrangedSubview).hashValue
            let sizing = viewSizing(for: arrangedSubview)
            let layoutValue: CGFloat = orientation == .horizontal ? width : height
            var ratio: CGFloat = 1
            var size: CGSize?
            switch sizing {
            case .percentage(let percentage):
                ratio = percentage / 100
            case .equal:
                ratio = (1.0 - calculation.percentageLossSum) / calculation.equalSizeCount
            case .fixed, .automatic:
                size = viewCalculatedValues[id]!
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
            offsetTracker += (orientation == .horizontal ? viewFrame.width : viewFrame.height) + spacing
        }
        layoutDistributions()
    }
    
    private func calculateSizes() -> LayoutCalculation? {
        viewCalculatedValues.removeAll()
        let arrangedSubviews = arrangedSubviews.filter({!$0.isHidden})
        guard !arrangedSubviews.isEmpty else { return nil }
        let availableSpace = bounds.inset(by: layoutMargins).size
        var calculation = LayoutCalculation()
        for arrangedSubview in arrangedSubviews {
            let id = ObjectIdentifier(arrangedSubview).hashValue
            let sizing = viewSizing(for: arrangedSubview)
            switch sizing {
            case .equal:
                calculation.equalSizeCount += 1
            case .fixed(let value):
                calculation.fixedValueSum += value
                let isSpacer = arrangedSubview as? SpacerView != nil
                viewCalculatedValues[id] = orientation == .horizontal ? CGSize(value, isSpacer ? 0 : arrangedSubview.frame.height) : CGSize(isSpacer ? 0 : arrangedSubview.frame.width, value)
            case .automatic:
                #if os(macOS)
                var fittingSize = (arrangedSubview as? NSControl)?.sizeThatFits(availableSpace) ?? arrangedSubview.fittingSize
                #else
                var fittingSize = arrangedSubview.sizeThatFits(availableSpace)
                #endif
                fittingSize = fittingSize.width <= 0 || fittingSize.height <= 0 ? arrangedSubview.bounds.size : fittingSize
                calculation.fixedValueSum += orientation == .horizontal ? fittingSize.width : fittingSize.height
                viewCalculatedValues[id] = fittingSize
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
                let distribution = distribution(for: arrangedSubview) ?? .fill
                switch distribution {
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
                    arrangedSubview.frame.origin.y = 0-arrangedSubview.firstBaselineOffsetY
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
            let baselineOffset = 0 - (baselineOffsets.min() ?? 0)
            for arrangedSubview in arrangedSubviews {
                if distribution(for: arrangedSubview) == .firstBaseline {
                    arrangedSubview.frame.origin.y += baselineOffset + layoutMargins.bottom
                }
            }
        } else {
            for arrangedSubview in arrangedSubviews {
                let distribution = distribution(for: arrangedSubview) ?? .fill
                switch distribution {
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
    
    private func distribution(for view: NSUIView) -> ViewDistribution? {
        viewDistributions[ObjectIdentifier(view).hashValue]
    }
    
    private func viewSizing(for view: NSUIView) -> ViewSizing {
        viewSizing[ObjectIdentifier(view).hashValue] ?? .automatic
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
