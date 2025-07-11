//
//  CurvedShadowShape.swift
//
//
//  Created by Florian Zand on 20.12.23.
//

import Foundation
import SwiftUI

/// A curved shadow shape.
public struct CurvedShadowShape: Shape, InsettableShape {
    /// The radius of the shape.
    public var radius: CGFloat = 5.0
    /// The curve amunt.
    public var curveAmount: CGFloat = 20
    var inset: CGFloat = 0.0

    /**
     Creates a curved shadow shape.
     
     - Parameters:
        - radius: The radius of the shape.
        - curveAmount: The curve amunt.
     */
    public init(radius: CGFloat = 5.0, curveAmount: CGFloat = 20.0) {
        self.radius = radius
        self.curveAmount = curveAmount
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        return Path { path in
            path.move(to: CGPoint(x: radius, y: 0))
            path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
            path.addLine(to: CGPoint(x: rect.width - radius, y: rect.height + curveAmount))
            path.addCurve(to: CGPoint(x: radius, y: rect.height + curveAmount), control1: CGPoint(x: rect.width, y: rect.height - radius), control2: CGPoint(x: 0, y: rect.height - radius))
        }
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(radius, curveAmount) }
        set {
            radius = newValue.first
            curveAmount = newValue.second
        }
    }
}

extension Shape where Self == CurvedShadowShape {
    /**
     Creates a curved shadow shape.
     
     - Parameters:
        - radius: The radius of the shape.
        - curveAmount: The curve amunt.
     */
    public static func curvedShadow(radius: CGFloat = 5.0, curveAmount: CGFloat = 20.0) -> CurvedShadowShape {
        CurvedShadowShape(radius: radius, curveAmount: curveAmount)
    }
}
