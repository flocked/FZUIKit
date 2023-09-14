//
//  DashedBorderView.swift
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

/// A view with a dashed border.
public class DashedBorderView: NSUIView {
    internal static let Tag = 435_234_364

    /// The insets of the border.
    public var borderInsets: NSDirectionalEdgeInsets {
        get { borderedLayer.borderInsets }
        set { borderedLayer.borderInsets = newValue }
    }
    
    /// The dash pattern of the border.
    public var borderDashPattern: [CGFloat]? {
        get { borderedLayer.borderDashPattern }
        set { borderedLayer.borderDashPattern = newValue }
    }

    /// THe configuration of the border.
    public var configuration: ContentConfiguration.Border {
        get { borderedLayer.configuration }
        set { borderedLayer.configuration = newValue }
    }
        
    /**
     Initalizes a dashed border view with the specified configuration.
     
     - Parameters configuration: The configuration of the border.
     - Returns: The dashed border view.
     */
    public init(configuration: ContentConfiguration.Border) {
        super.init(frame: .zero)
        self.configuration = configuration
    }

    internal var borderedLayer: DashedBorderLayer {
#if os(macOS)
        self.wantsLayer = true
#endif
        return self.layer as! DashedBorderLayer
    }
    
    #if os(macOS)
    override public func makeBackingLayer() -> CALayer {
        let borderedLayer = DashedBorderLayer()
     //   shadowLayer.zPosition = FLT_MAX
        return borderedLayer
    }

    override public var tag: Int {
        return Self.Tag
    }
    #else
    override public class var layerClass: AnyClass {
        return DashedBorderLayer.self
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
