//
//  KeyboardShortcut+Name.swift
//
//
//  Created by Florian Zand on 11.08.25.
//

#if os(macOS)
import Foundation
import FZSwiftUtils

public extension KeyboardShortcut {
    /**
     A global keyboard shortcut name.
          
     When you use it with ``AppKit/NSEvent/KeyMonitor/name``, the monitor automatically updates it's shortcut whenever the shortcut of the name get's updated.
     
     Whenever ``shortcut`` gets updated, a ``didChangeKeyboardShortcutNotification`` notification is posted with the name as object of the notification.
     */
    public struct Name: Hashable, RawRepresentable, Codable {
        /// The name of the shortcut.
        public let rawValue: String
        
        /// The default shortcut.
        public let defaultShortcut: KeyboardShortcut?
        
        /// The keyboard shortcut assigned to the name.
        public var shortcut: KeyboardShortcut? {
            get { Self.shortcuts[rawValue] }
            nonmutating set {
                guard newValue != shortcut else { return }
                Self.shortcuts[rawValue] = newValue
                NotificationCenter.default.post(name: KeyboardShortcut.didChangeKeyboardShortcutNotification, object: rawValue, userInfo: ["keyboardShortcut" : newValue])
            }
        }
        
        static var shortcuts: [String: KeyboardShortcut] {
            get { Defaults.shared["shortcuts", initalValue: [:]] }
            set { Defaults.shared["shortcuts"] = newValue }
        }
        
        private static var didSetupInitial: [String: Bool] {
            get { Defaults.shared["didSetupInitial", initalValue: [:]] }
            set { Defaults.shared["didSetupInitial"] = newValue }
        }
        
        /**
         Creates an assignable keyboard shortcut.
         
         - Parameters:
         - name: The name of the shortcut.
         - default: An optional default key combination.
         */
        public init(_ name: String, default initialShortcut: KeyboardShortcut? = nil) {
            self.rawValue = name
            self.defaultShortcut = initialShortcut
            
            guard Self.didSetupInitial[name] == nil else { return }
            Self.didSetupInitial[name] = true
            Self.shortcuts[name] = initialShortcut
        }
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
            defaultShortcut = nil
        }
    }
    
    /// A notification that a keyboard shortcut has changed.
    public static let didChangeKeyboardShortcutNotification = Notification.Name("keyboardShortcutDidChange")
}

extension Notification.Name {
    /// A notification that a keyboard shortcut has changed.
    public static let didChangeKeyboardShortcut = Notification.Name("keyboardShortcutDidChange")
}
#endif
