//
//  NSUIView+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension NSUIView {
    var optionalLayer: CALayer? {
        #if os(macOS)
        wantsLayer = true
        #endif
        return layer
    }

    /// The level of the view from the most outer `superview`. A value of `0` indicates that there isn't a superview.
    @objc open var viewLevel: Int {
        var depth = 0
        var aSuperview = superview
        while aSuperview != nil {
            depth += 1
            aSuperview = aSuperview?.superview
        }
        return depth
    }

    /// Updates the anchor point of the view’s bounds rectangle while retaining the position.
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        guard let layer = optionalLayer else { return }
        guard layer.anchorPoint != anchorPoint else { return }
        var newPoint = CGPoint(bounds.size.width * anchorPoint.x, bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(bounds.size.width * layer.anchorPoint.x, bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(layer.affineTransform())
        oldPoint = oldPoint.applying(layer.affineTransform())

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }

    /// Removes all constrants from the view.
    @objc open func removeAllConstraints() {
        var _superview = superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? NSUIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? NSUIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }
        removeConstraints(constraints)
    }

    /// Sends the view to the front of it's superview.
    @objc open func sendToFront() {
        guard let superview = superview else { return }
        #if os(macOS)
        superview.addSubview(self)
        #else
        superview.bringSubviewToFront(self)
        #endif
    }

    /// Sends the view to the back of it's superview.
    @objc open func sendToBack() {
        guard let superview = superview else { return }
        #if os(macOS)
        superview.addSubview(self, positioned: .below, relativeTo: nil)
        #else
        superview.sendSubviewToBack(self)
        #endif
    }

    /**
     Returns the enclosing rect for the specified subviews.
     - Parameter subviews: The subviews for the rect.
     - Returns: The rect enclosing all the specified subviews.
     */
    @objc open func enclosingRect(for subviews: [NSUIView]) -> CGRect {
        var enlosingFrame = CGRect.zero
        for subview in subviews {
            let frame = convert(subview.bounds, from: subview)
            enlosingFrame = enlosingFrame.union(frame)
        }
        return enlosingFrame
    }

    /**
     Moves the specified subview to the index.

     - Parameters:
        - view: The view to move.
        - index: The index for moving.
     */
    @objc open func moveSubview(_ subview: NSUIView, to toIndex: Int) {
        if let index = subviews.firstIndex(of: subview) {
            moveSubview(at: index, to: toIndex)
        }
    }

    /**
     Moves the specified subviews to the index.

     - Parameters:
        - subviews: The subviews to move.
        - toIndex: The index for moving.
        - moveIndividually: A Boolean value indicating whether each subview should be moved one at a time (`true`) or as a group (`false`). Use `true` to preserve relative ordering when moving multiple subviews.
     */
    @objc open func moveSubviews(_ subviews: [NSUIView], to toIndex: Int, moveIndividually: Bool = false) {
        var indexSet = IndexSet()
        for view in subviews {
            if let index = subviews.firstIndex(of: view), indexSet.contains(index) == false {
                indexSet.insert(index)
            }
        }
        if indexSet.isEmpty == false {
            moveSubviews(at: indexSet, to: toIndex, moveIndividually: moveIndividually)
        }
    }

    /**
     Moves the subview at the specified index to another index.

     - Parameters:
        - index: The index of the subview to move.
        - toIndex: The index to where the subview should be moved.
     */
    @objc open func moveSubview(at index: Int, to toIndex: Int) {
        moveSubviews(at: IndexSet(integer: index), to: toIndex)
    }

    /**
     Moves subviews at the specified indexes to another index.

     - Parameters:
        - indexes: The indexes of the subviews to move.
        - toIndex: The index where the subviews should be moved to.
        - moveIndividually: A Boolean value indicating whether each subview should be moved one at a time (`true`) or as a group (`false`). Use `true` to preserve relative ordering when moving multiple subviews.
     */
    @objc open func moveSubviews(at indexes: IndexSet, to toIndex: Int, moveIndividually: Bool = false) {
        guard !subviews.isEmpty, toIndex >= 0, toIndex < subviews.count else { return }
        let subviewsCount = subviews.count
        let indexes = indexes.filter { $0 >= 0 && $0 < subviewsCount }
        #if os(macOS)
        var subviews = subviews
        subviews.move(from: moveIndividually ? indexes.reversed() : indexes, to: toIndex)
        self.subviews = subviews
        #elseif canImport(UIKit)
        let movingSubviews = (moveIndividually ? indexes.reversed() : indexes).map { subviews[$0] }
        var belowSubview = subviews[toIndex]
        for subview in movingSubviews {
            insertSubview(subview, belowSubview: belowSubview)
            belowSubview = moveIndividually ? subview : belowSubview
        }
        #endif
    }

    #if os(macOS)
    /**
     Inserts a view above another view in the view hierarchy.

     - Parameters:
        - view: The view to insert. It’s removed from its superview if it’s not a sibling of siblingSubview.
        - siblingSubview: The sibling view that will be above the inserted view.
     */
    @objc open func insertSubview(_ view: NSView, belowSubview siblingSubview: NSView) {
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }

    /**
     Inserts a view above another view in the view hierarchy.

     - Parameters:
        - view: The view to insert. It’s removed from its superview if it’s not a sibling of siblingSubview.
        - siblingSubview: The sibling view that will be behind the inserted view.
     */
    @objc open func insertSubview(_ view: NSView, aboveSubview siblingSubview: NSView) {
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }
    #endif

    /**
     The first superview that matches the specificed view type.

     - Parameter viewType: The type of view to match.
     - Returns: The first parent view that matches the view type or `nil` if none match or there isn't a matching parent.
     */
    public func firstSuperview<V: NSUIView>(for _: V.Type) -> V? {
        firstSuperview(where: { $0 is V }) as? V
    }

    /**
     The first superview that matches the specificed predicate.

     - Parameter predicate: The closure to match.
     - Returns: The first parent view that is matching the predicate or `nil` if none match or there isn't a matching parent.
     */
    @objc open func firstSuperview(where predicate: (NSUIView) -> (Bool)) -> NSUIView? {
        if let superview = superview {
            return predicate(superview) ? superview : superview.firstSuperview(where: predicate)
        }
        return nil
    }

    /// An array of all enclosing superviews.
    @objc open func superviewChain() -> [NSUIView] {
        if let superview = superview {
            return [superview] + superview.superviewChain()
        }
        return []
    }

    /**
     An array of all subviews upto the maximum depth.

     A depth of `0` returns the subviews of the view, a value of `1` returns the subviews of the view and all their subviews, etc. To return all subviews use `max`.

     - Parameter depth: The maximum depth.
     */
    @objc open func subviews(depth: Int) -> [NSUIView] {
        if depth > 0 {
            return subviews + subviews.flatMap { $0.subviews(depth: depth - 1) }
        } else {
            return subviews
        }
    }

    /**
     An array of all subviews matching the specified view type.

      - Parameters:
         - type: The type of subviews.
         - depth: The maximum depth. As example a value of `0` returns the subviews of receiver and a value of `1` returns the subviews of the receiver and all their subviews. To return all subviews use `max`.
      */
    public func subviews<V: NSUIView>(type _: V.Type, depth: Int = 0) -> [V] {
        subviews(depth: depth).compactMap { $0 as? V }
    }

    /**
     An array of all subviews matching the specified view type.

      - Parameters:
         - type: The type of subviews.
         - depth: The maximum depth. As example a value of `0` returns the subviews of receiver and a value of `1` returns the subviews of the receiver and all their subviews. To return all subviews use `max`.
      */
    @objc open func subviews(type: String, depth: Int = 0) -> [NSUIView] {
        subviews(where: { NSStringFromClass(Swift.type(of: $0)) == type }, depth: depth)
    }

    /**
     An array of all subviews matching the specified predicte.

      - Parameters:
         - predicate: The predicate to match.
         - depth: The maximum depth. As example a value of `0` returns the subviews of receiver and a value of `1` returns the subviews of the receiver and all their subviews. To return all subviews use `max`.
      */
    @objc open func subviews(where predicate: (NSUIView) -> (Bool), depth: Int = 0) -> [NSUIView] {
        subviews(depth: depth).filter { predicate($0) == true }
    }

    /**
     The first subview that matches the specificed view type.

     - Parameters:
        - type: The type of view to match.
        - depth: The maximum depth. As example a value of `0` returns the first subview matching of the receiver's subviews and a value of `1` returns the first subview matching of the receiver's subviews or any of their subviews. To return the first subview matching of all subviews use `max`.
     - Returns: The first subview that matches the view type or `nil` if no subview matches.
     */
    public func firstSubview<V: NSUIView>(type _: V.Type, depth: Int = 0) -> V? {
        firstSubview(where: { $0 is V }, depth: depth) as? V
    }

    /**
     The first subview that matches the specificed view type.

     - Parameters:
        - type: The type of view to match.
        - depth: The maximum depth. As example a value of `0` returns the first subview matching of the receiver's subviews and a value of `1` returns the first subview matching of the receiver's subviews or any of their subviews. To return the first subview matching of all subviews use `max`.
     - Returns: The first subview that matches the view type or `nil` if no subview matches.
     */
    @objc open func firstSubview(type: String, depth: Int = 0) -> NSUIView? {
        firstSubview(where: { NSStringFromClass(Swift.type(of: $0)) == type }, depth: depth)
    }

    /**
     The first subview that matches the specificed predicate.

     - Parameters:
        - predicate: TThe closure to match.
        - depth: The maximum depth. As example a value of `0` returns the first subview matching of the receiver's subviews and a value of `1` returns the first subview matching of the receiver's subviews or any of their subviews. To return the first subview matching of all subviews use `max`.

     - Returns: The first subview that is matching the predicate or `nil` if no subview is matching.
     */
    @objc open func firstSubview(where predicate: (NSUIView) -> (Bool), depth: Int = 0) -> NSUIView? {
        if let subview = subviews.first(where: predicate) {
            return subview
        }
        if depth > 0 {
            for subview in subviews {
                if let subview = subview.firstSubview(where: predicate, depth: depth - 1) {
                    return subview
                }
            }
        }
        return nil
    }

    /// Positions the view above the specified view.
    @objc open func position(above view: NSUIView) {
        guard let superview = view.superview else { return }
        #if os(macOS)
        superview.addSubview(self, positioned: .above, relativeTo: view)
        #else
        superview.insertSubview(self, aboveSubview: view)
        #endif
    }

    /// Positions the view behind the specified view.
    @objc open func postion(behind view: NSUIView) {
        guard let superview = view.superview else { return }
        #if os(macOS)
        superview.addSubview(self, positioned: .below, relativeTo: view)
        #else
        superview.insertSubview(self, belowSubview: view)
        #endif
    }

    /// Animates a transition to changes made to the view after calling this.
    @objc open func transition(_ transition: CATransition?) {
        if let transition = transition {
            optionalLayer?.add(transition, forKey: CATransitionType.fade.rawValue)
        } else {
            optionalLayer?.removeAnimation(forKey: CATransitionType.fade.rawValue)
        }
    }

    /// Recursive description of the view useful for debugging.
    @objc open var recursiveDescription: String {
        value(forKeySafely: "recursiveDescription") as? String ?? ""
    }

    /**
     The background gradient of the view.

     Applying a gradient sets the view's `backgroundColor` to `nil`.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    public var gradient: Gradient? {
        get { optionalLayer?.gradient }
        set {
            if let newValue = newValue, !newValue.stops.isEmpty {
                if optionalLayer?.gradient == nil {
                    optionalLayer?.gradient = .init(stops: [])
                }
                backgroundColor = nil
            }
            guard var endGradient = newValue ?? optionalLayer?.gradient?.opacity(0.0) else { return }
            let stops = (optionalLayer?.gradient?.stops ?? []).animatable(to: newValue?.stops ?? [])
            NSUIView.performWithoutAnimation {
                self.optionalLayer?.gradient?.stops = stops.start
            }
            endGradient.stops = stops.end
            optionalLayer?.gradient = endGradient
        }
    }

    /// Sets the background gradient of the view.
    public func gradient( _ gradient: Gradient?) -> Self {
        self.gradient = gradient
        return self
    }

    /// Sets the Boolean value indicating whether the view is hidden.
    @discardableResult
    @objc open func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }

    /// Sets the corner radius of the view.
    @discardableResult
    @objc open func cornerRadius(_ radius: CGFloat) -> Self {
        cornerRadius = radius
        return self
    }

    /// Sets the rounded corners of the view.
    @discardableResult
    @objc open func roundedCorners(_ corners: CACornerMask) -> Self {
        roundedCorners = corners
        return self
    }

    /// Sets the border of the view.
    @discardableResult
    @objc open func border(_ border: BorderConfiguration) -> Self {
        self.border = border
        return self
    }

    #if os(macOS)
    /// Sets the outer shadow of the view.
    @discardableResult
    @objc open func outerShadow(_ shadow: ShadowConfiguration) -> Self {
        outerShadow = shadow
        return self
    }
    #else
    /// Sets the outer shadow of the view.
    @discardableResult
    @objc open func shadow(_ shadow: ShadowConfiguration) -> Self {
        self.shadow = shadow
        return self
    }
    #endif

    /// Sets the inner shadow of the view.
    @discardableResult
    @objc open func innerShadow(_ shadow: ShadowConfiguration) -> Self {
        self.innerShadow = shadow
        return self
    }

    #if os(macOS)
    /// Sets the anchor point of the view’s bounds rectangle.
    @discardableResult
    @objc open func anchorPoint(_ anchorPoint: FractionalPoint) -> Self {
        self.anchorPoint = anchorPoint
        return self
    }
    #elseif os(iOS) || os(tvOS)

    /// Sets the anchor point of the view’s bounds rectangle.
    @discardableResult
    @available(iOS 16.0, tvOS 16.0, *)
    @objc open func anchorPoint(_ anchorPoint: CGPoint) -> Self {
        self.anchorPoint = anchorPoint
        return self
    }
    #endif

    /// Sets the scale transform of the view.
    @discardableResult
    @objc open func scale(_ scale: Scale) -> Self {
        self.scale = scale
        return self
    }

    /// Sets the rotation of the view as euler angles in degrees.
    @discardableResult
    @objc open func rotation(_ rotation: Rotation) -> Self {
        self.rotation = rotation
        return self
    }

    /// Sets the rotation of the view as euler angles in radians.
    @discardableResult
    @objc open func rotationInRadians(_ rotation: Rotation) -> Self {
        self.rotationInRadians = rotation
        return self
    }

    /// Sets the Boolean value indicating whether the view, and its subviews, confine their drawing areas to the bounds of the view.
    @discardableResult
    @objc open func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        self.clipsToBounds = clipsToBounds
        return self
    }

    /// Sets the view whose alpha channel is used to mask a view’s content.
    @discardableResult
    @objc open func mask(_ mask: NSUIView?) -> Self {
        self.mask = mask
        return self
    }

    /// Sets the view’s bounds rectangle, which expresses its location and size in its own coordinate system.
    @discardableResult
    @objc open func bounds(_ bounds: CGRect) -> Self {
        self.bounds = bounds
        return self
    }

    /// Sets the view’s frame rectangle, which defines its position and size in its superview’s coordinate system.
    @discardableResult
    @objc open func frame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }

    /// Sets the view’s frame size.
    @discardableResult
    @objc open func size(_ size: CGSize) -> Self {
        self.frame.size = size
        return self
    }

    /// Sets the view’s frame origin, which defines its position in its superview’s coordinate system.
    @discardableResult
    @objc open func origin(_ origin: CGPoint) -> Self {
        self.frame.origin = origin
        return self
    }

    /// Sets the center point of the view’s frame rectangle.
    @discardableResult
    @objc open func center(_ center: CGPoint) -> Self {
        self.center = center
        return self
    }

    /// Sets the view’s position on the z axis.
    @discardableResult
    @objc open func zPosition(_ zPosition: CGFloat) -> Self {
        self.zPosition = zPosition
        return self
    }

    /// Sets the options that determine how the view is resized relative to its superview.
    @discardableResult
    @objc open func autoresizingMask(_ mask: AutoresizingMask) -> Self {
        autoresizingMask = mask
        return self
    }

    #if os(macOS)
    /// Sets the opacity of the view.
    @discardableResult
    @objc open func alphaValue(_ alphaValue: CGFloat) -> Self {
        self.alphaValue = alphaValue
        return self
    }
    #else
    /// Sets the opacity of the view.
    @discardableResult
    @objc open func alpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }

    /// Sets the first nondefault tint color value in the view’s hierarchy, ascending from and starting with the view itself.
    @discardableResult
    @objc open func tintColor(_ color: UIColor?) -> Self {
        tintColor = color
        return self
    }

    /// Sets the flag used to determine how a view lays out its content when its bounds change.x
    @discardableResult
    @objc open func contentMode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode
        return self
    }
    #endif
    
    /// Sets the Boolean indicating whether the view displays its content when facing away from the viewer.
    @discardableResult
    public func isDoubleSided(_ isDoubleSided: Bool) -> Self {
        optionalLayer?.isDoubleSided = isDoubleSided
        return self
    }

    /**
     Prints the hierarchy of the view and its subviews to the console.

     - Parameters:
       - depth: The maximum depth of the view hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
       - includeDetails: If `true` prints the full description of each view; otherwise prints only the type.
     */
    public func printHierarchy(depth: Int = .max, includeDetails: Bool = false) {
        guard depth >= 0 else { return }
        printHierarchy(level: 0, depth: depth, includeDetails: false)
    }

    private func printHierarchy(level: Int, depth: Int, includeDetails: Bool) {
        let string = includeDetails ? "\(self)" : "\(type(of: self))"
        Swift.print("\(Array(repeating: " ", count: level).joined(separator: ""))\(string)")
        guard level+1 <= depth else { return }
        for subview in subviews {
            subview.printHierarchy(level: level+1, depth: depth, includeDetails: includeDetails)
        }
    }

    /**
     Prints the hierarchy of views of a specific type starting from this view.

     - Parameters:
        - type: The view type to match (e.g., `NSTextField.self`). Only subtrees containing at least one view of this type will be printed.
        - depth: The maximum depth of the view hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
        - includeDetails: If `true` prints the full description of each view; otherwise prints only the type.
     */
    public func printHierarchy<V: NSUIView>(type _: V.Type, depth: Int = .max, includeDetails: Bool = false) {
        printHierarchy(predicate: {$0 is V}, depth: depth, includeDetails: includeDetails)
    }

    /**
     Prints the hierarchy of views that match a given predicate starting from this view.

     - Parameters:
        - predicate: A closure that determines whether a view should be included in the printed hierarchy. Entire subtrees are printed only if at least one view in the subtree matches the predicate.
        - depth: The maximum depth of the view hierarchy to print. A value of `.max` prints the entire hierarchy. Defaults to `.max`.
        - includeDetails: If `true` prints the full description of each view; otherwise prints only the type.
     */
    public func printHierarchy(predicate: (NSUIView) -> Bool, depth: Int = .max, includeDetails: Bool = false) {
        guard depth >= 0 else { return }
        printHierarchy(level: 0, depth: depth, predicate: predicate, includeDetails: includeDetails)
    }
    
    /**
     A Boolean value indicating whether the view is effectively visible within its window.

     This property does not check if the window itself is visible or onscreen. It only determines whether the view is visible within the window.

     The visibility determination considers the following factors:
     - The view must be associated with a `window`.
     - The view's `isHidden` must be `false`.
     - The view's `alphaValue` must be larger than `0.0`.
     - The view's `visibleRect` must not be empty.
     - If the view has a layer, the layer's `isHidden` must be `false` and `opacity` must be larger than `0.0`.
     - All of the view's superviews in the hierarchy must also be effectively visible.
     */
    @objc open var isVisible: Bool {
        window != nil && isVisibleInHierarchy
    }

    private var isVisibleInHierarchy: Bool {
        #if os(macOS)
        !isHidden && alphaValue > 0.0 && !bounds.isEmpty && layer?.isVisible ?? true && isVisibleInSuperview
        #else
        !isHidden && alpha > 0.0 && !bounds.isEmpty && layer.isVisible && isVisibleInSuperview
        #endif
    }

    private var isVisibleInSuperview: Bool {
        guard let superview = superview else { return true }
        return !frame.intersection(superview.bounds).isEmpty && superview.isVisibleInHierarchy
    }
    
    /**
     Resizes and repositions the view to it's superview using the specified scale.

     - Parameter option: The option for resizing and repositioning the view.
     */
    @objc open func resizeAndRepositionInSuperview(using option: CALayerContentsGravity) {
        guard let superview = superview else { return }
        switch option {
        case .resize:
            frame.size = superview.bounds.size
        case .resizeAspect:
            frame.size = frame.size.scaled(toFit: superview.bounds.size)
        case .resizeAspectFill:
            frame.size = frame.size.scaled(toFill: superview.bounds.size)
        default:
            break
        }
        switch option {
        case .bottom:
            frame.bottom = superview.bounds.bottom
        case .bottomLeft:
            frame.origin = .zero
        case .bottomRight:
            frame.bottomRight = superview.bounds.bottomRight
        case .left:
            frame.left = superview.bounds.left
        case .right:
            frame.right = superview.bounds.right
        case .topLeft:
            frame.topLeft = superview.bounds.topLeft
        case .top:
            frame.top = superview.bounds.top
        case .topRight:
            frame.topRight = superview.bounds.topRight
        default:
            center = superview.bounds.center
        }
    }

    private func printHierarchy(level: Int, depth: Int, predicate: (NSUIView) -> Bool, includeDetails: Bool) {
        let string = includeDetails ? "\(self)" : "\(type(of: self))"
        Swift.print("\(Array(repeating: " ", count: level).joined(separator: ""))\(string)")
        guard level+1 <= depth else { return }
        for subview in subviews {
            guard subview.matchesPredicateRecursively(predicate, level: level+1, depth: depth) else { continue }
            subview.printHierarchy(level: level+1, depth: depth, predicate: predicate, includeDetails: includeDetails)
        }
    }

    private func matchesPredicateRecursively(_ predicate: (NSUIView) -> Bool, level: Int, depth: Int) -> Bool {
        if predicate(self) {
            return true
        }
        guard level+1 <= depth else { return false }
        return subviews.contains { $0.matchesPredicateRecursively(predicate, level: level+1, depth: depth) }
    }

    /**
     A Boolean value indicating whether to debug autolayout problems.
     
     If set to `true`, autolayout problems are printed to the console.
     */
    public static var debugAutoLayoutProblems: Bool {
        get { isMethodHooked(NSSelectorFromString("engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:")) }
        set {
            guard newValue != debugAutoLayoutProblems else { return }
            if newValue {
                do {
                    #if os(macOS) || os(iOS)
                    try hook("engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:", closure: { original, object, sel, engine, constraint, constraints in
                        Swift.print()
                        Swift.print("Autolayout Error:")
                        Swift.print("- willBreak:", constraint)
                        Swift.print("- dueToMutuallyExclusive:", constraints)
                        Swift.print(engine)
                        Swift.print()
                        original(object, sel, engine, constraint, constraints)
                    } as @convention(block) (
                        (AnyObject, Selector, NSObject, NSLayoutConstraint, [NSLayoutConstraint]) -> Void,
                        AnyObject, Selector, NSObject, NSLayoutConstraint, [NSLayoutConstraint]) -> Void)
                    #else
                    try hook(NSSelectorFromString("engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:"),
                             methodSignature: (@convention(c)  (AnyObject, Selector, NSObject, NSLayoutConstraint, [NSLayoutConstraint]) -> ()).self,
                             hookSignature: (@convention(block)  (AnyObject, NSObject, NSLayoutConstraint, [NSLayoutConstraint]) -> ()).self) { store in {
                        object, engine, constraint, constraints in
                        Swift.print()
                        Swift.print("Autolayout Error:")
                        Swift.print("- willBreak:", constraint)
                        Swift.print("- dueToMutuallyExclusive:", constraints)
                        Swift.print(engine)
                        Swift.print()
                        store.original(object, store.selector, engine, constraint, constraints)
                    }
                    }
                    #endif
                } catch {
                    debugPrint(error)
                }
            } else {
                revertHooks(for: NSSelectorFromString("engine:willBreakConstraint:dueToMutuallyExclusiveConstraints:"))
            }
        }
    }
}

fileprivate extension [Gradient.ColorStop] {
    func animatable(to stops: Self) -> (start: Self, end: Self) {
        var from = self
        var to = stops
        if count < stops.count {
            from += stops[safe: count...].map({$0.transparent})
        } else if count > stops.count {
            to += self[safe: stops.count...].map({ $0.transparent })
        }
        return (from, to)
    }
}

fileprivate extension CALayer {
    var isVisible: Bool {
        !isHidden && opacity > 0.0
    }
}
#endif
