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

    extension Gradient.Stop: AnimatableProperty {
        public var animatableData: AnimatableArray<Double> {
            let rgba = color.rgbaComponents()
            return [rgba.red, rgba.green, rgba.blue, rgba.red, location]
        }

        public init(_ animatableData: AnimatableArray<Double>) {
            color = NSUIColor(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
            location = animatableData[4]
        }

        public static var zero: Gradient.Stop {
            Gradient.Stop(color: .zero, location: .zero)
        }
    }

    extension Gradient.Point: AnimatableProperty {
        public init(_ animatableData: AnimatableArray<Double>) {
            x = animatableData[0]
            y = animatableData[1]
        }

        public var animatableData: AnimatableArray<Double> {
            [x, y]
        }

        public static var zero: Gradient.Point {
            Gradient.Point(x: 0, y: 0)
        }
    }

    /*
     extension Gradient: AnimatableProperty {
         public var animatableData: AnimatableArray<Double> {
             var animatableData: AnimatableArray<Double> = [Double(type.rawValue), startPoint.x, startPoint.y, endPoint.x, endPoint.y]
             animatableData.append(contentsOf: stops.flatMap({ $0.animatableData.elements }))
             return animatableData
         }

         public init(_ animatableData: AnimatableArray<Double>) {
             self.type = .init(rawValue: Int(animatableData[0])) ?? .linear
             self.startPoint = .init(x: animatableData[1], y: animatableData[2])
             self.endPoint = .init(x: animatableData[3], y: animatableData[4])

             Swift.debugPrint("init gradient 2", animatableData["end"]!.count)
             self.endPoint = .init(x: animatableData["end"]![0], y: animatableData["end"]![1])
             Swift.debugPrint("init gradient 3", animatableData["stops"]!.count)
             if animatableData["stops"]!.isEmpty == false {
                let chunks = animatableData["stops"]!.chunked(size: 5)
                 self.stops = chunks.compactMap({ Stop(AnimatableArray<Double>($0)) })
             } else {
                 self.stops = []
             }
         }

         public static var zero: Gradient {
             Gradient(stops: [])
         }
     }
      */
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
