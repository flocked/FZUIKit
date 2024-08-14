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
        public var color: NSColor?

        /// The color transformer of the background color.
        public var colorTransformer: ColorTransformer?

        ///  Generates the resolved background color for the specified background color, using the color and color transformer.
        public func resolvedColor() -> NSColor? {
            guard let color = color else { return nil }
            return colorTransformer?(color) ?? color
        }

        /// The background image.
        public var image: NSImage?
        
        /// The scaling of the background image.
        public var imageScaling: ImageView.ImageScaling = .none

        /// The background view.
        public var view: NSView?

        /// Properties for configuring the border.
        public var border: BorderConfiguration = .none()

        /// Properties for configuring the shadow.
        public var shadow: ShadowConfiguration = .none()

        /// Properties for configuring the inner shadow.
        public var innerShadow: ShadowConfiguration = .none()

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
        
        /// Creates a background configuration with the specified color.
        public static func color(_ color: NSUIColor) -> NSBackgroundConfiguration {
            var configuration = NSBackgroundConfiguration()
            configuration.color = color
            return configuration
        }

        /// Creates a background configuration.
        public init() { }
        
        public func makeContentView() -> NSView & NSContentView {
            NSBackgroundView(configuration: self)
        }
        
        var borderTransformer: BorderTransformer?
        var shadowTransformer: ShadowTransformer?
        var _colorTransformer: ColorTransformer?
        var isSelected: Bool? = nil
        var isEmphasized: Bool? = nil

        var resolvedShadow: ShadowConfiguration {
            shadowTransformer?(shadow) ?? shadow
        }
        
        var resolvedBorder: BorderConfiguration {
            borderTransformer?(border) ?? border
        }
        
        var _resolvedColor: NSColor? {
            guard let color = resolvedColor() else { return nil }
            return _colorTransformer?(color) ?? color
        }

        public func updated(for state: NSConfigurationState) -> NSBackgroundConfiguration {
            guard let isSelected = state["isSelected"] as? Bool, let isEmphasized = state["isEmphasized"] as? Bool, self.isSelected != isSelected, self.isEmphasized != isEmphasized else { return self }
            
            var configuration = self
            configuration.isSelected = isSelected
            configuration.isEmphasized = isEmphasized
            configuration._colorTransformer = .init("resolved") { color in
                isSelected ? .controlAccentColor.withAlphaComponent(isEmphasized ? 0.5 : 0.2) : color.withAlphaComponent(color.alphaComponent / (isEmphasized ? 1.0 : 2.0))
            }
            configuration.borderTransformer = .init("resolved") { border in
                var border = border
                border.width = border.width != 0 ? border.width : 3.0
                if isSelected {
                    border.color = isEmphasized ? .controlAccentColor : .controlAccentColor.withAlphaComponent(0.5)
                } else if let color = border.color {
                    border.color = color.withAlphaComponent(color.alphaComponent / (isEmphasized ? 1.0 : 2.0))
                }
                return border
            }
            configuration.shadowTransformer = .init("resolved") { shadow in
                var shadow = shadow
                if isSelected {
                    shadow.color = isEmphasized ? .controlAccentColor : .controlAccentColor.withAlphaComponent(0.5)
                } else if let color = shadow.color {
                    shadow.color = color.withAlphaComponent(color.alphaComponent / (isEmphasized ? 1.0 : 2.0))
                }
                return shadow
            }
            return configuration
        }
    }

#endif
