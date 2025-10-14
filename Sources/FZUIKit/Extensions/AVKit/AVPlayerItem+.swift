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
    /// Handlers for a player item.
    struct Handlers {
        /// The handler that is called when the item did play to the end time.
        public var playedToEnd: (()->())?
        /// The handler that is called when the item failed to play to the end time.
        public var failedToPlayToEnd: (()->())?
        /// The handler that is called when the playback of the item available.
        public var playbackStalled: (()->())?
        /// The handler that is called when a new error log for the item is available.
        public var newErrorLog: (()->())?
        /// The handler that is called when a new network access log for the item is available.
        public var newAccessLog: (()->())?
        /// The handler that gets called whenever the status of the item changes.
        public var status: ((Status)->())?
    }
    
    /// The handlers of the item.
    var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            observe(AVPlayerItem.failedToPlayToEndTimeNotification, handler: handlers.failedToPlayToEnd)
            observe(AVPlayerItem.newAccessLogEntryNotification, handler: handlers.newAccessLog)
            observe(AVPlayerItem.newErrorLogEntryNotification, handler: handlers.newErrorLog)
            observe(AVPlayerItem.playbackStalledNotification, handler: handlers.playbackStalled)
            if let handler = handlers.status {
                statusObservation = observeChanges(for: \.status) { old, new in
                    handler(new)
                }
            } else {
                statusObservation = nil
            }
        }
    }
    
    private func observe(_ name: Notification.Name, handler: (()->())?) {
        if let handler = handler {
            handlerNotificationTokens[name] = .init(name, object: self) { [weak self] notification in
                guard self != nil else { return }
                handler()
            }
        } else {
            handlerNotificationTokens[name] = nil
        }
    }
    
    private var handlerNotificationTokens: [Notification.Name : NotificationToken] {
        get { getAssociatedValue("handlerNotificationTokens") ?? [:] }
        set { setAssociatedValue(newValue, key: "handlerNotificationTokens") }
    }
    
    /// The current playback percentage (between `0.0` and `1.0`).
    var playbackPercentage: Double {
        get { currentTime().seconds / duration.seconds }
        set { seek(toPercentage: newValue.clamped(to: 0...1.0)) }
    }
    
    private var statusObservation: KeyValueObservation? {
        get { getAssociatedValue("statusObservation") }
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
            - finished: A Boolean value indicating whether the seek operation completed.
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
            - finished: A Boolean value indicating whether the seek operation completed.
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
    
    /// The player of the item.
    var player: AVPlayer? {
        value(forKeySafely: "_player") as? AVPlayer
    }
}
