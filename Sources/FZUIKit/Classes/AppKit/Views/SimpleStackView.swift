//
//  SimpleStackView.swift
//  TextStackView
//
//  Created by Florian Zand on 18.06.23.
//

#if os(macOS)
import AppKit
import FZUIKit
import FZSwiftUtils

/**
 A view that arranges an array of views horizontally or vertically and updates their placement and sizing when the window size changes.
 
 It's a simplified stack view compared to NSStackView.
 */
public class SimpleStackView: NSView {
    
    /// The array of views arranged by the stack view.
    public var arrangedSubviews: [NSView] = [] {
        didSet {
            if oldValue != self.arrangedSubviews {
                self.setupManagedViews(previous: oldValue)
            }
        }
    }
    
    /// The horizontal or vertical layout direction of the stack view.
    public var orientation: NSUserInterfaceLayoutOrientation = .vertical {
        didSet {
            if oldValue != self.orientation {
                self.updateViewConstraints()
            }
        }
    }
    
    /// The spacing between views in the stack view.
    public var spacing: CGFloat = 2.0 {
        didSet {
            if oldValue != self.spacing {
                self.updateSpacing()
            }
        }
    }
            
    /**
     Creates and returns a stack view with a specified array of views.
     
     - Parameters views: The array of views for the new stack view.
     - Returns: A stack view initialized with the specified array of views.
     */
    public init(views: [NSView]) {
        super.init(frame: .zero)
        self.arrangedSubviews = views
        self.setupManagedViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var observers: [Int: NSKeyValueObservation] = [:]
    
    internal func setupManagedViews(previous: [NSView] = []) {
        var removedViews: [NSView] = []
        var newViews: [NSView] = []
        for oldView in previous {
            if arrangedSubviews.contains(oldView) == false {
                removedViews.append(oldView)
            }
        }
        for managedView in self.arrangedSubviews {
            if previous.contains(managedView) == false {
                newViews.append(managedView)
            }
        }
        removedViews.forEach({
            $0.removeFromSuperview()
            self.removeObserver(for: $0)
        })
        
        newViews.forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addObserver(for: $0)
            self.addSubview($0)
        })
        
        self.updateViewConstraints()
    }
    
    func removeObserver(for view: NSView) {
        let id = ObjectIdentifier(view).hashValue
        observers[id] = nil
    }
    
    func addObserver(for view: NSView) {
        let id = ObjectIdentifier(view).hashValue
        observers[id] = view.observeChange(\.isHidden, handler: {[weak self] _, old, new in
            guard let self = self else { return }
            if old != new {
                self.updateViewConstraints()
            }
        })
    }
        
    internal var viewConstraints: [NSLayoutConstraint] = []
    
    internal func updateSpacing() {
        viewConstraints.filter({
            if self.orientation == .vertical {
                return $0.firstAttribute == .top
            } else {
                return $0.firstAttribute == .leading
            }
        }).forEach({$0.constant = spacing})
        
        
        viewConstraints.filter({
            if self.orientation == .vertical {
                return $0.firstAttribute == .bottom
            } else {
                return $0.firstAttribute == .trailing
            }
        }).forEach({$0.constant = -spacing})
         
    }
    
    internal func updateViewConstraints() {
        NSLayoutConstraint.deactivate(viewConstraints)
        viewConstraints.removeAll()
        var nextAnchorView: NSView = self
        let nonHiddenViews = arrangedSubviews.filter({$0.isHidden == false})
        for (index, managedView) in nonHiddenViews.enumerated() {
            if orientation == .vertical {
                var constraints = [
                    managedView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    managedView.widthAnchor.constraint(equalTo: widthAnchor),
                    managedView.topAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.topAnchor : nextAnchorView.bottomAnchor, constant: spacing)
                ]
                if index == nonHiddenViews.count - 1 {
                    constraints.append(managedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -spacing))
                }
                nextAnchorView = managedView
                viewConstraints.append(contentsOf: constraints)
            } else {
                var constraints = [
                    managedView.topAnchor.constraint(equalTo: topAnchor),
                    managedView.heightAnchor.constraint(equalTo: heightAnchor),
                    managedView.leadingAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.leadingAnchor : nextAnchorView.trailingAnchor, constant: spacing)
                ]
                if index == nonHiddenViews.count - 1 {
                    constraints.append(managedView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing))
                }
                nextAnchorView = managedView
                viewConstraints.append(contentsOf: constraints)
            }
        }
        NSLayoutConstraint.activate(viewConstraints)
    }
}

#endif
