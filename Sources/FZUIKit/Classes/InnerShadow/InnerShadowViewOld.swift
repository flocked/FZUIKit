//
//  InnerShadowView.swift
//  FZExtensions
//
//  Created by Florian Zand on 03.09.22.
//

/*
#if os(macOS)
import AppKit

public class InnerShadowView: NSView {
    static let Tag = 435_234_364

    public var shadowOpacity: CGFloat {
        get { return CGFloat(innershadowLayer.shadowOpacity) }
        set { innershadowLayer.shadowOpacity = Float(newValue) }
    }

    public var shadowRadius: CGFloat {
        get { innershadowLayer.shadowRadius }
        set { innershadowLayer.shadowRadius = newValue }
    }

    public var shadowOffset: CGSize {
        get { innershadowLayer.offset }
        set { innershadowLayer.offset = newValue }
    }

    public var shadowColor: NSColor? {
        get { innershadowLayer.color }
        set { innershadowLayer.color = newValue }
    }

    public var configuration: ContentConfiguration.Shadow {
        get { innershadowLayer.configuration }
        set { innershadowLayer.configuration = newValue }
    }

    internal lazy var innershadowLayer: InnerShadowLayer = {
        self.wantsLayer = true
        let shadowLayer: InnerShadowLayer
        if let sLayer = self.layer as? InnerShadowLayer {
            shadowLayer = sLayer
        } else {
            shadowLayer = InnerShadowLayer()
            self.layer = shadowLayer
        }
        self.layer?.zPosition = .greatestFiniteMagnitude
        return shadowLayer
    }()

    override public func makeBackingLayer() -> CALayer {
        let shadowLayer = InnerShadowLayer()
        return shadowLayer
    }

    override public var tag: Int {
        return Self.Tag
    }
}

#elseif canImport(UIKit)
import UIKit
public class InnerShadowView: UIView {
    static let Tag = 435_234_364

    public var shadowOpacity: CGFloat {
        get { return CGFloat(innershadowLayer.shadowOpacity) }
        set { innershadowLayer.shadowOpacity = Float(newValue) }
    }

    public var shadowRadius: CGFloat {
        get { innershadowLayer.shadowRadius }
        set { innershadowLayer.shadowRadius = newValue }
    }

    public var shadowOffset: CGSize {
        get { innershadowLayer.offset }
        set { innershadowLayer.offset = newValue }
    }

    public var shadowColor: NSUIColor? {
        get { innershadowLayer.color }
        set { innershadowLayer.color = newValue }
    }

    public var configuration: ContentConfiguration.Shadow {
        get { innershadowLayer.configuration }
        set { innershadowLayer.configuration = newValue }
    }

    internal var innershadowLayer: InnerShadowLayer {
        return self.layer as! InnerShadowLayer
    }

    override public class var layerClass: AnyClass { return InnerShadowLayer.self }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        tag = Self.Tag
        layer.zPosition = .greatestFiniteMagnitude
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        tag = Self.Tag
        layer.zPosition = .greatestFiniteMagnitude
    }
}
#endif
*/
