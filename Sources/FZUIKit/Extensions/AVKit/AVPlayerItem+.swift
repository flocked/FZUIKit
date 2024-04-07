//
//  AVPlayerItem+.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

import AVFoundation
import Foundation
import FZSwiftUtils

public extension AVPlayerItem {
    /// Returns the current playback time as percentage.
    var playbackPercentage: Double {
        currentTime().seconds / duration.seconds
    }
    
    /// The remaining time until the item reaches to end.
    var remainingTime: CMTime? {
        let remainingSeconds = duration.seconds - currentTime().seconds
        return CMTime(seconds: remainingSeconds)
    }
    
    /**
     Sets the current playback time to the specified percentage.

     - Parameters
        - percentage: The percentage to which to seek.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(toPercentage percentage: Double, completionHandler: ((Bool) -> Void)? = nil) {
        let to: Double = duration.seconds * percentage.clamped(to: 0.0...1.0)
        let seekTo = CMTime(seconds: to)
        seek(to: seekTo, completionHandler: completionHandler)
    }
    
    /**
     Sets the current playback time to the specified time.

     - Parameters:
        - time: The time to which to seek.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(to time: TimeDuration, completionHandler: ((Bool) -> Void)? = nil) {
        let seekTo = CMTime(seconds: time.seconds.clamped(to: 0...duration.seconds))
        seek(to: seekTo, completionHandler: completionHandler)
    }
}
