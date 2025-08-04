//
//  NSContentUnavailableConfiguration+ButtonConfiguration.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

@available(macOS 12.0, *)
public extension NSContentUnavailableConfiguration {
    /// Properties to configure buttons for a content-unavailable view.
    struct ButtonConfiguration: Hashable {
        
        /// The style of the button.
        public enum ButtonType: Hashable {
            /// A standard push style button.
            case push
            /// A push button with a flexible height to accommodate longer text labels or an image.
            case flexiblePush
            /// A button style that’s appropriate for a toolbar item.
            case toolbar
            /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
            case accessoryBar
            /// A button style that you use for extra actions in an accessory toolbar.
            case accessoryBarAction
            /// A button style suitable for displaying additional information.
            case badge
            /// A round button that can contain either a single character or an icon.
            case circular
            /// A simple square bezel style that can scale to any size.
            case smallSquare
            /// A checkbox button.
            case checkBox
            /// A radio button.
            case help
            
            var buttonType: NSButton.ButtonType {
                switch self {
                case .accessoryBar: return .pushOnPushOff
                case .checkBox: return .switch
                default: return .momentaryPushIn
                }
            }
            
            var bezel: NSButton.BezelStyle {
                switch self {
                case .push: return .rounded
                case .flexiblePush: return .regularSquare
                case .toolbar: return .texturedRounded
                case .accessoryBar: return .recessed
                case .accessoryBarAction: return .roundRect
                case .badge: return .inline
                case .circular: return .circular
                case .smallSquare: return .smallSquare
                case .help: return .helpButton
                default: return .rounded
                }
            }
        }
                
        /// The title.
        public var title: String? {
            didSet {
                guard title != nil else { return }
                atributedTitle = nil
            }
        }
        
        /// The attributed title.
        public var atributedTitle: AttributedString? {
            didSet {
                guard atributedTitle != nil else { return }
                atributedTitle = nil
            }
        }
        
        /// The image.
        public var image: NSImage?
        
        /// The action of the button.
        public var action: (() -> Void)?
        
        /// A Boolean value indicating whether the button is enabled.
        public var isEnabled: Bool = true
        
        /// The state of the button.
        public var state: NSControl.StateValue = .on
        
        /// The size of the button.
        public var size: NSControl.ControlSize = .regular
        
        /// The tint color.
        public var tintColor: NSColor?
        
        /// The color transformer of the tint color.
        public var tintColorTransformer: ColorTransformer?
        
        ///  Generates the resolved tint color, using the tint color and color transformer.
        public func resolvedTintColor() -> NSColor? {
            guard let color = tintColor else { return nil }
            return tintColorTransformer?(color) ?? color
        }
        
        /// The button type..
        public var type: ButtonType = .push
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: ImageSymbolConfiguration?
        
        public init() {
            
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(atributedTitle)
            hasher.combine(image)
            hasher.combine(type)
            hasher.combine(size)
            hasher.combine(tintColor)
            hasher.combine(tintColorTransformer)
            hasher.combine(symbolConfiguration)
            hasher.combine(isEnabled)
        }
    }
}

#endif
