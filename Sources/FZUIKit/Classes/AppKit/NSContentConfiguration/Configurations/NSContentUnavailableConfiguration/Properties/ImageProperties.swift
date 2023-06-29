//
//  ImageProperties.swift
//  
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI
import FZSwiftUtils

@available(macOS 12.0, *)
public extension NSContentUnavailableConfiguration {
    /// Properties that affect the cell content configuration’s image.
    struct ImageProperties: Hashable {
        
        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? = nil
        
        /// The corner radius of the image.
        public var cornerRadius: CGFloat = 0.0
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: SymbolConfiguration? = .font(.largeTitle)
        
        /// The image scaling.
        public var scaling: NSImageScaling = .scaleNone
        
        /// The maximum size of the image.
        public var maxSize: CGSize? = nil
    
        
        /// Creates image properties.
        public init(tintColor: NSColor? = .secondaryLabelColor,
                    cornerRadius: CGFloat = 0.0,
                    symbolConfiguration: SymbolConfiguration? = .font(.largeTitle),
                    scaling: NSImageScaling = .scaleNone,
                    maxSize: CGSize? = nil) {
            self.tintColor = tintColor
            self.cornerRadius = cornerRadius
            self.symbolConfiguration = symbolConfiguration
            self.scaling = scaling
            self.maxSize = maxSize
        }
        
    }
}

@available(macOS 12.0, *)
internal extension NSContentUnavailableConfiguration.SymbolConfiguration {
    func nsSymbolConfiguration() -> NSImage.SymbolConfiguration {
        var configuration: NSImage.SymbolConfiguration
        switch self.colorConfiguration {
        case .hierarchical(let color):
            configuration = .hierarchical(color)
        case .monochrome:
            configuration = .monochrome()
        case .palette(let primary, let secondary, let tertiary):
            configuration = .palette(primary, secondary, tertiary)
        case .multicolor(let color):
            configuration = .multicolor(color)
        case .none:
            configuration = .unspecified
        }
        
        switch self.font {
            case .systemFont(size: let size, weight: let weight):
                configuration = configuration.font(size: size)
            configuration = configuration.weight(weight?.symbolWeight())
            case .textStyle(let style, weight: let weight):
                configuration = configuration.font(style)
            configuration = configuration.weight(weight?.symbolWeight())
            case .none:
                break
        }
        
        if let symbolScale = self.imageScale?.nsSymbolScale {
            configuration = configuration.scale(symbolScale)
        }
        
        return configuration
    }
}

#endif
