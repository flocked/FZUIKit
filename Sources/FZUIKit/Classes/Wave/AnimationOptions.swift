//
//  AnimationOptions.swift
//  
//
//  Created by Florian Zand on 17.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation

/// Options for animations.
public struct AnimationOptions: OptionSet, Sendable {
    public let rawValue: UInt
    
    /// When the animation finishes the value will be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public static let integralizeValues = AnimationOptions(rawValue: 1 << 0)
    
    /// The animation repeats indefinitely.
    public static let repeats = AnimationOptions(rawValue: 1 << 1)
    
    /// The animation automatically starts when it's `target` value changes to a value that isn't equal to `value`.
    public static let autoStarts = AnimationOptions(rawValue: 1 << 2)
    
    #if os(iOS) || os(tvOS)
    /// Prevents the user to interact with views while they are being animated.
    public static let preventUserInteraction = AnimationOptions(rawValue: 1 << 3)
    #endif

    /// Creates a structure that represents animation options.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

#endif
