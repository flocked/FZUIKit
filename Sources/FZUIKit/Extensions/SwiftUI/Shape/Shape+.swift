//
//  Shape+.swift
//
//
//  Created by Florian Zand on 02.10.22.
//

import Foundation
import SwiftUI

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension Shape {
    /// Returns the shape as `AnyShape`.
    func asAnyShape() -> AnyShape {
        return AnyShape(self)
    }
}

public extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
    
    /*
    @ViewBuilder
    func stroke<S>(_ content: S?, lineWidth: CGFloat = 1) -> some View where S : ShapeStyle {
        if let content = content, lineWidth != 0.0 {
            self.stroke(content, lineWidth: lineWidth)
        } else {
            self
        }
    }
    */
}

public extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}
