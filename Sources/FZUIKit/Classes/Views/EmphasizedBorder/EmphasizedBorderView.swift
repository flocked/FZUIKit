//
//  EmphasizedBorderView.swift
//
//
//  Created by Florian Zand on 03.09.22.
//


#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A view that with a emphasized border.
public class EmphasizedBorderView: NSUIView {
    internal static let Tag = 435_234_364_445

    internal var borderedLayer: EmphasizedBorderLayer {
        #if os(macOS)
        self.wantsLayer = true
        #endif
        return self.layer as! EmphasizedBorderLayer
    }
    
    #if os(macOS)
    override public func makeBackingLayer() -> CALayer {
        let borderedLayer = EmphasizedBorderLayer()
        return borderedLayer
    }

    override public var tag: Int {
        return Self.Tag
    }
    #else
    override public class var layerClass: AnyClass {
        return EmphasizedBorderLayer.self
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
        #endif
    }
}

