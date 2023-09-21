//
//  AVPlayerItem+.swift
//  
//
//  Created by Florian Zand on 21.09.23.
//

import Foundation
import FZSwiftUtils
import AVFoundation


public extension AVPlayerItem {
    /// Returns the current playback time as percentage.
    var playbackPercentage: Double {
        self.currentTime().seconds / self.duration.seconds
    }
    
    /**
     Sets the current playback time to the specified percentage.
     
     - Parameters
        - percentage: The percentage to which to seek.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted.
     */
    func seek(toPercentage percentage: Double, completionHandler: ((Bool) -> Void)? = nil) {
        let to: Double = duration.seconds / percentage.clamped(max: 1.0)
        let seekTo = CMTime(seconds: to)
        seek(to: seekTo, completionHandler: completionHandler)
    }
}
