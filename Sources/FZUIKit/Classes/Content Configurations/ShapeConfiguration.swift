//
//  ShapeConfiguration.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils
    import SwiftUI

    /**
      A configuration that specifies the shape of a view or layer.

     `NSView`, `UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ShapeConfiguration)`.
      */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public struct ShapeConfiguration: Hashable {
        /// The shape.
        public var shape: (any SwiftUI.Shape)? {
            didSet { name = UUID().uuidString }
        }

        /// The margins for the shape.
        public var margins: NSDirectionalEdgeInsets = .zero

        /// A Boolean value that indicates whether the shape is inverted.
        public var inverted: Bool = false

        var name: String = UUID().uuidString

        /**
         A shape configuration with the specified shape and margins.

         - Parameters:
            - shape: The shape of the configuration. The default value is `nil`.
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public init(shape: (any SwiftUI.Shape)?, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) {
            self.shape = shape
            self.inverted = inverted
            self.margins = margins
            name = UUID().uuidString
        }

        init(shape: (any SwiftUI.Shape)?, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero, name: String? = nil) {
            self.shape = shape
            self.inverted = inverted
            self.margins = margins
            self.name = name ?? UUID().uuidString
        }

        /**
         A circle shape.

         - Parameters:
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func circle(inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Circle(), inverted: inverted, margins: margins, name: "Circle\(inverted ? "Inverted" : "")")
        }
        
        /// A circle shape.
        public static var circle: Self {
            circle()
        }

        /**
         A capsule shape.

         - Parameters:
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func capsule(inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Capsule(), inverted: inverted, margins: margins, name: "Capsule\(inverted ? "Inverted" : "")")
        }
        
        /// A capsule shape.
        public static var capsule: Self {
            capsule()
        }

        /**
         A ellipse shape.

         - Parameters:
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func ellipse(inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Ellipse(), inverted: inverted, margins: margins, name: "Ellipse\(inverted ? "Inverted" : "")")
        }
        
        /// A ellipse shape.
        public static var ellipse: Self {
            ellipse()
        }

        /**
         A rounded rectangle shape with the specified corner radius.

         - Parameters:
            - cornerRadius: The corner radius of the rectangle.
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func roundedRectangle(cornerRadius: CGFloat, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.RoundedRectangle(cornerRadius: cornerRadius), inverted: inverted, margins: margins, name: "RoundedRectangleCornerRadius\(inverted ? "Inverted" : "")")
        }
        
        /**
         A rounded rectangle shape that rounds the specified corners with the specified corner radius.

         - Parameters:
            - cornerRadius: The corner radius of the rectangle.
            - corners: The rounded corners.
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func roundedRectangle(cornerRadius: CGFloat, corners: NSUIRectCorner, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: RoundedCornerRectangle(cornerRadius: cornerRadius, corners: corners), inverted: inverted, margins: margins, name: "RoundedCornerShape\(corners)\(inverted ? "Inverted" : "")")
        }

        /**
         A rounded rectangle shape with the specified corner size.

         - Parameters:
            - cornerSize: The corner size of the rectangle.
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func roundedRectangle(cornerSize: CGSize, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.RoundedRectangle(cornerSize: cornerSize), inverted: inverted, margins: margins, name: "RoundedRectangleCornerSize")
        }

        /**
         A star shape.

         - Parameters:
            - points: The number of points of the star. The default value is `5`.
            - rounded: A Boolean value that indicates whether star is rounded. The default value is `false`.
            - inverted: A Boolean value that indicates whether the shape is inverted. The default value is `false`.
            - margins: The margins of the shape. The default value is `zero`.
         */
        public static func star(points: Int = 5, rounded: Bool = false, inverted: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            let name = rounded ? "StarRounded\(points)\(inverted ? "Inverted" : "")" : "Star\(points)\(inverted ? "Inverted" : "")"
            return Self(shape: Star(points: points, rounded: rounded), inverted: inverted, margins: margins, name: name)
        }
        
        /// A star shape.
        public static var star: Self {
            star()
        }

        /// No shape.
        public static var none: Self = .init(shape: nil, name: "None")

        public static func == (lhs: ShapeConfiguration, rhs: ShapeConfiguration) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(margins)
            hasher.combine(inverted)
        }
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public extension NSUIView {
        /**
         Configurates shape of the view.

         - parameter configuration:The shape configuration.
         */
        func configurate(using configuration: ShapeConfiguration) {
            optionalLayer?.configurate(using: configuration)
        }
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public extension CALayer {
        /**
         Configurates shape of the layer.

         - parameter configuration:The shape configuration.
         */
        func configurate(using configuration: ShapeConfiguration) {
            if configuration.shape != nil {
                if let shapeLayer = configuration.inverted ? inverseMask as? ShapeLayer : mask as? ShapeLayer {
                    shapeLayer.configuration = configuration
                } else {
                    let shapeLayer = ShapeLayer()
                    shapeLayer.configuration = configuration
                    shapeLayer.setupObserver(for: self)
                }
            } else {
                if let shapeLayer = configuration.inverted ? inverseMask as? ShapeLayer : mask as? ShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                    frameObserver = nil
                    if configuration.inverted {
                        inverseMask = nil
                    } else {
                        mask = nil
                    }
                }
            }
        }

        fileprivate var frameObserver: KeyValueObservation? {
            get { getAssociatedValue("frameObserver") }
            set { setAssociatedValue(newValue, key: "frameObserver") }
        }
    }

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    struct ShapeContentView: View {
        let shape: AnyShape
        let color: Color
        
        public init(_ configuration: ShapeConfiguration, color: Color = .black) {
            self.shape = configuration.shape?.asAnyShape() ?? Rectangle().asAnyShape()
            self.color = color
        }

        public var body: some View {
            shape.fill(color)
        }
    }

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /*
    /**
     Sets a clipping shape for this view.
     
     - Parameter configuration: The shape configuration.
     */
    @ViewBuilder
    func clipShape(configuration: ShapeConfiguration?) -> some View {
        if let shape = configuration?.shape?.asAnyShape() {
            self.clipShape(shape)
        } else {
            self
        }
    }
    */
}

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    class ShapeLayer: CALayer {
        var configuration: ShapeConfiguration = .none {
            didSet {
                guard oldValue != configuration else { return }
                updateShape()
            }
        }

        lazy var hostingController = NSUIHostingController(rootView: ShapeContentView(configuration))

        func setupObserver(for layer: CALayer) {
            layer.frameObserver = layer.observeChanges(for: \.frame, handler: { [weak self] old, new in
                guard let self = self, old.size != new.size else { return }
                self.frame.size = new.size
            })
            if configuration.inverted {
                layer.inverseMask = self
            } else {
                layer.mask = self
            }
            frame.size = layer.frame.size
        }

        override var frame: CGRect {
            didSet {
                guard oldValue != frame else { return }
                layoutShape()
            }
        }

        func updateShape() {
            hostingController.rootView = ShapeContentView(configuration)
            setNeedsLayout()
        }

        func layoutShape() {
            var newSize = bounds.size

            newSize.width -= configuration.margins.width
            if newSize.width < 0 {
                newSize.width = 0
            }
            newSize.height -= configuration.margins.height
            if newSize.height < 0 {
                newSize.height = 0
            }
            hostingController.view.frame.size = newSize
            imageLayer.frame.size = newSize
            if let superviewFrame = superlayer?.bounds {
                imageLayer.frame.center = superviewFrame.center
            }
            imageLayer.contents = hostingController.view.renderedImage
        }

        override init() {
            super.init()
            sharedInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        let imageLayer = CALayer()

        func sharedInit() {
            contentsGravity = .resizeAspect
            addSublayer(imageLayer)
        }
    }

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
struct ShapeShadowView: View {
    let shape: AnyShape
    let shadow: ShadowConfiguration
    
    public init(_ configuration: ShapeConfiguration, shadow: ShadowConfiguration) {
        self.shape = configuration.shape?.asAnyShape() ?? Rectangle().asAnyShape()
        self.shadow = shadow
    }

    public var body: some View {
        shape.fill(Color(shadow.resolvedColor() ?? .black)).shadow(shadow)
    }
}
#endif
