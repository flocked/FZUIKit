//
//  GradientLayer.swift
//
//
//  Created by Florian Zand on 16.09.21.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public class GradientLayer: CAGradientLayer {
        public convenience init(gradient: Gradient) {
            self.init()
            self.gradient = gradient
        }

        override init() {
            super.init()
            sharedInit()
        }

        override init(layer: Any) {
            super.init(layer: layer)
            sharedInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        private func sharedInit() {
            masksToBounds = true
        }
    }

#endif
