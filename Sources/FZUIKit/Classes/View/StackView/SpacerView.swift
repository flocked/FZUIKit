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

/// A flexible spacer view for ``StackView`` that expands along the major axis of it's containing stack view.
open class SpacerView: NSUIView {
    var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal
    var constraint: NSLayoutConstraint? = nil
    weak var stackView: NSUIStackView? = nil
    weak var previousStackView: NSUIStackView? = nil

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
    open override func viewWillMove(toSuperview newSuperview: NSUIView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            previousStackView = stackView
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        super.viewWillMove(toSuperview: newSuperview)
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if let previousStackView = previousStackView {
            updateSpacers(for: previousStackView)
            self.previousStackView = nil
        }
        update()
    }
    
    open override func layout() {
        super.layout()
        if let stackView = stackView, stackView.orientation != orientation {
            update()
        }
    }
    #else
    open override func willMove(toSuperview newSuperview: UIView?) {
        if let stackView = stackView, newSuperview != stackView, length == nil, constraint != nil {
            previousStackView = stackView
        }
        constraint?.activate(false)
        stackView = newSuperview as? NSUIStackView
        super.willMove(toSuperview: newSuperview)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let previousStackView = previousStackView {
            updateSpacers(for: previousStackView)
            self.previousStackView = nil
        }
        update()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let stackView = stackView, stackView.axis != orientation {
            update()
        }
    }
    #endif
    
    open override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden, length == nil, constraint != nil else { return }
            update()
        }
    }
    
    func update() {
        guard let stackView = self.stackView else { return }
        orientation = stackView._orientation
        if orientation == .horizontal {
            setContentHuggingPriority(.init(250), for: .vertical)
            setContentHuggingPriority(.init(rawValue: 50), for: .horizontal)
        } else {
            setContentHuggingPriority(.init(250), for: .horizontal)
            setContentHuggingPriority(.init(rawValue: 50), for: .vertical)
        }
        if let length = length {
            constraint?.activate(false)
            if orientation == .horizontal {
                constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: length).priority(.init(rawValue: 50)).activate()
              //  constraint = widthAnchor.constraint(equalToConstant: length).priority(.fittingSizeCompression).activate()
            } else {
                constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: length).priority(.init(rawValue: 50)).activate()
            }
        } else {
            updateSpacers()
        }
    }
        
    func updateSpacers(for stackView: NSUIStackView? = nil) {
        guard let stackView = stackView ?? self.stackView else { return }
        var spacerViews = stackView.subviews.compactMap({$0 as? SpacerView}).filter({ stackView.arrangedViews.contains($0) && $0.length == nil })
        spacerViews.forEach({ $0.constraint?.activate(false) })
        spacerViews = spacerViews.filter({!$0.isHidden })
        guard spacerViews.count >= 2 else { return }
        var view = spacerViews.first!
        for spacerView in spacerViews[1..<spacerViews.count] {
            if stackView._orientation == .horizontal {
                view.constraint = view.widthAnchor.constraint(equalTo: spacerView.widthAnchor).activate()
            } else {
                view.constraint = view.heightAnchor.constraint(equalTo: spacerView.heightAnchor).activate()
            }
            view = spacerView
        }
        view.constraint = view.widthAnchor.constraint(equalTo: spacerViews.first!.widthAnchor).activate()
    }
    
    struct Update: Hashable {
        var length: CGFloat? = nil
        var views: [Int] = []
        var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal
    }
    
    var lastUpdate = Update()
    
    /// Creates a spacer.
    public init() {
        super.init(frame: .zero)
    }
    
    /// Creates a spacer with the specified length.
    public init(length: CGFloat) {
        super.init(frame: .zero)
        self.length = length
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /*
    #if os(macOS)
    public override var firstBaselineOffsetFromTop: CGFloat {
        bounds.height-0.5
    }
    #endif
     */
}

fileprivate extension NSUIView {
    var id: Int {
        ObjectIdentifier(self).hashValue
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
