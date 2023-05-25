//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

#if os(macOS)
/*
import AppKit
import FZSwiftUtils

@available(macOS 12, *)
public extension NSButton {
    struct Configuration: NSContentConfiguration {
        public enum Size {
            case mini
            case small
            case medium
            case large
        }
        
        public enum TitleAlignment {
            /// Align title & subtitle automatically
            case automatic
            /// Align title & subtitle along their leading edges
            case leading
            /// Align title & subtitle to be centered with respect to each other
            case center
            /// Align title & subtitle along their trailing edges
            case trailing
        }
        
        public enum CornerStyle {
            /// The corner radius provided by the background style will be used as is, without adjusting for dynamic type
            case fixed
            /// The corner radius provided by the background style is adjusted based on dynamic type
            case dynamic
            /// Ignore the corner radius provided by the background style and substitute a small system defined corner radius.
            case small
            /// Ignore the corner radius provided by the background style and substitute a medium system defined corner radius.
            case medium
            /// Ignore the corner radius provided by the background style and substitute a large system defined corner radius.
            case large
            /// Ignore the corner radius provided by the background style and always set the corner radius to generate a capsule.
            case capsule
        }
        
        public enum Indicator {
            /// Automatically determine an indicator based on the button's properties.
            case automatic
            /// Don't show any indicator
            case none
            /// Show an indicator appropriate for a popup-style button
            case popup
        }
        
        public static func plain() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func tinted() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func gray() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func filled() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func borderless() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func bordered() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func borderedTinted() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        public static func borderedProminent() -> NSButton.Configuration {
            let configuration = NSButton.Configuration()
            return configuration
        }

        /// The corner style controls how background.cornerRadius is interpreted by the button. Defaults to `.dynamic`.
        public var cornerStyle: NSButton.Configuration.CornerStyle = .medium

        /// Determines the metrics and ideal size of the button. Clients may resize the button arbitrarily regardless of this value.
        public var buttonSize: NSButton.Configuration.Size? = nil

        /// The base color to use for foreground elements. This color may be modified before being passed to a transformer, and finally applied to specific elements. Setting nil will cede full control to the configuration to select a color appropriate to the style.
        public var baseForegroundColor: NSColor? = .controlAccentColor

        /// The base color to use for background elements. This color may be modified before being passed to a transformer, and finally applied to specific elements. Setting nil will cede full control to the configuration to select a color appropriate to the style.
        public var baseBackgroundColor: NSColor? = nil

        public var image: NSImage? = nil

        public var imageColorTransformer: NSConfigurationColorTransformer? = nil

        public var preferredSymbolConfigurationForImage: NSImage.SymbolConfiguration? = nil

        /// Shows an activity indicator in place of an image. Its placement is controlled by the imagePlacement property.
        public var showsActivityIndicator: Bool = false

        public var activityIndicatorColorTransformer: NSConfigurationColorTransformer? = nil

        public var title: String? = nil

        public var attributedTitle: AttributedString? = nil

        public var titleTextAttributesTransformer: NSConfigurationTextAttributesTransformer? = nil

        public var subtitle: String? = nil

        public var attributedSubtitle: AttributedString? = nil

        public var subtitleTextAttributesTransformer: NSConfigurationTextAttributesTransformer? = nil

        public var indicator: NSButton.Configuration.Indicator = .none

        public var indicatorColorTransformer: NSConfigurationColorTransformer? = nil

        /// By default the button's content region is inset from its bounds based on the button's styling properties. The contentInsets are an additional inset applied afterwards.
        public var contentInsets: NSDirectionalEdgeInsets = .zero

        /*
        /// Restore the default content insets.
        public mutating func setDefaultContentInsets()
*/
        
        /// Defaults to Leading, only single edge values (top/leading/bottom/trailing) are supported.
        public var imagePlacement: NSDirectionalRectEdge = .leading

        /// When a button has both image and text content, this value is the padding between the image and the text.
        public var imagePadding: CGFloat = 2.0

        /// When a button has both a title & subtitle, this value is the padding between those titles.
        public var titlePadding: CGFloat = 2.0

        /// The alignment to use for relative layout between title & subtitle.
        public var titleAlignment: NSButton.Configuration.TitleAlignment = .automatic

        /// If the style should automatically update when the button is selected. Default varies by style. Disable to customize selection behavior.
        public var automaticallyUpdateForSelection: Bool = false
        
        public func makeContentView() -> NSView & NSContentView {
            return NSButtonContentView(configuration: self)
        }
        
        public func updated(for state: NSConfigurationState) -> NSButton.Configuration {
            return self
        }
    }
    
    class NSButtonContentView: NSView, NSContentView {
        public var configuration: NSContentConfiguration {
            get { _configuration }
            set {
                if let newValue = newValue as? NSButton.Configuration {
                _configuration = newValue
                }
            }
        }
        
        internal var _configuration: NSButton.Configuration
        
        init(configuration: NSButton.Configuration) {
            self._configuration = configuration
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
 */

#endif
