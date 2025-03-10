//
//  NSColorMenuItem.swift
//
//
//  Created by Florian Zand on 08.03.25.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A menu item that displays a color.
public class NSColorMenuItem: NSMenuItem {
    
    /// Color style of the menu item.
    public enum Style: Int, Hashable {
        /// Rounded rectangle.
        case roundedRectangle
        /// Rectangle.
        case rectangle
        /// Circular.
        case circular
        /// Capsule.
        case capsule
    }
    
    /// The color style of the menu item.
    public var style: Style {
        get { itemView.hostingView.rootView.style }
        set { itemView.setRootView(.init(color: color, title: itemView.hostingView.rootView.title, style: newValue, colorIsLeading: colorIsLeading)) }
    }
    
    /// Sets the color style of the menu item.
    @discardableResult
    public func style(_ style: Style) -> Self {
        self.style = style
        return self
    }
    
    public override var title: String {
        get { itemView.hostingView.rootView.title ?? "" }
        set { itemView.setRootView(.init(color: color, title: newValue, style: style, colorIsLeading: colorIsLeading)) }
    }
    
    /// A Boolean value that indicates whether the color is leading the text.
    public var colorIsLeading: Bool {
        get { itemView.hostingView.rootView.colorIsLeading }
        set { itemView.setRootView(.init(color: color, title: itemView.hostingView.rootView.title, style: style, colorIsLeading: newValue)) }
    }
    
    /// Sets the Boolean value that indicates whether the color is leading the text.
    @discardableResult
    public func colorIsLeading(_ isLeading: Bool) -> Self {
        self.colorIsLeading = isLeading
        return self
    }
    
    /// The color.
    public var color: NSColor {
        get { itemView.hostingView.rootView.color }
        set { itemView.setRootView(.init(color: newValue, title: itemView.hostingView.rootView.title, style: style, colorIsLeading: colorIsLeading)) }
    }
    
    /// Sets the color.
    @discardableResult
    public func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    /**
     The width of the menu item.
     
     A value of `nil` automatically adjusts the width to fit the title.
     */
    public var itemWidth: CGFloat? {
        get { itemView.width }
        set { itemView.width = newValue }
    }
    
    /**
     Sets the width of the menu item.
     
     A value of `nil` automatically adjusts the width to fit the title.
     */
    @discardableResult
    public func itemWidth(_ width: CGFloat?) -> Self {
        self.itemWidth = itemWidth
        return self
    }
    
    /**
     Creates a menu item that displays the specified color and title.
     
     - Parameters:
        - color: The color of the menu item.
        - title: The title of the menu item.
        - style: The color style of the menu item.
        - colorIsLeading: A Boolean value that indicates whether the color is leading the text.
        - itemWidth: The width of the menu item.
        - action: The action block of the menu item.
     */
    public init(_ color: NSColor, title: String? = nil, style: Style = .roundedRectangle, colorIsLeading: Bool = true, itemWidth: CGFloat? = nil, action: ActionBlock? = nil) {
        super.init(title: "", action: nil, keyEquivalent: "")
        view = MenuItemView(color: color, title: title, style: .init(rawValue: style.rawValue)!, colorIsLeading: colorIsLeading, width: itemWidth)
        actionBlock = action
    }
        
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NSColorMenuItem {
    var itemView: MenuItemView {
        view as! MenuItemView
    }
    
    class MenuItemView: NSMenuItemView {
        let hostingView: NSHostingView<ColorTitleView>
        
        var width: CGFloat? = nil {
            didSet { frame.size.width = (width ?? hostingView.fittingSize.width).clamped(min: hostingView.fittingSize.width) }
        }
        
        func setRootView(_ rootView: ColorTitleView) {
            hostingView.rootView = rootView
            frame.size.width = (width ?? hostingView.fittingSize.width).clamped(min: hostingView.fittingSize.width)
        }
        
        init(color: NSColor, title: String? = nil, style: Style, colorIsLeading: Bool, width: CGFloat? = nil) {
            hostingView = .init(rootView: .init(color: color, title: title, style: style, colorIsLeading: colorIsLeading))
            super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
            addSubview(hostingView, layoutAutomatically: true)
            self.width = width
            frame.size.width = (width ?? hostingView.fittingSize.width).clamped(min: hostingView.fittingSize.width)
            showsHighlight = true
            contentMargins = NSEdgeInsets(top: 3, left: 13, bottom: 3, right: 13)
            highlightMargins = NSEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct ColorTitleView: View {
        let color: NSColor
        let title: String?
        let style: Style
        let colorIsLeading: Bool
        
        @ViewBuilder
        var colorView: some View {
            switch style {
            case .capsule:
                Capsule()
                    .modify(Color(color), shape: Capsule())
                    .frame(width: 26, height: 16)
            case .circular:
                Circle()
                    .modify(Color(color), shape: Circle())
                    .frame(width: 16, height: 16)
            default:
                RoundedRectangle(cornerRadius: style == .roundedRectangle ? 3.0 : 0.0)
                    .modify(Color(color), shape: RoundedRectangle(cornerRadius: style == .roundedRectangle ? 3.0 : 0.0))
                    .frame(width: 26, height: 16)
            }
        }
        
        var font: Font {
            if let font = NSUIFont(name: ".AppleSystemUIFont", size: 13.0) {
                return Font(font)
            }
            return .body.weight(.medium)
        }
        
        @ViewBuilder
        var titleView: some View {
            if let title = title {
                Text(title)
                    .font(font)
            }
        }
        
        var body: some View {
            HStack(alignment: .center, spacing: 6) {
                if colorIsLeading {
                    colorView
                    titleView
                    Spacer()
                } else {
                    titleView
                    Spacer()
                    colorView
                }
            }
        }
    }
}

fileprivate extension View {
    func modify<S: Shape>(_ color: Color, shape: S) -> some View {
        modifier(ColorViewModifier(color: color, shape: shape))
    }
}

fileprivate struct ColorViewModifier<S: Shape>: ViewModifier {
    let color: Color
    let shape: S

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(macOS 13.0, *) {
            content.foregroundStyle(color.shadow(.inner(color: Color(NSColor.shadowColor), radius: 3, x: 0, y: 0)))
        } else if #available(macOS 12.0, *) {
            content.foregroundStyle(color)
        } else {
            content.overlay(shape)
        }
    }
}
/*
 <NSContextMenuItemView> (0.0, 0.0, 91.0, 22.0)
 <_NSMenuItemTextField> (12.0, 3.0, 73.0, 16.0) ".AppleSystemUIFont 13.00 pt. P [] spc=3.58"
 */
#endif
