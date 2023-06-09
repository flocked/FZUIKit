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
        
        /// The color of the border.
        public var color: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the border color.
        public var colorTransformer: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved border color for the specified border color, using the border color and color transformer.
        public func resolvedColor() -> NSUIColor? {
            if let color = self.color {
                return colorTransformer?(color) ?? color
            }
            return nil
        }
        
        /// The width of the border.
        public var width: CGFloat = 0.0
        /// The pattern of the border.
        public var pattern: [PatternValue] = [.line]
                
        public enum PatternValue: Int {
            case line
            case space
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
            self.updateResolvedColor()
        }

        public static func none() -> Self {
            return Self()
        }
        
        public static func black() -> Self {
            Self(color: .black, width: 1.0)
        }
        
        internal var _resolvedColor: NSColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
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
        borderColor = configuration._resolvedColor?.cgColor
        borderWidth = configuration.width
    }
}
