//
//  EmphasizedBorderView.swift
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

    /// A view that with an emphasized border.
    public class EmphasizedBorderView: NSUIView {
        static let Tag = 435_234_364_445

        var borderedLayer: EmphasizedBorderLayer {
            return optionalLayer as! EmphasizedBorderLayer
        }

        #if os(macOS)
        override public func makeBackingLayer() -> CALayer {
            EmphasizedBorderLayer()
        }

        override public var tag: Int {
            Self.Tag
        }
        #else
        override public class var layerClass: AnyClass {
            EmphasizedBorderLayer.self
        }
        #endif

        override public init(frame: CGRect) {
            super.init(frame: frame)
            sharedInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        func sharedInit() {
            #if canImport(UIKit)
            tag = Self.Tag
            #endif
        }
    }
#endif
