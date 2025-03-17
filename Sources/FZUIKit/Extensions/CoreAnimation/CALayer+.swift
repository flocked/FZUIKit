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
        /**
         The center point of the layer's frame rectangle.

         Setting this property updates the origin of the rectangle in the frame property appropriately.

         Use this property, instead of the frame property, when you want to change the position of a layer. The center point is always valid, even when scaling or rotation factors are applied to the layer's transform.

         Changes to this property can be animated via `animator().center`.
         */
        @objc open var center: CGPoint {
            get { frame.center }
            set { frame.center = newValue }
        }
        
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
        
        /// The shape of the shadow.
        public var shadowShape: PathShape? {
            get { getAssociatedValue("shadowPathHandler") }
            set {
                setAssociatedValue(newValue, key: "shadowPathHandler")
                if let newValue = newValue {
                    shadowPathObservation = observeChanges(for: \.bounds) { [weak self] old, new in
                        guard let self = self, old.size != new.size else { return }
                        self.shadowPath = newValue.path(in: new)
                    }
                    shadowPath = newValue.path(in: bounds)
                } else {
                    shadowPathObservation = nil
                }
            }
        }
        
        var shadowPathObservation: KeyValueObservation? {
            get { getAssociatedValue("shadowPathObservation") }
            set { setAssociatedValue(newValue, key: "shadowPathObservation") }
        }
        
        /// The shape that is used for masking the layer.
        public var maskShape: PathShape? {
            get { (mask as? PathShapeMaskLayer)?.shape }
            set {
                if let newValue = newValue {
                    let layer = mask as? PathShapeMaskLayer ?? PathShapeMaskLayer(layer: self, shape: newValue)
                    layer.shape = newValue
                } else if mask is PathShapeMaskLayer {
                    mask = nil
                }
            }
        }
        
        class PathShapeMaskLayer: CAShapeLayer {
            var shape: PathShape {
                didSet { path = shape.path(in: bounds) }
            }
            var observation: KeyValueObservation!
            init(layer: CALayer, shape: PathShape) {
                self.shape = shape
                super.init()
                frame = layer.bounds
                layer.mask = self
                observation = layer.observeChanges(for: \.bounds) { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.frame = new
                    self.path = self.shape.path(in: new)
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        internal var innerShadowLayer: InnerShadowLayer? {
            firstSublayer(type: InnerShadowLayer.self)
        }
        
        /// The border of the layer.
        @objc open var border: BorderConfiguration {
            get { borderLayer?.configuration ?? (self as? CAShapeLayer)?.border ?? BorderConfiguration(color: borderColor?.nsUIColor, width: borderWidth) }
            set {
                guard newValue != border else { return }
                if let layer = self as? CAShapeLayer {
                    layer._border = newValue
                } else {
                    if newValue.needsDashedBorder {
                        borderColor = nil
                        borderWidth = 0.0
                        if let layer = self as? CAShapeLayer {
                            layer.strokeColor = newValue.resolvedColor()?.cgColor
                            layer.lineDashPattern = newValue.dash.pattern  as [NSNumber]
                            layer.lineWidth = newValue.width
                            layer.lineDashPhase = newValue.dash.phase
                            layer.lineJoin = newValue.dash.lineJoin.shapeLayerLineJoin
                            layer.lineCap = newValue.dash.lineCap.shapeLayerLineCap
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
    }

extension CAShapeLayer {
    var borderColorTransformer: ColorTransformer? {
        get { getAssociatedValue("borderColorTransformer") }
        set { setAssociatedValue(newValue, key: "borderColorTransformer") }
    }
    
    var borderConfigurationColor: (color: NSUIColor?, cgColor: CGColor?) {
        get { getAssociatedValue("borderConfigurationColor") ?? (nil, nil) }
        set { setAssociatedValue(newValue, key: "borderConfigurationColor") }
    }
    
    var borderInsets: NSDirectionalEdgeInsets {
        get { getAssociatedValue("borderInsets") ?? .zero }
        set { setAssociatedValue(newValue, key: "borderInsets") }
    }
    
    var _border: BorderConfiguration {
        get {
            var configuration = BorderConfiguration()
            configuration.insets = borderInsets
            configuration.colorTransformer = borderColorTransformer
            configuration.width = lineWidth
            configuration.dash.lineCap = lineCap.cgLineCap
            configuration.dash.lineJoin = lineJoin.cgLineJoin
            configuration.dash.phase = lineDashPhase
            configuration.dash.pattern = lineDashPattern?.compactMap({ CGFloat($0.doubleValue) }) ?? []
            if strokeColor == borderConfigurationColor.cgColor {
                configuration.color = borderConfigurationColor.color
            } else {
                borderConfigurationColor = (nil, nil)
            }
            return configuration
        }
        set {
            if let color = newValue.resolvedColor() {
                if let parentView = parentView {
                    strokeColor = color.resolvedColor(for: parentView).cgColor
                }
                strokeColor = color.cgColor
            } else {
                strokeColor = nil
            }
            lineDashPattern = newValue.dash.pattern  as [NSNumber]
            lineWidth = newValue.width
            lineDashPhase = newValue.dash.phase
            lineJoin = newValue.dash.lineJoin.shapeLayerLineJoin
            lineCap = newValue.dash.lineCap.shapeLayerLineCap
            borderConfigurationColor = (newValue.color, strokeColor)
            borderInsets = newValue.insets
            borderColorTransformer = newValue.colorTransformer
        }
    }
}

/*
 public init(color: NSUIColor? = nil,
             colorTransformer: ColorTransformer? = nil,
             width: CGFloat = 0.0,
             dash: Dash = Dash(),
             insets: NSDirectionalEdgeInsets = .init(0)) {
 */
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
