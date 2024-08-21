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
                
                var textAlignment: SwiftUI.TextAlignment {
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
                    if title != nil {
                        attributedTitle = nil
                    }
                    updateResolvedTitleAlignment()
                }
            }

            /// The text and style attributes for the button’s title label.
            public var attributedTitle: NSAttributedString? {
                didSet { 
                    if attributedTitle != nil {
                        title = nil
                    }
                    updateResolvedTitleAlignment()
                }
            }

            /// The text the subtitle label of the button displays.
            public var subtitle: String? {
                didSet { 
                    if subtitle != nil {
                        attributedSubtitle = nil
                    }
                    updateResolvedTitleAlignment()
                }
            }

            /// The text and style attributes for the button’s subtitle label.
            public var attributedSubtitle: NSAttributedString? {
                didSet { 
                    if attributedSubtitle != nil {
                        subtitle = nil
                    }
                    updateResolvedTitleAlignment()
                }
            }

            /// The image the button displays.
            public var image: NSImage? {
                didSet { updateResolvedTitleAlignment() }
            }

            /// The distance between the button’s image and text.
            public var imagePadding: CGFloat = 4.0

            /// The edge against which the button places the image.
            public var imagePlacement: NSDirectionalRectEdge = .leading
            
            var imageAlignment:  VerticalAlignment {
                imagePlacement == .leading || imagePlacement == .trailing ? .center : .bottom
            }

            /// The symbol configuration for the image.
            public var imageSymbolConfiguration: ImageSymbolConfiguration? {
                didSet {
                    guard imageSymbolConfiguration != oldValue else { return }
                    updateResolvedColors()
                }
            }

            ////  The sound that plays when the user clicks the button.
            public var sound: NSSound?

            /// The width of the stroke.
            public var borderWidth: CGFloat = 0.0
            
            /// A Boolean value that determines whether the button displays its border only when the pointer is over it.
            public var showsBorderOnlyWhileMouseInside: Bool = false
            
            /// The size of the button.
            public var size: NSControl.ControlSize = .regular

            /// The untransformed color for foreground views.
            public var foregroundColor: NSColor? { 
                didSet {
                    guard oldValue != foregroundColor else { return }
                    updateResolvedColors()
                }
            }

            /// The color transformer for resolving the foreground color.
            public var foregroundColorTransformer: ColorTransformer? { 
                didSet {
                    guard oldValue != foregroundColorTransformer else { return }
                    updateResolvedColors()
                }
            }

            /// Generates the resolved foreground color, using the foreground color and color transformer.
            public func resolvedForegroundColor() -> NSColor? {
                if let foregroundColor = foregroundColor {
                    return foregroundColorTransformer?(foregroundColor) ?? foregroundColor
                }
                return nil
            }

            /// The untransformed color for background views.
            public var backgroundColor: NSColor? { 
                didSet {
                    guard oldValue != backgroundColor else { return }
                    updateResolvedColors()
                }
            }

            /// The color transformer for resolving the background color.
            public var backgroundColorTransformer: ColorTransformer? { 
                didSet {
                    guard oldValue != backgroundColorTransformer else { return }
                    updateResolvedColors()
                }
            }

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
                didSet { 
                    guard oldValue != titleAlignment else { return }
                    updateResolvedTitleAlignment()
                }
            }

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
            
            var hasTitle: Bool {
                title != nil || attributedTitle != nil
            }
            
            var hasSubtitle: Bool {
                subtitle != nil || attributedSubtitle != nil
            }
            
            mutating func updateResolvedTitleAlignment() {
                if titleAlignment == .automatic {
                    if image != nil {
                        switch imagePlacement {
                        case .leading: _TitleAlignment = .leading
                        case .trailing: _TitleAlignment = .trailing
                        default: _TitleAlignment = .center
                        }
                    }
                    _TitleAlignment = hasTitle && hasSubtitle ? .leading : .center
                }
                _TitleAlignment = titleAlignment
            }
            
            var _TitleAlignment: TitleAlignment = .automatic
            var resolvedImageSymbolConfiguration: ImageSymbolConfiguration?
            
            mutating func updateResolvedColors() {
                resolvedImageSymbolConfiguration = imageSymbolConfiguration
                if let colorConfiguration = imageSymbolConfiguration?.color, var configuration = imageSymbolConfiguration {
                    switch colorConfiguration {
                    case let .palette(primary, secondary, ter):
                        configuration.color = .palette(foregroundColor ?? primary, secondary, ter)
                        resolvedImageSymbolConfiguration = configuration
                    case .monochrome: return
                    case let .multicolor(color):
                        configuration.color = .multicolor(foregroundColor ?? color)
                        resolvedImageSymbolConfiguration = configuration
                    case let .hierarchical(color):
                        configuration.color = .hierarchical(foregroundColor ?? color)
                        resolvedImageSymbolConfiguration = configuration
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
