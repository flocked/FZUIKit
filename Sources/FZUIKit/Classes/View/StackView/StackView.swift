//
//  StackView.swift
//  
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
    }
    
    /// Creates and returns a stack view.
    public init() {
        super.init(frame: .zero)
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
    public convenience init(@Builder views: () -> [NSUIView]) {
        self.init(views: views())
    }
    
    /// A horizontal stack view with the specified views, spacing and distribution.
    public static func horizontal(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .horizontal
        stackView.spacing = spacing
        if distribution != .fill {
            stackView.setDistribution(distribution)
        }
        return stackView
    }
    
    /// A horizontal stack view with the specified views, spacing and distribution.
    public static func horizontal(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, @Builder views: () -> [NSUIView]) -> StackView {
        horizontal(views: views(), spacing: spacing, distribution: distribution)
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(views: [NSUIView], spacing: CGFloat = 2, distribution: ViewDistribution = .fill) -> StackView {
        let stackView = StackView(views: views)
        stackView.orientation = .vertical
        stackView.spacing = spacing
        if distribution != .fill {
            stackView.setDistribution(distribution)
        }
        return stackView
    }
    
    /// A vertical stack view with the specified views, spacing and distribution.
    public static func vertical(spacing: CGFloat = 2, distribution: ViewDistribution = .fill, @Builder views: () -> [NSUIView]) -> StackView {
        vertical(views: views(), spacing: spacing, distribution: distribution)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    open var edgeInsets: NSUIEdgeInsets  = .zero {
        didSet {
            guard oldValue != edgeInsets else { return }
            layoutArrangedSubviews()
        }
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
        var views = arrangedSubviews.filter({ !$0.isHidden })
        var sizes: [CGSize] = []
        for view in views {
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
        let height = sizes.compactMap({$0.height}).sum() + (CGFloat(views.count-1) * spacing)
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
            self.removeObserver(for: $0)
            self.viewDistributions[ObjectIdentifier($0).hashValue] = nil
        }

        newViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addObserver(for: $0)
            self.viewDistributions[ObjectIdentifier($0).hashValue] = .fill
            self.addSubview($0)
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
    
    private func layoutArrangedSubviews() {
        guard !arrangedSubviews.isEmpty else { return }
        let arrangedSubviews = arrangedSubviews.filter({!$0.isHidden})
        let spacerCount = arrangedSubviews.compactMap({$0 as? SpacerView}).filter({$0.length == nil}).count
        if orientation == .horizontal {
            var sizes: [CGSize] = []
            for arrangedSubview in arrangedSubviews {
                addSubview(arrangedSubview)
                if let spacer = arrangedSubview as? SpacerView {
                    if let length = spacer.length {
                        sizes.append(CGSize(length, bounds.height))
                    } else {
                        sizes.append(CGSize(-1, -1))
                    }
                } else {
                    #if os(macOS)
                    var fittingSize = arrangedSubview.fittingSize
                    #else
                    var fittingSize = arrangedSubview.sizeThatFits(bounds.size)
                    #endif
                    fittingSize = fittingSize.width <= 0 || fittingSize.height <= 0 ? arrangedSubview.bounds.size : fittingSize
                    sizes.append(fittingSize.clamped(maxHeight: bounds.height))
                }
            }
            let remainingWidth = frame.width - sizes.filter({$0 != CGSize(-1, -1)}).compactMap({$0.width}).sum() - (CGFloat(arrangedSubviews.count-1) * spacing) - edgeInsets.width
            if remainingWidth < -1.0 {
               
               let remove = (remainingWidth * -1) / CGFloat(arrangedSubviews.count - spacerCount)
                sizes = sizes.compactMap({
                    if $0 == CGSize(-1, -1) {
                        return $0 }
                    else {
                        return CGSize($0.width - remove, $0.height)
                    }
                })
            }
            
            let spacerSize = CGSize(remainingWidth / CGFloat(spacerCount), bounds.height)
            var xValue = edgeInsets.left
            for (index, arrangedSubview) in arrangedSubviews.enumerated() {
                arrangedSubview.frame.origin.x = xValue
                let size = sizes[index]
                arrangedSubview.frame.size = size == CGSize(-1,-1) ? spacerSize : size
                xValue = xValue + arrangedSubview.frame.size.width + spacing
            }
            var baselineOffsets: [CGFloat] = []
            for arrangedSubview in arrangedSubviews {
                let distribution = distribution(for: arrangedSubview) ?? .fill
                switch distribution {
                case .center:
                    arrangedSubview.center.y = bounds.center.y
                case .leading:
                    arrangedSubview.frame.top = bounds.top - edgeInsets.top
                case .trailing:
                    arrangedSubview.frame.bottom = bounds.bottom + edgeInsets.bottom
                case .fill:
                    arrangedSubview.frame.bottom = bounds.bottom + edgeInsets.bottom
                    arrangedSubview.frame.size.height = bounds.height - edgeInsets.height
                case .firstBaseline:
                    arrangedSubview.frame.origin.y = 0
                    arrangedSubview.frame.origin.y = 0-arrangedSubview.firstBaselineOffsetY
                    baselineOffsets.append(arrangedSubview.frame.origin.y)
                }
            }
            let baselineOffset =  0 - (baselineOffsets.min() ?? 0)
            for arrangedSubview in arrangedSubviews {
                if distribution(for: arrangedSubview) == .firstBaseline {
                    arrangedSubview.frame.origin.y += baselineOffset + edgeInsets.bottom
                }
            }
        } else {
            var sizes: [CGSize] = []
            for arrangedSubview in arrangedSubviews {
                addSubview(arrangedSubview)
                if let spacer = arrangedSubview as? SpacerView {
                    if let length = spacer.length {
                        sizes.append(CGSize(bounds.width, length))
                    } else {
                        sizes.append(CGSize(-1, -1))
                    }
                } else {
                    #if os(macOS)
                    var fittingSize = arrangedSubview.fittingSize
                    #else
                    var fittingSize = arrangedSubview.sizeThatFits(bounds.size)
                    #endif
                    fittingSize = fittingSize.width <= 0 || fittingSize.height <= 0 ? arrangedSubview.bounds.size : fittingSize
                    sizes.append(fittingSize.clamped(maxWidth: bounds.width))
                }
            }
            let remainingHeight = frame.height - sizes.filter({$0 != CGSize(-1, -1)}).compactMap({$0.height}).sum() - (CGFloat(arrangedSubviews.count-1) * spacing) - edgeInsets.height
            let spacerSize = CGSize(bounds.width, remainingHeight / CGFloat(spacerCount))
            var yValue =  edgeInsets.bottom
            for (index, arrangedSubview) in arrangedSubviews.enumerated() {
                arrangedSubview.frame.origin.y = yValue
                let size = sizes[index]
                arrangedSubview.frame.size = size == CGSize(-1,-1) ? spacerSize : size
                yValue = yValue + arrangedSubview.frame.size.height + spacing
            }
            for arrangedSubview in arrangedSubviews {
                let distribution = distribution(for: arrangedSubview) ?? .fill
                switch distribution {
                case .center:
                    arrangedSubview.center.x = bounds.center.x
                case .leading:
                    arrangedSubview.frame.left = bounds.left + edgeInsets.left
                case .trailing:
                    arrangedSubview.frame.right = bounds.right - edgeInsets.right
                case .fill, .firstBaseline:
                    arrangedSubview.frame.left = bounds.left + edgeInsets.left
                    arrangedSubview.frame.size.width = bounds.width - edgeInsets.width
                }
            }
        }
    }
    
    private func distribution(for view: NSUIView) -> ViewDistribution? {
        viewDistributions[ObjectIdentifier(view).hashValue]
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
