//
//  NSButton+ModernConfiguration.swift
//  
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI
import FZSwiftUtils

@available(macOS 13.0, *)
public extension NSButton {
    /// A configuration that specifies the appearance and behavior of a button and its contents.
    struct ModernConfiguration: NSButtonConfiguration, Hashable {
        /**
         Specifies how to align a button’s title and subtitle.
         
         If your button displays both ``title`` and ``subtitle``, use this enumeration to configure how the text aligns.
         */
        public enum TitleAlignment: Hashable {
            /// Aligns the title and subtitle based on other elements in the button configuration, like an image or activity indicator.
            case automatic
            /// Aligns the title and subtitle on their horizontal centers.
            case center
            /// Aligns the title and subtitle on their leading edges.
            case leading
            /// Aligns the title and subtitle on their trailing edges.
            case trailing
            internal var alignment: HorizontalAlignment {
                switch self {
                case .automatic: return .center
                case .center: return .center
                case .leading: return .leading
                case .trailing: return .trailing
                }
            }
        }
        
        /**
         Settings that determine the appearance of the background corner radius.
         
         Use this property to control how the button uses the `cornerRadius` property of the button’s background`.
         */
        public enum CornerStyle: Hashable {
            /// A style that adjusts the background corner radius for dynamic type.
            case dynamic
            /// A style that uses the background corner radius without modification.
            case fixed
            /// A style that ignores the background corner radius and uses a corner radius that generates a capsule.
            case capsule
            /// A style that ignores the background corner radius and uses a large system-defined corner radius.
            case large
            /// A style that ignores the background corner radius and uses a medium system-defined corner radius.
            case medium
            /// A style that ignores the background corner radius and uses a small system-defined corner radius.
            case small
            
            internal var shape: some Shape {
                switch self {
                case .dynamic: return Rectangle().asAnyShape()
                case .fixed: return Rectangle().asAnyShape()
                case .capsule: return Capsule().asAnyShape()
                case .large:   return RoundedRectangle(cornerRadius: 10.0).asAnyShape()
                case .medium:   return RoundedRectangle(cornerRadius: 6.0).asAnyShape()
                case .small:  return RoundedRectangle(cornerRadius: 2.0).asAnyShape()
                }
            }
        }
        
        /// The text of the title label the button displays.
        public var title: String? = nil
        
        /// The text and style attributes for the button’s title label.
        public var attributedTitle: NSAttributedString? = nil
        
        /// The text the subtitle label of the button displays.
        public var subtitle: String? = nil
        
        /// The text and style attributes for the button’s subtitle label.
        public var attributedSubtitle: NSAttributedString? = nil
        
        /// The image the button displays.
        public var image: NSImage? = nil
        
        /// The distance between the button’s image and text.
        public var imagePadding: CGFloat = 4.0
        
        /// The edge against which the button places the image.
        public var imagePlacement: NSDirectionalRectEdge = .leading
        
        /// The symbol configuration for the image.
        public var imageSymbolConfiguration: ContentConfiguration.SymbolConfiguration? = nil
        
        ////  The sound that plays when the user clicks the button.
        public var sound: NSSound? = nil
        
        /// The width of the stroke.
        public var borderWidth: CGFloat = 0.0
        
        /// The outset (or inset, if negative) for the stroke.
        public var borderOutset: CGFloat = 0.0
        
        /// The color of the border.
        public var borderColor: NSColor? = nil { didSet {
            if oldValue != self.borderColor {
                updateResolvedValues()
            } } }
        
        /// The color transformer for resolving the border color.
        var borderColorTransformer: ColorTransformer? = nil  { didSet {
            if oldValue != self.borderColorTransformer {
                updateResolvedValues()
            } } }
        
        /// Generates the resolved border color, using the border color and color transformer.
        func resolvedBorderColor() -> NSColor? {
            if let borderColor = borderColor {
                return borderColorTransformer?(borderColor) ?? borderColor
            }
            return nil
        }
        
        /// The untransformed color for foreground views.
        public var foregroundColor: NSColor? = nil { didSet {
            if oldValue != self.foregroundColor {
                updateResolvedValues()
            } } }
        
        /// The untransformed color for background views.
        public var backgroundColor: NSColor? = nil { didSet {
            if oldValue != self.backgroundColor {
                updateResolvedValues()
            } } }
        
        /// The distance between the title and subtitle labels.
        public var titlePadding: CGFloat = 2.0
        
        /// The text alignment the button uses to lay out the title and subtitle.
        public var titleAlignment: TitleAlignment = .automatic {
            didSet { if oldValue != self.titleAlignment {
                updateResolvedValues() } } }
        
        /// The distance from the button’s content area to its bounds.
        public var contentInsets: NSDirectionalEdgeInsets = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0)
        
        /// The button style that controls the display behavior of the background corner radius.
        public var cornerStyle: CornerStyle = .medium
        
        /// The opacity of the button.
        public var opacity: CGFloat = 1.0
        
        /// The scale transform of the button.
        public var scaleTransform: CGFloat = 1.0
        
        /// The size of the button.
        public var size: NSControl.ControlSize = .regular
        
        ///  Creates a button configuration.
        public init(title: String? = nil,
                    attributedTitle: NSAttributedString? = nil,
                    subtitle: String? = nil,
                    attributedSubtitle: NSAttributedString? = nil,
                    image: NSImage? = nil,
                    imagePadding: CGFloat = 4.0,
                    imagePlacement: NSDirectionalRectEdge = .leading,
                    imageSymbolConfiguration: ContentConfiguration.SymbolConfiguration? = nil,
                    sound: NSSound? = nil,
                    borderWidth: CGFloat = 0.0,
                    borderOutset: CGFloat = 0.0,
                    borderColor: NSColor? = nil,
                    borderColorTransformer: ColorTransformer? = nil,
                    foregroundColor: NSColor? = nil,
                    backgroundColor: NSColor? = nil,
                    titlePadding: CGFloat = 2.0,
                    titleAlignment: TitleAlignment = .automatic,
                    contentInsets: NSDirectionalEdgeInsets = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0),
                    cornerStyle: CornerStyle = .medium,
               //     indicator: Indicator = .automatic,
               //     showsActivityIndicator: Bool = false,
                    opacity: CGFloat = 1.0,
                    scaleTransform: CGFloat = 1.0,
                    size: NSControl.ControlSize = .regular) {
            self.title = title
            self.attributedTitle = attributedTitle
            self.subtitle = subtitle
            self.attributedSubtitle = attributedSubtitle
            self.image = image
            self.imagePadding = imagePadding
            self.imagePlacement = imagePlacement
            self.imageSymbolConfiguration = imageSymbolConfiguration
            self.sound = sound
            self.borderWidth = borderWidth
            self.borderOutset = borderOutset
            self.borderColor = borderColor
            self.borderColorTransformer = borderColorTransformer
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.titlePadding = titlePadding
            self.titleAlignment = titleAlignment
            self.contentInsets = contentInsets
            self.cornerStyle = cornerStyle
            self.opacity = opacity
            self.scaleTransform = scaleTransform
            self.size = size
            self.updateResolvedValues()
        }
        
        ///  Creates a configuration for a button with a transparent background.
        public static func plain(color: NSColor = .controlAccentColor) -> NSButton.ModernConfiguration {
            var configuration = NSButton.ModernConfiguration()
            configuration.foregroundColor = color
            return configuration
        }
        
        /// Creates a configuration for a button with a gray background.
        public static func gray() -> NSButton.ModernConfiguration {
            var configuration = NSButton.ModernConfiguration()
            configuration.backgroundColor = .gray.withAlphaComponent(0.5)
            configuration.foregroundColor = .controlAccentColor
            return configuration
        }
        
        /// Creates a configuration for a button with a tinted background color.
        public static func tinted(color: NSColor = .controlAccentColor) -> NSButton.ModernConfiguration {
            var configuration = NSButton.ModernConfiguration()
            configuration.backgroundColor = color.tinted().withAlphaComponent(0.5)
            configuration.foregroundColor = color
            return configuration
        }
        
        /// Creates a configuration for a button with a background filled with the button’s tint color.
        public static func filled(color: NSColor = .controlAccentColor) -> NSButton.ModernConfiguration {
            var configuration = NSButton.ModernConfiguration()
            configuration.foregroundColor = .white
            configuration.backgroundColor = color
            return configuration
        }
        
        /// Creates a configuration for a button that has a bordered style.
        public static func bordered(color: NSColor = .controlAccentColor) -> NSButton.ModernConfiguration {
            var configuration = NSButton.ModernConfiguration()
            configuration.foregroundColor = color
            configuration.borderWidth = 1.0
            return configuration
        }
        
        internal var _resolvedTitleAlignment: TitleAlignment = .automatic
        internal var _resolvedBorderColor: NSColor? = nil
        
        internal mutating func updateResolvedValues() {
            _resolvedTitleAlignment = resolvedTitleAlignment()
            _resolvedBorderColor = resolvedBorderColor()
            if let colorConfiguration = self.imageSymbolConfiguration?.color {
                switch colorConfiguration {
                case .palette(let primary, let secondary, let ter):
                    self.imageSymbolConfiguration?.color = .palette(foregroundColor ?? primary, secondary, ter)
                case .monochrome: return
                case .multicolor(let color):
                    self.imageSymbolConfiguration?.color = .multicolor(foregroundColor ?? color)
                case .hierarchical(let color):
                    self.imageSymbolConfiguration?.color = .hierarchical(foregroundColor ?? color)
                }
            }
        }
        
        internal func resolvedTitleAlignment() -> TitleAlignment {
            if (self.titleAlignment == .automatic) {
                if image != nil {
                    if (self.imagePlacement == .leading) {
                        return .leading
                    } else if (self.imagePlacement == .trailing) {
                        return .trailing
                    } else {
                        return .center
                    }
                }
                return .leading
            }
            return self.titleAlignment
        }
    }
}
#endif

/*
public enum Indicator: Hashable {
    case automatic
    case none
    case popup
}

//     public var indicator: Indicator = .automatic
 //    public var showsActivityIndicator: Bool = false
 */
