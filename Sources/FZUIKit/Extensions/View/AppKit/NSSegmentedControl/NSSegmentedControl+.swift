//
//  NSSegmentedControl+.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils

    public extension NSSegmentedControl {
        /// Selects all segments.
        func selectAll() {
            let count = segmentCount - 1
            for index in 0 ... count {
                setSelected(true, forSegment: index)
            }
        }

        /// Deselects all segments.
        func deselectAll() {
            let count = segmentCount - 1
            for index in 0 ... count {
                setSelected(false, forSegment: index)
            }
        }
        
        /// Sets the type of tracking behavior the control exhibits.
        @discardableResult
        func trackingMode(_ mode: SwitchTracking) -> Self {
            trackingMode = mode
            return self
        }
        
        /// The visual style used to display the segmented control.
        var style: Styling {
            get { .init(segmentStyle) }
            set { segmentStyle = newValue.segmentStyle }
        }
        
        /// Sets the visual style used to display the segmented control.
        @discardableResult
        func style(_ style: Styling) -> Self {
            segmentStyle = style.segmentStyle
            return self
        }
        
        ///  The visual style used to display a segmented control.
        enum Styling: Int, CaseIterable {
            /// The appearance of the segmented control is automatically determined based on the type of window in which the control is displayed and the position within the window.
            case automatic = 0
            /// Rounded.
            case rounded = 1
            /// Round rect.
            case roundRect = 3
            /// Capsule.
            case capsule = 5
            /// Square.
            case square = 6
            /// The segments of the segmented control are displayed very close to each other but not touching.
            case separated = 8
            
            init(_ style: Style) {
                switch style {
                case .rounded, .texturedRounded: self = .rounded
                case .roundRect: self = .roundRect
                case .smallSquare: self = .square
                case .separated: self = .separated
                case .capsule, .texturedSquare: self = .capsule
                default: self = .automatic
                }
            }
            
            var segmentStyle: Style {
                .init(rawValue: rawValue) ?? .automatic
            }
        }
        
        /// The indexes of the selected segments.
        var indexesOfSelectedSegments: [Int] {
            (0..<segmentCount).filter { isSelected(forSegment: $0) }
        }
        
        /**
         Returns the font of the specified segment.

         - Parameter segment:The index of the segment whose font you want to get.
         */
        func font(forSegment segment: Int) -> NSFont? {
            segmentViews[safe: segment]?.value(forKey: "font") as? NSFont
        }
        
        /**
         Sets the font for the specified segment.
         
         - Parameters:
            - font: The label for the segment.
            - index: The index of the segment whose label you want to set.
         */
        func setFont(_ font: NSFont, forSegment segment: Int) {
            segmentViews[safe: segment]?.setValue(safely: font, forKey: "font")
        }
                
        /**
         Returns the frame of the specified segment.

         - Parameter segment:The index of the segment whose frame you want to get.
         */
        func frame(forSegment segment: Int) -> CGRect? {
            segmentViews[safe: segment]?.frame
        }
        
        internal var segmentViews: [NSView] {
            subviews.filter({ NSStringFromClass(type(of: $0)) == "NSSegmentItemView" })
        }
    }
#endif
