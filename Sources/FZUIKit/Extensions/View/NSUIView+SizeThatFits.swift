//
//  NSUIView+SizeThatFits.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
        import SwiftUI
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import AVKit

public protocol Sizable: NSUIView {
        /**
         Asks the view to calculate and return the size that best fits the specified size.

         The default implementation of this method returns the existing size of the view. Subclasses can override this method to return a custom value based on the desired layout of any subviews.

         This method does not resize the receiver.

         - Parameter size:  The size for which the view should calculate its best-fitting size.
         - Returns: A new size that fits the receiver’s subviews.
         */
        func fittingSize(for size: CGSize) -> CGSize
        /**
         Resizes and moves the receiver view so it just encloses its subviews.

         Call this method when you want to resize the current view so that it uses the most appropriate amount of space.

         You should not override this method. If you want to change the default sizing information for your view, override the `sizeThatFits(_:)` instead. That method performs any needed calculations and returns them to this method, which then makes the change.
         */
        func sizeToFit()
    }

#if os(macOS)
extension NSTextField: Sizable { }
extension NSButton: Sizable { }
extension AVPlayerView: Sizable { }
extension NSImageView: Sizable { }
extension NSStepper: Sizable { }
extension NSSlider: Sizable { }
extension NSSegmentedControl: Sizable { }
extension NSSwitch: Sizable { }
extension NSProgressIndicator: Sizable { }
extension NSLevelIndicator: Sizable { }
extension NSPathControl: Sizable { }
extension NSDatePicker: Sizable { }

#else

#endif

extension Sizable {
    /// Resizes the view to a fitting size.
    public func sizeToFit() {
        frame.size = sizeThatFits()
    }
    
    /// Asks the view to calculate and return the size that best fits.
    public func sizeThatFits() -> CGSize {
        fittingSize(for: CGSize(-1, -1))
    }
    
    /// Asks the view to calculate and return the size that best fits the specified width.
    public func sizeThatFits(width: CGFloat) -> CGSize {
        fittingSize(for: CGSize(width, -1))
    }
    
    /// Asks the view to calculate and return the size that best fits the specified height.
    public func sizeThatFits(height: CGFloat) -> CGSize {
        fittingSize(for: CGSize(-1, height))
    }
    
    /// Asks the view to calculate and return the size that best fits the specified width.
    public func sizeThatFits(width: CGFloat?, height: CGFloat?) -> CGSize {
        fittingSize(for: CGSize(width ?? -1, height ?? -1))
    }
}



    #if os(macOS)
public extension Sizable where Self: SimpleStackView {
}
        public extension Sizable where Self: NSTextField {
            func fittingSize(for size: CGSize) -> CGSize {
                guard let cell = cell else { return fittingSize }
                var size = size
                if size.width == -1 || size.width == 0 {
                    size.width = 40000
                }
                if size.height == -1 || size.height == 0 {
                    size.height = 40000
                }
                size = size.clamped(to: CGSize.zero...)
                return cell.cellSize(forBounds: CGRect(.zero, size))
            }
        }

        public extension Sizable where Self: NSButton {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
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

        public extension Sizable where Self: NSSegmentedControl {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

public extension Sizable where Self: NSSwitch {
            func fittingSize(for size: CGSize) -> CGSize {
                fittingSize
            }
        }

        public extension Sizable where Self: NSProgressIndicator {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if style == .spinning { return fittingSize }
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSLevelIndicator {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSPathControl {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > 0, size.width.isFinite {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSDatePicker {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if datePickerStyle != .clockAndCalendar, size.width > 0, size.width.isFinite {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSSlider {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if sliderType == .circular { return fittingSize }
                if isVertical == false, size.width > fittingSize.width {
                    fittingSize.width = size.width
                } else if isVertical, size.height > fittingSize.height {
                    fittingSize.height = size.height
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSStepper {
            func fittingSize(for size: CGSize) -> CGSize {
                fittingSize
            }
        }

        public extension Sizable where Self: NSComboBox {
            func fittingSize(for size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSImageView {
            func fittingSize(for size: CGSize) -> CGSize {
                image?.size ?? bounds.size
            }
        }

        public extension Sizable where Self: AVPlayerView {
            func fittingSize(for size: CGSize) -> CGSize {
                player?.currentItem?.asset.videoNaturalSize ?? bounds.size
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
#endif
