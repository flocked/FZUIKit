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
        self.sharedInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        self.sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.masksToBounds = true
    }
}

public extension CAGradientLayer {
    var gradient: Gradient {
        get {
            let colors = (self.colors as? [CGColor])?.compactMap({$0.nsUIColor}) ?? []
            let locations = self.locations?.compactMap({CGFloat($0.floatValue)}) ?? []
            let stops = colors.enumerated().compactMap({ Gradient.Stop(color: $0.element, location: locations[$0.offset]) })
            return Gradient(stops: stops, startPoint: .init(startPoint), endPoint: .init(endPoint), type: .init(type))
        }
        set {
            self.masksToBounds = true
            self.colors = newValue.stops.compactMap({$0.color.cgColor})
            self.locations = newValue.stops.compactMap({NSNumber($0.location)})
            self.startPoint = newValue.startPoint.point
            self.endPoint = newValue.endPoint.point
            self.type = newValue.type.gradientLayerType
        }
    }
}

#endif
