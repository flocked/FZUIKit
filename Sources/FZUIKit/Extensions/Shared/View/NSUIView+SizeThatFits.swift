//
//  NSUIView+SizeThatFits.swift
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
    /**
     Asks the view to calculate and return the size that best fits the specified size.
     
     The default implementation of this method returns the existing size of the view. Subclasses can override this method to return a custom value based on the desired layout of any subviews.
     
     This method does not resize the receiver.
     
     - Parameters size:  The size for which the view should calculate its best-fitting size.
     - Returns: A new size that fits the receiver’s subviews.
     */
    func sizeThatFits(_ size: CGSize) -> CGSize
    /**
     Resizes and moves the receiver view so it just encloses its subviews.

     Call this method when you want to resize the current view so that it uses the most appropriate amount of space.
     
     You should not override this method. If you want to change the default sizing information for your view, override the `sizeThatFits(_:)` instead. That method performs any needed calculations and returns them to this method, which then makes the change.
     */
    func sizeToFit()
    
    /// The minimum size of the view that satisfies the constraints it holds.
    var fittingSize: CGSize { get }
}

extension NSUIView: Sizable { }

public extension Sizable where Self: NSUIView {
    var fittingSize: CGSize {
        sizeThatFits(CGSize(width: 100000, height: 100000))
    }
    
    func sizeToFit() {
        self.frame.size = self.sizeThatFits(CGSize(NSUIView.noIntrinsicMetric, NSUIView.noIntrinsicMetric))
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.frame.size
        /*
        let rect = self.subviews.compactMap({$0.frame}).union()
        if rect.origin.x < 0 {
            frame.origin.x =  frame.origin.x+rect.origin.x
        }
        if rect.origin.y < 0 {
            frame.origin.y =  frame.origin.x+rect.origin.y
        }
        if rect.size != .zero {
            frame.size = rect.size
        } else if self.intrinsicContentSize != CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric) {
            frame.size = self.intrinsicContentSize
        } else if fittingSize != .zero {
            frame.size = fittingSize
        }
         */
    }
}

public extension Sizable where Self: NSUIView {
    /// Asks the view to calculate and return the size that best fits the specified width and height.
    func sizeThatFits(width: CGFloat?, height: CGFloat?) -> CGSize {
        return sizeThatFits(CGSize(width: width ?? NSUIView.noIntrinsicMetric, height: height ?? NSUIView.noIntrinsicMetric))
    }
}

extension NSUIHostingController: Sizable {
    public var fittingSize: CGSize {
        return view.fittingSize
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits(in: size)
    }
    
    public func sizeToFit() {
        view.frame.size = fittingSize
    }
}

#if os(macOS)
public extension Sizable where Self: ResizingTextField {
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
}

public extension Sizable where Self: NSTextField {
    func sizeThatFits(_ size: CGSize) -> CGSize {
        if size.height == NSView.noIntrinsicMetric, size.width != NSView.noIntrinsicMetric {
            let compression = self.contentCompressionResistancePriority(for: .horizontal)
            let maxWidth = self.preferredMaxLayoutWidth
            self.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
            self.preferredMaxLayoutWidth = size.width
            self.invalidateIntrinsicContentSize()
            let intrinsicContentSize = self.intrinsicContentSize
            self.setContentCompressionResistancePriority(compression, for: .horizontal)
            self.preferredMaxLayoutWidth = maxWidth
            self.invalidateIntrinsicContentSize()
            return intrinsicContentSize
        }
        self.invalidateIntrinsicContentSize()
        let intrinsicContentSize = intrinsicContentSize
        if intrinsicContentSize != CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric) {
            return intrinsicContentSize
        }
        return self.frame.size
    }
}

public extension Sizable where Self: NSImageView {
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return image?.size ?? self.frame.size
    }
}
#endif
