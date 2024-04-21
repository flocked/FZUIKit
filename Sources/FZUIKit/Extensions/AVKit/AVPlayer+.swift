//
//  AVPlayer+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import AVFoundation
import Foundation
import FZSwiftUtils

public extension AVPlayer {
    
    /// The playback state of the player.
    enum State: Hashable, CustomStringConvertible {
        /// The player is playing.
        case isPlaying
        /// The player is paused.
        case isPaused
        /// The player is stopped.
        case isStopped
        /// The player has an error.
        case error(Error)
        
        public var description: String {
            switch self {
            case .isPlaying: return "playing"
            case .isPaused: return "paused"
            case .isStopped: return "stopped"
            case .error(let error):  return "error: \(error.localizedDescription)"
            }
        }

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
        guard let currentItem = currentItem else { return }
        let duration = currentItem.duration
        let to: Double = duration.seconds * percentage.clamped(to: 0.0...1.0)
        let seekTo = CMTime(seconds: to)
        if let completionHandler = completionHandler {
            seek(to: seekTo, completionHandler: completionHandler)
        } else {
            seek(to: seekTo)
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
    var remainingTime: TimeDuration {
        currentItem?.remainingTime ?? .zero
    }

    /// The current playback percentage (between `0` and `1.0`).
    var playbackPercentage: Double {
        get { currentItem?.playbackPercentage ?? .zero }
        set { seek(toPercentage: newValue) }
    }
    
    /// The duration of the current player item.
    var duration: TimeDuration {
        currentItem?.timeDuration ?? .zero
    }
    
    /// The current time of the current player item as `TimeDuration`.
    var currentTimeDuration: TimeDuration {
        get { TimeDuration(time: currentTime()) }
        set { seek(to: newValue.clamped(max: duration)) }
    }

    /// Toggles the playback between play and pause.
    func togglePlayback() {
        if state == .isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// A Boolean value that indicates whether the player should restart the playing item when it did finished playing.
    var isLooping: Bool {
        get { getAssociatedValue("isLooping", initialValue: false) }
        set {
            guard newValue != isLooping else { return }
            setAssociatedValue(newValue, key: "isLooping")
            if newValue {
                actionAtItemEnd = .none
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

    internal var loopNotificationToken: NotificationToken? {
        get { getAssociatedValue("loopNotificationToken", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "loopNotificationToken") }
    }
}

extension AVPlayer {
    /// Playback option when loading a new item.
    public enum ItemPlaybackOption: Int, Hashable {
        /// New items start automatically,
        case autostart
        /// New items keep the playback state of the previous item.
        case previousPlaybackState
        /// New items are paused.
        case pause
    }
    
    /// Playback option when loading a new item.
    public var playbackOption: ItemPlaybackOption {
        get { getAssociatedValue("videoPlaybackOption", initialValue: .pause) }
        set { 
            guard newValue != playbackOption else { return }
            setAssociatedValue(newValue, key: "videoPlaybackOption")
            if newValue == .pause {
                playerObservation = nil
            } else if playerObservation == nil {
                playerObservation = .init(self)
                playerObservation?.addWillChange(\.currentItem) { [weak self] old in
                    guard let self = self, old != nil else { return }
                    self.previousItemState = self.state
                }
                playerObservation?.add(\.currentItem) { [weak self] old, new in
                    guard let self = self, new != nil else { return }
                    switch self.playbackOption {
                    case .autostart:
                        self.play()
                    case .previousPlaybackState:
                        switch self.previousItemState {
                        case .isPlaying: self.play()
                        default: self.pause()
                        }
                    case .pause:
                        self.pause()
                    }
                }
            }
        }
    }
    
    var previousItemState: AVPlayer.State {
        get { getAssociatedValue("previousItemState", initialValue: state) }
        set { setAssociatedValue(newValue, key: "previousItemState") }
    }
    
    var playerObservation: KeyValueObserver<AVPlayer>? {
        get { getAssociatedValue("playerObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "playerObservation") }
    }
    
    /**
     Observes the playback time and calls the specified handler.
     
     - Parameters:
        - interval: The time interval at which the system invokes the handler during normal playback, according to progress of the player’s current time.
        - queue: The dispatch queue on which the system calls the block.
        - handler: The handler that the system periodically invokes:
            - time: The time at which the system invokes the block.
          
     Example usage:
     
     ```swift
     let observation = player.addPlaybackObserver(timeInterval: 0.1) { time in
        // handle playback
    }
     ```
     
     To stop the observation, either call ``invalidate()```, or deinitalize the object.
     */
    public func addPlaybackObserver(timeInterval: TimeInterval, queue: dispatch_queue_t = .main, handler: @escaping (_ time: TimeDuration)->()) -> AVPlayerTimeObservation {
        AVPlayerTimeObservation(self, interval: timeInterval, queue: queue, handler: handler)
    }
}

/**
 An object that observes the playback time of an `AVPlayer`.
 
 To observe the value of a property that is key-value compatible, use  ``AVFoundation/AVPlayer/addPlaybackObserver(timeInterval:queue:handler:)``.
 
 ```swift
 let observation = player.addPlaybackObserver(timeInterval: 0.1) { time in
    // handle playback
}
 ```
 To stop the observation, either call ``invalidate()```, or deinitalize the object.
 */
public class AVPlayerTimeObservation {
    weak var player: AVPlayer?
    var observer: Any?
    
    init (_ player: AVPlayer, interval: TimeInterval, queue: dispatch_queue_t?,  handler: @escaping (TimeDuration)->()) {
        self.player = player
        self.observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: interval), queue: queue) { time in
            handler(TimeDuration(time: time))
        }
    }
    
    ///  A Boolean value indicating whether the observation is active.
    public var isObserving: Bool {
        observer != nil
    }
    
    /// Invalidates the observation.
    public func invalidate() {
        guard let observer = observer else { return }
        player?.removeTimeObserver(observer)
        self.observer = nil
    }
    
    deinit {
        invalidate()
    }
}

