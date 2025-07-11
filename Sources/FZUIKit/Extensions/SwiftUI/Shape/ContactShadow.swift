//
//  ContactShadowShape.swift
//
//
//  Created by Florian Zand on 20.12.23.
//

import Foundation
import SwiftUI

/// A contact shadow shape.
public struct ContactShadowShape: Shape, InsettableShape {
    /// The height of the shape.
    public var height: CGFloat = 20.0
    /// The vertical offset of the shape.
    public var distance: CGFloat = 0.0
    
    var inset: CGFloat = 0.0
    
    /**
     Creates a contact shadow shape.
     
     - Parameters:
        - height: The height of the shape.
        - distance: The vertical offset of the shape.
     */
    public init(height: CGFloat = 20.0, distance: CGFloat = 0.0) {
        self.height = height
        self.distance = distance
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        return Path(ellipseIn: CGRect(x: height, y: rect.height - (height * 0.4) + distance, width: rect.width - height * 2, height: height))
    }
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }
    
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(height, distance) }
        set {
            height = newValue.first
            distance = newValue.second
        }
    }
}

extension Shape where Self == ContactShadowShape {
    /**
     Creates a contact shadow shape.
     
     - Parameters:
        - height: The height of the shape.
        - distance: The vertical offset of the shape.
     */
    public static func contactShadow(height: CGFloat = 20.0, distance: CGFloat = 0.0) -> ContactShadowShape {
        ContactShadowShape(height: height, distance: distance)
    }
}
