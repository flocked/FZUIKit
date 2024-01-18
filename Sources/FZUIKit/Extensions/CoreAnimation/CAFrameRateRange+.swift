//
//  CAFrameRateRange+.swift
//
//
//  Created by Florian Zand on 15.12.23.
//

#if canImport(QuartzCore)
    import QuartzCore

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
    public extension CAFrameRateRange {
        init(_ range: ClosedRange<Float>,  preferred: Float? = nil) {
            self = .init(minimum: range.lowerBound, maximum: range.upperBound, preferred: preferred)
        }
    }

#endif
