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
    public extension CALayer {
        /// The shadow of the layer.
        var shadow: ShadowConfiguration {
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
        var innerShadow: ShadowConfiguration {
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
        
        /// The border of the layer.
        var border: BorderConfiguration {
            get { borderLayer?.configuration ?? BorderConfiguration(color: borderColor?.nsUIColor, width: borderWidth) }
            set {
                guard newValue != border else { return }
                if newValue.isInvisible || !newValue.needsDashedBordlerLayer {
                    borderLayer?.removeFromSuperlayer()
                }

                if newValue.needsDashedBordlerLayer {
                    borderColor = nil
                    borderWidth = 0.0
                    if borderLayer == nil {
                        let borderedLayer = DashedBorderLayer()
                        addSublayer(withConstraint: borderedLayer, insets: newValue.insets)
                        borderedLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                    }
                    borderLayer?.configuration = newValue
                } else {
                    borderColor = newValue._resolvedColor?.cgColor
                    borderWidth = newValue.width
                }
            }
        }
        
        /// Sends the layer to the front of it's superlayer.
        func sendToFront() {
            guard let superlayer = superlayer else { return }
            superlayer.addSublayer(self)
        }

        /// Sends the layer to the back of it's superlayer.
        func sendToBack() {
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
        func addSublayer(withConstraint layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
            addSublayer(layer)
            layer.constraintTo(layer: self, insets: insets)
        }

        /**
         Inserts the specified layer at the specified index and constraints it to the layer.

         The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` of the specified layer will be constraint. To remove the constraints use `removeConstraints()`.

         - Parameters:
         - layer: The layer to be added.
         - index: The index at which to insert layer. This value must be a valid 0-based index into the `sublayers` array.
         - insets: Insets from the new sublayer border to the layer border.
         */
        func insertSublayer(withConstraint layer: CALayer, at index: UInt32, insets: NSDirectionalEdgeInsets = .zero) {
            insertSublayer(layer, at: index)
            layer.constraintTo(layer: self, insets: insets)
        }

        /**
         Constraints the layer to the specified layer.

         The properties `bounds`, `cornerRadius`, `cornerCurve` and `maskedCorners` will be constraint to the specified layer. To remove the constraints use `removeConstraints()`.

         - Parameter layer: The layer to constraint to.
         */
        func constraintTo(layer: CALayer, insets: NSDirectionalEdgeInsets = .zero) {
            let layerBoundsUpdate: (() -> Void) = { [weak self] in
                guard let self = self else { return }
                let frameSize = layer.frame.size
                var shapeRect = CGRect(origin: .zero, size: frameSize)
                if frameSize.width > insets.width, frameSize.height > insets.height {
                    shapeRect = shapeRect.inset(by: insets)
                }
                let position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
                self.bounds = shapeRect
                self.position = position
            }

            let layerUpdate: (() -> Void) = { [weak self] in
                guard let self = self else { return }
                self.cornerRadius = layer.cornerRadius
                self.maskedCorners = layer.maskedCorners
                self.cornerCurve = layer.cornerCurve
            }

            if layerObserver?.observedObject != layer {
                layerObserver = KeyValueObserver(layer)
            }

            layerObserver?.add(\.cornerRadius) { old, new in
                guard old != new else { return }
                layerUpdate()
            }

            layerObserver?.add(\.cornerCurve) { old, new in
                guard old != new else { return }
                layerUpdate()
            }

            layerObserver?.add(\.maskedCorners) { old, new in
                guard old != new else { return }
                layerUpdate()
            }

            layerObserver?.add(\.bounds) { old, new in
                guard old != new else { return }
                layerBoundsUpdate()
            }
            layerBoundsUpdate()
            layerUpdate()
        }

        /// Removes the layer constraints.
        func removeConstraints() {
            layerObserver = nil
        }

        internal var layerObserver: KeyValueObserver<CALayer>? {
            get { getAssociatedValue("layerObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "layerObserver") }
        }

        /// The associated view using the layer.
        var parentView: NSUIView? {
            if let view = delegate as? NSUIView {
                return view
            }
            return superlayer?.parentView
        }

        /// A rendered image of the layer.
        var renderedImage: NSUIImage {
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
        func firstSuperlayer<V: CALayer>(for _: V.Type) -> V? {
            firstSuperlayer(where: { $0 is V }) as? V
        }

        /**
         The first superlayer that matches the specificed predicate.

         - Parameter predicate: The closure to match.
         - Returns: The first parent layer that is matching the predicate or `nil` if none match or there isn't a matching parent.
         */
        func firstSuperlayer(where predicate: (CALayer) -> (Bool)) -> CALayer? {
            if let superlayer = superlayer {
                if predicate(superlayer) == true {
                    return superlayer
                }
                return superlayer.firstSuperlayer(where: predicate)
            }
            return nil
        }

        /// Returns the first sublayer of a specific type.
        func firstSublayer<V: CALayer>(type _: V.Type) -> V? {
            sublayers?.first(where: { $0 is V }) as? V
        }

        /**
         An array of all sublayers upto the maximum depth.

         - Parameter depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
         */
        func sublayers(depth: Int) -> [CALayer] {
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
        func sublayers<V: CALayer>(type _: V.Type, depth: Int = 0) -> [V] {
            sublayers(depth: depth).compactMap { $0 as? V }
        }

        /**
         An array of all sublayers matching the specified predicte.

          - Parameters:
             - predicate: The predicate to match.
             - depth: The maximum depth. As example a value of `0` returns the sublayers of the current layer and a value of `1` returns the sublayers of the current layer and all of their sublayers. To return all sublayers use `max`.
          */
        func sublayers(where predicate: (CALayer) -> (Bool), depth: Int = 0) -> [CALayer] {
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
        var nonAnimated: NonAnimated {
            getAssociatedValue("nonAnimated", initialValue: NonAnimated(self))
        }
        
        /// Access layer properties non-animated.
        @dynamicMemberLookup
        class NonAnimated {
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
 @discardableResult
 func addSublayer(withConstraint layer: CALayer) -> [NSLayoutConstraint] {
 addSublayer(layer)
 layer.cornerRadius = cornerRadius
 layer.maskedCorners = maskedCorners
 layer.masksToBounds = true
 return layer.constraintTo(layer: self)
 }

 @discardableResult
 func constraintTo(layer: CALayer) -> [NSLayoutConstraint] {
 frame = layer.bounds
 let constrains = [
 NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0),
 NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0),
 NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0),
 NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: layer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0),
 ]
 constrains.forEach { $0.isActive = true }
 return constrains
 }
 */
