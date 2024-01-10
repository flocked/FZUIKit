//
//  NSImageView+Transition.swift
//
//
//  Created by Florian Zand on 01.01.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSImageView {
    var transitionAlpha: CGFloat {
        get { transitionImageView.alphaValue }
        set { transitionImageView.alphaValue = newValue }
    }

    var transitionImage: NSImage? {
        get { transitionImageView.image }
        set { transitionImageView.image = newValue }
    }

    var transitionImageView: NSImageView {
        get { getAssociatedValue(key: "transitionImageView", object: self, initialValue: transitionView()) }
    }

    func transitionView() -> NSImageView {
        let imageView = NSImageView(frame: bounds)
        imageView.imageScaling = imageScaling
        imageView.imageAlignment = imageAlignment
        imageView.imageFrameStyle = imageFrameStyle
        imageView.animates = animates
        if #available(macOS 14.0, *) {
            imageView.preferredImageDynamicRange = preferredImageDynamicRange
        }
        imageView.alphaValue = 0.0
        addSubview(withConstraint: imageView)
        return imageView
    }
}

#endif
