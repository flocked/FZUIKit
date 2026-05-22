//
//  NSApplication+URLSchemeObservation.swift
//  FZUIKit
//
//  Created by Florian Zand on 22.05.26.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSApplication {
    /**
     Observes URLs opened with the specified URL scheme.
     
     The handler is called whenever the application receives a URL whose scheme matches the specified value. The received ``URL`` is passed to the handler.
     
     The returned ``URLSchemeObservation`` object controls the lifetime of the observation. The observation remains active while the observation object exists and is active. Invalidating or deinitializing the observation stops further URL notifications automatically.
     
     URL scheme matching is case-insensitive.
     
     Example usage:
     
     ```swift
     let observation = NSApp.observeURLScheme("MyURLScheme") {
        url in
        print("Received URL:", url)
     }
     ```
     
     - Parameters:
        - scheme: The URL scheme to observe.
        - handler: A closure that is called when the application receives a matching URL.
     - Returns: An object representing the active URL scheme observation.
     */
    public func observeURLScheme(_ scheme: String, handler: @escaping (_ url: URL) -> ()) -> URLSchemeObservation {
        let observation = URLSchemeObservation(scheme: scheme, handler: handler)
        urlSchemeObservations.insert(observation)
        return observation
    }
    
    var urlSchemeObservations: Set<Weak<URLSchemeObservation>> {
        get { getAssociatedValue("urlSchemeObservations") ?? [] }
        set {
            setAssociatedValue(newValue, key: "urlSchemeObservations")
            if !newValue.isEmpty, !isURLSchmaObservationEnabled {
                isURLSchmaObservationEnabled = true
                NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
            } else if newValue.isEmpty, isURLSchmaObservationEnabled {
                isURLSchmaObservationEnabled = false
                NSAppleEventManager.shared().removeEventHandler(forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
            }
        }
    }
    
    @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue, let url = URL(string: urlString), let scheme = url.scheme else { return }
        urlSchemeObservations.reap()
        DispatchQueue.main.async {
            self.urlSchemeObservations.nonNil.filter({$0.scheme == scheme}).forEach({ $0.handler(url) })
        }
    }
    
    private var isURLSchmaObservationEnabled: Bool {
        get { getAssociatedValue("isURLSchmaObservationEnabled") ?? false }
        set { setAssociatedValue(newValue, key: "isURLSchmaObservationEnabled") }
    }
}

/**
 An object that observes URLs opened with a specific URL scheme.
      
 Instances of this class are returned by `NSApplication's` ``AppKit/NSApplication/observeURLScheme(_:handler:)``. Keep a strong reference to the observation for as long as URL notifications are needed.
 
 Invalidating or releasing the observation stops further notifications automatically.
 */
public class URLSchemeObservation: NSObject {
    /// The URL scheme being observed.
    public let scheme: String
    
    /// The closure that is called when a matching URL is received.
    public let handler: (URL) -> ()
    
    /**
     A Boolean value indicating whether the observation is active.
     
     Setting this property to `false` removes the observation and stops URL notifications. etting it to `true` reactivates the observation.
     */
    public var isActive: Bool {
        get { NSApp.urlSchemeObservations.contains(self) }
        set {
            guard newValue != isActive else { return }
            if newValue {
                NSApp.urlSchemeObservations.insert(self)
            } else {
                NSApp.urlSchemeObservations.remove(self)
            }
        }
    }
    
    init(scheme: String, handler: @escaping (URL) -> Void) {
        self.scheme = scheme.lowercased()
        self.handler = handler
    }
    
    /**
     Stops observing the URL scheme.
     
     After invalidation, the handler is no longer called for matching URLs.
     */
    public func invalidate() {
        isActive = false
    }
    
    deinit {
        invalidate()
    }
}

#endif
