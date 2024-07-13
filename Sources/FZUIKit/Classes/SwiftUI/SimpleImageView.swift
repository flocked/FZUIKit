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

        var image: NSImage?
        var images: [NSImage] = []
        var imageScaling: ImageView.ImageScaling = .scaleToFit
        var symbolConfiguration: NSImage.SymbolConfiguration?
        var tintColor: NSColor?
        var animates: Bool = false

        /**
         Creates a image view with the specified image.
         
         - Parameter image: The image.
         */
        public init(_ image: NSImage) {
            self.image = image
        }

        /**
         Creates a image view with the specified system symbol image.
         
         - Parameter systemName: The name of the system symbol image. Use the SF Symbols app to look up the names of system symbol images.
         */
        public init(systemName: String) {
            image = NSImage(systemSymbolName: systemName)
            imageScaling = .none
        }
        
        /**
         Creates a image view with the specified images.
         
         - Parameter images: The images.
         */
        public init(_ images: [NSImage]) {
            self.images = images
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
        
        /// Sets the image displayed in the image view.
        public func image(_ image: NSImage?) -> SimpleImageView {
            var view = self
            view.image = image
            view.images = []
            return view
        }
        
        /// Sets the images displayed by the image view.
        public func images(_ images: [NSImage]) -> SimpleImageView {
            var view = self
            view.images = images
            view.image = nil
            return view
        }

        /// Sets the image scaling.
        public func imageScaling(_ imageScaling: ImageView.ImageScaling) -> SimpleImageView {
            var view = self
            view.imageScaling = imageScaling
            return view
        }

        /// Sets the symbol configuration of the image.
        public func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration?) -> SimpleImageView {
            var view = self
            view.symbolConfiguration = configuration
            return view
        }

        /// Sets the image tint color for template and symbol images.
        public func tintColor(_ tintColor: NSColor?) -> SimpleImageView {
            var view = self
            view.tintColor = tintColor
            return view
        }

        /// Sets the Boolean value that indicates whether the image animates.
        public func animates(_ animates: Bool) -> SimpleImageView {
            var view = self
            view.animates = animates
            return view
        }
    }
#endif
