//
//  AVPlayer+.swift
//  
//
//  Created by Florian Zand on 07.08.22.
//

import AVKit
import Foundation
import FZSwiftUtils

extension AVPlayer {
    /// A Boolean value that indicates whether the player should restart the playing item when it did finished playing.
    public var isLooping: Bool {
        get {
            return getAssociatedValue(key: "_playerIsLooping", object: self, initialValue: false)
        }
        set {
            set(associatedValue: newValue, key: "_playerIsLooping", object: self)
            setupLooping()
        }
    }

    internal var loopNotificationToken: NotificationToken? {
        get {
            return getAssociatedValue(key: "_playerLoopNotificationToken", object: self, initialValue: nil)
        }
        set {
            set(associatedValue: newValue, key: "_playerLoopNotificationToken", object: self)
        }
    }

    internal func setupLooping() {
        if isLooping {
            actionAtItemEnd = .none
            guard loopNotificationToken == nil else { return }
            loopNotificationToken = NotificationCenter.default.observe(name: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { [weak self] notification in
                guard let self = self else { return }
                if let playerItem = notification.object as? AVPlayerItem {
                    if self.isLooping {
                        playerItem.seek(to: CMTime.zero, completionHandler: nil)
                    }
                }
            })
        } else {
            actionAtItemEnd = .pause
            loopNotificationToken = nil
        }
    }
}

public extension AVPlayer {
    /// The state of hte player.
    enum State: String {
        /// The player is playing.
        case isPlaying
        /// The player is paused.
        case isPaused
        /// The player is stopped.
        case isStopped
        /// The player has an error.
        case error
    }

    var state: State {
        if error != nil {
            return .error
        } else {
            if (rate == 0) && currentTime() != .zero {
                return .isPaused
            } else if rate != 0 {
                return .isPlaying
            } else {
                return .isStopped
            }
        }
    }

    /// Stops playback of the current item and seeks it to the start.
    func stop() {
        pause()
        seek(to: TimeDuration.zero)
    }

    /**
     Requests that the player seek to a specified percentage.
     
     - Parameters percentage: The percentage to which to seek.
     */
    func seek(toPercentage percentage: Double) {
        if let currentItem = currentItem {
            let duration = currentItem.duration
            let to: Double = duration.seconds / percentage.clamped(max: 1.0)
            let seekTo = CMTime(seconds: to)
            seek(to: seekTo)
        }
    }

    /**
     Requests that the player seek to a specified time expressed by seconds.
     
     - Parameters duration: The time to which to seek.
     */
    func seek(to time: TimeDuration) {
        let seekTo = CMTime(duration: time)
        seek(to: seekTo)
    }

    /// The remaining time until the player reaches to end.
    var remainingTime: CMTime? {
        if let duration = currentItem?.duration {
            let remainingSeconds = duration.seconds - currentTime().seconds
            return CMTime(seconds: remainingSeconds)
        }
        return nil
    }

    /// The percentage played.
    var currentPercentage: Double? {
        if let duration = currentItem?.duration {
            return currentTime().seconds / duration.seconds
        }
        return nil
    }

    /// Toggles the playback.
    func togglePlayback() {
        if state == .isPlaying {
            pause()
        } else {
            play()
        }
    }
}

public extension AVLayerVideoGravity {
    init?(caLayerContentsGravity: CALayerContentsGravity) {
        switch caLayerContentsGravity {
        case .resizeAspectFill:
            self = .resizeAspectFill
        case .resizeAspect:
            self = .resizeAspect
        case .resize:
            self = .resize
        default:
            return nil
        }
    }
}
