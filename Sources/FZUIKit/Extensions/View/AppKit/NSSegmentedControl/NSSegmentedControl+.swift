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
        (0..<segmentCount).forEach({ setSelected(true, forSegment: $0) })
    }
    
    /// Deselects all segments.
    func deselectAll() {
        (0..<segmentCount).forEach({ setSelected(false, forSegment: $0) })
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
        segmentViews[safe: segment]?.value(forKeySafely: "font") as? NSFont
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
    
    /// Returns the index of the segment at the specified location.
    func indexOfSegment(at location: CGPoint) -> Int? {
        segmentViews.firstIndex(where: { $0.frame.contains(location) })
    }
    
    /**
     Sets the selection state of the specified segment.
     
     - Parameters:
        - select: `true` if you want to select the segment; otherwise, `false`.
        - segment: The index of the segment whose selection state you want to set.
        - exclusive: If `true`, all other segments will be deselected/selected.
     */
    func setSelected(_ selected: Bool, forSegment segment: Int, exclusive: Bool) {
        guard segment >= 0 && segment < segmentCount else { return }
        for index in 0..<segmentCount {
            if index == segment {
                setSelected(selected, forSegment: index)
            } else if exclusive {
                setSelected(!selected, forSegment: index)
            }
        }
    }
    /**
     A Boolean value indicating whether to select a segment exclusively on right click.
     
     If set to `true`, right clicking a segment deselects all other segments. The default value is `false`.
     */
    var selectsExclusivelyOnRightClick: Bool {
        get { selectsExclusivelyOnRightClickHook != nil }
        set {
            guard newValue != selectsExclusivelyOnRightClick else { return }
            if newValue {
                do {
                    selectsExclusivelyOnRightClickHook = try hook(#selector(NSView.rightMouseDown(with:)), closure: { original, view, sel, event in
                        if view.trackingMode == .selectAny, let index = view.indexOfSegment(at: event.location(in: view)) {
                            view.setSelected(true, forSegment: index, exclusive: true)
                            view.performAction()
                        } else {
                            original(view, sel, event)
                        }
                    } as @convention(block) ((NSSegmentedControl, Selector, NSEvent) -> Void, NSSegmentedControl, Selector, NSEvent) -> Void)
                } catch {
                    debugPrint(error)
                }
            } else {
                selectsExclusivelyOnRightClickHook?.isActive = false
                selectsExclusivelyOnRightClickHook = nil
            }
        }
    }
    
    internal var segmentViews: [NSView] {
        subviews(type: "NSSegmentItemView")
    }
    
    internal var selectsExclusivelyOnRightClickHook: Hook? {
        get { getAssociatedValue("selectsExclusivelyOnRightClickHook") }
        set { setAssociatedValue(newValue, key: "selectsExclusivelyOnRightClickHook") }
    }
}
#endif
