//
//  NSView+ContentConfiguration.swift
//
//
//  Created by Florian Zand on 27.06.24.
//

#if os(macOS)
import AppKit

/*
extension NSView {
    /**
     The current content configuration of the view.
     
     */
    public var contentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("viewContentConfiguration", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "viewContentConfiguration")
            if let configuration = newValue {
                if contentConfigurationView == nil {
                    contentConfigurationView = ContentConfigurationView()
                    addSubview(contentConfigurationView!)
                }
                contentConfigurationView!.sendToBack()
                contentConfigurationView?.configuration = configuration
            } else {
                contentConfigurationView?.removeFromSuperview()
                contentConfigurationView = nil
            }
        }
    }
    
    var contentView: (NSView & NSContentView)? {
        contentConfigurationView?._contentView
    }
    
    /**
     A Boolean value that determines whether the vkew automatically updates its content configuration when its state changes.

     When this value is true, the item automatically calls `updated(for:)` on its ``contentConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.

     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesContentConfiguration", initialValue: false) }
        set { setAssociatedValue(newValue, key: "automaticallyUpdatesContentConfiguration") }
    }
    
    /**
     The current configuration state of the view.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSViewConfigurationState {
        NSViewConfigurationState()
    }
    
    var contentConfigurationView: ContentConfigurationView? {
        get { getAssociatedValue("contentConfigurationView", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "contentConfigurationView") }
    }
}
 */

#endif
