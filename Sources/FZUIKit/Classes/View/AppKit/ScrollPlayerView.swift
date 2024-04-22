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
    public enum VolumeScrollControl: Double {
        case slow = 0.25
        case normal = 0.5
        case fast = 0.75
        /// The volume can't be modified by scrolling.
        case off = 0.0
    }
    
    /// A value that indicates whether the playback position is controllable by scrolling left & right.
    open var playbackPositionScrollControl: PlaybackPositionScrollControl = .normal
    
    /// Sets the value that indicates whether the playback position is controllable by scrolling left & right.
    @discardableResult
    open func playbackPositionScrollControl(_ playbackPositionScrollControl: PlaybackPositionScrollControl) -> Self {
        set(\.playbackPositionScrollControl, to: playbackPositionScrollControl)
    }

    /// The value that indicates whether the playback position is controllable by scrolling left & right.
    public enum PlaybackPositionScrollControl: Double {
        case slow = 0.1
        case normal = 0.25
        case fast = 0.5
        /// The playback position can't be modified by scrolling.
        case off = 0.0
        var mouse: Double {
            switch self {
            case .slow: return 1
            case .normal: return 2
            case .fast: return 4
            case .off: return 0
            }
        }
    }
    
    var _magnification: CGFloat {
        enclosingScrollView?.magnification ?? (superview as? MediaView)?.enclosingScrollView?.magnification ?? 1.0
    }
    
    open override func scrollWheel(with event: NSEvent) {
        Swift.print("scrollWheel", _magnification == 1.0, player != nil, player?.currentItem != nil, volumeScrollControl != .off, playbackPositionScrollControl != .off)
        if event.modifierFlags.contains(any: [.command, .shift]) || _magnification == 1.0, let player = player, player.currentItem != nil, (volumeScrollControl != .off || playbackPositionScrollControl != .off) {
            let isMouse = event.phase.isEmpty
            let isTrackpadBegan = event.phase.contains(.began)
            let isTrackpadEnd = event.phase.contains(.ended)
            var scrollDirection: NSUIUserInterfaceLayoutOrientation?
            
            if isMouse || isTrackpadBegan {
              if event.scrollingDeltaX != 0 {
                scrollDirection = .horizontal
              } else if event.scrollingDeltaY != 0 {
                scrollDirection = .vertical
              }
            } else if isTrackpadEnd {
              scrollDirection = nil
            }
            let isPrecise = event.hasPreciseScrollingDeltas
            let isNatural = event.isDirectionInvertedFromDevice

            if scrollDirection == .vertical, volumeScrollControl != .off {
                var deltaY = (isPrecise ? Double(event.scrollingDeltaY) : event.scrollingDeltaY.unified * 2)/100.0
                if isNatural {
                    deltaY = -deltaY
                }
                let newVolume = (Double(player.volume) + (isMouse ? deltaY : volumeScrollControl.rawValue * deltaY)).clamped(to: 0...1.0)
                player.volume = Float(newVolume)
            } else if scrollDirection == .horizontal, playbackPositionScrollControl != .off {
                let currentTime = player.currentTimeDuration.seconds
                let duration = player.duration.seconds
                var deltaX = isPrecise ? Double(event.scrollingDeltaX) : event.scrollingDeltaX.unified
                if !isNatural {
                    deltaX = -deltaX
                }
                let seconds = (isMouse ? playbackPositionScrollControl.mouse : playbackPositionScrollControl.rawValue)*deltaX
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
}
#endif
