//
//  ScrollPlayerView.swift
//  
//
//  Created by Florian Zand on 22.04.24.
//

#if os(macOS)
import AppKit
import AVKit

/// A player view that allows controlling the playback position and volume by scrolling.
open class ScrollPlayerView: AVPlayerView {
    
    /// A value that indicates whether the volume is controllable by scrolling up & down.
    open var volumeScrollControl: VolumeScrollControl = .normal
    
    /// Sets the value that indicates whether the volume is controllable by scrolling up & down.
    @discardableResult
    open func volumeScrollControl(_ volumeScrollControl: VolumeScrollControl) -> Self {
        set(\.volumeScrollControl, to: volumeScrollControl)
    }
    
    /// The value that indicates whether the volume is controllable by scrolling up & down.
    public enum VolumeScrollControl: Int {
        /// Scrolling doesn't change the volume.
        case off = 0
        /// Scrolling changes the volume slowly.
        case slow = 1
        /// Scrolling changes the volume.
        case normal = 2
        /// Scrolling changes the volume fastly.
        case fast = 3
        
        var value: Double {
            [0.0, 0.25, 0.5, 0.75][rawValue]
        }
    }
    
    /// A value that indicates whether the playback position is controllable by scrolling left & right.
    open var playbackPositionScrollControl: PlaybackPositionScrollControl = .normal
    
    /// Sets the value that indicates whether the playback position is controllable by scrolling left & right.
    @discardableResult
    open func playbackPositionScrollControl(_ playbackPositionScrollControl: PlaybackPositionScrollControl) -> Self {
        set(\.playbackPositionScrollControl, to: playbackPositionScrollControl)
    }

    /// The value that indicates whether the playback position is controllable by scrolling left & right.
    public enum PlaybackPositionScrollControl: Int {
        /// Scrolling doesn't change the playback position.
        case off = 0
        /// Scrolling changes the playback position slowly.
        case slow = 1
        /// Scrolling changes the playback position.
        case normal = 2
        /// Scrolling changes the playback position fastly.
        case fast = 3
        
        func value(isMouse: Bool) -> Double {
            (isMouse ? [0, 1, 2, 4] : [0.0, 0.1, 0.25, 0.5])[rawValue]
        }
    }
    
    /// A Boolean value that indicates whether right clicking toggles the playback between play and pause.
    open var togglePlaybackByRightClick: Bool = false
    
    /// Sets the Boolean value that indicates whether right clicking toggles the playback between play and pause.
    @discardableResult
    open func togglePlaybackByRightClick(_ togglePlaybackByRightClick: Bool) -> Self {
        set(\.togglePlaybackByRightClick, to: togglePlaybackByRightClick)
    }
    
    var mediaView: MediaView? {
        superview as? MediaView
    }
    
    var magnifyMediaView: MagnifyMediaView? {
        firstSuperview(for: MagnifyMediaView.self)
    }
    
    var _magnification: CGFloat {
        enclosingScrollView?.magnification ?? mediaView?.enclosingScrollView?.magnification ?? 1.0
    }
    
    var scrollDirection: NSUIUserInterfaceLayoutOrientation?
    var wasPlayingBeforeSeeking: Bool = false
    open override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(any: [.command, .shift]) || _magnification == 1.0, let player = player, player.currentItem != nil, (volumeScrollControl != .off || playbackPositionScrollControl != .off) {
            let isMouse = event.phase.isEmpty
            let isTrackpadBegan = event.phase.contains(.began)
            let isTrackpadEnd = event.phase.contains(.ended)

            // determine direction

            if isMouse || isTrackpadBegan {
              if event.scrollingDeltaX != 0 {
                scrollDirection = .horizontal
              } else if event.scrollingDeltaY != 0 {
                scrollDirection = .vertical
              }
            } else if isTrackpadEnd {
              scrollDirection = nil
            }
            if isTrackpadBegan, scrollDirection == .horizontal, player.state == .isPlaying {
                wasPlayingBeforeSeeking = true
                player.pause()
                // pause player
            } else if isTrackpadEnd, wasPlayingBeforeSeeking {
                player.play()
                wasPlayingBeforeSeeking = false
            }
            
            let isPrecise = event.hasPreciseScrollingDeltas
            let isNatural = event.isDirectionInvertedFromDevice

            var deltaX = isPrecise ? Double(event.scrollingDeltaX) : event.scrollingDeltaX.unified
            var deltaY = isPrecise ? Double(event.scrollingDeltaY) : event.scrollingDeltaY.unified * 2

            if isNatural {
              deltaY = -deltaY
            } else {
              deltaX = -deltaX
            }

            let delta = scrollDirection == .horizontal ? deltaX : deltaY/100.0
            if scrollDirection == .vertical, volumeScrollControl != .off {
              //  let newVolume = player.info.volume + (isMouse ? delta : AppData.volumeMap[volumeScrollAmount] * delta)
                let newVolume = (Double(player.volume) + (isMouse ? delta : volumeScrollControl.value * delta)).clamped(to: 0...1.0)
                mediaView?.willChangeValue(for: \.volume)
                magnifyMediaView?.willChangeValue(for: \.volume)
                player.volume = Float(newVolume)
                mediaView?.didChangeValue(for: \.volume)
                magnifyMediaView?.didChangeValue(for: \.volume)
            } else if scrollDirection == .horizontal, playbackPositionScrollControl != .off {
                let currentTime = player.currentTimeDuration.seconds
                let duration = player.duration.seconds
                let seconds = playbackPositionScrollControl.value(isMouse: isMouse)*delta
                if !player.isLooping {
                    player.currentTimeDuration = .seconds((currentTime + seconds).clamped(to: 0...duration))
                } else {
                    let truncating = (currentTime+seconds).truncatingRemainder(dividingBy: duration)
                    if truncating < 0.0 {
                        player.currentTimeDuration = .seconds(duration-(truncating * -1.0))
                    } else {
                        player.currentTimeDuration = .seconds(truncating)
                    }
                }
            }
        } else {
            super.scrollWheel(with: event)
        }
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        if togglePlaybackByRightClick, menu == nil, let player = player {
            player.togglePlayback()
        } else {
            super.rightMouseDown(with: event)
        }
    }
    
    open override func hitTest(_ point: NSPoint) -> NSView? {
        if volumeScrollControl != .off || playbackPositionScrollControl != .off, NSEvent.current?.type == .scrollWheel {
            return self
        }
        return super.hitTest(point)
    }
}
#endif
