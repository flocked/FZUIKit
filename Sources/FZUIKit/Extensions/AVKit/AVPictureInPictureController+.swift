//
//  AVPictureInPictureController+.swift
//  PipExtension
//
//  Created by Florian Zand on 18.07.26.
//


import AVKit
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension AVPictureInPictureController {
    /// The style of the system Picture in Picture controls.
    public var controlsStyle: ControlsStyle {
        get { ControlsStyle(rawValue: value(forKey: "controlsStyle") ?? 0) ?? .default }
        set { setValue(safely: newValue.rawValue, forKey: "controlsStyle") }
    }
    
    /// The style of the system Picture in Picture controls.
    public enum ControlsStyle: Int, CustomStringConvertible, Hashable, Sendable {
        /// Displays the standard Picture in Picture controls.
        case `default`
        /// Displays a reduced set of Picture in Picture controls.
        case minimal
        /// Hides the Picture in Picture controls.
        case hidden
        
        /// A textual representation of the controls style.
        public var description: String {
            switch self {
            case .default:  "default"
            case .minimal: "minimal"
            case .hidden: "hidden"
            }
        }
    }
}
