//
//  MissionControl.swift
//
//
//  Created by Florian Zand on 08.11.25.
//

#if canImport(ApplicationServices) && os(macOS)
import AppKit
import ApplicationServices
import FZSwiftUtils

public enum MissionControl {
    /// The state of Mission Control.
    public enum State {
        /// Mission Control shows an overview of all windows on the current space.
        case showAllWindows
        /// Mission Control shows all front windows.
        case showFrontWindows
        /// Mission Control shows the desktop.
        case showDesktop
        /// Mission Control is inactive.
        case inactive
    }
    
    /// Observes the state of Mission Control using the specified block.
    public static func observe(handler: @escaping (_ state: State)->()) -> AXNotificationToken? {
        guard let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first else { return nil }
        let element = AXUIElement.application(dock)

        var tokens: [AXNotificationToken] = []
        tokens += element.observe("AXExposeShowAllWindows") { _ in handler(.showAllWindows) }
        tokens += element.observe("AXExposeShowFrontWindows") { _ in handler(.showFrontWindows) }
        tokens += element.observe("AXExposeShowDesktop") { _ in handler(.showDesktop) }
        tokens += element.observe("AXExposeExit")  { _ in handler(.inactive) }
        return AXCombinedNotificationToken(tokens, "AXExposeState")
    }
}

#endif
