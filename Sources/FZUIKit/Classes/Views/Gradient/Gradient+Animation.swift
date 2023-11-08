//
//  Gradient+Animation.swift
//  
//
//  Created by Florian Zand on 13.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension Gradient.Stop: AnimatableData {
    public var animatableData: AnimatableVector {
        let rgba = self.color.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.red, location]
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.color = NSUIColor(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
        self.location = animatableData[4]
    }
    
    public static var zero: Gradient.Stop {
        Gradient.Stop(color: .zero, location: .zero)
    }
}

extension Gradient.Point: AnimatableData {
    public var animatableData: AnimatableVector {
        [x, y]
    }
    
    public static var zero: Gradient.Point {
        Gradient.Point(x: 0, y: 0)
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.x = animatableData[0]
        self.y = animatableData[1]
    }
}

extension Gradient: AnimatableData {
    public var animatableData: AnimatableVector {
        var animatableData = [Double(type.rawValue)] + startPoint.animatableData + endPoint.animatableData
        animatableData = animatableData + self.stops.flatMap({$0.animatableData})
        return animatableData
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.type = .init(rawValue: Int(animatableData[0])) ?? .linear
        self.startPoint = .init(x: animatableData[1], y: animatableData[2])
        self.endPoint = .init(x: animatableData[3], y: animatableData[4])
        if animatableData.count > 4 {
            let chunks = Array(animatableData[safe: 5..<animatableData.count]).chunked(size: 5)
            self.stops = chunks.compactMap({ Stop(AnimatableVector($0)) })
        }
    }
    
    public static var zero: Gradient {
        Gradient(stops: [])
    }
}
 
/*
extension PropertyAnimator where Object: GradientView {
    /// The gradient of the view.
    public var gradient: Gradient {
        get { value(for: \.gradient, key: "gradient") }
        set { setValue(newValue, for: \.gradient, key: "gradient") }
    }
}
*/
#endif
