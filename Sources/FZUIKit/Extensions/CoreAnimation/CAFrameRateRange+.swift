//
//  CAFrameRateRange+.swift
//  
//
//  Created by Florian Zand on 15.12.23.
//

#if canImport(QuartzCore)
import QuartzCore

@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
extension CAFrameRateRange {
    public init(_ range: ClosedRange<Float>) {
        self = .init(minimum: range.lowerBound, maximum: range.upperBound)
    }
}

#endif
