//
//  ContainerView.swift
//
//
//  Created by Florian Zand on 09.06.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// A SwiftUI view that displays a `NSView` / `UIView`.
public struct ContainerView<Content: NSUIView>: NSUIViewRepresentable {
    public let view: Content

    public init(view: Content) {
        self.view = view
    }

    #if os(macOS)
    public typealias NSViewType = Content

    public func updateNSView(_: Content, context _: Context) {}

    public func makeNSView(context _: Context) -> Content {
        view
    }

    #elseif canImport(UIKit)
    public typealias UIViewType = Content

    public func updateUIView(_: Content, context _: Context) {}

    public func makeUIView(context _: Context) -> Content {
        view
    }
    #endif
}
#endif
