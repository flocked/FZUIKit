//
//  ImageConfiguration.swift
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

    /**
     A configuration that specifies the image.

     `NSImageView/UIImageView` can be configurated by passing the configuration to `configurate(using configuration: ImageConfiguration)`.
     */
    @available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
    public struct ImageConfiguration: Hashable {
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
        var maxWidth: CGFloat?

        /// The max height of the image.
        var maxHeight: CGFloat?

        /// The tint color of the image.
        var tintColor: NSUIColor?

        /// The color transformer for resolving the tint color.
        public var tintColorTransformer: ColorTransformer? {
            didSet { updateResolvedColor() }
        }

        /// Generates the resolved tint color, using the tint color and color transformer.
        public func resolvedTintColor() -> NSUIColor? {
            if let tintColor = tintColor {
                return tintColorTransformer?(tintColor) ?? tintColor
            }
            return nil
        }

        /// The symbol configuration of the image.
        public var symbolConfiguration: ImageSymbolConfiguration?

        #if os(macOS)
            /// Initalizes a image configuration.
            init(scaling: NSImageScaling = .scaleProportionallyUpOrDown,
                 alignment: NSImageAlignment = .alignCenter,
                 maxWidth: CGFloat? = nil,
                 maxHeight: CGFloat? = nil,
                 tintColor: NSUIColor? = nil,
                 symbolConfiguration: ImageSymbolConfiguration? = nil)
            {
                self.scaling = scaling
                self.alignment = alignment
                self.maxWidth = maxWidth
                self.maxHeight = maxHeight
                self.tintColor = tintColor
                self.symbolConfiguration = symbolConfiguration
                updateResolvedColor()
            }

        #elseif canImport(UIKit)
            /// Initalizes a image configuration.
            init(scaling: UIView.ContentMode = .scaleAspectFit,
                 maxWidth: CGFloat? = nil,
                 maxHeight: CGFloat? = nil,
                 tintColor: NSUIColor? = nil,
                 symbolConfiguration: ImageSymbolConfiguration? = nil)
            {
                self.scaling = scaling
                self.maxWidth = maxWidth
                self.maxHeight = maxHeight
                self.tintColor = tintColor
                self.symbolConfiguration = symbolConfiguration
                updateResolvedColor()
            }
        #endif

        var _resolvedTintColor: NSUIColor?
        mutating func updateResolvedColor() {
            _resolvedTintColor = resolvedTintColor()
        }
    }

    @available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
    public extension NSUIImageView {
        /**
         Configurates the image of the image view.

         - Parameters:
            - configuration:The configuration for configurating the image.
         */
        func configurate(using configuration: ImageConfiguration) {
            #if os(macOS)
                imageScaling = configuration.scaling
                imageAlignment = configuration.alignment
                contentTintColor = configuration._resolvedTintColor
                symbolConfiguration = configuration.symbolConfiguration?.nsUI()
            #elseif canImport(UIKit)
                contentMode = configuration.scaling
                tintColor = configuration._resolvedTintColor
                preferredSymbolConfiguration = configuration.symbolConfiguration?.nsUI()
            #endif

            if var imageSize = image?.size {
                switch (configuration.maxWidth, configuration.maxHeight) {
                case let (.some(maxWidth), .some(maxHeight)):
                    imageSize = imageSize.scaled(toFit: CGSize(maxWidth, maxHeight))
                case (.some(let maxWidth), nil):
                    imageSize = imageSize.scaled(toWidth: maxWidth)
                case (nil, let .some(maxHeight)):
                    imageSize = imageSize.scaled(toHeight: maxHeight)
                default: break
                }
                if imageSize != image?.size {
                    image = image?.resized(to: imageSize) ?? image
                }
            }
        }
    }
#endif
