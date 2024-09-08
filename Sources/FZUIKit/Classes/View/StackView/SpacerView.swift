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

/**
 A flexible spacer view for `NSStackView`, `UIStackView` and ``StackView`` that expands along the major axis of it's containing stack view.
 
 The spacer view expands as much as it can inside stack views. For example, when placed within an horizontal stack view, the spacer expands horizontally as much as the stack view allows, moving sibling views out of the way, within the limits of the stack view’s size.
 */
open class SpacerView: NSUIView {
    
    weak var stackView: NSUIStackView? = nil
    var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal
    var constraint: NSLayoutConstraint? = nil
    
    /// The length of the spacer.
    open var length: CGFloat? = nil {
        didSet {
            guard oldValue != length else { return }
            let needsUpdate = oldValue == nil && constraint != nil
            update()
            if needsUpdate {
                updateSpacers()
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
    public override func viewWillMove(toSuperview newSuperview: NSUIView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            updateSpacers(exclude: true)
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        super.viewWillMove(toSuperview: newSuperview)
    }
    
    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        update()
    }
    
    public override func layout() {
        super.layout()
        if let stackView = stackView, stackView.orientation != orientation {
            update()
        }
    }
    #else
    public override func willMove(toSuperview newSuperview: UIView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            updateSpacers(exclude: true)
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        super.willMove(toSuperview: newSuperview)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        update()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let stackView = stackView, stackView.axis != orientation {
            update()
        }
    }
    #endif
    
    func update() {
        guard let stackView = self.stackView else { return }
        orientation = stackView._orientation
        if let length = length {
            constraint?.activate(false)
            if orientation == .horizontal {
                constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: length).priority(.init(rawValue: 50)).activate()
            } else {
                constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: length).priority(.init(rawValue: 50)).activate()
            }
        } else {
            updateSpacers()
        }
    }
        
    func updateSpacers(exclude: Bool = false) {
        guard let stackView = stackView else { return }
        var spacerViews = stackView.subviews(type: SpacerView.self).filter({ stackView.arrangedViews.contains($0) && $0.length == nil })
        spacerViews.forEach({ $0.constraint?.activate(false) })
        if exclude {
            spacerViews = spacerViews.filter({ $0 != self })
        }
        guard spacerViews.count >= 2 else { return }
        var view = spacerViews.removeFirst()
        for spacerView in spacerViews {
            if stackView._orientation == .horizontal {
                view.constraint = view.widthAnchor.constraint(equalTo: spacerView.widthAnchor).activate()
            } else {
                view.constraint = view.heightAnchor.constraint(equalTo: spacerView.heightAnchor).activate()
            }
            view = spacerView
        }
    }
    
    /// Creates a spacer.
    public init() {
        super.init(frame: .zero)
        initalSetup()
    }
    
    /// Creates a spacer with the specified length.
    public init(length: CGFloat) {
        super.init(frame: .zero)
        initalSetup()
        self.length = length
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalSetup()
    }
    
    func initalSetup() {
        setContentHuggingPriority(.init(rawValue: 50), for: .vertical)
        setContentHuggingPriority(.init(rawValue: 50), for: .horizontal)
    }
}

fileprivate extension NSUIStackView {
    var _orientation: NSUIUserInterfaceLayoutOrientation {
        #if os(macOS)
        orientation
        #else
        axis
        #endif
    }
}
#endif
