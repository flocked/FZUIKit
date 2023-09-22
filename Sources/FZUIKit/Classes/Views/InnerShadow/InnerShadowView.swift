//
//  InnerShadowView.swift
//  
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A view with an inner shadow.
public class InnerShadowView: NSUIView {
    internal static let Tag = 435_234_364

    /// The opacity of the inner shadow.
    public var innerShadowOpacity: CGFloat {
        get { return CGFloat(innershadowLayer.shadowOpacity) }
        set { innershadowLayer.shadowOpacity = Float(newValue) }
    }

    /// The radius of the inner shadow.
    public var innerShadowRadius: CGFloat {
        get { innershadowLayer.shadowRadius }
        set { innershadowLayer.shadowRadius = newValue }
    }

    /// The offset of the inner shadow.
    public var innerShadowOffset: CGSize {
        get { innershadowLayer.shadowOffset }
        set { innershadowLayer.shadowOffset = newValue }
    }

    /// The color of the inner shadow.
    public var innerShadowColor: NSUIColor? {
        get {
#if os(macOS)
          return innershadowLayer.shadowColor?.nsColor
#elseif canImport(UIKit)
            return innershadowLayer.shadowColor?.uiColor
#endif
        }
        set { innershadowLayer.shadowColor = newValue?.cgColor }
    }

    /// The configuration of the inner shadow.
    public var configuration: ContentConfiguration.InnerShadow {
        get { innershadowLayer.configuration }
        set { innershadowLayer.configuration = newValue }
    }
    
    /*
    public override func layoutSubviews() {
        innershadowLayer.update()
        super.layoutSubviews()
    }
     */
        
    /**
     Initalizes an inner shadow view with the specified configuration.
     
     - Parameters configuration: The configuration of the inner shadow.
     - Returns: The inner shadow view.
     */
    public init(configuration: ContentConfiguration.InnerShadow) {
        super.init(frame: .zero)
        self.configuration = configuration
    }

    internal var innershadowLayer: InnerShadowLayer {
#if os(macOS)
        self.wantsLayer = true
#endif
        return self.layer as! InnerShadowLayer
    }
    
    #if os(macOS)
    override public func makeBackingLayer() -> CALayer {
        let shadowLayer = InnerShadowLayer()
     //   shadowLayer.zPosition = FLT_MAX
        return shadowLayer
    }

    override public var tag: Int {
        return Self.Tag
    }
    #else
    override public class var layerClass: AnyClass {
        return InnerShadowLayer.self
    }
    #endif
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    internal func sharedInit() {
#if canImport(UIKit)
        tag = Self.Tag
    //    layer.zPosition = .greatestFiniteMagnitude
#endif
    }
}
#endif
