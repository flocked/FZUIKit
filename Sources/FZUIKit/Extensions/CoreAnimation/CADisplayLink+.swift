//
//  File.swift
//  
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(macOS 14.0, iOS 3.1, tvOS 9.0, *)
public extension CADisplayLink {
    /// The frame rate of the display link.
    var framesPerSecond: Double {
        1 / (targetTimestamp - timestamp)
    }
    
    /// The frame duration.
    var frameDuration: Double {
        targetTimestamp - timestamp
    }
}

#endif
