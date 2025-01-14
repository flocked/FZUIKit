//
//  NSUIView+Constraints.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIView {
    /**
     Adds a view to the view’s subviews while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: The view to add to the view as a subview.
        - perserveFrame: A Boolean value that indicates whether the view's frame in it's superview's coordinate system is peserved.
     */
    func addSubview(_ view: NSUIView, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        addSubview(view)
    }
    
    /**
     Inserts the subview at the specified index while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
        - perserveFrame: A Boolean value that indicates whether the view's frame in it's superview's coordinate system is peserved.
     */
    func insertSubview(_ view: NSUIView, at index: Int, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        insertSubview(view, at: index)
    }
    
    #if os(macOS)
    /**
     Inserts a view among the view’s subviews so it’s displayed immediately above or below another view while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: The view object to add to the view as a subview.
        - place: An enum constant specifying the position of the `view` relative to `otherView`.
        - otherView: The other view is to be positioned relative to. If `otherView` is `nil` (or isn’t a subview of the view), `view` is added above or below all of its new siblings.
        - perserveFrame: A Boolean value that indicates whether the view's frame in it's superview's coordinate system is peserved.
     */
    func addSubview(_ view: NSView, positioned place: NSWindow.OrderingMode, relativeTo otherView: NSView?, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        addSubview(view, positioned: place, relativeTo: otherView)
    }
    #else
    /**
     Inserts a view below another view in the view hierarchy while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: The view to insert below another view. It’s removed from its superview if it’s not a sibling of siblingSubview.
        - siblingSubview: The sibling view that will be above the inserted view.
        - perserveFrame: A Boolean value that indicates whether the view's frame in it's superview's coordinate system is peserved.
     */
    func insertSubview(_ view: NSUIView, belowSubview siblingSubview: NSUIView, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        insertSubview(view, belowSubview: siblingSubview)
    }
    
    /**
     Inserts a view below another view in the view hierarchy while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: Inserts a view above another view in the view hierarchy.
        - siblingSubview: The sibling view that will be behind the inserted view.
        - perserveFrame: A Boolean value that indicates whether the view's frame in it's superview's coordinate system is peserved.
     */
    func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        insertSubview(view, aboveSubview: siblingSubview)
    }
    #endif
    
    /// Constants how a view is constraint.
    enum ConstraintMode {
        
        /// The view's frame is constraint to the edges of the other view.
        case full
        /// The view's frame is constraint relative to the edges of the other view.
        case relative
        /// The view's frame is constraint absolute to the edges of the other view.
        case absolute
        /// The view's frame is constraint to the edges of the other view with the specified insets.
        case insets(NSUIEdgeInsets)
        /// The view's frame is constraint to the specified position of the other view.
        case positioned(Position, padding: CGPoint = .zero)
        
        /// The view's frame is constraint to the specified position of the other view.
        public static func positioned(_ position: Position, padding: CGFloat) -> Self {
            .positioned(position, padding: CGPoint(padding, padding))
        }
        
        public enum Position: Int {
            case top
            case topLeading
            case topTrailing
            case center
            case leading
            case trailing
            case bottom
            case bottomLeading
            case bottomTrailing
        }
    }
    
    /**
     Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.
     
     - Parameter view: The view to be added. After being added, this view appears on top of any other subviews.
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func addSubview(withConstraint view: NSUIView) -> [NSLayoutConstraint] {
        addSubview(withConstraint: view, .full)
    }
    
    /**
     Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver using the specified mode.
     
     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func addSubview(withConstraint view: NSUIView, _ mode: ConstraintMode) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self, mode)
    }
    
    /**
     Inserts the view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
     
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    
    func insertSubview(withConstraint view: NSUIView, at index: Int) -> [NSLayoutConstraint] {
        insertSubview(withConstraint: view, .full, at: index)
    }
    
    /**
     Inserts the view to the end of the receiver’s list of subviews and constraits it's frame to the receiver using the specified mode.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func insertSubview(withConstraint view: NSUIView, _ mode: ConstraintMode, at index: Int) -> [NSLayoutConstraint] {
        guard index >= 0 else { return [] }
        insertSubview(view, at: index)
        return view.constraint(to: self, mode)
    }
    
    /**
     Constraits the view's frame to the superview.
     
     - Parameter view: The mode for constraining the subview's frame.
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func constraintToSuperview(_ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }
        return constraint(to: superview, mode)
    }
    
    /**
     Constraits the view's frame to the specified view.
     
     - Parameters:
        - view: The view to be constraint to.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    func constraint(to view: NSUIView, _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        let constants: [CGFloat]
        switch mode {
        case .absolute:
            let x = view.frame.minX
            let y = -view.frame.minY
            let width = view.frame.width - bounds.width
            let height = view.frame.height - bounds.height
            constants = [x, y, width, height]
        case let .insets(insets):
            constants = [insets.left, insets.bottom, -insets.right, -insets.top]
        default:
            constants = [0, 0, 0, 0]
        }
        
        let multipliers: [CGFloat]
        switch mode {
        case .relative:
            let x = view.frame.x / bounds.width
            let y = view.frame.y / bounds.height
            let width = view.frame.width / bounds.width
            let height = view.frame.height / bounds.height
            multipliers = [x, y, width, height]
        default: multipliers = [1.0, 1.0, 1.0, 1.0]
        }
        
        switch mode {
        case .full: frame = view.bounds
        default: break
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        switch mode {
        case let .positioned(position, padding):
            switch position {
            case .top, .topLeading, .topTrailing:
                constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: padding.x))
            case .bottom, .bottomLeading, .bottomTrailing:
                constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.x))
            case .center, .leading, .trailing:
                constraints.append(centerYAnchor.constraint(equalTo: view.centerYAnchor))
            }
            switch position {
            case .leading, .bottomLeading, .topLeading:
                constraints.append(leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.y))
            case .trailing, .bottomTrailing, .topTrailing:
                constraints.append(trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.y))
            case .center, .bottom, .top:
                constraints.append(centerXAnchor.constraint(equalTo: view.centerXAnchor))
            }
        default:
            //  self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constants[0]).
            constraints = [
                .init(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: multipliers[0], constant: constants[0]),
                .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: multipliers[1], constant: constants[1]),
                .init(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: multipliers[2], constant: constants[2]),
                .init(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: multipliers[3], constant: constants[3]),
            ]
        }
        constraints.activate()
        return constraints
    }
    
#if os(macOS)
    /**
     Adds a view to the end of the receiver’s list of subviews and autoresizes it.
     
     - Parameter view: The view to be added. After being added, this view appears on top of any other subviews.
     */
    func addSubview(withAutoresizing view: NSView) {
        addSubview(withAutoresizing: view, mode: .full)
    }
    
    /**
     Adds a view to the end of the receiver’s list of subviews and autoresizes it to the receiver.
     
     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - mode: The mode for autoresizing the subview..
     */
    func addSubview(withAutoresizing view: NSUIView, mode: ConstraintMode) {
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        view.autoresize(to: view, using: mode)
    }
    
    /**
     Inserts the view to the end of the receiver’s list of subviews and autoresizes it to the receiver.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
        - mode: The mode for autoresizing the subview..
     */
    func insertSubview(withAutoresizing view: NSUIView, _ mode: ConstraintMode, to index: Int) {
        guard index >= 0 else { return }
        addSubview(withAutoresizing: view, mode: mode)
        moveSubview(view, to: index)
    }
    
    func autoresize(to view: NSView, using mode: ConstraintMode) {
        translatesAutoresizingMaskIntoConstraints = true
        switch mode {
        case .full:
            frame = view.bounds
        case let .insets(insets):
            let width = insets.right - insets.left
            let height = insets.top - insets.bottom
            frame = CGRect(x: insets.bottom, y: insets.left, width: width, height: height)
        default:
            break
        }
        
        if case .relative = mode {
            autoresizingMask = [.height, .width]
        } else {
            autoresizingMask = .all
        }
    }
#endif
}
#endif
