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

    public protocol Sizable {
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

        /// The minimum size of the view that satisfies the constraints it holds.
        var fittingSize: CGSize { get }
    }

    extension NSUIView: Sizable {}

    public extension Sizable where Self: NSUIView {
        var fittingSize: CGSize {
            sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        }

        func sizeToFit() {
            frame.size = sizeThatFits(CGSize(NSUIView.noIntrinsicMetric, NSUIView.noIntrinsicMetric))
        }

        func sizeThatFits(_: CGSize) -> CGSize {
            frame.size
        }
    }

    public extension Sizable where Self: NSUIView {
        /// Asks the view to calculate and return the size that best fits the specified width and height.
        func sizeThatFits(width: CGFloat?, height: CGFloat?) -> CGSize {
            sizeThatFits(CGSize(width: width ?? NSUIView.noIntrinsicMetric, height: height ?? NSUIView.noIntrinsicMetric))
        }
    }

    #if os(macOS)
        public extension Sizable where Self: NSTextField {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var size = size
                if size.width == NSView.noIntrinsicMetric {
                    size.width = 40000
                }
                if size.height == NSView.noIntrinsicMetric {
                    size.height = 40000
                }
                size.width = size.width.clamped(min: 0)
                size.height = size.height.clamped(min: 0)

                if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: size.width, height: size.height)) {
                    return CGSize(size.width, cellSize.height)
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSButton {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                let styles: [NSButton.BezelStyle] = [.helpButton, .disclosure, .roundedDisclosure, .circular, .smallSquare]
                let buttonType = buttonType.rawValue
                if size.width > fittingSize.width, styles.contains(where: { $0.rawValue == buttonType }) == false {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSSegmentedControl {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSSwitch {
            func sizeThatFits(_: CGSize) -> CGSize {
                fittingSize
            }
        }

        public extension Sizable where Self: NSProgressIndicator {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if style == .spinning { return fittingSize }
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSLevelIndicator {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSPathControl {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > 0, size.width.isFinite {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSDatePicker {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if datePickerStyle != .clockAndCalendar, size.width > 0, size.width.isFinite {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSSlider {
            func sizeThatFits(_ size: CGSize) -> CGSize {
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
            func sizeThatFits(_: CGSize) -> CGSize {
                fittingSize
            }
        }

        public extension Sizable where Self: NSComboBox {
            func sizeThatFits(_ size: CGSize) -> CGSize {
                var fittingSize = fittingSize
                if size.width > fittingSize.width {
                    fittingSize.width = size.width
                }
                return fittingSize
            }
        }

        public extension Sizable where Self: NSImageView {
            func sizeThatFits(_: CGSize) -> CGSize {
                image?.size ?? bounds.size
            }
        }

        public extension Sizable where Self: AVPlayerView {
            func sizeThatFits(_: CGSize) -> CGSize {
                player?.currentItem?.asset.videoNaturalSize ?? bounds.size
            }
        }

        /*
         public extension Sizable where Self: NSStackView {
             func sizeThatFits(_ size: CGSize) -> CGSize {
                 if constraints.isEmpty, translatesAutoresizingMaskIntoConstraints == false {
                     if self.orientation == .vertical {
                         if size.width != NSView.noIntrinsicMetric, size.width > 0 {
                             let width = self.widthAnchor.constraint(equalToConstant: size.width).activate()
                             let fittingSize = self.fittingSize
                             width.activate(false)
                             return fittingSize
                         }
                     } else {
                         if size.height != NSView.noIntrinsicMetric, size.height > 0 {
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
