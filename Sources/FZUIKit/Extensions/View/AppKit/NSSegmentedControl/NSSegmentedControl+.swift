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
        
        /// Sets the visual style used to display the control.
        @discardableResult
        func style(_ style: Style) -> Self {
            segmentStyle = style
            return self
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
            segmentViews[safe: segment]?.value(forKey: Keys.font.unmangled) as? NSFont
        }
        
        /**
         Sets the font for the specified segment.
         
         - Parameters:
            - font: The label for the segment.
            - index: The index of the segment whose label you want to set.
         */
        func setFont(_ font: NSFont, forSegment segment: Int) {
            segmentViews[safe: segment]?.setValue(font, forKey: Keys.font.unmangled)
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
        
        private struct Keys {
            static let font = "font".mangled
        }
    }
#endif
