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

    public extension CAGradientLayer {
        var gradient: Gradient {
            get {
                let colors = (colors as? [CGColor])?.compactMap(\.nsUIColor) ?? []
                let locations = locations?.compactMap { CGFloat($0.floatValue) } ?? []
                let stops = colors.enumerated().compactMap { Gradient.Stop(color: $0.element, location: locations[$0.offset]) }
                return Gradient(stops: stops, startPoint: .init(startPoint), endPoint: .init(endPoint), type: .init(type))
            }
            set {
                masksToBounds = true
                colors = newValue.stops.compactMap(\.color.cgColor)
                locations = newValue.stops.compactMap { NSNumber($0.location) }
                startPoint = newValue.startPoint.point
                endPoint = newValue.endPoint.point
                type = newValue.type.gradientLayerType
            }
        }
    }

#endif
