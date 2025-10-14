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
        
        /// A Boolean value indicating whether the player is playing.
        public var isPlaying: Bool {
            switch self {
            case .isPlaying: return true
            default: return false
            }
        }
        
        /// A Boolean value indicating whether the player is paused.
        public var isPaused: Bool {
            switch self {
            case .isPaused: return true
            default: return false
            }
        }
        
        /// A Boolean value indicating whether the player is stopped.
        public var isStopped: Bool {
            switch self {
            case .isStopped: return true
            default: return false
            }
        }
        
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
            if currentItem != nil {
                if rate == 0, currentTime() != .zero {
                    return .isPaused
                } else if rate != 0 {
                    return .isPlaying
                }
            }
        }
        return .isStopped
    }
    
    /// The handler that is called when the playback state changes.
    var stateHandler: ((State)->())? {
        get { getAssociatedValue("stateHandler") }
        set {
            setAssociatedValue(newValue, key: "stateHandler")
            if newValue == nil {
                playerObserver = nil
            } else if playerObserver == nil {
                previousState = state
                playerObserver = KeyValueObserver(self)
                playerObserver?.add(\.error) { [weak self] _, error in
                    guard let self = self else { return }
                    self.callStateHandler()
                }
                playerObserver?.add(\.currentItem) { [weak self] _, item in
                    guard let self = self else { return }
                    self.callStateHandler()
                }
                playerObserver?.add(\.rate) { [weak self] old, new in
                    guard let self = self else { return }
                    self.callStateHandler()
                }
            }
        }
    }
    
    private func callStateHandler() {
        guard let stateHandler = stateHandler else { return }
        let state = state
        if state != previousState {
            stateHandler(state)
            previousState = state
        }
    }
    
    internal var playerObserver: KeyValueObserver<AVPlayer>? {
        get { getAssociatedValue("playerObserver") }
        set { setAssociatedValue(newValue, key: "playerObserver") }
    }
    
    internal var previousState: State {
        get { getAssociatedValue("previousState") ?? .isStopped }
        set { setAssociatedValue(newValue, key: "previousState") }
    }

    /// Stops playback of the current item and seeks it to the start.
    func stop() {
        pause()
        seek(to: TimeDuration.zero)
    }

    /**
     Requests that the player seek to a specified percentage.

     - Parameters:
        - percentage: The percentage to which to seek (between `0.0` and `1.0`).
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    func seek(toPercentage percentage: Double, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        guard let currentItem = currentItem else { return }
        let duration = currentItem.duration
        let to: Double = duration.seconds * percentage.clamped(to: 0.0...1.0)
        let time = CMTime(seconds: to)
        seek(to: time, tolerance: tolerance, completionHandler: completionHandler)
    }

    /**
     Requests that the player seek to a specified time.

     - Parameters:
        - time: The time to which to seek.
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    func seek(to time: TimeDuration, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        let time = CMTime(duration: time)
        seek(to: time, tolerance: tolerance, completionHandler: completionHandler)
    }
    
    internal func seek(to time: CMTime, tolerance: TimeDuration?, completionHandler: ((Bool) -> Void)?) {
        if let completionHandler = completionHandler {
            if let tolerance = tolerance?.seconds {
                seek(to: time, toleranceBefore: CMTime(seconds: tolerance / 2.0), toleranceAfter: CMTime(seconds: tolerance / 2.0), completionHandler: completionHandler)
            } else {
                seek(to: time, completionHandler: completionHandler)
            }
        } else {
            if let tolerance = tolerance?.seconds {
                seek(to: time, toleranceBefore: CMTime(seconds: tolerance / 2.0), toleranceAfter: CMTime(seconds: tolerance / 2.0))
            } else {
                seek(to: time)
            }
        }
    }

    /// The remaining time until the player reaches to end.
    var remainingTime: TimeDuration {
        currentItem?.remainingTime ?? .zero
    }

    /// The current playback percentage (between `0` and `1.0`).
    var playbackPercentage: Double {
        get { currentItem?.playbackPercentage ?? .zero }
        set { seek(toPercentage: newValue, tolerance: .zero) }
    }
    
    /// The duration of the current player item.
    var duration: TimeDuration {
        currentItem?.timeDuration ?? .zero
    }
    
    /// The current time of the current player item as `TimeDuration`.
    var currentTimeDuration: TimeDuration {
        get { currentTime().timeDuration }
        set { seek(to: newValue.clamped(max: duration), tolerance: .zero) }
    }

    /// Toggles the playback between play and pause.
    func togglePlayback() {
        if state == .isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    /// A Boolean value indicating whether the player should restart the playing item when it did finished playing.
    var isLooping: Bool {
        get { getAssociatedValue("isLooping", initialValue: false) }
        set {
            guard newValue != isLooping else { return }
            setAssociatedValue(newValue, key: "isLooping")
            setupCurrentItemObservation()
            setupPlaybackEndedObservation()
        }
    }
    
    /// The handlers for the current item of the player.
    struct ItemHandlers {
        /// The handler that is called when the current item did play to the end time.
        public var playedToEnd: ((_ item: AVPlayerItem)->())?
        /// The handler that is called when the current item failed to play to the end time.
        public var failedToPlayToEnd: ((_ item: AVPlayerItem)->())?
        /// The handler that is called when the playback of the current item available.
        public var playbackStalled: ((_ item: AVPlayerItem)->())?
        /// The handler that is called when a new error log for the current item is available.
        public var newErrorLog: ((_ item: AVPlayerItem)->())?
        /// The handler that is called when a new network access log for the current item is available.
        public var newAccessLog: ((_ item: AVPlayerItem)->())?
        /// The handler that is called whenever the status of the current item changes.
        public var status: ((_ item: AVPlayerItem, _ status: AVPlayerItem.Status)->())?

        
        var needsObservation: Bool {
            playedToEnd != nil || failedToPlayToEnd != nil || playbackStalled != nil || newErrorLog != nil || newAccessLog != nil || status != nil
        }
    }
    
    /// The handlers for the current item of the player.
    var itemHandlers: ItemHandlers {
        get { getAssociatedValue("itemHandlers", initialValue: ItemHandlers()) }
        set {
            setAssociatedValue(newValue, key: "itemHandlers")
            setupCurrentItemObservation()
            setupHandlerObservations()
        }
    }
    
    private func setupHandlerObservations() {
        observe(AVPlayerItem.failedToPlayToEndTimeNotification, handler: itemHandlers.failedToPlayToEnd)
        observe(AVPlayerItem.newAccessLogEntryNotification, handler: itemHandlers.newAccessLog)
        observe(AVPlayerItem.newErrorLogEntryNotification, handler: itemHandlers.newErrorLog)
        observe(AVPlayerItem.playbackStalledNotification, handler: itemHandlers.playbackStalled)
        setupPlaybackEndedObservation()
        if let handler = itemHandlers.status, let currentItem = currentItem {
            itemStatusObservation = currentItem.observeChanges(for: \.status) { [weak self] old, new in
                guard self != nil else { return }
                handler(currentItem, new)
            }
        } else {
            itemStatusObservation = nil
        }
    }
    
    private func observe(_ name: Notification.Name, handler: ((_ item: AVPlayerItem)->())?) {
        if let handler = handler, let currentItem = currentItem {
            itemNotificationTokens[name] = .init(name, object: currentItem) { [weak self] notification in
                guard self != nil else { return }
                handler(currentItem)
            }
        } else {
            itemNotificationTokens[name] = nil
        }
    }
    
    private func setupPlaybackEndedObservation() {
        if isLooping || itemHandlers.playedToEnd != nil {
            observe(AVPlayerItem.didPlayToEndTimeNotification) { [weak self] item in
                guard let self = self else { return }
                self.itemHandlers.playedToEnd?(item)
                guard self.isLooping else { return }
                self.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
            }
        } else {
            observe(AVPlayerItem.didPlayToEndTimeNotification, handler: nil)
        }
        actionAtItemEnd = isLooping ? .none : .pause
    }
    
    private var itemNotificationTokens: [Notification.Name : NotificationToken] {
        get { getAssociatedValue("itemNotificationTokens") ?? [:] }
        set { setAssociatedValue(newValue, key: "itemNotificationTokens") }
    }
    
    private func setupCurrentItemObservation() {
        if !itemHandlers.needsObservation && !isLooping {
            currentItemObservation = nil
        } else if currentItemObservation == nil {
            currentItemObservation = observeChanges(for: \.currentItem) { [weak self] old, new in
                guard let self = self else { return }
                self.setupHandlerObservations()
                self.setupPlaybackEndedObservation()
            }
        }
    }
    
    private var currentItemObservation: KeyValueObservation? {
        get { getAssociatedValue("currentItemObservation") }
        set { setAssociatedValue(newValue, key: "currentItemObservation") }
    }
    
    /// The handler that gets changed when the status of the current item changes.
    var itemStatusHandler: ((AVPlayerItem.Status)->())? {
        get { getAssociatedValue("itemStatusHandler") }
        set { setAssociatedValue(newValue, key: "itemStatusHandler")
            if let statusHandler = newValue {
                itemStatusObservation = observeChanges(for: \.currentItem?.status) { old, new in
                    guard old != new, let new = new else { return }
                    statusHandler(new)
                }
            } else {
                itemStatusObservation = nil
            }
        }
    }
    
    private var itemStatusObservation: KeyValueObservation? {
        get { getAssociatedValue("itemStatusObservation") }
        set { setAssociatedValue(newValue, key: "itemStatusObservation") }
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
        get { getAssociatedValue("playerObservation") }
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
            handler(time.timeDuration)
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

