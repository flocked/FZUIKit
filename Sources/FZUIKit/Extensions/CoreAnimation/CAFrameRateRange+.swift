//
//  CAFrameRateRange+.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
import QuartzCore

public extension CAFrameRateRange {
    init(_ range: ClosedRange<Float>,  preferred: Float? = nil) {
        self = .init(minimum: range.lowerBound, maximum: range.upperBound, preferred: preferred)
    }
}

#endif
