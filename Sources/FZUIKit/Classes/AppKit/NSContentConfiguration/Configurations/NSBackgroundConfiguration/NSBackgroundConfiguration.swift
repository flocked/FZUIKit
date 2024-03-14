//
//  NSBackgroundConfiguration.swift
//
//
//  Created by Florian Zand on 08.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    /**
     A content configuration suitable for backgrounds.

     ```swift
     var configuration = NSBackgroundConfiguration()

     // Customize appearance.
     configuration.backgroundColor = .controlAccentColor
     configuration.cornerRadius = 6.0
     configuration.shadow = .black
     configuration.imageProperties.tintColor = .purple

     collectionItem.backgroundConfiguration = configuration
     ```
     */
    public struct NSBackgroundConfiguration: NSContentConfiguration, Hashable {
        /// The background color
        public var color: NSColor? {
            didSet {
                if color != oldValue {
                    updateResolvedColors()
                }
            }
        }

        /// The color transformer of the background color.
        public var colorTransformer: ColorTransformer? {
            didSet {
                if colorTransformer != oldValue {
                    updateResolvedColors()
                }
            }
        }

        ///  Generates the resolved background color for the specified background color, using the color and color transformer.
        public func resolvedColor() -> NSColor? {
            if let color = color {
                return colorTransformer?(color) ?? color
            }
            return nil
        }

        /// The background image.
        public var image: NSImage?
        /// The scaling of the background image.
        public var imageScaling: ImageView.ImageScaling = .none

        /// The background view.
        public var view: NSView?

        /// Properties for configuring the border.
        public var border: BorderConfiguration = .none() {
            didSet {
                if border != oldValue {
                    updateResolvedColors()
                }
            }
        }

        /// Properties for configuring the shadow.
        public var shadow: ShadowConfiguration = .none() {
            didSet {
                if shadow != oldValue {
                    updateResolvedColors()
                }
            }
        }

        /// Properties for configuring the inner shadow.
        public var innerShadow: ShadowConfiguration = .none() {
            didSet {
                if innerShadow != oldValue {
                    updateResolvedColors()
                }
            }
        }

        /// Properties for configuring the background visual effect.
        public var visualEffect: VisualEffectConfiguration?

        /// The corner radius.
        public var cornerRadius: CGFloat = 0.0

        /// The rounded corners.
        public var roundedCorners: CACornerMask = .all
        /// The insets (or outsets, if negative) for the background and border, relative to the edges of the containing view.
        public var insets: NSDirectionalEdgeInsets = .zero

        /// Creates an empty background configuration with a transparent background and no default styling.
        public static func clear() -> NSBackgroundConfiguration { NSBackgroundConfiguration() }

        /// Creates a background configuration.
        public init() {}
        
        public func makeContentView() -> NSView & NSContentView {
            NSBackgroundView(configuration: self)
        }

        public func updated(for state: NSConfigurationState) -> NSBackgroundConfiguration {
            var configuration = self
            if let isItemState = state["isItemState"] as? Bool, isItemState, let isSelected = state["isSelected"] as? Bool, let isEmphasized = state["isEmphasized"] as? Bool {
                if configuration.state.didConfigurate == false {
                    configuration.state.borderWidth = configuration.border.width
                    configuration.state.borderColor = configuration.border.color
                    configuration.state.color = configuration.color
                    configuration.state.shadowColor = configuration.shadow.color
                    configuration.state.didConfigurate = true
                }

                if isSelected {
                    configuration.border.width = configuration.state.borderWidth != 0.0 ? configuration.state.borderWidth : 2.0
                    if isEmphasized {
                        configuration.color = .controlAccentColor.withAlphaComponent(0.5)
                        configuration.border.color = .controlAccentColor
                        configuration.shadow.color = configuration.shadow.isInvisible ? nil : .controlAccentColor
                    } else {
                        configuration.border.color = .controlAccentColor.withAlphaComponent(0.5)
                        configuration.color = .controlAccentColor.withAlphaComponent(0.2)
                        configuration.shadow.color = configuration.shadow.isInvisible ? nil : .controlAccentColor.withAlphaComponent(0.5)
                    }
                } else {
                    if configuration.state.didConfigurate {
                        configuration.border.width = configuration.state.borderWidth
                        configuration.border.color = configuration.state.borderColor
                        configuration.shadow.color = configuration.state.shadowColor
                        configuration.color = configuration.state.color
                        configuration.state.didConfigurate = false
                    }
                }
            }
            return configuration
        }
        
        /// The saved state when `updated(for:)` is applied.
        struct State: Hashable {
            var didConfigurate: Bool = false
            var color: NSColor?
            var shadowColor: NSColor?
            var borderColor: NSColor?
            var borderWidth: CGFloat = 0.0
        }

        /// The saved state when `updated(for:)` is applied.
        var state: State = .init()

        var _resolvedColor: NSColor?
        var _resolvedBorderColor: NSColor?
        var _resolvedShadowColor: NSColor?
        var _resolvedInnerShadowColor: NSColor?

        mutating func updateResolvedColors() {
            _resolvedColor = resolvedColor()
            _resolvedBorderColor = border.resolvedColor()
            _resolvedShadowColor = shadow.resolvedColor(withOpacity: false)
            _resolvedInnerShadowColor = innerShadow.resolvedColor(withOpacity: false)
        }
    }

#endif
