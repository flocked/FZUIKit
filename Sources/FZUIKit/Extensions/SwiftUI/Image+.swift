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
        if #available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *), let symbolName = self.symbolName {
               return Image(systemName: symbolName)
        }
        #if os(macOS)
        if self.isTemplate {
            return Image(nsImage: self).renderingMode(.template)
        } else {
            return Image(nsImage: self)
        }
        #elseif canImport(UIKit)
        if self.renderingMode == .alwaysTemplate || self.isSymbolImage {
            return Image(uiImage: self).renderingMode(.template)
        } else {
            return Image(uiImage: self)
        }
        #endif
    }
}
