//
//  CATransform3DConvenienceExtensions.swift
//
//
//  Created by Adam Bell on 5/21/20.
//

#if canImport(QuartzCore)

import Foundation
import QuartzCore

// MARK: - Convenience Extensions

public typealias Translation = CGVector3
public typealias Perspective = CGVector4
public typealias Skew = CGVector3

extension CGVector3 {
    var asPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

// Perspective

public extension CGVector4 {
    var m14: CGFloat {
        get { CGFloat(storage[0]) }
        set { storage[0] = Double(newValue) }
    }
    
    var m24: CGFloat {
        get { CGFloat(storage[1]) }
        set { storage[1] = Double(newValue) }
    }
    
    var m34: CGFloat {
        get { CGFloat(storage[2]) }
        set { storage[2] = Double(newValue) }
    }
    
    var m44: CGFloat {
        get { CGFloat(storage[3]) }
        set { storage[3] = Double(newValue) }
    }
    
    init(m14: CGFloat = 0.0, m24: CGFloat = 0.0, m34: CGFloat = 0.0, m44: CGFloat = 1.0) {
        self.init(m14, m24, m34, m44)
    }
    
    init(m14: Double = 0.0, m24: Double = 0.0, m34: Double = 0.0, m44: Double = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m44))
    }
    
    init(m14: Float = 0.0, m24: Float = 0.0, m34: Float = 0.0, m44 _: Float = 1.0) {
        self.init(CGFloat(m14), CGFloat(m24), CGFloat(m34), CGFloat(m34))
    }
}

// Skew

public extension CGVector3 {
    var xy: CGFloat {
        get { CGFloat(storage[0]) }
        set { storage[0] = Double(newValue) }
    }
    
    var xz: CGFloat {
        get { CGFloat(storage[1]) }
        set { storage[1] = Double(newValue) }
    }
    
    var yz: CGFloat {
        get { CGFloat(storage[2]) }
        set { storage[2] = Double(newValue) }
    }
    
    init(xy: CGFloat = 0.0, xz: CGFloat = 0.0, yz: CGFloat = 0.0) {
        self.init(xy, xz, yz)
    }
    
    init(xy: Double = 0.0, xz: Double = 0.0, yz: Double = 0.0) {
        self.init(CGFloat(xy), CGFloat(xz), CGFloat(yz))
    }
    
    init(xy: Float = 0.0, xz: Float = 0.0, yz: Float = 0.0) {
        self.init(CGFloat(xy), CGFloat(xz), CGFloat(yz))
    }
}

#endif
