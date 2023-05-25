//
//  File.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import SwiftUI
#elseif canImport(UIKit)
import UIKit
#endif

public protocol Sizable {
    func sizeThatFits(_ size: CGSize) -> CGSize
    var fittingSize: CGSize { get }
}

extension NSUIView: Sizable {}

public extension Sizable where Self: NSUIView {
    func sizeToFit(size: CGSize) {
        frame.size = sizeThatFits(size)
    }

    func sizeToFit() {
        frame.size = fittingSize
    }

    func sizeToFit(width: CGFloat?, height: CGFloat?) {
        frame.size = sizeThatFits(width: width, height: height)
    }

    func sizeThatFits(width: CGFloat?, height: CGFloat?) -> CGSize {
        return sizeThatFits(CGSize(width: width ?? NSUIView.noIntrinsicMetric, height: height ?? NSUIView.noIntrinsicMetric))
    }
}

#if os(macOS)
public extension Sizable where Self: NSView {
    func sizeThatFits(_: CGSize) -> CGSize {
        return fittingSize
    }
}

extension NSHostingController: Sizable {
    public var fittingSize: CGSize {
        return view.fittingSize
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits(in: size)
    }

    public func sizeToFit(size: CGSize) {
        view.frame.size = sizeThatFits(size)
    }

    public func sizeToFit() {
        view.frame.size = fittingSize
    }
}
#endif

#if canImport(UIKit)
public extension Sizable where Self: NSUIView {
    var fittingSize: CGSize {
        sizeThatFits(bounds.size)
    }
}
#endif
