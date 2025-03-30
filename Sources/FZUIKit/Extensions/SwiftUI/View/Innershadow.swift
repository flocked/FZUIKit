//
//  Innershadow.swift
//  
//
//  Created by Florian Zand on 30.03.25.
//

import Foundation
import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
/// A view that displays an inner shadow.
public struct InnerShadow<S: Shape>: View {
    let shape: S
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    /**
     Creates a view that displays an inner shadow.
     
     - Parameters:
        - shape: The shape of the inner shadow.
        - color: The color of the inner shadow.
        - radius: The blur radius of the inner shadow.
        - x: An amount to offset the shadow horizontally from the view.
        - y: An amount to offset the shadow vertically from the view.
     */
    public init(shape: S, color: Color = .init(.sRGBLinear, white: 0, opacity: 0.55), radius: CGFloat, x: CGFloat = 0.0, y: CGFloat = 0.0) {
        self.shape = shape
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    /**
     Creates a view that displays an inner shadow.
     
     - Parameters:
        - configuration: The shadow configuration.
        - shape: The shape of the inner shadow.
     */
    public init(_ configuration: ShadowConfiguration, shape: S) {
        self.shape = shape
        self.radius = configuration.radius
        self.x = configuration.offset.x
        self.y = configuration.offset.y
        self.color = configuration.resolvedColor(withOpacity: true)?.swiftUI ?? .clear
    }

    public var body: some View {
        let padding: CGFloat = radius * 2
        color
            .padding(-padding)
            .reverseMask {
                shape
                    .padding(padding)
            }
            .shadow(color: color, radius: radius, x: x, y: y)
            .padding(-padding)
            .clipShape(shape)
            .drawingGroup()
            .allowsHitTesting(false)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Shape {
    /**
     Returns a view that displays an inner shadow for the shape.
     
     - Parameters:
        - color: The color of the inner shadow.
        - radius: The blur radius of the inner shadow.
        - x: An amount to offset the shadow horizontally from the view.
        - y: An amount to offset the shadow vertically from the view.
     */
    func innerShadow(color: Color = .init(.sRGBLinear, white: 0, opacity: 0.55), radius: CGFloat, x: CGFloat = 0.0, y: CGFloat = 0.0) -> some View {
        InnerShadow(shape: self, color: color, radius: radius, x: x, y: y)
    }
}
