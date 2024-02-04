//
//  File.swift
//  
//
//  Created by Florian Zand on 04.02.24.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A popover that presents a `SwiftUI` view.
public class HostingPopover<Content: View>: NSPopover {
    let hostingController: NSHostingController<Content>
    
    /**
     Creates and returns a popover with the specified `SwiftUI` view.
     
     - Parameter rootView: The `SwiftUI` view of the popover.
     */
    public init(rootView: Content) {
        self.hostingController = NSHostingController(rootView: rootView)
        super.init()
        contentViewController = hostingController
        if #available(macOS 13.0, *) {
            hostingController.sizingOptions = .preferredContentSize
        }
        contentSize = hostingController.preferredContentSize
    }
    
    /// The `SwiftUI` view of the popover.
    public var rootView: Content {
        get { hostingController.rootView }
        set {
            let shouldChangeContentSize = contentSize == hostingController.preferredContentSize
            hostingController.rootView = newValue
            if shouldChangeContentSize {
                contentSize = hostingController.preferredContentSize
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
