//
//  NSButton+ModernConfiguration.swift
//
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 13.0, *)
    public extension NSButton {
        
        /// A configuration that specifies the appearance and behavior of a button and its contents.
        struct AdvanceButtonConfiguration: NSButtonConfiguration, Hashable, NSContentConfiguration {
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
                
                var alignment: HorizontalAlignment {
                    switch self {
                    case .automatic: return .center
                    case .center: return .center
                    case .leading: return .leading
                    case .trailing: return .trailing
                    }
                }
            }

            /**
             Settings that determine the appearance of the button.

             Use this property to control how the button uses the `cornerRadius`.
             */
            public enum CornerStyle: Hashable {
                /// A shape that uses a large system-defined corner radius.
                case large
                /// A shape that uses a medium system-defined corner radius.
                case medium
                /// A shape that uses a small system-defined corner radius.
                case small
                /// A shape that uses the specified corner radius.
                case cornerRadius(CGFloat)
                /// A shape that uses a corner radius that generates a capsule.
                case capsule
                /// A rectangle button shape
                case rectangle
                /// A circular button shape.
                case circular

                var shape: some Shape {
                    switch self {
                    case .capsule: return Capsule().asAnyShape()
                    case .large: return RoundedRectangle(cornerRadius: 10.0).asAnyShape()
                    case .medium: return RoundedRectangle(cornerRadius: 6.0).asAnyShape()
                    case .small: return RoundedRectangle(cornerRadius: 2.0).asAnyShape()
                    case .cornerRadius(let radius): return RoundedRectangle(cornerRadius: radius).asAnyShape()
                    case .circular: return Circle().asAnyShape()
                    case .rectangle: return Rectangle().asAnyShape()
                    }
                }
            }

            /// The text of the title label the button displays.
            public var title: String?

            /// The text and style attributes for the button’s title label.
            public var attributedTitle: NSAttributedString?

            /// The text the subtitle label of the button displays.
            public var subtitle: String?

            /// The text and style attributes for the button’s subtitle label.
            public var attributedSubtitle: NSAttributedString?

            /// The image the button displays.
            public var image: NSImage?

            /// The distance between the button’s image and text.
            public var imagePadding: CGFloat = 4.0

            /// The edge against which the button places the image.
            public var imagePlacement: NSDirectionalRectEdge = .leading

            /// The symbol configuration for the image.
            public var imageSymbolConfiguration: ImageSymbolConfiguration?

            ////  The sound that plays when the user clicks the button.
            public var sound: NSSound?

            /// The width of the stroke.
            public var borderWidth: CGFloat = 0.0
            
            /// A Boolean value that determines whether the button displays its border only when the pointer is over it.
            public var showsBorderOnlyWhileMouseInside: Bool = false

            /*
            /// The outset (or inset, if negative) for the stroke.
            public var borderOutset: CGFloat = 0.0

            /// The color of the border.
            public var borderColor: NSColor? { didSet {
                if oldValue != borderColor {
                    updateResolvedValues()
                }
            } }

            /// The color transformer for resolving the border color.
            var borderColorTransformer: ColorTransformer? { didSet {
                if oldValue != borderColorTransformer {
                    updateResolvedValues()
                }
            } }

            /// Generates the resolved border color, using the border color and color transformer.
            func resolvedBorderColor() -> NSColor? {
                if let borderColor = borderColor {
                    return borderColorTransformer?(borderColor) ?? borderColor
                }
                return nil
            }
             */

            /// The untransformed color for foreground views.
            public var foregroundColor: NSColor? { didSet {
                if oldValue != foregroundColor {
                    updateResolvedValues()
                }
            } }

            /// The color transformer for resolving the foreground color.
            public var foregroundColorTransformer: ColorTransformer? { didSet {
                if oldValue != foregroundColorTransformer {
                    updateResolvedValues()
                }
            } }

            /// Generates the resolved foreground color, using the foreground color and color transformer.
            public func resolvedForegroundColor() -> NSColor? {
                if let foregroundColor = foregroundColor {
                    return foregroundColorTransformer?(foregroundColor) ?? foregroundColor
                }
                return nil
            }

            /// The untransformed color for background views.
            public var backgroundColor: NSColor? { didSet {
                if oldValue != backgroundColor {
                    updateResolvedValues()
                }
            } }

            /// The color transformer for resolving the background color.
            public var backgroundColorTransformer: ColorTransformer? { didSet {
                if oldValue != backgroundColorTransformer {
                    updateResolvedValues()
                }
            } }

            /// Generates the resolved background color, using the background color and color transformer.
            public func resolvedBackgroundColor() -> NSColor? {
                if let backgroundColor = backgroundColor {
                    return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
                }
                return nil
            }

            /// The distance between the title and subtitle labels.
            public var titlePadding: CGFloat = 2.0

            /// The text alignment the button uses to lay out the title and subtitle.
            public var titleAlignment: TitleAlignment = .automatic {
                didSet { if oldValue != titleAlignment {
                    updateResolvedValues()
                } }
            }

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
                        imageSymbolConfiguration: ImageSymbolConfiguration? = nil,
                        sound: NSSound? = nil,
                        borderWidth: CGFloat = 0.0,
                        /*
                        borderOutset: CGFloat = 0.0,
                        borderColor: NSColor? = nil,
                        borderColorTransformer: ColorTransformer? = nil,
                         */
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
                        size: NSControl.ControlSize = .regular)
            {
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
                /*
                self.borderOutset = borderOutset
                self.borderColor = borderColor
                self.borderColorTransformer = borderColorTransformer
                 */
                self.foregroundColor = foregroundColor
                self.backgroundColor = backgroundColor
                self.titlePadding = titlePadding
                self.titleAlignment = titleAlignment
                self.contentInsets = contentInsets
                self.cornerStyle = cornerStyle
                self.opacity = opacity
                self.scaleTransform = scaleTransform
                self.size = size
                updateResolvedValues()
            }

            ///  Creates a configuration for a button with a transparent background.
            public static func plain(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
                var configuration = NSButton.AdvanceButtonConfiguration()
                configuration.foregroundColor = color
                return configuration
            }

            /// Creates a configuration for a button with a gray background.
            public static func gray() -> NSButton.AdvanceButtonConfiguration {
                var configuration = NSButton.AdvanceButtonConfiguration()
                configuration.backgroundColor = .gray.withAlphaComponent(0.5)
                configuration.foregroundColor = .controlAccentColor
                return configuration
            }

            /// Creates a configuration for a button with a tinted background color.
            public static func tinted(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
                var configuration = NSButton.AdvanceButtonConfiguration()
                configuration.backgroundColor = color.tinted().withAlphaComponent(0.5)
                configuration.foregroundColor = color
                return configuration
            }

            /// Creates a configuration for a button with a background filled with the button’s tint color.
            public static func filled(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
                var configuration = NSButton.AdvanceButtonConfiguration()
                configuration.foregroundColor = .white
                configuration.backgroundColor = color
                return configuration
            }

            /// Creates a configuration for a button that has a bordered style.
            public static func bordered(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
                var configuration = NSButton.AdvanceButtonConfiguration()
                configuration.foregroundColor = color
                configuration.borderWidth = 1.0
                return configuration
            }

            var _resolvedTitleAlignment: TitleAlignment = .automatic
            var _resolvedTextAlignment: SwiftUI.TextAlignment = .center

        //    var _resolvedBorderColor: NSColor?
            var _resolvedForegroundColor: NSColor?
            var _resolvedBackgroundColor: NSColor?
            
            var hasTitle: Bool {
                title != nil || attributedTitle != nil
            }
            
            var hasSubtitle: Bool {
                subtitle != nil || attributedSubtitle != nil
            }

            mutating func updateResolvedValues() {
                _resolvedTitleAlignment = resolvedTitleAlignment()
                switch _resolvedTitleAlignment.alignment {
                case .leading:
                    _resolvedTextAlignment = .leading
                case .trailing:
                    _resolvedTextAlignment = .trailing
                default:
                    _resolvedTextAlignment = .center
                }
             //   _resolvedBorderColor = resolvedBorderColor()
                _resolvedForegroundColor = resolvedForegroundColor()
                _resolvedBackgroundColor = resolvedBackgroundColor()

                if let colorConfiguration = imageSymbolConfiguration?.color, var configuration = imageSymbolConfiguration {
                    switch colorConfiguration {
                    case let .palette(primary, secondary, ter):
                        configuration.color = .palette(foregroundColor ?? primary, secondary, ter)
                        imageSymbolConfiguration = configuration
                    case .monochrome: return
                    case let .multicolor(color):
                        configuration.color = .multicolor(foregroundColor ?? color)
                        imageSymbolConfiguration = configuration
                    case let .hierarchical(color):
                        configuration.color = .hierarchical(foregroundColor ?? color)
                        imageSymbolConfiguration = configuration
                    }
                }
            }
            
            public func makeContentView() -> NSView & NSContentView {
                AdvanceButtonView(configuration: self)
            }

            /**
             Returns a copy of the configuration, updated for the given state.

             - Parameter state: A state to use as a basis for the update.
             */
            public func updated(for state: ConfigurationState) -> Self {
                var configuration = self
                if state.isEnabled == false {
                    if let transformer = configuration.foregroundColorTransformer {
                        configuration.foregroundColorTransformer = transformer + .systemEffect(.disabled)
                    } else {
                        configuration.foregroundColorTransformer = .systemEffect(.disabled)
                    }
                    if let transformer = configuration.backgroundColorTransformer {
                        configuration.backgroundColorTransformer = transformer + .systemEffect(.disabled)
                    } else {
                        configuration.backgroundColorTransformer = .systemEffect(.disabled)
                    }
                } else if state.isPressed {
                    if let transformer = configuration.foregroundColorTransformer {
                        configuration.foregroundColorTransformer = transformer + .systemEffect(.pressed)
                    } else {
                        configuration.foregroundColorTransformer = .systemEffect(.pressed)
                    }
                    if let transformer = configuration.backgroundColorTransformer {
                        configuration.backgroundColorTransformer = transformer + .systemEffect(.pressed)
                    } else {
                        if configuration.backgroundColor == nil {
                            configuration.backgroundColor = configuration.foregroundColor?.withAlphaComponent(0.175)
                        } else {
                            configuration.backgroundColorTransformer = .systemEffect(.pressed)
                        }
                    }
                }
                return configuration
            }
            
            

            func resolvedTitleAlignment() -> TitleAlignment {
                if titleAlignment == .automatic {
                    if image != nil {
                        switch imagePlacement {
                        case .leading: return .leading
                        case .trailing: return .trailing
                        default: return .center
                        }
                    }
                    return hasTitle && hasSubtitle ? .leading : .center
                }
                return titleAlignment
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
