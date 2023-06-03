//
//  File.swift
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
public extension Image {
    init(_ nsImage: NSImage) {
        self = nsImage.uiImage
    }
}

public extension NSImage {
    var uiImage: Image {
        if #available(macOS 11.0, *), let systemName = self.systemSymbolName {
               return Image(systemName: systemName)
        }
        if self.isTemplate {
            return Image(nsImage: self).renderingMode(.template)
        } else {
            return Image(nsImage: self)
        }
    }
}
#endif
