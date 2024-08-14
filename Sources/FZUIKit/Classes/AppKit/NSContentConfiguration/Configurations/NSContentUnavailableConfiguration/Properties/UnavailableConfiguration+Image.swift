//
//  NSContentUnavailableConfiguration+ImageProperties.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 12.0, *)
    public extension NSContentUnavailableConfiguration {
        /// Properties that affect the cell content configuration’s image.
        struct ImageProperties: Hashable {
            
            /// The image scaling.
            public enum Scaling {
                /// The image is resized so it’s all within the available space, both vertically and horizontally.
                case scaleToFit
                /// The image is resized so it occupies all available space, both vertically and horizontally.
                case scaleToFill
                /// The image is resized.
                case resize
                /// The image isn't resized.
                case none
                
                var contentMode: ContentMode? {
                    switch self {
                    case .scaleToFit: return .fit
                    case .scaleToFill: return .fill
                    default: return nil
                    }
                }
            }
            
            /// The tint color for an image that is a template or symbol image.
            public var tintColor: NSColor?

            /// The corner radius of the image.
            public var cornerRadius: CGFloat = 0.0
            
            /// The shadow of the image.
            public var shadow: ShadowConfiguration = .none()

            /// The symbol configuration of the image.
            public var symbolConfiguration: ImageSymbolConfiguration? = .font(.largeTitle)

            /// The image scaling.
            public var scaling: Scaling = .scaleToFit

            /**
             A maximum size for the image.

             The default value is `zero`. Setting a width or height of `0` makes the size unconstrained on that dimension. If the image exceeds `maximumSize size on either dimension, the view reduces its size proportionately, maintaining aspect ratio.
             */
            public var maximumSize: CGSize = .zero

            var maximumWidth: CGFloat? {
                maximumSize.width != 0 ? maximumSize.width : nil
            }

            var maximumHeight: CGFloat? {
                maximumSize.height != 0 ? maximumSize.height : nil
            }

            /// Creates image properties.
            public init(tintColor: NSColor? = .secondaryLabelColor,
                        cornerRadius: CGFloat = 0.0,
                        shadow: ShadowConfiguration = .none(),
                        symbolConfiguration: ImageSymbolConfiguration? = .font(.largeTitle),
                        scaling: Scaling = .scaleToFit,
                        maximumSize: CGSize = .zero)
            {
                self.tintColor = tintColor
                self.cornerRadius = cornerRadius
                self.symbolConfiguration = symbolConfiguration
                self.scaling = scaling
                self.maximumSize = maximumSize
            }
        }
    }

    @available(macOS 12.0, *)
    extension Image {
        @ViewBuilder
        func scaling(_ scaling: NSContentUnavailableConfiguration.ImageProperties.Scaling) -> some View {
            if scaling == .none {
                self
            } else if let contentMode = scaling.contentMode {
                self.resizable().aspectRatio(contentMode: contentMode)
            } else {
                self.resizable()
            }
        }
    }
#endif
