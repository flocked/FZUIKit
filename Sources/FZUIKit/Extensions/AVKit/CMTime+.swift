//
//  CMTime+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreMedia
import Foundation
import FZSwiftUtils

public extension CMTime {
    /// Creates a time that represents number of seconds.
    init(seconds: Double) {
        self = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1.0))
    }

    /// Creates a time that represents the duration.
    init(duration: TimeDuration) {
        self = CMTime(seconds: duration.seconds, preferredTimescale: CMTimeScale(1.0))
    }
    
    static func + (lhs: Self, rhs: TimeDuration) -> Self {
        CMTime(seconds: lhs.seconds + rhs.seconds)
    }
    
    static func += (lhs: inout Self, rhs: TimeDuration) {
        lhs = lhs + rhs
    }
}

extension TimeDuration {
    /**
     Initializes a new time duration from a `CMTime`.

     - Parameter time: The time.
     */
    public init(time: CMTime) {
        self.init(time.seconds)
    }
}


extension CMTime: Codable {
    public enum CodingKeys: CodingKey {
        case value
        case timescale
        case flags
        case epoch
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(timescale, forKey: .timescale)
        try container.encode(flags, forKey: .flags)
        try container.encode(epoch, forKey: .epoch)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Int64.self, forKey: .value)
        let timescale = try container.decode(Int32.self, forKey: .timescale)
        let flags = try container.decode(CMTimeFlags.self, forKey: .flags)
        let epoch = try container.decode(Int64.self, forKey: .epoch)
        self.init(value: value, timescale: timescale, flags: flags, epoch: epoch)
    }
}

extension CMTimeFlags: Codable { }

extension CMTimeRange: Codable {
    public enum CodingKeys: CodingKey {
        case start
        case duration
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        start = try values.decode(CMTime.self, forKey: .start)
        duration = try values.decode(CMTime.self, forKey: .duration)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(duration, forKey: .duration)
    }
}
