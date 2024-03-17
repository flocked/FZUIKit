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

    public extension NSUIView {
        var optionalLayer: CALayer? {
            #if os(macOS)
                wantsLayer = true
            #endif
            return layer
        }

        /// The level of the view from the most outer `superview`. A value of `0` indicates that there isn't a superview.
        var viewLevel: Int {
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

        func removeAllConstraints() {
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
        func sendToFront() {
            guard let superview = superview else { return }
            #if os(macOS)
                superview.addSubview(self)
            #else
                superview.bringSubviewToFront(self)
            #endif
        }

        /// Sends the view to the back of it's superview.
        func sendToBack() {
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
        func enclosingRect(for subviews: [NSUIView]) -> CGRect {
            var enlosingFrame = CGRect.zero
            for subview in subviews {
                let frame = convert(subview.bounds, from: subview)
                enlosingFrame = enlosingFrame.union(frame)
            }
            return enlosingFrame
        }

        /**
         Inserts the subview at the specified index.

         - Parameters:
            - view: The view to insert.
            - index: The index of insertation.
         */
        func insertSubview(_ view: NSUIView, at index: Int) {
            guard index < self.subviews.count else {
                addSubview(view)
                return
            }
            #if os(macOS)
                var subviews = subviews
                subviews.insert(view, at: index)
                self.subviews = subviews
            #elseif canImport(UIKit)
                insertSubview(view, belowSubview: self.subviews[index])
            #endif
        }

        /**
         Moves the specified subview to the index.

         - Parameters:
            - view: The view to move.
            - index: The index for moving.
         */
        func moveSubview(_ subview: NSUIView, to toIndex: Int) {
            if let index = subviews.firstIndex(of: subview) {
                moveSubview(at: index, to: toIndex)
            }
        }

        /**
         Moves the specified subviews to the index.

         - Parameters:
            - subviews: The subviews to move.
            - toIndex: The index for moving.
         */
        func moveSubviews(_ subviews: [NSUIView], to toIndex: Int, reorder: Bool = false) {
            var indexSet = IndexSet()
            for view in subviews {
                if let index = subviews.firstIndex(of: view), indexSet.contains(index) == false {
                    indexSet.insert(index)
                }
            }
            if indexSet.isEmpty == false {
                moveSubviews(at: indexSet, to: toIndex, reorder: reorder)
            }
        }

        /**
         Moves the subview at the specified index to another index.

         - Parameters:
            - index: The index of the subview to move.
            - toIndex: The index to where the subview should be moved.
         */
        func moveSubview(at index: Int, to toIndex: Int) {
            moveSubviews(at: IndexSet(integer: index), to: toIndex)
        }

        /**
         Moves subviews at the specified indexes to another index.

         - Parameters:
            - indexes: The indexes of the subviews to move.
            - toIndex: The index where the subviews should be moved to.
         */
        func moveSubviews(at indexes: IndexSet, to toIndex: Int, reorder: Bool = false) {
            let subviewsCount = subviews.count
            if subviews.isEmpty == false {
                if toIndex >= 0, toIndex < subviewsCount {
                    let indexes = IndexSet(Array(indexes).filter { $0 < subviewsCount })
                    #if os(macOS)
                        var subviews = subviews
                        if reorder {
                            for index in indexes.reversed() {
                                subviews.move(from: IndexSet(integer: index), to: toIndex)
                            }
                        } else {
                            subviews.move(from: indexes, to: toIndex)
                        }
                        self.subviews = subviews
                    #elseif canImport(UIKit)
                        var below = self.subviews[toIndex]
                        let subviewsToMove = (reorder == true) ? self.subviews[indexes].reversed() : self.subviews[indexes]
                        for subviewToMove in subviewsToMove {
                            insertSubview(subviewToMove, belowSubview: below)
                            below = (reorder == true) ? subviews[toIndex] : subviewToMove
                        }
                    #endif
                }
            }
        }

        /**
         The first superview that matches the specificed view type.

         - Parameter viewType: The type of view to match.
         - Returns: The first parent view that matches the view type or `nil` if none match or there isn't a matching parent.
         */
        func firstSuperview<V: NSUIView>(for _: V.Type) -> V? {
            firstSuperview(where: { $0 is V }) as? V
        }

        /**
         The first superview that matches the specificed predicate.

         - Parameter predicate: The closure to match.
         - Returns: The first parent view that is matching the predicate or `nil` if none match or there isn't a matching parent.
         */
        func firstSuperview(where predicate: (NSUIView) -> (Bool)) -> NSUIView? {
            if let superview = superview {
                if predicate(superview) == true {
                    return superview
                }
                return superview.firstSuperview(where: predicate)
            }
            return nil
        }

        /**
         An array of all subviews upto the maximum depth.

         - Parameter depth: The maximum depth. As example a value of `0` returns the subviews of receiver and a value of `1` returns the subviews of the receiver and all their subviews. To return all subviews use `max`.
         */
        func subviews(depth: Int) -> [NSUIView] {
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
        func subviews<V: NSUIView>(type _: V.Type, depth: Int = 0) -> [V] {
            subviews(depth: depth).compactMap { $0 as? V }
        }

        /**
         An array of all subviews matching the specified predicte.

          - Parameters:
             - predicate: The predicate to match.
             - depth: The maximum depth. As example a value of `0` returns the subviews of receiver and a value of `1` returns the subviews of the receiver and all their subviews. To return all subviews use `max`.
          */
        func subviews(where predicate: (NSUIView) -> (Bool), depth: Int = 0) -> [NSUIView] {
            subviews(depth: depth).filter { predicate($0) == true }
        }

        /// Animates a transition to changes made to the view after calling this.
        func transition(_ transition: CATransition?) {
            #if os(macOS)
                wantsLayer = true
            if let transition = transition {
               
                layer?.add(transition, forKey: CATransitionType.fade.rawValue)
            } else {
                layer?.removeAnimation(forKey: CATransitionType.fade.rawValue)
            }
            #else
            if let transition = transition {
                layer.add(transition, forKey: CATransitionType.fade.rawValue)
            } else {
                layer.removeAnimation(forKey: CATransitionType.fade.rawValue)
            }
            #endif
        }

        /// Recursive description of the view useful for debugging.
        var recursiveDescription: NSString {
            value(forKey: "recursiveDescription") as! NSString
        }

        #if os(macOS)
            /**
             The background gradient of the view. 
             
             Applying a gradient sets the view's `backgroundColor` to `nil`.

             Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
             */
            var gradient: Gradient? {
                get { self.optionalLayer?._gradientLayer?.gradient }
                set {
                    NSView.swizzleAnimationForKey()
                    let newGradient = newValue ?? .init(stops: [])
                    var didSetupNewGradientLayer = false
                    if newValue?.stops.isEmpty == false {
                        backgroundColor = nil
                        didSetupNewGradientLayer = true
                        self.wantsLayer = true
                        if self.optionalLayer?._gradientLayer == nil {
                            let gradientLayer = GradientLayer()
                            self.optionalLayer?.addSublayer(withConstraint: gradientLayer)
                            gradientLayer.sendToBack()
                            gradientLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude)

                            gradientLayer.locations = newGradient.stops.compactMap { NSNumber($0.location) }
                            gradientLayer.startPoint = newGradient.startPoint.point
                            gradientLayer.endPoint = newGradient.endPoint.point
                            gradientLayer.colors = newGradient.stops.compactMap { $0.color.withAlphaComponent(0.0).cgColor }
                        }
                        self.layer?.backgroundColor = nil
                    }
                    if didSetupNewGradientLayer == false {
                        self.gradientLocations = newGradient.stops.compactMap(\.location)
                        self.gradientStartPoint = newGradient.startPoint.point
                        self.gradientEndPoint = newGradient.endPoint.point
                    }
                    self._gradientColors = newGradient.stops.compactMap(\.color.cgColor)
                    self.optionalLayer?._gradientLayer?.type = newGradient.type.gradientLayerType
                }
            }

        #elseif canImport(UIKit)
            /**
             The background gradient of the view.
         
             Applying a gradient sets the view's `backgroundColor` to `nil`.
             */
            var gradient: Gradient? {
                get { optionalLayer?._gradientLayer?.gradient }
                set { 
                    configurate(using: newValue ?? .init(stops: []))
                    if newValue?.stops.isEmpty == false {
                        backgroundColor = nil
                    }
                }
            }
        #endif

        internal var gradientLocations: [CGFloat] {
            get { optionalLayer?._gradientLayer?.locations as? [CGFloat] ?? [] }
            set {
                var newValue = newValue
                let currentLocations = optionalLayer?._gradientLayer?.locations as? [CGFloat] ?? []
                let diff = newValue.count - currentLocations.count
                if diff < 0 {
                    for i in newValue.count - (diff * -1) ..< newValue.count {
                        newValue[i] = 0.0
                    }
                } else if diff > 0 {
                    newValue.append(contentsOf: Array(repeating: .zero, count: diff))
                }
                gradientLocationsAnimatable = newValue
            }
        }

        @objc internal var gradientLocationsAnimatable: [CGFloat] {
            get { optionalLayer?._gradientLayer?.locations as? [CGFloat] ?? [] }
            set { optionalLayer?._gradientLayer?.locations = newValue.compactMap { NSNumber($0) }
            }
        }

        @objc internal var gradientStartPoint: CGPoint {
            get { optionalLayer?._gradientLayer?.startPoint ?? .zero }
            set { optionalLayer?._gradientLayer?.startPoint = newValue }
        }

        @objc internal var gradientEndPoint: CGPoint {
            get { optionalLayer?._gradientLayer?.endPoint ?? .zero }
            set { optionalLayer?._gradientLayer?.endPoint = newValue }
        }

        internal var _gradientColors: [CGColor] {
            get { optionalLayer?._gradientLayer?.colors as? [CGColor] ?? [] }
            set {
                var newValue = newValue
                let currentColors = optionalLayer?._gradientLayer?.colors ?? []
                let diff = newValue.count - currentColors.count
                if diff < 0 {
                    for i in newValue.count - (diff * -1) ..< newValue.count {
                        newValue[safe: i] = newValue[i].nsUIColor?.withAlphaComponent(0.0).cgColor
                    }
                } else if diff > 0 {
                    newValue.append(contentsOf: Array(repeating: .clear, count: diff))
                }
                gradientColors = newValue
            }
        }

        @objc internal var gradientColors: [CGColor] {
            get { optionalLayer?._gradientLayer?.colors as? [CGColor] ?? [] }
            set { optionalLayer?._gradientLayer?.colors = newValue }
        }
        
        
        /// Sets the Boolean value indicating whether the view is hidden.
        @discardableResult
        func isHidden(_ isHidden: Bool) -> Self {
            self.isHidden = isHidden
            return self
        }
        
        /// Sets the corner radius of the view.
        @discardableResult
        func cornerRadius(_ radius: CGFloat) -> Self {
            cornerRadius = radius
            return self
        }
        
        /// Sets the rounded corners of the view.
        @discardableResult
        func roundedCorners(_ corners: CACornerMask) -> Self {
            roundedCorners = corners
            return self
        }
        
        /// Sets the border of the view.
        @discardableResult
        func border(_ border: BorderConfiguration) -> Self {
            self.border = border
            return self
        }
        
        /// Sets the shadow of the view.
        @discardableResult
        func shadow(_ shadow: ShadowConfiguration) -> Self {
            #if os(macOS)
            self.outerShadow = shadow
            #else
            self.shadow = shadow
            #endif
            return self
        }
        
        /// Sets the inner shadow of the view.
        @discardableResult
        func innerShadow(_ shadow: ShadowConfiguration) -> Self {
            self.innerShadow = shadow
            return self
        }
        
        /// Sets the anchor point of the view’s bounds rectangle.
        @discardableResult
        func anchorPoint(_ anchorPoint: CGPoint) -> Self {
            #if os(macOS)
            self.anchorPoint = anchorPoint
            #else
            self.layer.anchorPoint = anchorPoint
            #endif
            return self
        }
        
        /// Sets the scale transform of the view.
        @discardableResult
        func scale(_ scale: CGPoint) -> Self {
            self.scale = scale
            return self
        }
        
        /// Sets the rotation of the view as euler angles in degrees.
        @discardableResult
        func rotation(_ rotation: CGVector3) -> Self {
            self.rotation = rotation
            return self
        }
        
        /// Sets the rotation of the view as euler angles in radians.
        @discardableResult
        func rotationInRadians(_ rotation: CGVector3) -> Self {
            self.rotationInRadians = rotation
            return self
        }
        
        /// Sets the Boolean value that indicates whether the view, and its subviews, confine their drawing areas to the bounds of the view.
        @discardableResult
        func clipsToBounds(_ clipsToBounds: Bool) -> Self {
            self.clipsToBounds = clipsToBounds
            return self
        }
        
        /// Sets the view whose alpha channel is used to mask a view’s content.
        @discardableResult
        func mask(_ mask: NSUIView?) -> Self {
            self.mask = mask
            return self
        }
        
        /// Sets the view’s bounds rectangle, which expresses its location and size in its own coordinate system.
        @discardableResult
        func bounds(_ bounds: CGRect) -> Self {
            self.bounds = bounds
            return self
        }
        
        /// Sets the view’s frame rectangle, which defines its position and size in its superview’s coordinate system.
        @discardableResult
        func frame(_ frame: CGRect) -> Self {
            self.frame = frame
            return self
        }
        
        /// Sets the center point of the view’s frame rectangle.
        @discardableResult
        func center(_ center: CGPoint) -> Self {
            self.center = center
            return self
        }
        
        #if os(macOS)
        /// Sets the opacity of the view.
        @discardableResult
        func alphaValue(_ alphaValue: CGFloat) -> Self {
            self.alphaValue = alphaValue
            return self
        }
        #else
        /// Sets the opacity of the view.
        @discardableResult
        func alpha(_ alpha: CGFloat) -> Self {
            self.alpha = alpha
            return self
        }
        
        /// Sets the first nondefault tint color value in the view’s hierarchy, ascending from and starting with the view itself.
        @discardableResult
        func tintColor(_ color: UIColor!) -> Self {
            tintColor = color
            return self
        }
        
        /// Sets the flag used to determine how a view lays out its content when its bounds change.x
        @discardableResult
        func contentMode(_ mode: UIView.ContentMode) -> Self {
            contentMode = mode
            return self
        }
        #endif
        
    }
#endif
