//
//  ContentConfiguration+Image.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration {
    /**
     A configuration that specifies the image.
     
     `NSImageView/UIImageView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Image)`.     
     */
    struct Image: Hashable {
#if os(macOS)
        /// The scaling of the image.
        var scaling: NSImageScaling = .scaleProportionallyUpOrDown
        
        /// The alignment of the image.
        var alignment: NSImageAlignment = .alignCenter
#elseif canImport(UIKit)
        /// The scaling of the image.
        var scaling: UIView.ContentMode = .scaleAspectFit
#endif
        
        /// The max width of the image.
        var maxWidth: CGFloat? = nil
        
        /// The max height of the image.
        var maxHeight: CGFloat? = nil
        
        /// The tint color of the image.
        var tintColor: NSUIColor? = nil
                
        /// The color transformer for resolving the tint color.
        public var tintColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved tint color for the specified tint color, using the tint color and color transformer.
        public func resolvedTintColor() -> NSUIColor? {
            if let tintColor = tintColor {
                return tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: SymbolConfiguration? = nil
        
#if os(macOS)
        /// Initalizes a image configuration.
        init(scaling: NSImageScaling = .scaleProportionallyUpOrDown,
             alignment: NSImageAlignment = .alignCenter,
             maxWidth: CGFloat? = nil,
             maxHeight: CGFloat? = nil,
             tintColor: NSUIColor? = nil,
             symbolConfiguration: SymbolConfiguration? = nil) {
            self.scaling = scaling
            self.alignment = alignment
            self.maxWidth = maxWidth
            self.maxHeight = maxHeight
            self.tintColor = tintColor
            self.symbolConfiguration = symbolConfiguration
            self.updateResolvedColor()
        }
#elseif canImport(UIKit)
        /// Initalizes a image configuration.
        init(scaling: UIView.ContentMode = .scaleAspectFit,
             maxWidth: CGFloat? = nil,
             maxHeight: CGFloat? = nil,
             tintColor: NSUIColor? = nil,
             symbolConfiguration: SymbolConfiguration? = nil) {
            self.scaling = scaling
            self.maxWidth = maxWidth
            self.maxHeight = maxHeight
            self.tintColor = tintColor
            self.symbolConfiguration = symbolConfiguration
            self.updateResolvedColor()
        }
#endif
        
        internal var _resolvedTintColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedTintColor = resolvedTintColor()
        }
    }
}

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension NSUIImageView {
    /**
     Configurates the image of the image view.

     - Parameters:
        - configuration:The configuration for configurating the image.
     */
    func configurate(using configuration: ContentConfiguration.Image) {
        #if os(macOS)
        self.imageScaling = configuration.scaling
        self.imageAlignment = configuration.alignment
        self.contentTintColor = configuration._resolvedTintColor
        self.symbolConfiguration = configuration.symbolConfiguration?.nsUI()
        #elseif canImport(UIKit)
        self.contentMode = configuration.scaling
        self.tintColor = configuration._resolvedTintColor
        self.preferredSymbolConfiguration = configuration.symbolConfiguration?.nsUI()
        #endif
        
        if var imageSize = self.image?.size {
            switch (configuration.maxWidth, configuration.maxHeight) {
            case (.some(let maxWidth), .some(let maxHeight)):
                imageSize = imageSize.scaled(toFit: CGSize(maxWidth, maxHeight))
            case (.some(let maxWidth), nil):
                imageSize = imageSize.scaled(toWidth: maxWidth)
            case (nil, .some(let maxHeight)):
                imageSize = imageSize.scaled(toHeight: maxHeight)
            default: break
            }
            if imageSize != self.image?.size {
                self.image = image?.resized(to: imageSize) ?? self.image
            }
        }
    }
}
#endif
