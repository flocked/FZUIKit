//
//  NSWorkspace+.swift
//
//
//  Created by Florian Zand on 22.04.24.
//

#if os(macOS)
import AppKit

public extension NSWorkspace.OpenConfiguration {
    /// Sets the Boolean value indicating whether the system activates the app and brings it to the foreground.
    @discardableResult
    func activates(_ activates: Bool) -> Self {
        self.activates = activates
        return self
    }
    
    /// Sets the Boolean value indicating whether to add the app or documents to the Recent Items menu.
    @discardableResult
    func addsToRecentItems(_ addsToRecentItems: Bool) -> Self {
        self.addsToRecentItems = addsToRecentItems
        return self
    }
    
    /// Sets the Boolean value indicating whether you want the app to hide itself after it launches.
    @discardableResult
    func hides(_ hides: Bool) -> Self {
        self.hides = hides
        return self
    }
    
    /// Sets the Boolean value indicating whether you want to hide all apps except the one that launched.
    @discardableResult
    func hidesOthers(_ hidesOthers: Bool) -> Self {
        self.hidesOthers = hidesOthers
        return self
    }
    
    /// Sets the Boolean value indicating whether to display errors, authentication requests, or other UI elements to the user.
    @discardableResult
    func promptsUserIfNeeded(_ prompts: Bool) -> Self {
        promptsUserIfNeeded = prompts
        return self
    }
    
    /// Sets the Boolean value indicating whether you want to print the contents of documents and URLs instead of opening them.
    @discardableResult
    func isForPrinting(_ isForPrinting: Bool) -> Self {
        self.isForPrinting = isForPrinting
        return self
    }
    
    /// Sets the Boolean value indicating whether you require the URL to have an associated universal link.
    @discardableResult
    func requiresUniversalLinks(_ requires: Bool) -> Self {
        requiresUniversalLinks = requires
        return self
    }
    
    /// Sets the set of command-line arguments to pass to a new app instance at launch time.
    @discardableResult
    func arguments(_ arguments: [String]) -> Self {
        self.arguments = arguments
        return self
    }
    
    /// Sets the first Apple event to send to the new app.
    @discardableResult
    func appleEvent(_ appleEvent: NSAppleEventDescriptor?) -> Self {
        self.appleEvent = appleEvent
        return self
    }
    
    /// Sets the architecture version of the app to launch.
    @discardableResult
    func architecture(_ architecture: cpu_type_t) -> Self {
        self.architecture = architecture
        return self
    }
    
    /// Sets the set of environment variables to set in a new app instance.
    @discardableResult
    func environment(_ environment: [String : String]) -> Self {
        self.environment = environment
        return self
    }
}

#endif
