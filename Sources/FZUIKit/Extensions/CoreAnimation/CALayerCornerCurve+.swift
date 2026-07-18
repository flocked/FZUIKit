//
//  CALayerCornerCurve+.swift
//  FZUIKit
//
//  Created by Florian Zand on 17.07.26.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
import QuartzCore.CoreAnimation

extension CALayerCornerCurve: Swift.CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

#endif
