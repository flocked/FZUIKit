//
//  Image+.swift
//
//
//  Created by Florian Zand on 30.09.22.
//

import Foundation
import SwiftUI

public protocol ImageModifier {
    associatedtype Body: View
    @ViewBuilder func body(image: Image) -> Self.Body
}

public extension Image {
    func modifier<M>(_ modifier: M) -> some View where M: ImageModifier {
        modifier.body(image: self)
    }
}

extension Image {
    
    /// The image scaling.
    public enum ImageScaling: Int, Hashable {
        /// The image is resized to fit the bounds rectangle, preserving the aspect of the image. If the image does not completely fill the bounds rectangle, the image is centered in the partial axis.
        case scaleToFit
        /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect of the image.
        case scaleToFill
        /// The image is resized to fit the entire bounds rectangle.
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
    
    /// Constrains this image’s dimensions to the specified image scaling.
    @ViewBuilder
    public func imageScaling(_ scaling: ImageScaling) -> some View {
        if scaling == .none {
            self
        } else if let contentMode = scaling.contentMode {
            self.resizable().aspectRatio(contentMode: contentMode)
        } else {
            self.resizable()
        }
    }
}

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension Image {
    /// Creates a SwiftUI image from an AppKit/UIKit image instance.
    init(_ image: NSUIImage) {
        self = image.swiftui
    }
}

public extension NSUIImage {
    /// A SwiftUI representation of the image.
    var swiftui: Image {
        if #available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *), let symbolName = symbolName {
            return Image(systemName: symbolName)
        }
        #if os(macOS)
            if isTemplate {
                return Image(nsImage: self).renderingMode(.template)
            } else {
                return Image(nsImage: self)
            }
        #elseif canImport(UIKit)
            if renderingMode == .alwaysTemplate || isSymbolImage {
                return Image(uiImage: self).renderingMode(.template)
            } else {
                return Image(uiImage: self)
            }
        #endif
    }
}
