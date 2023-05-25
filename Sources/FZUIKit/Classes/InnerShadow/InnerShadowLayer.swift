//
//  InnerShadowLayer.swift
//  FZExtensions
//
//  Created by Florian Zand on 16.09.21.
//

import Foundation
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public class InnerShadowLayer: CALayer {
    override public var opacity: Float {
        get { return shadowOpacity }
        set { shadowOpacity = newValue }
    }

    override public init() {
        super.init()
    }

    public init(configuration: ContentConfiguration.Shadow) {
        super.init()
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public var radius: CGFloat {
        get { shadowRadius }
        set { shadowRadius = newValue
            update()
        }
    }

    public var offset: CGSize {
        get { shadowOffset }
        set { shadowOffset = newValue
            update()
        }
    }

    public var color: NSUIColor? {
        get { if let cgColor = shadowColor {
            return NSUIColor(cgColor: cgColor)
        }
        return nil
        }
        set { shadowColor = newValue?.cgColor }
    }

    public var configuration: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: self.color, opacity: CGFloat(self.opacity), radius: self.radius, offset: self.offset) }
        set {
            self.color = newValue.color
            self.opacity = Float(newValue.opacity)
            self.offset = newValue.offset
            self.radius = newValue.radius
        }
    }

    override public var frame: CGRect {
        didSet { update() }
    }

    private func update() {
        if superlayer != nil {
            var path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
            #if os(macOS)
                var innerPart = NSUIBezierPath(rect: bounds).reversed
            #else
                var innerPart = NSUIBezierPath(rect: bounds).reversing()
            #endif
            if cornerRadius != 0.0 {
                path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
                #if os(macOS)
                    innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
                #else
                    innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
                #endif
            }
            path.append(innerPart)
            shadowPath = path.cgPath
            masksToBounds = true

            backgroundColor = .clear
        }
    }

    override public func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        update()
    }

    override public func display() {
        super.display()
        update()
    }
}
