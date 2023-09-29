//
//  GradientView.swift
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

/// A view that displays a gradient.
public class GradientView: NSUIView {
    /// The gradient.
    public var gradient: Gradient {
        get { gradientLayer.gradient }
        set { gradientLayer.gradient = newValue }
    }
            
    /**
     Initalizes an inner shadow view with the specified configuration.
     
     - Parameters configuration: The configuration of the inner shadow.
     - Returns: The inner shadow view.
     */
    public init(gradient: Gradient) {
        super.init(frame: .zero)
        self.gradient = gradient
    }

    internal var gradientLayer: GradientLayer {
#if os(macOS)
        self.wantsLayer = true
#endif
        return self.layer as! GradientLayer
    }
    
    #if os(macOS)
    override public func makeBackingLayer() -> CALayer {
        let gradientLayer = GradientLayer()
        return gradientLayer
    }
    #else
    override public class var layerClass: AnyClass {
        return GradientLayer.self
    }
    #endif
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
