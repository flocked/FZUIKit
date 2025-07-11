//
//  FlatLongShadowShape.swift
//
//
//  Created by Florian Zand on 20.12.23.
//

import Foundation
import SwiftUI

/// A flat long shadow shape.
public struct FlatLongShadowShape: Shape, InsettableShape {
    /// The horizontal offset of the shape.
    public var offset: CGFloat = 2000.0
    /// A Boolean value indicating whether to use an alternative shape style.
    public var alternative: Bool = false
    
    var inset: CGFloat = 0.0

    /**
     Creates a flat long shape.
     
     - Parameters:
        - offset: The horizontal offset of the shape.
        - alternative: A Boolean value indicating whether to use an alternative shape style.
     */
    public init(offset: CGFloat = 2000.0, alternative: Bool = false) {
        self.offset = offset
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        return Path { path in
            if !alternative {
                path.move(to: CGPoint(x: 0, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width + offset, y: 2000))
                path.addLine(to: CGPoint(x: offset, y: 2000))
            } else {
                path.move(to: CGPoint(x: 0, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width, y: 0))
                path.addLine(to: CGPoint(x: rect.width + offset, y: 2000))
                path.addLine(to: CGPoint(x: offset, y: 2000))
            }
        }
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
}

extension Shape where Self == FlatLongShadowShape {
    /**
     Creates a flat long shape.
     
     - Parameters:
        - offset: The horizontal offset of the shape.
        - alternative: A Boolean value indicating whether to use an alternative shape style.
     */
    public static func flatLongShadow(offset: CGFloat = 2000.0, alternative: Bool = false) -> FlatLongShadowShape {
        FlatLongShadowShape(offset: offset, alternative: alternative)
    }
}
