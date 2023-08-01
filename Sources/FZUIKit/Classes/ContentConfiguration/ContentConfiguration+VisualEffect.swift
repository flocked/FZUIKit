//
//  ContentConfiguration+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
import AppKit
public extension ContentConfiguration {
    /**
     A configuration that specifies the appearance of a visual effect view.
     
     `NSVisualEffect` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.VisualEffect)`.
     
     `NSView` can be configurated via it's `visualEffect` property.  It adds a visual effect view as background to the view.
     
     `NSWindow` can also be configurated via it's `visualEffect` property.  It adds a visual effect view as background to it's `contentView`.
     */
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
         The appearance of the visual effect view.

         When the value of this property is nil (the default), AppKit applies the current system appearance to visual effect view. Assigning an NSAppearance object to this property causes the visual effect view and it's subviews to adopt the specified appearance instead.

         Individual subviews may still override the the appearance.
         */
        public var appearance: NSAppearance? = nil
        
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
        
        /// A visual effect with the specified appearance.
        public static func appearance(_ appearanceName: NSAppearance.Name, blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> VisualEffect {
            return VisualEffect(material: material, blendingMode: blendingMode, appearance: NSAppearance(named: appearanceName))
        }

        /// A visual effect with a light system appearance.
        public static func light(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.aqua, blendingMode: blendingMode, material: material) }

        /// A visual effect with a dark system appearance.
        public static func dark(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.darkAqua, blendingMode: blendingMode, material: material) }

        /// A visual effect with a light vibrant appearance.
        public static func vibrantLight(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.vibrantLight, blendingMode: blendingMode, material: material) }

        /// A visual effect with a dark vibrant appearance.
        public static func vibrantDark(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.vibrantDark, blendingMode: blendingMode, material: material) }
        
        /// A visual effect with a high-contrast version of the standard light system appearance.
        public static func accessibilityHighContrastAqua(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastAqua, blendingMode: blendingMode, material: material) }
        
        /// A visual effect with a high-contrast version of the standard dark system appearance.
        public static func accessibilityHighContrastDarkAqua(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastDarkAqua, blendingMode: blendingMode, material: material) }
        
        /// A visual effect with a high-contrast version of the light vibrant appearance.
        public static func accessibilityHighContrastVibrantLight(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastVibrantLight, blendingMode: blendingMode, material: material) }
        
        /// A visual effect with a high-contrast version of the dark vibrant appearance.
        public static func accessibilityHighContrastVibrantDark(_ blendingMode: BlendingMode = .withinWindow, material: Material = .contentBackground) -> Self { return .appearance(.accessibilityHighContrastVibrantDark, blendingMode: blendingMode, material: material) }
        
        /*
        public static func `default`() -> Self { return .withinWindow() }

        public static func withinWindow() -> Self { return Self(material: .contentBackground, blendingMode: .withinWindow) }

        public static func behindWindow() -> Self { return Self(material: .windowBackground, blendingMode: .behindWindow) }
         
         /// Applies the specified material to the configuration.
         public func material(_ material: Material) -> Self {
             var visualEffect = self
             visualEffect.material = material
             return self
         }
         
         /// Applies the specified blending mode to the configuration.
         public func blendingMode(_ blendingMode: BlendingMode) -> Self {
             var visualEffect = self
             visualEffect.blendingMode = blendingMode
             return self
         }
         
         /// Applies the specified appearance to the configuration.
         public func appearance(_ appearance: NSAppearance?) -> Self {
             var visualEffect = self
             visualEffect.appearance = appearance
             return self
         }
         
         /// Applies the specified state to the configuration.
         public func state(_ state: State) -> Self {
             var visualEffect = self
             visualEffect.state = state
             return self
         }
         
         /// Applies the specified emphasized boolean to the configuration.
         public func isEmphasized(_ isEmphasized: Bool) -> Self {
             var visualEffect = self
             visualEffect.isEmphasized = isEmphasized
             return self
         }
         
         /// Applies the specified mask image to the configuration.
         public func maskImage(_ maskImage: NSImage?) -> Self {
             var visualEffect = self
             visualEffect.maskImage = maskImage
             return self
         }
        */
    }
}

public extension NSVisualEffectView {
    /**
     Configurates the visual effect view with the specified configuration.

     - Parameters:
        - configuration:The configuration for configurating the visual effect view.
     */
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
    /**
     A configuration that specifies the appearance of a visual effect view.

     `UIVisualEffectView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.VisualEffect)`.
     */
    struct VisualEffect: Hashable {
        /// The visual effect style.
        public enum Style: Hashable {
            /// A blurring and vibrancy effect.
            case vibrancy(UIVibrancyEffectStyle, blur: UIBlurEffect.Style)
            /// A blurring effect.
            case blur(UIBlurEffect.Style)
        }

        public var style: Self.Style? = nil
        public init(style: Self.Style? = nil) {
            self.style = style
        }
        
        /// A visual blurring vibrancy effect.
        public static func vibrancy(_ vibrancy: UIVibrancyEffectStyle, blur: UIBlurEffect.Style) -> Self { return Self(style: .vibrancy(vibrancy, blur: blur)) }

        /// A visual blurring effect.
        public static func blur(_ style: UIBlurEffect.Style) -> Self { return Self(style: .blur(style)) }
    }
}

public extension UIVisualEffectView {
    /**
     Configurates the visual effect view with the specified configuration.

     - Parameters:
        - configuration:The configuration for configurating the visual effect view.
     */
    func configurate(using configuration: ContentConfiguration.VisualEffect) {
        if let style = configuration.style {
            switch style {
            case let .vibrancy(vibrancy, blur: blur):
                effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: vibrancy)
            case let .blur(blurStyle):
                effect = UIBlurEffect(style: blurStyle)
            }
        } else {
            effect = nil
        }
    }
}

#endif
