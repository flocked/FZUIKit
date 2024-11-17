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

         `NSVisualEffectView` can be configurated via it's ``AppKit/NSVisualEffectView/configuration`` property.

         `NSView` can be configurated via it's ``visualEffect`` property.  It adds a visual effect view as background to the view.

         `NSWindow` can be configurated via it's ``AppKit/NSWindow/visualEffect`` property.  It adds a visual effect view as background to it's `contentView`.
         */
        public struct VisualEffectConfiguration: Hashable, Codable {
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

             The default value of this property is `nil`, which is the equivalent of allowing all of the visual effect view's content to show through. Assigning an image to this property masks the portions of the visual effect view using the image's alpha channel.

             If the visual effect view is the content view of a window, the mask is applied in an appropriate way to the window's shadow.
             */
            public var maskImage: NSImage?

            /// Initalizes a visual effect configuration.
            public init(material: Material, blendingMode: BlendingMode, appearance: NSAppearance? = nil, state: State = .followsWindowActiveState, isEmphasized: Bool = false, maskImage: NSImage? = nil) {
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
        }

        public extension NSVisualEffectView {
            /// The current configuration of the visual effect view.
            var configuration: VisualEffectConfiguration {
                get { VisualEffectConfiguration(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized, maskImage: maskImage) }
                set {
                    material = newValue.material
                    blendingMode = newValue.blendingMode
                    state = newValue.state
                    isEmphasized = newValue.isEmphasized
                    maskImage = newValue.maskImage
                    appearance = newValue.appearance
                }
            }

            /// Initializes and returns a new visual effect view with the specified configuration.
            convenience init(configuration: VisualEffectConfiguration) {
                self.init(frame: .zero)
                self.configuration = configuration
            }
        }

/// The Objective-C class for ``VisualEffectConfiguration``.
public class __VisualEffectConfiguration: NSObject, NSCopying {
    let configuration: VisualEffectConfiguration

    public init(configuration: VisualEffectConfiguration) {
        self.configuration = configuration
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __VisualEffectConfiguration(configuration: configuration)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        configuration == (object as? __VisualEffectConfiguration)?.configuration
    }
}

extension VisualEffectConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __VisualEffectConfiguration

    public func _bridgeToObjectiveC() -> __VisualEffectConfiguration {
        return __VisualEffectConfiguration(configuration: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __VisualEffectConfiguration, result: inout VisualEffectConfiguration?) {
        result = source.configuration
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __VisualEffectConfiguration, result: inout VisualEffectConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __VisualEffectConfiguration?) -> VisualEffectConfiguration {
        if let source = source {
            var result: VisualEffectConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return VisualEffectConfiguration(material: .contentBackground, blendingMode: .behindWindow)
    }
    
    public var description: String { "" }

    public var debugDescription: String {
        description
    }
}

    #elseif os(iOS) || os(tvOS)
        import UIKit
        /**
         A configuration that specifies the appearance of a visual effect view.

         `UIVisualEffectView` can be configurated by passing the configuration to `configurate(using configuration: VisualEffectConfiguration)`.

         `UIView` can be configurated via it's ``UIKIT/UIView/visualEffect`` property.  It adds a visual effect view as background to the view.
         */
        public struct VisualEffectConfiguration: Hashable {

            /// The visual effect.
            public var effect: UIVisualEffect?

            /// Creates a visual effect configuration.
            public init(effect: UIVisualEffect? = nil) {
                self.effect = effect
            }
            
            /// A visual blurring effect.
            public static func blur(_ style: UIBlurEffect.Style) -> Self { Self(effect: UIBlurEffect(style: style)) }
            
            /// A visual vibrancy effect.
            public static func vibrancy(blur: UIBlurEffect.Style) -> Self { Self(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur))) }

            #if os(iOS)
            /// A visual blurring vibrancy effect.
            public static func vibrancy(_ vibrancy: UIVibrancyEffectStyle, blur: UIBlurEffect.Style) -> Self { Self(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: vibrancy)) }
            #endif
        }

/// The Objective-C class for ``VisualEffectConfiguration``.
public class __VisualEffectConfiguration: NSObject, NSCopying {
    public var effect: UIVisualEffect?

    public init(effect: UIVisualEffect? = nil) {
        self.effect = effect
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __VisualEffectConfiguration(effect: effect)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        effect == (object as? __VisualEffectConfiguration)?.effect
    }
}

extension VisualEffectConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __VisualEffectConfiguration

    public func _bridgeToObjectiveC() -> __VisualEffectConfiguration {
        return __VisualEffectConfiguration(effect: effect)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __VisualEffectConfiguration, result: inout VisualEffectConfiguration?) {
        result = VisualEffectConfiguration(effect: source.effect)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __VisualEffectConfiguration, result: inout VisualEffectConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __VisualEffectConfiguration?) -> VisualEffectConfiguration {
        if let source = source {
            var result: VisualEffectConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return VisualEffectConfiguration()
    }
    
    public var description: String { "" }

    public var debugDescription: String {
        description
    }
}
    #endif
#endif
