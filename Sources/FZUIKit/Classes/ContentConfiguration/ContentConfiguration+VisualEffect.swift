//
//  ContentConfiguration+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
    import AppKit
    public extension ContentConfiguration {
        /// A configuration that specifies the appearance of a visual effect view.
        struct VisualEffect: Hashable {
            public typealias Material = NSVisualEffectView.Material
            public typealias State = NSVisualEffectView.State
            public typealias BlendingMode = NSVisualEffectView.BlendingMode

            /// The material shown by the visual effect view.
            public var material: Material
            /**
             A value indicating how the view’s contents blend with the surrounding content.

             When the value of this property is behindWindow, the visual effect view blurs the content behind the window. When the value is withinWindow, it blurs the content behind the view of the current window.

             If the visual effect view's material is Material.titlebar, set the blending mode to withinWindow.
             */
            public var blendingMode: BlendingMode
            /**
             A value that indicates whether a view has a visual effect applied.

             The default value of this property is followsWindowActiveState.
             */
            public var state: State
            /**
             A Boolean value indicating whether to emphasize the look of the material.

             Some materials change their appearance when they are emphasized. For example, the first responder view conveys its status.

             The default value of this property is false.
             */
            public var isEmphasized: Bool
            /**
             An image whose alpha channel masks the visual effect view's material.

             The default value of this property is nil, which is the equivalent of allowing all of the visual effect view's content to show through. Assigning an image to this property masks the portions of the visual effect view using the image's alpha channel.

             If the visual effect view is the content view of a window, the mask is applied in an appropriate way to the window's shadow.
             */
            public var maskImage: NSImage?
            /**
             The appearance of the visual effect view.

             When the value of this property is nil (the default), AppKit applies the current system appearance to visual effect view. Assigning an NSAppearance object to this property causes the visual effect view and it's subviews to adopt the specified appearance instead.

             Individual subviews may still override the the appearance.
             */
            public var appearance: NSAppearance? = nil

            public init(material: Material,
                        blendingMode: BlendingMode,
                        state: State = .followsWindowActiveState,
                        isEmphasized: Bool = false,
                        maskImage: NSImage? = nil,
                        appearance: NSAppearance? = nil)
            {
                self.material = material
                self.blendingMode = blendingMode
                self.state = state
                self.isEmphasized = isEmphasized
                self.maskImage = maskImage
                self.appearance = appearance
            }

            public static func appearance(_ appearanceName: NSAppearance.Name, blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> VisualEffect {
                return VisualEffect(material: material, blendingMode: blendingMode, appearance: NSAppearance(named: appearanceName))
            }

            public static func `default`() -> Self { return .withinWindow() }

            public static func withinWindow() -> Self { return Self(material: .contentBackground, blendingMode: .withinWindow) }

            public static func behindWindow() -> Self { return Self(material: .windowBackground, blendingMode: .behindWindow) }

            public static func aqua(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.aqua, blendingMode: blendingMode, material: material) }

            public static func darkAqua(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.darkAqua, blendingMode: blendingMode, material: material) }

            public static func vibrantLight(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.vibrantLight, blendingMode: blendingMode, material: material) }

            public static func vibrantDark(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.vibrantDark, blendingMode: blendingMode, material: material) }
        }
    }

    public extension NSVisualEffectView {
        /// Configurates
        func configurate(using configuration: ContentConfiguration.VisualEffect) {
            material = configuration.material
            blendingMode = configuration.blendingMode
            state = configuration.state
            isEmphasized = configuration.isEmphasized
            maskImage = configuration.maskImage
            appearance = configuration.appearance
        }
    }

#elseif canImport(UIKit)
    import UIKit
    public extension ContentConfiguration {
        struct VisualEffect: Hashable {
            public enum Style: Hashable {
                case vibrancy(blur: UIBlurEffect.Style, vibrancy: UIVibrancyEffectStyle? = nil)
                case blur(UIBlurEffect.Style)
            }

            public var style: Self.Style? = nil
            public init(style: Self.Style? = nil) {
                self.style = style
            }

            public static func vibrancy(blur: UIBlurEffect.Style, vibrancy: UIVibrancyEffectStyle? = nil) -> Self { return Self(style: .vibrancy(blur: blur, vibrancy: vibrancy)) }

            public static func blur(_ style: UIBlurEffect.Style) -> Self { return Self(style: .blur(style)) }
        }
    }

    public extension UIVisualEffectView {
        func configurate(using configuration: ContentConfiguration.VisualEffect) {
            if let style = configuration.style {
                switch style {
                case let .vibrancy(blur: blur, vibrancy: vibrancy):
                    effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur))
                    if let vibrancy = vibrancy {
                        effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: vibrancy)
                    }
                case let .blur(blurStyle):
                    effect = UIBlurEffect(style: blurStyle)
                }
            } else {
                effect = nil
            }
        }
    }

#endif
