//
//  File.swift
//
//
//  Created by Florian Zand on 02.10.22.
//

import Foundation
import SwiftUI

public struct AnyShape: InsettableShape {
    private var base: (CGRect) -> SwiftUI.Path
    private var insetAmount: CGFloat = 0

    public init<S: Shape>(_ shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> SwiftUI.Path {
        base(rect)
    }

    public func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount = amount
        return shape
    }
}

public extension Shape {
    func asAnyShape() -> AnyShape {
        return AnyShape(self)
    }
}

public extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
    
    @ViewBuilder
    func stroke<S>(_ content: S?, lineWidth: CGFloat = 1) -> some View where S : ShapeStyle {
        if let content = content, lineWidth != 0.0 {
            self.stroke(content, lineWidth: lineWidth)
        } else {
            self
        }
    }
}

public extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}
