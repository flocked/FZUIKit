//
//  NSContentUnavailableConfiguration+ImageProperties.swift
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
        
        public typealias SymbolConfiguration = ContentConfiguration.SymbolConfiguration
        
        /// The image scaling.
        public var scaling: NSImageScaling = .scaleNone
        
        /**
         A maximum size for the image.
         
         The default value is CGSizeZero. Setting a width or height of zero makes the size unconstrained on that dimension. If the image exceeds maximumSize size on either dimension, the view reduces its size proportionately, maintaining aspect ratio.
         */
        public var maximumSize: CGSize = .zero
        
        internal var maximumWidth: CGFloat? {
            maximumSize.width != 0 ? maximumSize.width : nil
        }
        internal var maximumHeight: CGFloat? {
            maximumSize.height != 0 ? maximumSize.height : nil
        }
    
        
        /// Creates image properties.
        public init(tintColor: NSColor? = .secondaryLabelColor,
                    cornerRadius: CGFloat = 0.0,
                    symbolConfiguration: SymbolConfiguration? = .font(.largeTitle),
                    scaling: NSImageScaling = .scaleNone,
                    maximumSize: CGSize = .zero) {
            self.tintColor = tintColor
            self.cornerRadius = cornerRadius
            self.symbolConfiguration = symbolConfiguration
            self.scaling = scaling
            self.maximumSize = maximumSize
        }
        
    }
}

#endif
