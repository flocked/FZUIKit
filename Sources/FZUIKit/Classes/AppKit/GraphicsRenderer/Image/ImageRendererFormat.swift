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
public final class GraphicsImageRendererFormat: GraphicsRendererFormat {
    var isRendering = false
    
    /**
     The display scale of the image renderer context.
     
     The display scale determines the number of pixels per point.
     
     The default value is equal to the scale of the `main` screen.
     */
    public var scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 1.0
    
    /**
     A Boolean value indicating whether the underlying Core Graphics context has an alpha channel.
     
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
    
    /// A Boolean value indicating the graphics context’s flipped state.
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
    
    /**
     Creates a image render format with the specified values.
     
     - Parameters:
        - scale: The display scale of the image renderer context. The default value is `0.0` and equal to the scale of the [main](https://developer.apple.com/documentation/appkit/nsscreen/main) screen.
        - isOpaque: A Boolean value that indicates whether the underlying Core Graphics context has an alpha channel.
        - isFlipped: A Boolean value indicating the graphics context’s flipped state.
        - preferredRange: The preferred color range of the image renderer context.
     */
    public init(scale: CGFloat = 1.0, isOpaque: Bool = false, isFlipped: Bool = false, preferredRange: Range = .standard) {
        self.scale = scale
        self.isOpaque = isOpaque
        self.isFlipped = isFlipped
        self.preferredRange = preferredRange
    }
    
    /// Creates the most suitable format for rendering on the specified screen.
    public init(for screen: NSScreen) {
        scale = screen.backingScaleFactor
        preferredRange = screen.colorSpace?.isExtended ?? false ? .extended : .standard
    }
    
    /**
     Creates the most suitable format for rendering on the specified window.
     
     It uses the most suitable format based on the window's screen, otherwise of the [main](https://developer.apple.com/documentation/appkit/nsscreen/main) screen.
     */
    public init(for window: NSWindow) {
        let colorSpace = window.colorSpace ?? (window.screen ?? NSScreen.main)?.colorSpace
        scale = window.backingScaleFactor
        preferredRange = colorSpace?.isExtended ?? false ? .extended : .standard
    }
    
    /**
     Creates the most suitable format for rendering on the specified view.
     
     It uses the most suitable format based on the view's screen, otherwise of the [main](https://developer.apple.com/documentation/appkit/nsscreen/main) screen.
     */
    public init(for view: NSView) {
        let colorSpace = view.window?.colorSpace ?? (NSScreen.main ?? NSScreen.screens.first)?.colorSpace
        scale = view.window?.backingScaleFactor ?? (NSScreen.main ?? NSScreen.screens.first)?.backingScaleFactor ?? 1.0
        preferredRange = colorSpace?.isExtended ?? false ? .extended : .standard
    }

    /// Returns the most suitable format for the main screen’s current configuration.
    public static func preferred() -> GraphicsImageRendererFormat {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return .init() }
        return GraphicsImageRendererFormat(for: screen)
    }
    
    /**
     Returns a format that represents the highest fidelity the current device supports.
     
     The returned format always represents the device’s highest fidelity, regardless of the actual fidelity currently employed by the device. A graphics renderer uses this method to create a format at initialization time if you use an initializer that does not have a format argument.
     
     This property doesn’t always return a format that’s optimized for the current configuration of the main screen. If you’re rendering content for immediate display, it’s recommended that you use ``preferred()`` instead of this property.
     */
    public static func `default`() -> GraphicsImageRendererFormat {
        let format = GraphicsImageRendererFormat.preferred()
        format.preferredRange = .extended
        return format
    }
}

extension GraphicsImageRendererFormat {
    /// Constants that specify the color range of the image renderer context.
    public enum Range: Int {
        /// The system automatically chooses the image renderer context’s pixel format according to the color range of its content.
        case automatic
        /// The image renderer context supports wide color.
        case extended
        /// The image renderer context doesn’t support extended colors.
        case standard
        
        func bitmapInfo(opaque: Bool) -> CGBitmapInfo {
            self == .extended ?
            CGBitmapInfo(alpha: opaque ? .noneSkipLast : .premultipliedLast, component: .float, byteOrder: .order32Little) :
            CGBitmapInfo(alpha: opaque ? .noneSkipFirst : .premultipliedFirst, byteOrder: .order32Little)
        }

        var cgColorSpace: CGColorSpace {
            self == .extended ? CGColorSpace(name: .extendedSRGB)! : CGColorSpace(name: .sRGB)!
        }
        
        var resolved: Range {
            guard self == .automatic else { return self }
            if (NSScreen.main ?? NSScreen.screens.first)?.colorSpace?.isExtended == true {
                return .extended
            }
            return .standard
        }
    }
}

private extension NSColorSpace {
    var isExtended: Bool {
        isHDR || usesExtendedRange
    }
}

extension NSColorSpaceName {
    static let genericRGB = NSColorSpaceName(rawValue: "NSCalibratedRGBColorSpace")
}

#endif
