//
//  NSMenuItemView.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A view that can be used as view of a `NSMenuItem` and displays a highlight background when the menu item is highlighted.
 
 If ``showsHighlight`` is enabled, the view renders an appropriate backdrop behind the view when the enclosing menu item is highlighed.

 # Overview
 This view is designed to be used as the `view` property of an `NSMenuItem`. By default, the view is empty: you can design your own content and add it as a subview of a `NSMenuItemView` instance to automatically get menu-like behaviors such as selection, highlighting, and flashing animations when clicked.

 The general use-case is that you pass a custom view to ``addSubview(_:layoutAutomatically:)`` and let the `NSMenuItemView` handle everything.

 ```swift
 let customView = { /* Build your view */ }()
 let menuItemView = NSMenuItemView()
 menuItemView.addSubview(customView, layoutAutomatically: true)

 // When you're ready to assign the view to a `NSMenuItem`.
 menuItem.view = menuItemView
 ```

 # Content
 You are expected to add your own content as subviews. While you can build complex layouts, the simplest use case is covered by the convenience function ``addSubview(_:layoutAutomatically:)``.

 This function adds the passed view to the subviews and the required constraints so that it matches the size of the menu item according to the `layoutMarginsGuide`. This ensures that the view is laid out with some margins from the highlight area.

 - Note: Using this function will also turn off `translatesAutoresizingMaskIntoConstraints` for the menu item view and the passed view.

 ## Adding Content Manually
 If you'd like to add your subviews manually, you can add subviews to ``contentView`` using `addSubview()`.

 If you are not using AutoLayout, use the ``contentMargins`` or the ``highlightMargins`` to align your views correctly.

 # Highlighting
 By default, when assigning a `view` to an `NSMenuItem`, the view is not highlighted as any other normal item in menus. This view solves this by automatically showing a highlighted view behind your content when the enclosing menu item is highlighted.

 - Note: Highlighting is not applied when the enclosing menu item is disabled. If your item is inside a menu that has `autoenablesItems` set to `true`, the item will be disabled when there is no action associated with it.

 ## Subviews
 Supported subviews like `NSTextField` and `NSImageView` can react automatically to the enclosing menu item's highlighting state.

 If ``autoHighlightSubviews`` is set to `true` (default), supported views will automatically change their appearance to match the highlighted state.
 */
open class NSMenuItemView: NSTableCellView {
    private var highlightViewConstraits: [NSLayoutConstraint] = []
    private var contentViewConstraits: [NSLayoutConstraint] = []
    
    // MARK: - Properties
    
    /**
     A Boolean value indicating whether this menu item view should automatically change the appearance of subviews based on the highlight state.

     The default value is `true` and the view will automatically change the appearance of supported views (e.g. `NSTextField` or `NSImageView`) to match the highlight state of the enclosing menu item.
     */
    public var autoHighlightSubviews = true {
        didSet { updateBackgroundStyle() }
    }
    
    /// Sets the Boolean value indicating whether this menu item view should automatically change the appearance of subviews based on the highlight state.
    @discardableResult
    public func autoHighlightSubviews(_ autoHighlightSubviews: Bool) -> Self {
        self.autoHighlightSubviews = autoHighlightSubviews
        return self
    }
    
    /// A Boolean value indicating whether the view displays the highlight background view (``highlightView``) when it's enclosing menu item is highlighted (the mouse is hovering the item).
    public var showsHighlight: Bool = true {
        didSet {
            guard oldValue != showsHighlight else { return }
            updateHighlight()
        }
    }
    
    /// Sets the Boolean value indicating whether the view displays the highlight background view (``highlightView``) when it's enclosing menu item is highlighted (the mouse is hovering the item).
    @discardableResult
    public func showsHighlight(_ showsHighlight: Bool) -> Self {
        self.showsHighlight = showsHighlight
        return self
    }
    
    /// A Boolean value indicating whether the enclosing menu item is enabled.
    var isEnabled: Bool {
        get { enclosingMenuItem?.isEnabled ?? true }
        set {
            guard newValue != isEnabled else { return }
            enclosingMenuItem?.isEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    var isHighlighted: Bool = false {
        didSet {
            guard oldValue != isHighlighted else { return }
            updateHighlight()
        }
    }
        
    /// The margins that are used to layout the ``highlightView``.
    public var highlightMargins = NSEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet { highlightViewConstraits.constant(highlightMargins) }
    }
    
    /// Sets the margins that are used to layout the ``highlightView``.
    @discardableResult
    public func highlightMargins(_ margins: NSEdgeInsets) -> Self {
        self.highlightMargins = margins
        return self
    }
    
    /**
     The margins that are used to layout the ``contentView``.
          
     Any view added using ``addSubview(_:layoutAutomatically:)`` and `layoutAutomatically` is `true`, gets constraint to the `layoutGuide` and it's margins.
     */
    public var contentMargins = NSEdgeInsets(top: 3, left: 8, bottom: 3, right: 8) {
        didSet { contentViewConstraits.constant(contentMargins) }
    }
    
    /// Sets the margins that are used to layout the ``contentView``.
    @discardableResult
    public func contentMargins(_ margins: NSEdgeInsets) -> Self {
        self.contentMargins = margins
        return self
    }
    
    // MARK: - Views
    
    /**
     The view that is used to represent the highlight state of the menu item.

     This view is a `NSVisualEffectView` configured to match exactly the look of highlighted menu items, by using the `menu` and `selection` material depending if the item is highlighted.
     
     Use ``highlightMargins`` to specifies the margins of the highlight view.
     */
    public let highlightView = NSVisualEffectView().material(.menu).blendingMode(.behindWindow).state(.active).isEmphasized(true).cornerRadius(4.0)
    
    /**
     The view that is used to add subviews to the menu item view.
     
     When you add subviews using ``addSubview(_:layoutAutomatically:)`` they are added to this view.
     
     Use ``contentMargins`` to specifies the margins of the content view.
     */
    public let contentView: NSView = ContentView(frame: .zero)
    
            
    private class ContentView: NSView {
        override var intrinsicContentSize: NSSize {
            var contentSize = super.intrinsicContentSize
            subviews.forEach({
                $0.invalidateIntrinsicContentSize()
                let size = $0.intrinsicContentSize
                contentSize = CGSize(max(contentSize.width, size.width), max(contentSize.height, size.height))
            })
            return contentSize
        }
    }
    
    /**
     Add a subview to the menu item and automatically add constraints to make it fill the content area.
     
     The subview is added to ``contentView``.
     
     - parameters:
         - view: The subview to add.
         - layoutAutomatically: If `true`, the view is constraint to ``contentView``.
     */
    public func addSubview(_ view: NSView, layoutAutomatically: Bool) {
        if layoutAutomatically {
            contentView.addSubview(withConstraint: view)
        } else {
            contentView.addSubview(view)
        }
    }
    
    // MARK: - Events Handling
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        performMenuItemAction()
    }
    
    open func performMenuItemAction(animateHighlight: Bool = true) {
        guard let item = enclosingMenuItem, item.isEnabled, let menu = item.menu else { return }
        if !animateHighlight || !showsHighlight || !isHighlighted {
            menu.performActionForItem(at: menu.index(of: item))
            menu.cancelTracking()
        } else {
            _animateHighlight {
                menu.performActionForItem(at: menu.index(of: item))
                menu.cancelTracking()
            }
        }
    }
    
    /**
     Animates the highlight of the menu item at the specified index and menu and performs it's action.
     
     If you overwrite this method for your custom animation, call ``performAction(ofItemAt:in:)`` to perform the action of the highlighted item.
     */
    func animateHighlightAndPerformAction(ofItemAt index: Int, in menu: NSMenu) {
        guard showsHighlight, isEnabled, isHighlighted else { return }
        _animateHighlight {
            NSView.animate(withDuration: 0.05) {
                self.highlightView.animator().alphaValue = 0.0
            }
            self.performAction(ofItemAt: index, in: menu)
        }
    }
    
    /// Performs the action of the menu item at the specified index and menu.
    func performAction(ofItemAt index: Int, in menu: NSMenu) {
        menu.performActionForItem(at: index)
        menu.cancelTracking()
    }
    
    
    func _animateHighlight(forward: Bool = true, completion: @escaping (() -> Void)) {
        NSView.animate(withDuration: 0.05, changes: {
            self.highlightView.animator().alphaValue = forward ? 0.0 : 1.0
        }, completion: forward ? { self._animateHighlight(forward: false, completion: completion) } : completion  )
    }
    
    // MARK: - Initializers
        
    /**
     Initialize and return a new menu item view with the specified content.

     - Note: You can achieve the same result by initializing with `init()` and invoking ``addSubview(_:layoutAutomatically:)``.

     - Parameters:
        - content: A subview.
        - showsHighlight: A Boolean value indicating whether the view displays the highlight background view (``highlightView``) when it's enclosing menu item is highlighted (the mouse is hovering the item).
     */
    public convenience init(content: NSView, showsHighlight: Bool = true) {
        self.init()
        initialSetup()
        addSubview(content, layoutAutomatically: false)
        layoutSubtreeIfNeeded()
        invalidateIntrinsicContentSize()
        self.showsHighlight = showsHighlight
    }
        
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        highlightMargins = coder.decodeEdgeInsets(forKey: "highlightMargins")
        contentMargins = coder.decodeEdgeInsets(forKey: "contentMargins")
        autoHighlightSubviews = coder.decodeBool(forKey: "autoHighlightSubviews")
        isHighlighted = coder.decodeBool(forKey: "isHighlighted")
        showsHighlight = coder.decodeBool(forKey: "showsHighlight")
        initialSetup()
        (coder.decodeObject(forKey: "subviews") as? [NSView])?.forEach({ addSubview($0, layoutAutomatically: true) })
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(autoHighlightSubviews, forKey: "autoHighlightSubviews")
        coder.encode(isHighlighted, forKey: "isHighlighted")
        coder.encode(showsHighlight, forKey: "showsHighlight")
        coder.encode(highlightMargins, forKey: "highlightMargins")
        coder.encode(contentMargins, forKey: "contentMargins")
        coder.encode(contentView.subviews, forKey: "subviews")
        super.encode(with: coder)
    }
    
    func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        highlightViewConstraits = addSubview(withConstraint: highlightView)
        highlightViewConstraits.constant(highlightMargins)
        contentViewConstraits = addSubview(withConstraint: contentView)
        contentViewConstraits.constant(contentMargins)
    }
    
    // MARK: - Layout

    public override var allowsVibrancy: Bool { false }
    
    open override var intrinsicContentSize: NSSize {
        subviews.forEach({ $0.invalidateIntrinsicContentSize() })
        var intrinsicContentSize = subviews.map{ $0.intrinsicContentSize }.max(by: \.width) ?? .zero
        if intrinsicContentSize == CGSize(-1, -1) {
            intrinsicContentSize = subviews.map{ $0.bounds.size }.max(by: \.width) ?? .zero
        }
        return intrinsicContentSize
        /*
        let fittingSize = subviews.map{ $0.fittingSize }.max(by: \.width) ?? .zero
        let size = subviews.map{ $0.frame.size }.max(by: \.width) ?? .zero
        let contentSize = innerContentGuide.frame.size
        Swift.print("intrinsicContentSize", subviews.last?.className ?? "nil", intrinsicContentSize, fittingSize, size, super.intrinsicContentSize)
         */
    }
    
    func updateHighlight() {
        if showsHighlight, isHighlighted, isEnabled {
            highlightView.material = .selection
        } else {
            highlightView.material = .menu
        }
        updateBackgroundStyle()
    }
    
    func updateBackgroundStyle() {
        if autoHighlightSubviews {
            if isEnabled {
                subviews.forEach({ $0.alphaValue = 1.0 })
                backgroundStyle = isHighlighted ? .emphasized : .normal
              // setBackgroundStyle(isHighlighted ? .emphasized : .normal)
            } else {
                subviews.forEach({ $0.alphaValue = 0.4 })
                backgroundStyle = .normal
             //   setBackgroundStyle(.normal)
            }
        } else {
            backgroundStyle = .normal
           // setBackgroundStyle(.normal)
        }
    }
     
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        isHighlighted = enclosingMenuItem?.isHighlighted ?? isHighlighted
        updateBackgroundStyle()
    }
}
#endif
