//
//  AVPlayerItem+.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

import AVFoundation
import Foundation
import FZSwiftUtils
import Combine

public extension AVPlayerItem {
    /// The current playback percentage (between `0.0` and `1.0`).
    var playbackPercentage: Double {
        get { currentTime().seconds / duration.seconds }
        set { seek(toPercentage: newValue.clamped(to: 0...1.0)) }
    }
    
    /// The handler that gets changed when the status of the item changes.
    var statusHandler: ((Status)->())? {
        get { getAssociatedValue("statusHandler", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "statusHandler")
            if let statusHandler = newValue {
                statusObservation = publisher(for: \.status).sink { status in
                    statusHandler(status)
                }
            } else {
                statusObservation = nil
            }
        }
    }
    
    internal var statusObservation: AnyCancellable? {
        get { getAssociatedValue("statusObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "statusObservation") }
    }
    
    /// The duration of the item as `TimeDuration`.
    var timeDuration: TimeDuration {
        duration.timeDuration
    }
    
    /// The current time of the item as `TimeDuration`.
    var currentTimeDuration: TimeDuration {
        get { currentTime().timeDuration }
        set { seek(to: newValue.clamped(max: timeDuration)) }
    }
    
    /// The remaining time until the item reaches to end.
    var remainingTime: TimeDuration {
        timeDuration - currentTimeDuration
    }
    
    /**
     Sets the current playback time to the specified percentage.

     - Parameters
        - percentage: The percentage to which to seek (between `0.0` and `1.0`).
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(toPercentage percentage: Double, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        let to: Double = duration.seconds * percentage.clamped(to: 0.0...1.0)
        let time = CMTime(seconds: to)
        seek(to: time, tolerance: tolerance, completionHandler: completionHandler)
    }
    
    /**
     Sets the current playback time to the specified time.

     - Parameters:
        - time: The time to which to seek.
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(to time: TimeDuration, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        let time = CMTime(seconds: time.seconds.clamped(to: 0...duration.seconds))
        seek(to: time, tolerance: tolerance, completionHandler: completionHandler)
    }
    
    internal func seek(to time: CMTime, tolerance: TimeDuration?, completionHandler: ((Bool) -> Void)?) {
        if let tolerance = tolerance?.seconds {
            seek(to: time, toleranceBefore: CMTime(seconds: tolerance / 2.0), toleranceAfter: CMTime(seconds: tolerance / 2.0), completionHandler: completionHandler)
        } else {
            seek(to: time, completionHandler: completionHandler)
        }
    }
}
