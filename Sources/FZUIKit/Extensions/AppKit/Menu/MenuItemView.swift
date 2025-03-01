//
//  MenuItemView.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A view that can be used as view of a `NSMenuItem` and displays a highlight background when the menu item is highlighted.

 # Overview
 This view is designed to be used as the `view` property of an `NSMenuItem`. By default, the view is empty: you can design your own content and add it as a subview of a `MenuItemView` instance to automatically get menu-like behaviors such as selection, highlighting, and flashing animations when clicked.

 The general use-case is that you pass a custom view to ``addSubview(_:layoutAutomatically:)`` and let the `MenuItemView` handle everything.

 ```swift
 let customView = { /* Build your view */ }()
 let menuItemView = MenuItemView()
 menuItemView.addSubview(customView, layoutAutomatically: true)

 // When you're ready to assign the view to a `NSMenuItem`.
 menuItem.view = menuItemView
 ```

 # Content
 You are expected to add your own content as subviews. While you can build complex layouts, the simplest use case is covered by the convenience function ``addSubview(_:layoutAutomatically:)``.

 This function adds the passed view to the subviews and the required constraints so that it matches the size of the menu item according to the `layoutMarginsGuide`. This ensures that the view is laid out with some margins from the highlight area.

 - Note: Using this function will also turn off `translatesAutoresizingMaskIntoConstraints` for the menu item view and the passed view.

 ## Adding Content Manually
 If you'd like to add your subviews manually, you can invoke `addSubview` as any other `NSView` subclass. However, when setting up constraints, make sure to use the `layoutMarginsGuide` anchors.

 If you are not using AutoLayout, use the ``contentMargins`` or the ``highlightMargins`` to align your views correctly.

 # Highlighting
 By default, when assigning a `view` to an `NSMenuItem`, the view is not highlighted as any other normal item in menus. This view solves this by automatically showing a highlighted view behind your content when the enclosing menu item is highlighted.

 - Note: Highlighting is not applied when the enclosing menu item is disabled. If your item is inside a menu that has `autoenablesItems` set to `true`, the item will be disabled when there is no action associated with it.

 ## Subviews
 Supported subviews like `NSTextField` and `NSImageView` can react automatically to the enclosing menu item's highlighting state.

 If ``autoHighlightSubviews`` is set to `true` (default), supported views will automatically change their appearance to match the highlighted state.

 When a view is highlighted, it will be set to `NSColor.selectedMenuItemTextColor`, whereas when it is not highlighted, it will default to `NSColor.controlTextColor`. If the enclosing menu item is disabled, the appearance will be set to `NSColor.disabledControlTextColor`.

 This behavior is supported, at the moment, for `NSTextField` and (on macOS 10.14 and higher) `NSImageView` instances.

 - Note: You can implement support for additional views, such as your own custom views, by subclassing `MenuItemView` and overriding ``highlightIfNeeded(_:isHighlighted:isEnabled:)``.

 - warning: The automatic highlighting of subviews changes the appearance of views directly. If you don't want the view to change at all, make sure you set the property to `false` **before** the menu item is displayed. If the item is highlighted even once before the property is turned off, your custom colors will be overridden by the automatic highlighting.

 ## Click Animation
 When a menu item is selected with a click or tap, it blinks to confirm to the user that the action was triggered. This view replicates this behavior by means of a sequence of animations that quickly change the opacity of the ``highlightView``.

 Although it looks similar to what the `NSMenuItem` does by default, it is not exactly the same. If you would like to change it, you can assign a different animation (or group of animations) to the ``highlightAnimation`` property. You can also turn off the animation by setting this property to `nil`.
 */
open class MenuItemView: NSTableCellView {
    private var highlightViewConstraits: [NSLayoutConstraint] = []
    private var innerContentConstraits: [NSLayoutConstraint] = []
    private lazy var innerContentGuide = NSLayoutGuide()
    
    // MARK: - Properties
    
    /**
     A Boolean value that indicates whether this menu item view should automatically change the appearance of subviews based on the highlight state.

     The default value is `true` and the view will automatically change the appearance of supported views (e.g. `NSTextField` or `NSImageView`) to match the highlight state of the enclosing menu item.
     */
    public var autoHighlightSubviews = true {
        didSet { updateBackgroundStyle() }
    }
    
    /// A Boolean value that indicates whether the enclosing menu item is enabled.
    public var isEnabled: Bool {
        get { enclosingMenuItem?.isEnabled ?? true }
        set {
            enclosingMenuItem?.isEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// A Boolean value that indicates whether the view displays the highlight background view (``highlightView``) when it's enclosing menu item is highlighted.
    public var showsHighlight: Bool = true {
        didSet { updateHighlight() }
    }
    
    // MARK: - Constants
    
    /// The margins that are used to layout the ``highlightView``.
    open var highlightMargins = NSEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet {
            guard oldValue != highlightMargins else { return }
            highlightViewConstraits.constant(highlightMargins)
        }
    }
    
    /**
     The margins that should be used to layout any content inside the menu item view.
     
     The margins are used  for the ``layoutMarginsGuide``.
     
     Any view added using ``addSubview(_:layoutAutomatically:)`` and `layoutAutomatically` is `true`, gets constraint to the `layoutGuide` and it's margins.
     */
    open var contentMargins = NSEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet {
            guard oldValue != contentMargins else { return }
            innerContentConstraits.constant(highlightMargins)
        }
    }
    
    // MARK: - Views
    
    /**
     The view that is used to represent the highlight state of the menu item.

     By default, this view is a `NSVisualEffectView` configured to match exactly the look of highlighted menu items, by using the `selection` material, the `active` state, and the `behindWindow` bending mode.

     You can change the configuration of this view at any time.
     */
    public private(set) var highlightView = NSVisualEffectView().material(.selection).blendingMode(.behindWindow).state(.active).isEmphasized(true).isHidden(true).cornerRadius(4.0)
    
    /**
     Add a subview to the menu item and automatically add constraints to make it fill the content area.

     - Note: If you don't want the view to fill the whole space, use `addSubview`

     - parameters:
         - view: The view to add.
         - layoutAutomatically: If `true`, the view is constraint to ``layoutMarginsGuide``.
     */
    public func addSubview(_ view: NSView, layoutAutomatically: Bool) {
        if layoutAutomatically {
            addSubview(view)
            view.constraint(to: innerContentGuide)
        } else {
            addSubview(view)
        }
    }
    
    // MARK: - Events Handling
    
    open override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        guard let enclosingMenuItem, enclosingMenuItem.isEnabled, let menu = enclosingMenuItem.menu else { return }
        animateHighlightAndPerformAction(ofItemAt: menu.index(of: enclosingMenuItem), in: menu)
    }
    
    /**
     Animates the highlight of the menu item at the specified index and menu and performs it's action.
     
     If you overwrite this method for your custom animation, call ``performAction(ofItemAt:in:)`` to perform the action of the highlighted item.
     */
    open func animateHighlightAndPerformAction(ofItemAt index: Int, in menu: NSMenu) {
        guard showsHighlight, isEnabled, isHighlighted else { return }
        _animateHighlight {
            self.performAction(ofItemAt: index, in: menu)
        }
    }
    
    /// Performs the action of the menu item at the specified index and menu.
    public func performAction(ofItemAt index: Int, in menu: NSMenu) {
        menu.performActionForItem(at: index)
        menu.cancelTracking()
    }
    
    func _animateHighlight(forward: Bool = true, completion: @escaping (() -> Void)) {
        NSView.animate(withDuration: 0.05, {
            highlightView.animator().alphaValue = forward ? 0.0 : 1.0
        }, completion: forward ? { self._animateHighlight(forward: false, completion: completion) } : completion  )
    }
    
    // MARK: - Initializers
    
    /**
     Initialize and return a new menu item view with the specified content.

     - Note: You can achieve the same result by initializing with `init()` and invoking ``addSubview(_:layoutAutomatically:)``.

     - Parameter content: A subview.
     */
    public convenience init(content: NSView) {
        self.init()
        addSubview(content, layoutAutomatically: true)
    }
        
    override init(frame frameRect: NSRect) {
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
        isEnabled = coder.decodeBool(forKey: "isEnabled")
        initialSetup()
        (coder.decodeObject(forKey: "subviews") as? [NSView])?.forEach({ addSubview($0, layoutAutomatically: true) })
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(autoHighlightSubviews, forKey: "autoHighlightSubviews")
        coder.encode(isHighlighted, forKey: "isHighlighted")
        coder.encode(showsHighlight, forKey: "showsHighlight")
        coder.encode(isEnabled, forKey: "isEnabled")
        coder.encode(highlightMargins, forKey: "highlightMargins")
        coder.encode(contentMargins, forKey: "contentMargins")
        coder.encode(subviews, forKey: "subviews")
        super.encode(with: coder)
    }
    
    func initialSetup() {
        highlightViewConstraits = addSubview(withConstraint: highlightView, .insets(highlightMargins.directional))
        innerContentConstraits = addLayoutGuide(withConstraint: innerContentGuide, insets: contentMargins)
    }
    
    // MARK: - Layout

    public override var allowsVibrancy: Bool { false }
    
    public override var layoutMarginsGuide: NSLayoutGuide {
        innerContentGuide
    }
    
    public override var intrinsicContentSize: NSSize {
       let intrinsicContentSize =  subviews
            .map { $0.intrinsicContentSize }
            .max { $0.width < $1.width } ?? .zero
        return intrinsicContentSize
    }
    
    var isHighlighted: Bool = false {
        didSet { updateHighlight() }
    }
    
    func updateHighlight() {
        if showsHighlight, isHighlighted {
            highlightView.isHidden = false
        } else {
            highlightView.isHidden = true
        }
        updateBackgroundStyle()
    }
    
    func updateBackgroundStyle() {
        if autoHighlightSubviews {
            if isEnabled {
                backgroundStyle = isHighlighted ? .emphasized : .normal
            } else {
                backgroundStyle = .lowered
            }
        } else {
            backgroundStyle = .normal
        }
    }
        
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if let menu = enclosingMenuItem?.menu, menu.delegateProxy == nil {
            menu.delegateProxy = NSMenu.Delegate(menu)
        }
    }
}
#endif
