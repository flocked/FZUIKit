//
//  SimpleImageView.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
    import AppKit

    @available(macOS 12.0, *)
    public struct SimpleImageView: NSViewRepresentable {
        public typealias NSViewType = ImageView

        private var imageScaling: ImageView.ImageScaling
        private var image: NSImage?
        private var images: [NSImage]
        private var symbolConfiguration: NSImage.SymbolConfiguration?
        private var tintColor: NSColor?
        private var animates: Bool

        public init(images: [NSImage],
                    imageScaling: ImageView.ImageScaling)
        {
            image = nil
            self.imageScaling = imageScaling
            self.images = images
            tintColor = nil
            symbolConfiguration = nil
            animates = false
        }

        public init(image: NSImage,
                    imageScaling: ImageView.ImageScaling, animates: Bool = true, symbolConfiguration: NSImage.SymbolConfiguration? = nil, tintColor: NSColor? = nil)
        {
            self.image = image
            self.imageScaling = imageScaling
            self.tintColor = tintColor
            self.symbolConfiguration = symbolConfiguration
            images = []
            self.animates = animates
        }

        public init(symbolName: String, symbolConfiguration: NSImage.SymbolConfiguration? = nil, tintColor: NSColor? = nil) {
            image = NSImage(systemSymbolName: symbolName)
            self.symbolConfiguration = symbolConfiguration
            self.tintColor = tintColor
            imageScaling = .none
            images = []
            animates = false
        }

        public func makeNSView(context _: Context) -> ImageView {
            let view = ImageView()
            if let image = image {
                view.image = image
            } else {
                view.images = images
            }
            view.imageScaling = imageScaling
            view.tintColor = tintColor
            view.symbolConfiguration = symbolConfiguration
            if animates {
                view.startAnimating()
            } else {
                view.stopAnimating()
            }
            return view
        }

        public func updateNSView(_ nsView: ImageView, context _: Context) {
            if let image = image {
                nsView.image = image
            } else {
                nsView.images = images
            }
            nsView.imageScaling = imageScaling
            nsView.symbolConfiguration = symbolConfiguration
            nsView.tintColor = tintColor
            if animates {
                nsView.startAnimating()
            } else {
                nsView.stopAnimating()
            }
        }

        public func imageScaling(_ imageScaling: ImageView.ImageScaling) -> SimpleImageView {
            var view = self
            view.imageScaling = imageScaling
            return view
        }

        public func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration?) -> SimpleImageView {
            var view = self
            view.symbolConfiguration = configuration
            return view
        }

        public func tintColor(_ tintColor: NSColor?) -> SimpleImageView {
            var view = self
            view.tintColor = tintColor
            return view
        }

        public func animates(_ animates: Bool) -> SimpleImageView {
            var view = self
            view.animates = animates
            return view
        }
    }
#endif
