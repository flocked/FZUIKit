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
import FZSwiftUtils

public extension NSUIView {
    /**
     Adds a view to the view’s subviews while perserving the view's frame in it's superview's coordinate system.
     
     - Parameters:
        - view: The view to add to the view as a subview.
        - perserveFrame: A Boolean value indicating whether the view's frame in it's superview's coordinate system is peserved.
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
        - perserveFrame: A Boolean value indicating whether the view's frame in it's superview's coordinate system is peserved.
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
        - perserveFrame: A Boolean value indicating whether the view's frame in it's superview's coordinate system is peserved.
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
        - perserveFrame: A Boolean value indicating whether the view's frame in it's superview's coordinate system is peserved.
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
        - perserveFrame: A Boolean value indicating whether the view's frame in it's superview's coordinate system is peserved.
     */
    func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView, perserveFrame: Bool) {
        if perserveFrame, view.superview !== self, let frame = view.superview?.convert(view.frame, to: self) {
            view.frame = frame
        }
        insertSubview(view, aboveSubview: siblingSubview)
    }
    #endif
    
    /// Constants how a view is constraint.
    enum ConstraintMode: Hashable, Codable {
        /// The view's frame is constraint to the edges of the other view.
        case full
        /// The view's frame is constraint relative to the edges of the other view.
        case relative
        /// The view's frame is constraint absolute to the edges of the other view.
        case absolute
        /**
         The view's frame is constraint to the edges of the other view with the specified inset values.
         
         A value of `nil` specifies no constraint for the corresponding edge.
         */
        case insets(top: CGFloat?, leading: CGFloat?, bottom: CGFloat?, trailing: CGFloat?)
        /// The view's frame is constraint to the specified position of the other view.
        case positioned(Position, padding: CGPoint)
        
        /// The view's frame is constraint to the edges of the other view with the specified insets.
        public static func insets(_ insets: NSDirectionalEdgeInsets) -> ConstraintMode {
            .insets(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing)
        }
        
        /// The view's frame is constraint to the specified position of the other view.
        public static func positioned(_ position: Position, padding: CGFloat) -> Self {
            .positioned(position, padding: CGPoint(padding, padding))
        }
        
        /// The view's frame is constraint to the specified position of the other view.
        public static func positioned(_ position: Position) -> Self {
            .positioned(position, padding: .zero)
        }
        
        /// The position of the view inside another view.
        public enum Position: Int, Hashable, Codable {
            /// Top.
            case top
            /// Top leading.
            case topLeading
            /// Top trailing.
            case topTrailing
            /// Center.
            case center
            /// Leading.
            case leading
            /// Trailing.
            case trailing
            /// Bottom.
            case bottom
            /// Bottom leading.
            case bottomLeading
            /// Bottom trailing.
            case bottomTrailing
        }
    }
        
    /**
     Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.
     
     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - mode: The mode for constraining the subview's frame.
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    @objc func addSubview(withConstraint view: NSUIView, _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self, mode)
    }
    
    /**
     Inserts the view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.
     
     - Parameters:
        - view: The view to insert.
        - index: The index of insertation.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    @objc func insertSubview(withConstraint view: NSUIView, at index: Int,  _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        guard index >= 0 else { return [] }
        insertSubview(view, at: index)
        return view.constraint(to: self, mode)
    }
    
    /**
     Constraits the view's frame to the superview.
     
     - Parameter view: The mode for constraining the subview's frame.
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    @objc func constraintToSuperview(_ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }
        return constraint(to: superview, mode)
    }
    
    /**
     Constraits the view's frame to the specified view.
     
     - Parameters:
        - view: The view to be constraint to.
        - usingConstraints: A Boolean value indicating whether the view is constraint using `NSLayoutConstraint`.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    @objc func constraint(to view: NSUIView, usingConstraints: Bool = true, _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        usingConstraints ? constraintUsingConstraints(to: view, mode: mode) : constraintUsingObservation(to: view, mode: mode)
    }
    
    fileprivate func constraintUsingConstraints(to view: NSUIView, mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constants: [CGFloat]
        switch mode {
        case .absolute:
            let x = view.frame.minX
            let y = -view.frame.minY
            let width = view.frame.width - bounds.width
            let height = view.frame.height - bounds.height
            constants = [x, y, width, height]
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
        var constraints: [NSLayoutConstraint] = []
        switch mode {
        case let .insets(top, leading, bottom, trailing):
            if let top = top {
                constraints += topAnchor.constraint(equalTo: view.topAnchor, constant: top)
            }
            if let leading = leading {
                constraints += leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading)
            }
            if let bottom = bottom {
                constraints += bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
            }
            if let trailing = trailing {
                constraints += trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing)
            }
        case let .positioned(position, padding):
            switch position {
            case .top, .topLeading, .topTrailing:
                constraints += topAnchor.constraint(equalTo: view.topAnchor, constant: padding.x)
            case .bottom, .bottomLeading, .bottomTrailing:
                constraints += bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.x)
            case .center, .leading, .trailing:
                constraints += centerYAnchor.constraint(equalTo: view.centerYAnchor)
            }
            switch position {
            case .leading, .bottomLeading, .topLeading:
                constraints += leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.y)
            case .trailing, .bottomTrailing, .topTrailing:
                constraints += trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.y)
            case .center, .bottom, .top:
                constraints += centerXAnchor.constraint(equalTo: view.centerXAnchor)
            }
        default:
            constraints = [leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constants[0], multiplier:  multipliers[0]), bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constants[1], multiplier:  multipliers[1]), trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constants[2], multiplier:  multipliers[2]), topAnchor.constraint(equalTo: view.topAnchor, constant: constants[3], multiplier:  multipliers[3])]
        }
        constraints.activate()
        return constraints
    }
    
    fileprivate func constraintUsingObservation(to view: NSUIView, mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        constraintDeinitObservation = view.observeDeinit { [weak self] in
            guard let self = self else { return }
            self.constraintBoundsObservation = nil
        }
        constraintBoundsObservation = view.observeChanges(for: \.bounds) { [weak self] old, new in
            guard let self = self else { return }
            switch mode {
            case .full:
               self.frame = new
            case .insets(let top, let leading, let bottom, let trailing):
                var frame = new
                frame.origin.x += leading ?? 0.0
                frame.origin.y += bottom ?? 0.0
                frame.size.width -= ((leading ?? 0.0) + (trailing ?? 0.0))
                frame.size.height -= ((bottom ?? 0.0) + (top ?? 0.0))
                self.frame = frame
            case .positioned(let position, let padding):
                switch position {
                case .top: frame.top = new.top - padding.y
                case .topLeading: frame.topLeft = new.topLeft.offset(by: padding)
                case .topTrailing: frame.topRight = new.topLeft.offset(by: padding)
                case .bottom: frame.bottom = new.bottom + padding.y
                case .bottomLeading: frame.bottomLeft = new.bottomLeft.offset(by: padding)
                case .bottomTrailing: frame.bottomRight = new.bottomRight.offset(by: padding)
                case .center: frame.center = new.center
                case .leading: frame.left = new.left + padding.x
                case .trailing: frame.right = new.right - padding.x
                }
            case .relative:
                break
            case .absolute:
                break
            }
        }
        return []
    }
    
    fileprivate var constraintDeinitObservation: DeinitObservation? {
        get { getAssociatedValue("constraintDeinitObservation") }
        set { setAssociatedValue(newValue, key: "constraintDeinitObservation") }
    }
    
    fileprivate var constraintBoundsObservation: KeyValueObservation? {
        get { getAssociatedValue("constraintBoundsObservation") }
        set { setAssociatedValue(newValue, key: "constraintBoundsObservation") }
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
        case let .insets(top, leading, bottom, trailing):
            let top = top ?? 0
            let bottom = bottom ?? 0
            let leading = leading ?? 0
            let trailing = trailing ?? 0
            frame = CGRect(x: view.userInterfaceLayoutDirection == .leftToRight ? leading : view.bounds.width-trailing, y: bottom, width: view.bounds.width - leading - trailing, height: view.bounds.height - top - bottom)
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

/// The Objective-C class for ``NSUIView/ConstraintMode``.
public class __ViewConstraintMode: NSObject, NSCopying {
    let mode: NSUIView.ConstraintMode
    
    public init(mode: NSUIView.ConstraintMode) {
        self.mode = mode
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __ViewConstraintMode(mode: mode)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        mode == (object as? __ViewConstraintMode)?.mode
    }
}

extension NSUIView.ConstraintMode: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __ViewConstraintMode
    
    public func _bridgeToObjectiveC() -> __ViewConstraintMode {
        return __ViewConstraintMode(mode: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __ViewConstraintMode, result: inout NSUIView.ConstraintMode?) {
        result = source.mode
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __ViewConstraintMode, result: inout NSUIView.ConstraintMode?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ViewConstraintMode?) -> NSUIView.ConstraintMode {
        if let source = source {
            var result: NSUIView.ConstraintMode?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return .full
    }
    
    public var description: String {
              "\(self)"
    }
    
    public var debugDescription: String {
        description
    }
}

extension NSUIView {
    enum ConstraintModeAlt {
        case full
        case insets(NSDirectionalEdgeInsets)
        case position(Position, CGFloat)
        
        public enum Position: Int, Hashable, Codable {
            /// Top.
            case top
            /// Top leading.
            case topLeading
            /// Top trailing.
            case topTrailing
            /// Center.
            case center
            /// Leading.
            case leading
            /// Trailing.
            case trailing
            /// Bottom.
            case bottom
            /// Bottom leading.
            case bottomLeading
            /// Bottom trailing.
            case bottomTrailing
        }
    }
}
#endif
