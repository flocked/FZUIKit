//
//  ImageRendererFormat.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/**
 A set of drawing attributes that represents the configuration of an image renderer context.
 
 Use an instance of UIGraphicsImageRendererFormat to initialize a ``NSGraphicsImageRenderer`` object with nondefault attributes.
 
 The image renderer format object contains properties that determine the attributes of the underlying Core Graphics contexts that the image renderer creates. Use the `default()` static method to create an image renderer format instance optimized for the current device.
 */
public class ImageGraphicsRendererFormat: GraphicsRendererFormat {
    
    /**
     The display scale of the image renderer context.
     
     The display scale determines the number of pixels per point.
     
     The default value is equal to the scale of the `main` screen.
     */
    public var scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 1.0
    
    /**
     A Boolean value that indicates whether the underlying Core Graphics context has an alpha channel.
     
     Setting the value of this property to `false` specifies that the underlying Core Graphics context has an alpha channel, whereas `true` indicates it does not. The default value is `false`.
     
     A Core Graphics context requires an alpha channel to express transparency. Without an alpha channel a Core Graphics context is said to be opaque, i.e. without transparency.
     */
    public var isOpaque: Bool = false
    
    /**
     The preferred color range of the image renderer context.
     
     This property affects the pixel format of the image that the renderer produces.
     
     Different pixel formats can store different color ranges. The system chooses the precise pixel format, but you can set this property to exclude certain formats that support larger or narrower color ranges than you need.
     */
    public var preferredRange: Range = .standard
    
    /// A Boolean value that indicates the graphics context’s flipped state.
    public var isFlipped: Bool = false
    
    /**
     The bounds of the graphics context.
     
     This value represents the bounds of every Core Graphics context that the associated graphics renderer creates.
     
     If the graphics renderer itself creates a format object, the bounds are set to those provided to the renderer as part of the initializer.
     */
    public internal(set) var bounds: CGRect {
        get { isRendering ? renderingBounds : .zero }
        set { renderingBounds = newValue }
    }
    
    var renderingBounds: CGRect = .zero
    var isRendering: Bool = false

    /**
     Returns a format that represents the highest fidelity that the current device supports.
     
     The returned format object always represents the device's highest fidelity, regardless of the actual fidelity currently employed by the device. A graphics renderer uses this method to create a format at initialization time if you use an initializer that does not have a format argument.
     
     This property doesn't always return a format that's optimized for the current configuration of the main screen. If you're rendering content for immediate display, it's recommended that you use ``preferred()`` instead of this property.
     */
    public static func `default`() -> Self {
        let maxScale = NSScreen.screens.map { $0.backingScaleFactor }.max() ?? 1.0
        //let supportsHDR = NSScreen.screens.contains { $0.maximumExtendedDynamicRangeColorComponentValue > 1.0 }
        return Self(scale: maxScale, isOpaque: false, preferredRange: .standard)
    }
    
    /// Returns the most suitable format for the main screen’s current configuration.
    public static func preferred() -> Self {
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        // let supportsHDR = NSScreen.main?.maximumExtendedDynamicRangeColorComponentValue ?? 1.0 > 1.0
        return Self(scale: scale, isOpaque: false, preferredRange: .extended)
    }
    
    /// Creates an image renderer format with the specified `scale`, `isOpaque`, `isFlipped` and `preferredRange`.
    public required init(scale: CGFloat = 1.0, isOpaque: Bool = false, isFlipped: Bool = false, preferredRange: Range = .standard) {
        self.scale = scale
        self.isOpaque = isOpaque
        self.isFlipped = isFlipped
        self.preferredRange = preferredRange
    }
}

extension ImageGraphicsRendererFormat {
    /// Constants that specify the color range of the image renderer context.
    public enum Range: Int, Hashable {
        /// The system automatically chooses the image renderer context’s pixel format according to the color range of its content.
        case automatic
        /// The image renderer context supports wide color.
        case extended
        /**
         The image renderer context doesn’t support extended colors.
         
         If you draw wide-color content into an image renderer context that uses the standard color range, you may lose color information. The system matches the colors to the standard range of their corresponding color space.
         */
        case standard
        
        var colorSpace: NSColorSpace {
            switch self {
            case .standard:
                return .sRGB
            case .extended:
                return .extendedSRGB
            case .automatic:
                return .deviceRGB
            }
        }
    }
}

#endif
