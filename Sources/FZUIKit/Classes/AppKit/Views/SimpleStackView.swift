//
//  SimpleStackViewNew.swift
//
//
//  Created by Florian Zand on 18.06.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A view that arranges an array of views horizontally or vertically and updates their placement and sizing when the window size changes.
 
 It's a simplified stack view compared to NSStackView.
 */
public class SimpleStackViewNew: NSView {
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
    
    /// Sets the distribution for an arranged subview. The default value is fill.
    public func setDistribution(_ distribution: ViewDistribution, for arrangedSubview: NSView) {
        guard self.arrangedSubviews.contains(arrangedSubview) else { return }
        let id = ObjectIdentifier(arrangedSubview).hashValue
        guard viewDistributions[id] != distribution else { return }
        viewDistributions[id] = distribution
        updateViewConstraints()
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
    
    internal var viewObservers: [Int: NSKeyValueObservation] = [:]
    internal var viewDistributions: [Int: ViewDistribution] = [:]
    
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
            self.viewDistributions[ObjectIdentifier($0).hashValue] = nil
        })
        
        newViews.forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addObserver(for: $0)
            self.viewDistributions[ObjectIdentifier($0).hashValue] = .fill
            self.addSubview($0)
        })
        
        self.updateViewConstraints()
    }
    
    internal func addObserver(for view: NSView) {
        let id = ObjectIdentifier(view).hashValue
        viewObservers[id] = view.observeChange(\.isHidden, handler: {[weak self] _, old, new in
            guard let self = self else { return }
            if old != new {
                self.updateViewConstraints()
            }
        })
    }
    
    internal func removeObserver(for view: NSView) {
        let id = ObjectIdentifier(view).hashValue
        viewObservers[id] = nil
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
            let distribution = self.viewDistributions[ObjectIdentifier(managedView).hashValue] ?? .fill
            if orientation == .vertical {
                var constraints = [
                    managedView.topAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.topAnchor : nextAnchorView.bottomAnchor, constant: spacing)
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
                    constraints.append(managedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -spacing))
                }
                nextAnchorView = managedView
                viewConstraints.append(contentsOf: constraints)
            } else {
                var constraints = [
                    managedView.leadingAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.leadingAnchor : nextAnchorView.trailingAnchor, constant: spacing)
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
                        let otherManagedView = nonHiddenViews[index+1]
                        constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                    } else if index > 0 {
                        let otherManagedView = nonHiddenViews[index-1]
                        constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                    } else {
                        constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                    }
                    constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                }
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
