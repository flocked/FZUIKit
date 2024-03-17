//
//  AVPlayer+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import AVFoundation
import Foundation
import FZSwiftUtils

extension AVPlayer {
    /// A Boolean value that indicates whether the player should restart the playing item when it did finished playing.
    public var isLooping: Bool {
        get { getAssociatedValue("isLooping", initialValue: false) }
        set {
            guard newValue != isLooping else { return }
            setAssociatedValue(newValue, key: "isLooping")
            setupLooping()
        }
    }

    var loopNotificationToken: NotificationToken? {
        get { getAssociatedValue("loopNotificationToken", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "loopNotificationToken") }
    }

    func setupLooping() {
        if isLooping {
            actionAtItemEnd = .none
            guard loopNotificationToken == nil else { return }
            loopNotificationToken = NotificationCenter.default.observe(.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { [weak self] notification in
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
    /// The playback state of the player.
    enum State: Hashable {
        /// The player is playing.
        case isPlaying
        /// The player is paused.
        case isPaused
        /// The player is stopped.
        case isStopped
        /// The player has an error.
        case error(Error)

        public static func == (lhs: AVPlayer.State, rhs: AVPlayer.State) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .isPlaying:
                hasher.combine(0)
            case .isPaused:
                hasher.combine(2)
            case .isStopped:
                hasher.combine(3)
            case .error:
                hasher.combine(4)
            }
        }
    }

    /// The current playback state.
    var state: State {
        if let error = error {
            return .error(error)
        } else {
            if rate == 0, currentTime() != .zero {
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

     - Parameters:
        - percentage: The percentage to which to seek.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(toPercentage percentage: Double, completionHandler: ((Bool) -> Void)? = nil) {
        if let currentItem = currentItem {
            let duration = currentItem.duration
            let to: Double = duration.seconds * percentage.clamped(max: 1.0)
            let seekTo = CMTime(seconds: to)
            if let completionHandler = completionHandler {
                seek(to: seekTo, completionHandler: completionHandler)
            } else {
                seek(to: seekTo)
            }
        }
    }

    /**
     Requests that the player seek to a specified time.

     - Parameters:
        - time: The time to which to seek.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value that indicates whether the seek operation completed.
     */
    func seek(to time: TimeDuration, completionHandler: ((Bool) -> Void)? = nil) {
        let seekTo = CMTime(duration: time)
        if let completionHandler = completionHandler {
            seek(to: seekTo, completionHandler: completionHandler)
        } else {
            seek(to: seekTo)
        }
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

    /// Toggles the playback between play and pause.
    func togglePlayback() {
        if state == .isPlaying {
            pause()
        } else {
            play()
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
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
        
        #if os(macOS)
        internal init?(imageScaling: ImageView.ImageScaling) {
            switch imageScaling {
            case .scaleToFill:
                self = .resizeAspectFill
            case .scaleToFit:
                self = .resizeAspect
            case .resize:
                self = .resize
            default:
                return nil
            }
        }
        #endif
    }

#endif
