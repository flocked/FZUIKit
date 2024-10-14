//
//  CALayer+.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

// import QuartzCore

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import FZSwiftUtils


#if os(macOS) || os(iOS) || os(tvOS)
    extension CALayer {
        /// The shadow of the layer.
        @objc open var shadow: ShadowConfiguration {
            get { .init(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
            set {
                if let parentView = parentView {
                    shadowColor = newValue.color?.resolvedColor(for: parentView).cgColor
                    #if os(macOS)
                    parentView.dynamicColors.shadow = newValue.color
                    #endif
                } else {
                    shadowColor = newValue.color?.cgColor
                }
                shadowOpacity = Float(newValue.opacity)
                shadowRadius = newValue.radius
                shadowOffset = newValue.offset.size
            }
        }
        
        /// The inner shadow of the layer.
        @objc open var innerShadow: ShadowConfiguration {
            get { innerShadowLayer?.configuration ?? .none() }
            set {
                if newValue.isInvisible {
                    innerShadowLayer?.removeFromSuperlayer()
                } else {
                    if innerShadowLayer == nil {
                        let innerShadowLayer = InnerShadowLayer()
                        addSublayer(withConstraint: innerShadowLayer)
                        innerShadowLayer.sendToBack()
                        innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
                    }
                    innerShadowLayer?.configuration = newValue
                }
            }
        }
        
        internal var innerShadowLayer: InnerShadowLayer? {
            firstSublayer(type: InnerShadowLayer.self)
        }
        
        /// The border of the layer.
        @objc open var border: BorderConfiguration {
            get { borderLayer?.configuration ?? BorderConfiguration(color: borderColor?.nsUIColor, width: borderWidth) }
            set {
                guard newValue != border else { return }
                if let layer = self as? CAShapeLayer {
                    layer.strokeColor = newValue.resolvedColor()?.cgColor
                    layer.lineDashPattern = newValue.dash.pattern  as [NSNumber]
                    layer.lineWidth = newValue.width
                } else {
                    if newValue.needsDashedBorder {
                        borderColor = nil
                        borderWidth = 0.0
                        if let layer = self as? CAShapeLayer {
                            layer.strokeColor = newValue.resolvedColor()?.cgColor
                            layer.lineDashPattern = newValue.dash.pattern  as [NSNumber]
                            layer.lineWidth = newValue.width
                            layer.lineDashPhase = newValue.dash.phase
                        } else {
                            if let borderLayer = borderLayer {
                                borderLayer.configuration = newValue
                            } else {
                                let borderedLayer = DashedBorderLayer()
                                addSublayer(withConstraint: borderedLayer, insets: newValue.insets)
                                borderedLayer.configuration = newValue
                            }
                        }
                    } else {
                        borderColor = newValue.resolvedColor()?.cgColor
                        borderWidth = newValue.width
                        if let layer = self as? CAShapeLayer {
                            layer.strokeColor = nil
                            layer.lineDashPattern = []
                            layer.lineWidth = 0.0
                        }
                    }
                }
            }
        }
        
        internal var borderLayer: DashedBorderLayer? {
            firstSublayer(type: DashedBorderLayer.self)
        }
        
        /**
         The relative percentage (between `0.0` and `1.0`) for rounding the corners based on the layer's height.
         
         For e.g. a  value of `0.5`  sets the corner radius to half the height of layer. The value can be used for a circular or capsule appearence of the layer depending if it's square.

         The corner radius updates automatically, if the height of the layer changes.
         
         Changing the ``cornerRadius``, sets the value to `nil`.
         */
        public var relativeCornerRadius: CGFloat? {
            get { getAssociatedValue("relativeCornerRadius") }
            set {
                setAssociatedValue(newValue?.clamped(to: 0...1), key: "relativeCornerRadius")
                if newValue == nil {
                    cornerFrameObservation = nil
                    cornerRadiusObservation = nil
                } else if cornerFrameObservation == nil {
                    self.cornerRadius = frame.height * newValue!
                    cornerFrameObservation = observeChanges(for: \.bounds) { [weak self] old, new in
                        guard let self = self, old.height != new.height, let relativeCornerRadius = self.relativeCornerRadius else { return }
                        self.isUpdatingCornerRadius = true
                        self.cornerRadius = new.height * relativeCornerRadius
                        self.isUpdatingCornerRadius = false
                    }
                    cornerRadiusObservation = observeChanges(for: \.cornerRadius) { [weak self] old, new in
                        guard let self = self, !self.isUpdatingCornerRadius else { return }
                        self.relativeCornerRadius = nil
                    }
                }
            }
        }
        
        var cornerRadiusObservation: KeyValueObservation? {
            get { getAssociatedValue("cornerRadiusObservation") }
            set { setAssociatedValue(newValue, key: "cornerRadiusObservation") }
        }
        
        var isUpdatingCornerRadius: Bool {
            get { getAssociatedValue("isUpdatingCornerRadius") ?? false }
            set { setAssociatedValue(newValue, key: "isUpdatingCornerRadius") }
        }
        
        var cornerFrameObservation: KeyValueObservation? {
            get { getAssociatedValue("cornerFrameObservation") }
            set { setAssociatedValue(newValue, key: "cornerFrameObservation") }
        }
        
        /// Sends the layer to the front of it's superlayer.
        @objc open func sendToFront() {
            guard let superlayer = superlayer else { return }
            superlayer.addSublayer(self)
        }

        /// Sends the layer to the back of it's superlayer.
        @objc open func sendToBack() {
            guard let superlayer = superlayer else { return }
            superlayer.insertSublayer(self, at: 0)
        }

        /**
         Adds the specified sublayer and constraints it to the layer.

         The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.

         - Parameters:
            - layer: The layer to be added.
            - insets: Insets from the new sublayer border to the layer border.
         */
        @objc open func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
            addSublayer(layer)
            layer.constraint(to: self, insets: insets)
        }

        /**
         Inserts the specified layer at the specified index and constraints it to the layer.

         The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.

         - Parameters:
            - layer: The layer to be added.
            - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
            - insets: Insets from the new sublayer border to the layer border.
         */
        @objc open func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
            guard index >= 0, index < sublayers?.count ?? Int.max else { return }
            insertSublayer(layer, at: index)
            layer.constraint(to: self, insets: insets)
        }
        
        /**
         Constraints the layer to the specified layer.

         The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.

         - Parameters:
            - layer: The layer to constraint to.
            - insets: The insets.
         */
        @objc open func constraint(to layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
            let frameUpdate: (() -> Void) = { [weak self] in
                guard let self = self else { return }
                var frame = layer.bounds
                frame.size.width -= insets.width
                frame.size.height -= insets.height
                frame.center = layer.bounds.center
                self.frame = frame
            }
            cornerRadius = layer.cornerRadius
            maskedCorners = layer.maskedCorners
            cornerCurve = layer.cornerCurve
            
            if layerObserver?.observedObject != layer {
                layerObserver = KeyValueObserver(layer)
            }
            layerObserver?.add(\.cornerRadius) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.cornerRadius = new
            }
            layerObserver?.add(\.cornerCurve) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.cornerCurve = new
            }
            layerObserver?.add(\.maskedCorners) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.maskedCorners = new
            }
            layerObserver?.add(\.bounds) { old, new in
                guard old != new else { return }
                frameUpdate()
            }
            frameUpdate()
            if superlayer == layer {
                superLayerObservation = observeChanges(for: \.superlayer) { [weak self] old, new in
                    guard let self = self, new != layer else { return }
                    self.removeConstraints()
                }
            } else {
                superLayerObservation = nil
            }
        }

        /// Removes the layer constraints.
        @objc open func removeConstraints() {
            layerObserver = nil
            superLayerObservation = nil
        }
        
        var superLayerObservation: KeyValueObservation? {
            get { getAssociatedValue("superLayerObservation") }
            set { setAssociatedValue(newValue, key: "superLayerObservation") }
        }

        var layerObserver: KeyValueObserver<CALayer>? {
            get { getAssociatedValue("layerObserver") }
            set { setAssociatedValue(newValue, key: "layerObserver") }
        }

        /// The associated view using the layer.
        @objc open var parentView: NSUIView? {
            if let view = delegate as? NSUIView {
                return view
            }
            return superlayer?.parentView
        }

        /// A rendered image of the layer.
        @objc open var renderedImage: NSUIImage {
            #if os(macOS)
                let btmpImgRep =
                    NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(frame.width), pixelsHigh: Int(frame.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 32)
                let ctx = NSGraphicsContext(bitmapImageRep: btmpImgRep!)
                let cgContext = ctx!.cgContext
                render(in: cgContext)
                let cgImage = cgContext.makeImage()
                let nsimage = NSImage(cgImage: cgImage!, size: CGSize(width: frame.width, height: frame.height))
                return nsimage
            #else
                UIGraphicsBeginImageContextWithOptions(frame.size, isOpaque, 0)
                render(in: UIGraphicsGetCurrentContext()!)
                let outputImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return outputImage!
            #endif
        }

        /**
         The first superlayer that matches the specificed layer type.

         - Parameter layerType: The type of layer to match.
         - Returns: The first parent layer that matches the layer type or `nil` if none match or there isn't a matching parent.
         */
        public func firstSuperlayer<V: CALayer>(for _: V.Type) -> V? {
            firstSuperlayer(where: { $0 is V }) as? V
        }

        /**
         The first superlayer that matches the specificed predicate.

         - Parameter predicate: The closure to match.
         - Returns: The first parent layer that is matching the predicate or `nil` if none match or there isn't a matching parent.
         */
        @objc open func firstSuperlayer(where predicate: (CALayer) -> (Bool)) -> CALayer? {
            if let superlayer = superlayer {
                if predicate(superlayer) == true {
                    return superlayer
                }
                return superlayer.firstSuperlayer(where: predicate)
            }
            return nil
        }
        
        /// An array of all enclosing superlayers..
        @objc open func supervlayerChain() -> [CALayer] {
            if let superlayer = superlayer {
                return [superlayer] + superlayer.supervlayerChain()
            }
            return []
        }

        /// Returns the first sublayer of a specific type.
        public func firstSublayer<V: CALayer>(type _: V.Type) -> V? {
            sublayers?.first(where: { $0 is V }) as? V
        }

        /**
         An array of all sublayers upto the maximum depth.

         - Parameter depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
         */
        public func sublayers(depth: Int) -> [CALayer] {
            let sublayers = sublayers ?? []
            if depth > 0 {
                return sublayers + sublayers.flatMap { $0.sublayers(depth: depth - 1) }
            } else {
                return sublayers
            }
        }

        /**
         An array of all sublayers matching the specified layer type.

          - Parameters:
             - type: The type of sublayers.
             - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
          */
        public func sublayers<V: CALayer>(type _: V.Type, depth: Int = 0) -> [V] {
            sublayers(depth: depth).compactMap { $0 as? V }
        }

        /**
         An array of all sublayers matching the specified predicte.

          - Parameters:
             - predicate: The predicate to match.
             - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
          */
        public func sublayers(where predicate: (CALayer) -> (Bool), depth: Int = 0) -> [CALayer] {
            sublayers(depth: depth).filter { predicate($0) == true }
        }

        /**
         An optional layer whose inverse alpha channel is used to mask the layer’s content.

         In contrast to `mask` transparent pixels allow the underlying content to show, while opaque pixels block the content.
         */
        @objc var inverseMask: CALayer? {
            get { (mask as? InverseMaskLayer)?.maskLayer }
            set {
                if let newValue = newValue {
                    mask = InverseMaskLayer(maskLayer: newValue)
                } else {
                    mask = nil
                }
            }
        }
        
        /// Sets the layer properties non-animated.
        public var nonAnimated: NonAnimated {
            NonAnimated(self)
        }
        
        /// Access layer properties non-animated.
        @dynamicMemberLookup
        public class NonAnimated {
            /// Sets the layer properties non-animated.
            public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<CALayer, T>) -> T {
                get { layer[keyPath: keyPath] }
                set {
                    CATransaction.performNonAnimated {
                        layer[keyPath: keyPath] = newValue
                    }
                }
            }
            
            init(_ layer: CALayer) {
                self.layer = layer
            }
            let layer: CALayer
        }
    }
#endif

#if os(macOS)
    public extension CAAutoresizingMask {
        static let all: CAAutoresizingMask = [.layerHeightSizable, .layerWidthSizable, .layerMinXMargin, .layerMinYMargin, .layerMaxXMargin, .layerMaxYMargin]
    }
#endif

/*
class CALayerConstraint {
    public weak internal(set) var first: CALayer?
    public weak internal(set) var second: CALayer?
    
    public var isActive: Bool  {
        get { observer.observedObject == second }
        set {
            guard newValue != isActive else { return }
            if newValue, let second = second {
                observer.replaceObservedObject(with: second)
            } else {
                observer.removeObservedObject()
            }
        }
    }
    public var insets: NSDirectionalEdgeInsets
    
    var observer: KeyValueObserver<CALayer>!
    
    init(_ first: CALayer, second: CALayer, insets: NSDirectionalEdgeInsets) {
        self.first = first
        self.second = second
        self.insets = insets
        
        let frameUpdate: (() -> Void) = { [weak self] in
            guard let self = self, let first = self.first, let second = self.second else { return }
            var frame = second.bounds
            frame.size.width -= insets.width
            frame.size.height -= insets.height
            frame.center = second.bounds.center
            first.frame = frame
        }
        first.cornerRadius = second.cornerRadius
        first.maskedCorners = second.maskedCorners
        first.cornerCurve = second.cornerCurve
                        
        observer = KeyValueObserver(second)
        observer.add(\.cornerRadius) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.cornerRadius = new
        }
        observer.add(\.cornerCurve) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.cornerCurve = new
        }
        observer.add(\.maskedCorners) { [weak self] old, new in
            guard let self = self, let first = self.first else { return }
            first.maskedCorners = new
        }
        observer.add(\.bounds) { old, new in
            guard old != new else { return }
            frameUpdate()
        }
        frameUpdate()
    }
}

var constraint: CALayerConstraint? {
    get { getAssociatedValue("layerConstraint") }
    set { setAssociatedValue(newValue, key: "layerConstraint") }
}
*/
