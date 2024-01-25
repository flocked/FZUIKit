//
//  VisualEffectConfiguration.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
        /**
         A configuration that specifies the appearance of a visual effect view.

         `NSVisualEffectView` can be configurated by passing the configuration to `configurate(using configuration: VisualEffect)`.

         `NSView` can be configurated via it's ``AppKit/NSView/visualEffect`` property.  It adds a visual effect view as background to the view.

         `NSWindow` can be configurated via it's ``AppKit/NSWindow/visualEffect`` property.  It adds a visual effect view as background to it's `contentView`.
         */
        public struct VisualEffectConfiguration: Hashable {
            public typealias Material = NSVisualEffectView.Material
            public typealias State = NSVisualEffectView.State
            public typealias BlendingMode = NSVisualEffectView.BlendingMode

            /// The material shown by the visual effect view.
            public var material: Material

            /**
             A value indicating how the view’s contents blend with the surrounding content.

             When the value of this property is `behindWindow`, the visual effect view blurs the content behind the window. When the value is `withinWindow`, it blurs the content behind the view of the current window.

             If the visual effect view's material is Material.titlebar, set the blending mode to withinWindow.
             */
            public var blendingMode: BlendingMode

            /**
             The appearance of the visual effect view.

             When the value of this property is `nil` (the default), AppKit applies the current system appearance to visual effect view. Assigning an NSAppearance object to this property causes the visual effect view and it's subviews to adopt the specified appearance instead.

             Individual subviews may still override the the appearance.
             */
            public var appearance: NSAppearance?

            /**
             A value that indicates whether a view has a visual effect applied.

             The default value of this property is `followsWindowActiveState`.
             */
            public var state: State

            /**
             A Boolean value indicating whether to emphasize the look of the material.

             Some materials change their appearance when they are emphasized. For example, the first responder view conveys its status.

             The default value of this property is `false`.
             */
            public var isEmphasized: Bool

            /**
             An image whose alpha channel masks the visual effect view's material.

             The default value of this property is `nil, which is the equivalent of allowing all of the visual effect view's content to show through. Assigning an image to this property masks the portions of the visual effect view using the image's alpha channel.

             If the visual effect view is the content view of a window, the mask is applied in an appropriate way to the window's shadow.
             */
            public var maskImage: NSImage?

            /// Initalizes a visual effect configuration.
            public init(material: Material,
                        blendingMode: BlendingMode,
                        appearance: NSAppearance? = nil,
                        state: State = .followsWindowActiveState,
                        isEmphasized: Bool = false,
                        maskImage: NSImage? = nil)
            {
                self.material = material
                self.blendingMode = blendingMode
                self.appearance = appearance
                self.state = state
                self.isEmphasized = isEmphasized
                self.maskImage = maskImage
            }

            /// A visual effect configuration with the specified appearance.
            static func appearance(_ appearanceName: NSAppearance.Name, blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self {
                Self(material: material, blendingMode: blendingMode, appearance: NSAppearance(named: appearanceName))
            }

            /// A visual effect configuration with a light system appearance.
            public static func light(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { .appearance(.aqua, blendingMode: blendingMode, material: material) }

            /// A visual effect configuration with a dark system appearance.
            public static func dark(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { .appearance(.darkAqua, blendingMode: blendingMode, material: material) }

            /// A visual effect configuration with a light vibrant appearance.
            public static func vibrantLight(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { .appearance(.vibrantLight, blendingMode: blendingMode, material: material) }

            /// A visual effect configuration with a dark vibrant appearance.
            public static func vibrantDark(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { .appearance(.vibrantDark, blendingMode: blendingMode, material: material) }

            /*
             /// A visual effect configuration with a high-contrast version of the standard light system appearance.
             public static func accessibilityHighContrastAqua(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastAqua, blendingMode: blendingMode, material: material) }

             /// A visual effect configuration with a high-contrast version of the standard dark system appearance.
             public static func accessibilityHighContrastDarkAqua(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastDarkAqua, blendingMode: blendingMode, material: material) }

             /// A visual effect configuration with a high-contrast version of the light vibrant appearance.
             public static func accessibilityHighContrastVibrantLight(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastVibrantLight, blendingMode: blendingMode, material: material) }

             /// A visual effect configuration with a high-contrast version of the dark vibrant appearance.
             public static func accessibilityHighContrastVibrantDark(blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastVibrantDark, blendingMode: blendingMode, material: material) }
             */
        }

        public extension NSView {
            /**
             Configurates the visual effect of the view.

             - Parameters:
                - configuration:The visual effect configuration.
             */
            func configurate(using configuration: VisualEffectConfiguration) {
                if let visualView = self as? NSVisualEffectView {
                    visualView.configuration = configuration
                } else {
                    visualEffect = configuration
                }
            }
        }

        public extension NSVisualEffectView {
            /// The current configuration of the visual effect view.
            var configuration: VisualEffectConfiguration {
                get {
                    var configuration: VisualEffectConfiguration = .light()
                    configuration.material = self.material
                    configuration.blendingMode = self.blendingMode
                    configuration.state = self.state
                    configuration.isEmphasized = self.isEmphasized
                    configuration.maskImage = self.maskImage
                    configuration.appearance = self.appearance
                    return configuration
                }
                set {
                    self.material = newValue.material
                    self.blendingMode = newValue.blendingMode
                    self.state = newValue.state
                    self.isEmphasized = newValue.isEmphasized
                    self.maskImage = newValue.maskImage
                    self.appearance = newValue.appearance
                }
            }

            /// Initializes and returns a new visual effect view with the specified configuration.
            convenience init(configuration: VisualEffectConfiguration) {
                self.init(frame: .zero)
                self.configuration = configuration
            }
        }

    #elseif os(iOS)
        import UIKit
        /**
         A configuration that specifies the appearance of a visual effect view.

         `UIVisualEffectView` can be configurated by passing the configuration to `configurate(using configuration: VisualEffectConfiguration)`.

         `UIView` can be configurated via it's ``UIKIT/UIView/visualEffect`` property.  It adds a visual effect view as background to the view.
         */
        public struct VisualEffectConfiguration: Hashable {
            /// The visual effect style.
            public enum Style: Hashable {
                /// A blurring and vibrancy effect.
                case vibrancy(UIVibrancyEffectStyle, blur: UIBlurEffect.Style)
                /// A blurring effect.
                case blur(UIBlurEffect.Style)
            }

            public var style: Self.Style?

            /// Creates a visual effect configuration.
            public init(style: Self.Style? = nil) {
                self.style = style
            }

            /// A visual blurring vibrancy effect.
            public static func vibrancy(_ vibrancy: UIVibrancyEffectStyle, blur: UIBlurEffect.Style) -> Self { Self(style: .vibrancy(vibrancy, blur: blur)) }

            /// A visual blurring effect.
            public static func blur(_ style: UIBlurEffect.Style) -> Self { Self(style: .blur(style)) }
        }

        public extension UIView {
            /**
             Configurates the visual effect of the view.

             - Parameters:
                - configuration:The visual effect configuration.
             */
            func configurate(using configuration: VisualEffectConfiguration) {
                if let visualView = self as? UIVisualEffectView {
                    if let style = configuration.style {
                        switch style {
                        #if os(iOS)
                            case let .vibrancy(vibrancy, blur: blur):
                                visualView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: vibrancy)
                        #endif
                        case let .blur(blurStyle):
                            visualView.effect = UIBlurEffect(style: blurStyle)
                        }
                    } else {
                        visualView.effect = nil
                    }
                } else {
                    visualEffect = configuration
                }
            }
        }
    #endif
#endif
