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
        struct AdvanceConfiguration: NSButtonConfiguration, Hashable, NSContentConfiguration {
            /**
             Specifies how to align a button’s title and subtitle.

             If your button displays both ``title`` and ``subtitle``, use this enumeration to configure how the text aligns.
             */
            public enum TitleAlignment: Int, Hashable {
                /// Aligns the title and subtitle based on other elements in the button configuration, like an image or activity indicator.
                case automatic
                /// Aligns the title and subtitle on their horizontal centers.
                case center
                /// Aligns the title and subtitle on their leading edges.
                case leading
                /// Aligns the title and subtitle on their trailing edges.
                case trailing
                
                var textAlignment: TextAlignment {
                    switch self {
                    case .leading: return .leading
                    case .trailing: return .trailing
                    default: return .center
                    }
                }
                
                var alignment: HorizontalAlignment {
                    switch self {
                    case .leading: return .leading
                    case .trailing: return .trailing
                    default: return .center
                    }
                }
            }

            /// The shape of the button.
            public enum Shape: Hashable {
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

                var swiftUI: some SwiftUI.Shape {
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
            public var title: String? {
                didSet { 
                    if title != nil { attributedTitle = nil }
                }
            }

            /// The text and style attributes for the button’s title label.
            public var attributedTitle: NSAttributedString? {
                didSet { 
                    if attributedTitle != nil { title = nil }
                }
            }

            /// The text the subtitle label of the button displays.
            public var subtitle: String? {
                didSet { 
                    if subtitle != nil { attributedSubtitle = nil }
                }
            }

            /// The text and style attributes for the button’s subtitle label.
            public var attributedSubtitle: NSAttributedString? {
                didSet { 
                    if attributedSubtitle != nil { subtitle = nil }
                }
            }

            /// The image the button displays.
            public var image: NSImage?

            /// The distance between the button’s image and text.
            public var imagePadding: CGFloat = 4.0

            /// The edge against which the button places the image.
            public var imagePosition: NSDirectionalRectEdge = .leading

            /// The symbol configuration for the image.
            public var imageSymbolConfiguration: ImageSymbolConfiguration?

            ////  The sound that plays when the user clicks the button.
            public var sound: NSSound?

            /// The width of the stroke.
            public var borderWidth: CGFloat = 0.0
            
            /// A Boolean value that determines whether the button displays its border only when the pointer is over it.
            public var showsBorderOnlyWhileMouseInside: Bool = false
            
            /// The size of the button.
            public var size: NSControl.ControlSize = .regular

            /// The untransformed color for foreground views.
            public var foregroundColor: NSColor?

            /// The color transformer for resolving the foreground color.
            public var foregroundColorTransformer: ColorTransformer?

            /// Generates the resolved foreground color, using the foreground color and color transformer.
            public func resolvedForegroundColor() -> NSColor? {
                if let foregroundColor = foregroundColor {
                    return foregroundColorTransformer?(foregroundColor) ?? foregroundColor
                }
                return nil
            }

            /// The untransformed color for background views.
            public var backgroundColor: NSColor?

            /// The color transformer for resolving the background color.
            public var backgroundColorTransformer: ColorTransformer?

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
            public var titleAlignment: TitleAlignment = .automatic

            /// The distance from the button’s content area to its bounds.
            public var contentInsets: NSDirectionalEdgeInsets = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0)

            /// The shape of the button.
            public var shape: Shape = .medium

            /// The opacity of the button.
            public var opacity: CGFloat = 1.0

            /// The scale transform of the button.
            public var scaleTransform: CGFloat = 1.0

            /// Creates a button configuration.
            public init() { }

            ///  Creates a configuration for a button with a transparent background.
            public static func plain(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
                var configuration = NSButton.AdvanceConfiguration()
                configuration.foregroundColor = color
                return configuration
            }

            /// Creates a configuration for a button with a gray background.
            public static func gray() -> NSButton.AdvanceConfiguration {
                var configuration = NSButton.AdvanceConfiguration()
                configuration.backgroundColor = .gray.withAlphaComponent(0.5)
                configuration.foregroundColor = .controlAccentColor
                return configuration
            }

            /// Creates a configuration for a button with a tinted background color.
            public static func tinted(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
                var configuration = NSButton.AdvanceConfiguration()
                configuration.backgroundColor = color.tinted().withAlphaComponent(0.5)
                configuration.foregroundColor = color
                return configuration
            }

            /// Creates a configuration for a button with a background filled with the button’s tint color.
            public static func filled(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
                var configuration = NSButton.AdvanceConfiguration()
                configuration.foregroundColor = .white
                configuration.backgroundColor = color
                return configuration
            }

            /// Creates a configuration for a button that has a bordered style.
            public static func bordered(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
                var configuration = NSButton.AdvanceConfiguration()
                configuration.foregroundColor = color
                configuration.borderWidth = 1.0
                return configuration
            }
            
            var hasTitle: Bool {
                title != nil || attributedTitle != nil
            }
            
            var hasSubtitle: Bool {
                subtitle != nil || attributedSubtitle != nil
            }
            
            func resolvedTitleAlignment() -> TitleAlignment {
                if titleAlignment == .automatic {
                    if image != nil {
                        switch imagePosition {
                        case .leading:  return .leading
                        case .trailing: return .trailing
                        default: return .center
                        }
                    } else {
                        return hasTitle || hasSubtitle ? .leading : .center
                    }
                }
                return titleAlignment
            }
                        
            func resolvedSymbolConfiguration() -> ImageSymbolConfiguration? {
                guard var configuration = imageSymbolConfiguration, let foregroundColor = resolvedForegroundColor() else { return nil }
                configuration.color?.colors[safe: 0] = foregroundColor
                return configuration
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
                if !state.isEnabled || state.isPressed {
                    let systemEffect = ColorTransformer.systemEffect(state.isPressed ? .pressed : .disabled)
                    if let transformer = configuration.foregroundColorTransformer {
                        configuration.foregroundColorTransformer = transformer + systemEffect
                    } else {
                        configuration.foregroundColorTransformer = systemEffect
                    }
                    if state.isPressed, configuration.backgroundColor == nil {
                        configuration.backgroundColor = configuration.foregroundColor?.withAlphaComponent(0.175)
                    }
                    if let transformer = configuration.backgroundColorTransformer {
                        configuration.backgroundColorTransformer = transformer + systemEffect
                    } else {
                        configuration.backgroundColorTransformer = systemEffect
                    }
                }
                return configuration
            }
        }
    }
#endif
