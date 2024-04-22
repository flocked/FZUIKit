//
//  NSUIView+SizeThatFits.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import SwiftUI
import AVKit

public protocol Sizable: NSUIView {
        /**
         Asks the view to calculate and return the size that best fits the specified size.

         The default implementation of this method returns the existing size of the view. Subclasses can override this method to return a custom value based on the desired layout of any subviews.

         This method does not resize the receiver.

         - Parameter size:  The size for which the view should calculate its best-fitting size.
         - Returns: A new size that fits the receiver’s subviews.
         */
        func sizeThatFits(_ size: CGSize) -> CGSize
        /**
         Resizes and moves the receiver view so it just encloses its subviews.

         Call this method when you want to resize the current view so that it uses the most appropriate amount of space.

         You should not override this method. If you want to change the default sizing information for your view, override the `sizeThatFits(_:)` instead. That method performs any needed calculations and returns them to this method, which then makes the change.
         */
        func sizeToFit()
    }

// extension NSView: Sizable { }
extension NSControl: Sizable { }

extension Sizable {
    /// Asks the view to calculate and return the size that best fits the specified width and height.
    public func sizeThatFits(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        sizeThatFits(CGSize(width ?? NSView.noIntrinsicMetric, height ?? NSView.noIntrinsicMetric))
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        bounds.size
    }
    
    public func sizeToFit() {
        frame.size = sizeThatFits()
    }
}

protocol ExpandingSizable: NSUIView {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize
}

extension NSButton: ExpandingSizable { }
extension NSSlider: ExpandingSizable { }
extension NSSegmentedControl: ExpandingSizable { }
extension NSProgressIndicator: ExpandingSizable { }
extension NSLevelIndicator: ExpandingSizable { }
extension NSPathControl: ExpandingSizable { }
extension NSDatePicker: ExpandingSizable { }

extension ExpandingSizable where Self: NSButton {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        let styles: [NSButton.BezelStyle] = [.helpButton, .disclosure, .roundedDisclosure, .circular, .smallSquare]
        let buttonType = buttonType.rawValue
        if !styles.contains(where: {$0.rawValue == buttonType}), !isBordered {
            if size.width > fittingSize.width {
                fittingSize.width = size.width
            }
            if size.height > fittingSize.height {
                fittingSize.height = size.height
            }
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSSegmentedControl {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if size.width > fittingSize.width {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSProgressIndicator {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = fittingSize
        if style == .spinning { return fittingSize }
        if size.width > fittingSize.width {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSLevelIndicator {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if size.width > fittingSize.width {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSPathControl {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if size.width > 0, size.width.isFinite {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSDatePicker {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if datePickerStyle != .clockAndCalendar, size.width > 0, size.width.isFinite {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSSlider {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if sliderType == .circular { return fittingSize }
        if isVertical == false, size.width > fittingSize.width {
            fittingSize.width = size.width
        } else if isVertical, size.height > fittingSize.height {
            fittingSize.height = size.height
        }
        return fittingSize
    }
}

extension ExpandingSizable where Self: NSComboBox {
    func expandingSizeThatFits(_ size: CGSize) -> CGSize {
        var fittingSize = sizeThatFits(size)
        if size.width > fittingSize.width {
            fittingSize.width = size.width
        }
        return fittingSize
    }
}

/*
 public extension Sizable where Self: NSStackView {
     func sizeThatFits(_ size: CGSize) -> CGSize {
         if constraints.isEmpty, translatesAutoresizingMaskIntoConstraints == false {
             if self.orientation == .vertical {
                 if size.width != -1, size.width > 0 {
                     let width = self.widthAnchor.constraint(equalToConstant: size.width).activate()
                     let fittingSize = self.fittingSize
                     width.activate(false)
                     return fittingSize
                 }
             } else {
                 if size.height != -1, size.height > 0 {
                     let height = self.heightAnchor.constraint(equalToConstant: size.height).activate()
                     let fittingSize = self.fittingSize
                     height.activate(false)
                     return fittingSize
                 }
             }
         }
         return self.fittingSize
     }
 }
 */
#endif
