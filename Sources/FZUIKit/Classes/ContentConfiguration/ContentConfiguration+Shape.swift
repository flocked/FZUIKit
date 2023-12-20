//
//  ContentConfiguration+Shape.swift
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

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ContentConfiguration {
    /**
     A configuration that specifies the shape of a view or layer.
     
    `NSView`, `UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Shape)`.
     */
    public struct Shape: Hashable {
        /// The shape.
        public var shape: (any SwiftUI.Shape)? = nil
        
        /// The margins for the shape.
        public var margins: NSDirectionalEdgeInsets = .zero
        
        var name: String? = nil
        
        /**
         A shape configuration with the specified shape and margins.
         
         - Parameters:
            - shape: The shape of the configuration.
            - margins: The margins of the shape.
         */
        public init(shape: (any SwiftUI.Shape)?, margins: NSDirectionalEdgeInsets = .zero) {
            self.shape = shape
            self.margins = margins
        }
                
        init(shape: (any SwiftUI.Shape)?, margins: NSDirectionalEdgeInsets = .zero, name: String? = nil) {
            self.shape = shape
            self.margins = margins
            self.name = name
        }
        
        /**
         A circle shape.
         
         - parameter margins: The margins of the shape.
         */
        public static func circle(margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Circle(), margins: margins, name: "Circle")
        }
        
        /**
         A capsule shape.
         
         - parameter margins: The margins of the shape.
         */
        public static func capsule(margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Capsule(), margins: margins, name: "Capsule")
        }
        
        /**
         A ellipse shape.
         
         - parameter margins: The margins of the shape.
         */
        public static func ellipse(margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.Ellipse(), margins: margins, name: "Ellipse")
        }
                
        /**
         A rounded rectangle shape with the specified corner radius.
         
         - Parameters:
            - cornerRadius: The corner radius of the rectangle.
            - margins: The margins of the shape.
         */
        public static func roundedRectangle(cornerRadius: CGFloat, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.RoundedRectangle(cornerRadius: cornerRadius), margins: margins, name: "RoundedRectangleCornerRadius")
        }
        
        /**
         A rounded rectangle shape with the specified corner size.
         
         - Parameters:
            - cornerSize: The corner size of the rectangle.
            - margins: The margins of the shape.
         */
        public static func roundedRectangle(cornerSize: CGSize, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            Self(shape: SwiftUI.RoundedRectangle(cornerSize: cornerSize), margins: margins, name: "RoundedRectangleCornerSize")
        }
        
        /**
         A star rectangle shape.
         
         - Parameters:
            - points: The number of points of the star. The default value is `5`.
            - rounded: A Boolean value that indicates whether star is rounded. The default value is `false`.
            - margins: The margins of the shape.
         */
        public static func star(points: Int = 5, rounded: Bool = false, margins: NSDirectionalEdgeInsets = .zero) -> Self {
            let name = rounded ? "StarRounded\(points)" : "Star\(points)"
            return Self(shape: Star(points: points, rounded: rounded), margins: margins, name: name)
        }
        
        /// No shape.
        public static var none: Self = Self(shape: nil, name: "None")
        
        public static func == (lhs: FZUIKit.ContentConfiguration.Shape, rhs: FZUIKit.ContentConfiguration.Shape) -> Bool {
            if lhs.name != nil, lhs.name == rhs.name, lhs.margins == rhs.margins {
                return true
            }
            return false
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(margins)
            hasher.combine(name)
        }
    }
}


@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension NSUIView {
    /**
     Configurates shape of the view.
     
     - parameter configuration:The shape configuration.
     */
    func configurate(using configuration: ContentConfiguration.Shape) {
        if configuration.shape != nil {
            if let shapeView = self.mask as? ShapeView {
                shapeView.shape = configuration
            } else {
                let shapeView = ShapeView()
                shapeView.shape = configuration
                shapeView.setupObserver(for: self)
            }
        } else {
            if let shapeView = self.mask as? ShapeView {
                shapeView.removeFromSuperview()
                shapeView.superviewObserver = nil
                self.mask = nil
            }
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
class ShapeView: NSUIView {
    static let tag: Int = 3467355
    
    #if os(macOS)
    override var tag: Int {
        return 3467355
    }
    #endif
    
    var shape: ContentConfiguration.Shape = .none {
        didSet {
            guard oldValue != shape else { return }
            updateShape()
        }
    }
    
    var superviewObserver: NSKeyValueObservation? = nil
    
    lazy var hostingController = NSUIHostingController(rootView: ShapeContentView(configuration: shape))
    
    func setupObserver(for view: NSUIView) {
        superviewObserver = view.observeChanges(for: \.bounds, handler: { [weak self] old, new in
            guard let self = self, old.size != new.size else { return }
            self.frame = new
        })
        view.mask = self
        frame.size = view.bounds.size
    }
    
    override var frame: CGRect {
        didSet {
            guard oldValue != frame else { return }
            layoutShape()
        }
    }
    
    func updateShape() {
        hostingController.rootView = ShapeContentView(configuration: shape)
        setNeedsLayout()
    }
    
    func layoutShape() {
        var newSize = self.bounds.size

        newSize.width -= shape.margins.width
        if newSize.width < 0 {
            newSize.width = 0
        }
        newSize.height -= shape.margins.height
        if newSize.height < 0 {
            newSize.height = 0
        }
        hostingController.view.frame.size = newSize
        imageLayer.frame.size = newSize
        if let superviewFrame = self.superview?.bounds {
            imageLayer.frame.center = superviewFrame.center
        }
        imageLayer.contents = hostingController.view.renderedImage
    }
    
    init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    let imageLayer = CALayer()
    
    func sharedInit() {
        #if canImport(UIKit)
        self.tag = 3467355
        #endif
        self.optionalLayer?.contentsGravity = .resizeAspect
        self.optionalLayer?.addSublayer(imageLayer)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
struct ShapeContentView: View {
    let configuration: ContentConfiguration.Shape
    var shape: AnyShape {
        configuration.shape?.asAnyShape() ?? Rectangle().asAnyShape()
    }
    var body: some View {
        shape.fill(.black)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension CALayer {
    /**
     Configurates shape of the layer.
     
     - parameter configuration:The shape configuration.
     */
    func configurate(using configuration: ContentConfiguration.Shape) {
        if configuration.shape != nil {
            if let shapeView = self.mask as? ShapeLayer {
                shapeView.shape = configuration
            } else {
                let shapeView = ShapeLayer()
                shapeView.shape = configuration
                shapeView.setupObserver(for: self)
            }
        } else {
            if let shapeView = self.mask as? ShapeLayer {
                shapeView.removeFromSuperlayer()
                shapeView.superviewObserver = nil
                self.mask = nil
            }
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
class ShapeLayer: CALayer {
    var shape: ContentConfiguration.Shape = .none {
        didSet {
            guard oldValue != shape else { return }
            updateShape()
        }
    }
    
    var superviewObserver: NSKeyValueObservation? = nil
    
    lazy var hostingController = NSUIHostingController(rootView: ShapeContentView(configuration: shape))
    
    func setupObserver(for layer: CALayer) {
        superviewObserver = layer.observeChanges(for: \.frame, handler: { [weak self] old, new in
            guard let self = self, old.size != new.size else { return }
            self.frame.size = new.size
        })
        layer.mask = self
        frame.size = layer.frame.size
    }
    
    override var frame: CGRect {
        didSet {
            guard oldValue != frame else { return }
            layoutShape()
        }
    }
    
    func updateShape() {
        hostingController.rootView = ShapeContentView(configuration: shape)
        setNeedsLayout()
    }
    
    func layoutShape() {
        var newSize = self.bounds.size

        newSize.width -= shape.margins.width
        if newSize.width < 0 {
            newSize.width = 0
        }
        newSize.height -= shape.margins.height
        if newSize.height < 0 {
            newSize.height = 0
        }
        hostingController.view.frame.size = newSize
        imageLayer.frame.size = newSize
        if let superviewFrame = self.superlayer?.bounds {
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
        #if canImport(UIKit)
        self.tag = 3467355
        #endif
        self.contentsGravity = .resizeAspect
        self.addSublayer(imageLayer)
    }
}

#endif
