//
//  SpacerView.swift
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
 A flexible spacer view for [NSStackView](https://developer.apple.com/documentation/appkit/nsstackview), [UIStackView](https://developer.apple.com/documentation/uikit/uistackview) and ``StackView`` that expands along the major axis of it's containing stack view.
 
 If you provide ``length``, the spacer view has a fixed length along the major axis of it's containing stack view.
 
 Otherwise the spacer view expands as much as it can inside stack views. For example, when placed within an horizontal stack view, the spacer expands horizontally as much as the stack view allows, moving sibling views out of the way, within the limits of the stack view’s size.
 */
open class SpacerView: NSUIView {
    private var fixedLengthConstraint: NSLayoutConstraint?
    
    private var stackView: NSUIStackView? {
        superview as? NSUIStackView
    }
    
    /// The length of the spacer.
    open var length: CGFloat? {
        didSet {
            guard oldValue != length else { return }
            if let length = length, let fixedLengthConstraint = fixedLengthConstraint , NSAnimationContext.hasActiveGrouping, NSAnimationContext.current.duration > 0 {
                fixedLengthConstraint.animator().constant = length
            } else {
                update(updateFlexibleConstraints: (oldValue == nil) != (length == nil))
            }
        }
    }
        
    /// Sets the length of the spacer.
    @discardableResult
    open func length(_ length: CGFloat?) -> Self {
        self.length = length
        return self
    }
      
    #if os(macOS)
    override open func viewWillMove(toSuperview newSuperview: NSView?) {
        setup(for: newSuperview)
        super.viewWillMove(toSuperview: newSuperview)
    }
    
    override open func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        update()
    }
    #else
    override open func willMove(toSuperview newSuperview: UIView?) {
        setup(for: newSuperview)
        super.willMove(toSuperview: newSuperview)
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        update()
    }
    #endif
    
    private func setup(for newSuperview: NSUIView?) {
        if let stackView = stackView, newSuperview !== stackView, length == nil {
            stackView.updateFlexibleSpacerConstraints(excluding: self)
        }
        fixedLengthConstraint?.activate(false)
        fixedLengthConstraint = nil
        (newSuperview as? NSUIStackView)?.swizzleOrientation()
    }
    
    fileprivate func update(updateFlexibleConstraints: Bool = true) {
        guard let stackView = stackView else { return }
        fixedLengthConstraint?.activate(false)
        fixedLengthConstraint = nil
        if let length = length {
            if stackView.orientation == .horizontal {
                fixedLengthConstraint = widthAnchor.constraint(equalToConstant: length).priority(50).activate()
            } else {
                fixedLengthConstraint = heightAnchor.constraint(equalToConstant: length).priority(50).activate()
            }
        } else if updateFlexibleConstraints {
            stackView.updateFlexibleSpacerConstraints()
        }
        if stackView.orientation == .horizontal {
            setContentHuggingPriority(50, for: .horizontal)
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            setContentCompressionResistancePriority(50, for: .horizontal)
        } else {
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
            setContentHuggingPriority(50, for: .vertical)
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            setContentCompressionResistancePriority(50, for: .vertical)
        }
    }
    
    #if os(macOS)
    override open func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
    #else
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
    #endif
    
    /// Creates a spacer view.
    public init() {
        super.init(frame: .zero)
    }
    
    /// Creates a spacer view with the specified length.
    public init(length: CGFloat) {
        super.init(frame: .zero)
        self.length = length
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        length = coder.decode("length")
    }
    
    override open func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(length, forKey: "length")
    }
}

private extension NSUIStackView {
    func updateFlexibleSpacerConstraints(excluding excludedSpacer: SpacerView? = nil) {
        flexibleSpacerConstraints.activate(false)
        flexibleSpacerConstraints.removeAll()
        let spacerViews = arrangedSubviews
            .compactMap { $0 as? SpacerView }
            .filter { $0 !== excludedSpacer && $0.length == nil && subviews.contains($0) }
        guard spacerViews.count > 1 else { return }
        flexibleSpacerConstraints = zip(spacerViews, spacerViews.dropFirst()).map { lhs, rhs in
            if orientation == .horizontal {
                lhs.widthAnchor.constraint(equalTo: rhs.widthAnchor)
            } else {
                lhs.heightAnchor.constraint(equalTo: rhs.heightAnchor)
            }
        }.activate()
    }
    
    var flexibleSpacerConstraints: [NSLayoutConstraint] {
        get { getAssociatedValue("flexibleSpacerConstraints") ?? [] }
        set { setAssociatedValue(newValue, key: "flexibleSpacerConstraints") }
    }
    
    func swizzleOrientation() {
        guard orientationHook == nil else { return }
        do {
            #if os(macOS)
            let keyPath: WritableKeyPath<NSStackView, NSUserInterfaceLayoutOrientation> = \.orientation
            #else
            let keyPath: WritableKeyPath<UIStackView, NSLayoutConstraint.Axis> = \.axis
            #endif
            orientationHook = try hookAfter(set: keyPath, uniqueValues: true) { stackView, _, _ in
                stackView.arrangedViews.compactMap { $0 as? SpacerView }.forEach { $0.update(updateFlexibleConstraints: false) }
                stackView.updateFlexibleSpacerConstraints()
            }
        } catch {
            Swift.print(error)
        }
    }
    
    var orientationHook: Hook? {
        get { getAssociatedValue("orientationHook") }
        set { setAssociatedValue(newValue, key: "orientationHook") }
    }
    
    #if canImport(UIKit)
    var orientation: NSLayoutConstraint.Axis {
        axis
    }
    #endif
}
#endif
