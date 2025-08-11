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
    
    private weak var stackView: NSUIStackView?
    fileprivate var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal
    private var constraint: NSLayoutConstraint?
    
    /// The length of the spacer.
    open var length: CGFloat? = nil {
        didSet {
            guard oldValue != length else { return }
            let needsUpdate = oldValue == nil && constraint != nil
            update()
            guard needsUpdate else { return }
            updateFlexibleSpacers()
        }
    }
    
    /// Sets the length of the spacer.
    @discardableResult
    open func length(_ length: CGFloat?) -> Self {
        self.length = length
        return self
    }
      
    #if os(macOS)
    open override func viewWillMove(toSuperview newSuperview: NSView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            updateFlexibleSpacers(exclude: true)
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        stackView?.swizzleOrientation()
        super.viewWillMove(toSuperview: newSuperview)
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        update()
    }
    
    open override func layout() {
        super.layout()
        guard let stackView = stackView, stackView.orientation != orientation else { return }
        update()
    }
    #else
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            updateFlexibleSpacers(exclude: true)
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        super.willMove(toSuperview: newSuperview)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        update()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let stackView = stackView, stackView.axis != orientation else { return }
        update()
    }
    #endif
    
    fileprivate func update() {
        guard let stackView = self.stackView else { return }
        orientation = stackView.orientation
        if let length = length {
            constraint?.activate(false)
            if orientation == .horizontal {
                constraint = widthAnchor.constraint(lessThanOrEqualToConstant: length).priority(50).activate()
            } else {
                constraint = heightAnchor.constraint(lessThanOrEqualToConstant: length).priority(50).activate()
            }
        } else {
            updateFlexibleSpacers()
        }
        if orientation == .horizontal {
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
        
    private func updateFlexibleSpacers(exclude: Bool = false) {
        guard let stackView = stackView else { return }
        var spacerViews = stackView.arrangedSubviews.compactMap({ $0 as? Self }).filter({ $0.length == nil })
        spacerViews.forEach({ $0.constraint?.activate(false) })
        if exclude {
            spacerViews = spacerViews.filter({ $0 != self })
        }
        guard spacerViews.count > 1 else { return }
        var view = spacerViews.removeFirst()
        for spacerView in spacerViews {
            if stackView.orientation == .horizontal {
                view.constraint = view.widthAnchor.constraint(equalTo: spacerView.widthAnchor).activate()
            } else {
                view.constraint = view.heightAnchor.constraint(equalTo: spacerView.heightAnchor).activate()
            }
            view = spacerView
        }
    }
    
    /// Creates a spacer view.
    public init() {
        super.init(frame: .zero)
    }
    
    /// Creates a spacer view with the specified length.
    public init(length: CGFloat) {
        super.init(frame: .zero)
        defer { self.length = length }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

fileprivate extension NSUIStackView {
    func swizzleOrientation() {
        guard orientationHook == nil else { return }
        do {
            #if os(macOS)
            orientationHook = try hookAfter(set: \.orientation, uniqueValues: true) { object, old, value in
                object.arrangedViews.compactMap({ $0 as? SpacerView }).forEach({ $0.update() })
            }
            #else
            orientationHook = try hookAfter(set: \.axis, uniqueValues: true) { object, old, value in
                object.arrangedViews.compactMap({ $0 as? SpacerView }).forEach({ $0.update() })
            }
            #endif
        } catch {
            Swift.print(error)
        }
    }
    
    var orientationHook: Hook? {
        get { getAssociatedValue("orientationHook") }
        set { setAssociatedValue(newValue, key: "orientationHook") }
    }
    
    #if canImport(UIKit)
    var orientation: NSUIUserInterfaceLayoutOrientation {
        axis
    }
    #endif
}
#endif
