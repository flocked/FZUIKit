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
    func sizeThatFits(_ size: CGSize) -> CGSize
    var fittingSize: CGSize { get }
}

extension NSUIView: Sizable { }


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
    func sizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize: CGSize? = nil
        
        let originalWidthConstraint: NSLayoutConstraint? = self.constraints.first(where: {$0.firstAttribute == .width
            || $0.secondAttribute == .width
        })
        let originalHeightConstraint: NSLayoutConstraint? = self.constraints.first(where: {$0.firstAttribute == .height
            || $0.secondAttribute == .height
        })
        
        let widthConstraint = (size.width != NSUIView.noIntrinsicMetric) ? self.widthAnchor.constraint(equalToConstant: (size.width == .infinity) ? 100000 : size.width) : nil
        let heightConstraint = (size.width != NSUIView.noIntrinsicMetric) ? self.heightAnchor.constraint(equalToConstant: (size.height == .infinity) ? 100000 : size.height) : nil
        
        if widthConstraint != nil {
            originalWidthConstraint?.isActive = false
        }
        
        if heightConstraint != nil {
            originalHeightConstraint?.isActive = false
        }
        
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
        fittingSize = self.fittingSize
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        originalWidthConstraint?.isActive = true
        originalHeightConstraint?.isActive = true
        return fittingSize ?? self.fittingSize
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
        sizeThatFits(CGSize(width: 10000, height: 10000))
    }
}
#endif
