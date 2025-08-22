//
//  HStackView & VStackVIew.swift
//
//
//  Created by Florian Zand on 22.08.25.
//

#if os(macOS)
import AppKit

class VStackView: NSUIView {
    private let stackView = NSUIStackView()
    
    public var alignment: HorizontalAlignment = .center {
        didSet { stackView.alignment = alignment.alignment }
    }
    
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    public var distribution: NSUIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }
    
    public var arrangedSubviews: [NSUIView] {
        get { stackView.arrangedSubviews }
        set { stackView.arrangedViews = newValue }
    }
    
    public override var fittingSize: NSSize {
        stackView.fittingSize
    }
    
    public override var intrinsicContentSize: NSSize {
        stackView.intrinsicContentSize
    }
    
    public override var firstBaselineOffsetFromTop: CGFloat {
        stackView.firstBaselineOffsetFromTop
    }
    
    public override var lastBaselineOffsetFromBottom: CGFloat {
        stackView.lastBaselineOffsetFromBottom
    }
    
    public func sizeToFit() {
        frame.size = fittingSize
    }
    
    public func customSpacing(after view: NSUIView) -> CGFloat {
        stackView.customSpacing(after: view)
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after view: NSUIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }
    
    public func visibilityPriority(for view: NSUIView) -> NSUIStackView.VisibilityPriority {
        stackView.visibilityPriority(for: view)
    }
    
    public func setVisibilityPriority(_ priority: NSUIStackView.VisibilityPriority, for view: NSUIView) {
        stackView.setVisibilityPriority(priority, for: view)
    }
    
    public var detachesHiddenViews: Bool {
        get { stackView.detachesHiddenViews }
        set { stackView.detachesHiddenViews = newValue }
    }
    
    #if os(macOS)
    public var edgeInsets: NSEdgeInsets {
        get { stackView.edgeInsets }
        set { stackView.edgeInsets = newValue }
    }
    #endif
    
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0.0, arrangedViews: [NSUIView] = []) {
        super.init(frame: .zero)
        self.spacing = spacing
        self.arrangedSubviews = arrangedViews
        defer { self.alignment = alignment }
    }
    
    public enum HorizontalAlignment: Hashable, Codable {
        case leading
        case center
        case trailing
        
        var alignment: NSLayoutConstraint.Attribute {
            switch self {
            case .leading: return .leading
            case .center: return .centerX
            case .trailing: return .trailing
            }
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class HStackView: NSUIView {
    private let stackView = NSUIStackView()
    
    public var alignment: VerticalAlignment = .center {
        didSet { stackView.alignment = alignment.alignment }
    }
    
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    public var distribution: NSUIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }
    
    public var arrangedSubviews: [NSUIView] {
        get { stackView.arrangedSubviews }
        set { stackView.arrangedViews = newValue }
    }
    
    public override var fittingSize: NSSize {
        stackView.fittingSize
    }
    
    public override var intrinsicContentSize: NSSize {
        stackView.intrinsicContentSize
    }
    
    public override var firstBaselineOffsetFromTop: CGFloat {
        stackView.firstBaselineOffsetFromTop
    }
    
    public override var lastBaselineOffsetFromBottom: CGFloat {
        stackView.lastBaselineOffsetFromBottom
    }
    
    public func sizeToFit() {
        frame.size = fittingSize
    }
    
    public func customSpacing(after view: NSUIView) -> CGFloat {
        stackView.customSpacing(after: view)
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after view: NSUIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }
    
    public func visibilityPriority(for view: NSUIView) -> NSUIStackView.VisibilityPriority {
        stackView.visibilityPriority(for: view)
    }
    
    public func setVisibilityPriority(_ priority: NSUIStackView.VisibilityPriority, for view: NSUIView) {
        stackView.setVisibilityPriority(priority, for: view)
    }
    
    public var detachesHiddenViews: Bool {
        get { stackView.detachesHiddenViews }
        set { stackView.detachesHiddenViews = newValue }
    }
    
    #if os(macOS)
    public var edgeInsets: NSEdgeInsets {
        get { stackView.edgeInsets }
        set { stackView.edgeInsets = newValue }
    }
    #endif

    public init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0.0, arrangedViews: [NSUIView] = []) {
        super.init(frame: .zero)
        self.spacing = spacing
        self.arrangedSubviews = arrangedViews
        defer { self.alignment = alignment }
    }
    
    public enum VerticalAlignment: Hashable, Codable {
        case firstTextBaseline
        case lastTextBaseline
        case bottom
        case center
        case top
        
        var alignment: NSLayoutConstraint.Attribute {
            switch self {
            case .firstTextBaseline: return .firstBaseline
            case .lastTextBaseline: return .lastBaseline
            case .bottom: return .bottom
            case .center: return .centerY
            case .top: return .top
            }
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
