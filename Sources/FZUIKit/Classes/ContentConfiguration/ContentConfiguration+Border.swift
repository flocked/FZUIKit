//
//  ContentConfiguration+Border.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a border.
    struct Border: Hashable {
        public var color: NSUIColor? = nil
        public var colorTransformer: NSUIConfigurationColorTransformer? = nil
        public var width: CGFloat = 0.0
        public var pattern: [PatternValue] = [.line]
        public func resolvedColor(for color: NSUIColor) -> NSUIColor {
            return colorTransformer?(color) ?? color
        }

        public enum PatternValue: Int {
            case line
            case noLine
        }

        public init(color: NSUIColor? = nil,
                    colorTransformer: NSUIConfigurationColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    pattern: [PatternValue] = [.line])
        {
            self.color = color
            self.width = width
            self.pattern = pattern
            self.colorTransformer = colorTransformer
        }

        public static func none() -> Self {
            return Self()
        }
    }
}

#if os(macOS)
    @available(macOS 10.15.1, *)
    public extension NSView {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: ContentConfiguration.Border) {
            wantsLayer = true
            layer?.configurate(using: configuration)
        }
    }

#elseif canImport(UIKit)
    @available(iOS 14.0, *)
    public extension UIView {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: ContentConfiguration.Border) {
            layer.configurate(using: configuration)
        }
    }
#endif

public extension CALayer {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        if let color = configuration.color {
            borderColor = configuration.resolvedColor(for: color).cgColor
        } else {
            borderColor = nil
        }
        borderWidth = configuration.width
    }
}
