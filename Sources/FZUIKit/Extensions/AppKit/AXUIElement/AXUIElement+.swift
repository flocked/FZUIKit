//
//  AXUIElement+.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices) && os(macOS)
import AppKit
import ApplicationServices
import Combine
import FZSwiftUtils

public extension AXUIElement {
    /// Returns an accessibility object that provides access to system attributes.
    static var systemWide: AXUIElement { AXUIElementCreateSystemWide() }
    
    /// Returns the accessibility object for the frontmost app, which is the app that receives key events.
    static var frontMostApplication: AXUIElement? {
        guard let app = NSRunningApplication.frontMost else { return nil }
        return application(app)
    }
    
    /// Returns the accessibility object for the app that owns the currently displayed menu bar.
    static var menuBarOwningApplication: AXUIElement? {
        guard let app = NSRunningApplication.menuBarOwning else { return nil }
        return application(app)
    }
    
    /// Returns the accessibility object for the specified running application.
    static func application(_ application: NSRunningApplication) -> AXUIElement {
        self.application(processIdentifier: application.processIdentifier)
    }
    
    /// Returns the accessibility objects for the running applications.
    static func applications() -> [AXUIElement] {
        NSRunningApplication.runningApplications.map(application(_:))
    }
    
    /// Returns the accessibility objects for the running applications with the specified bundle identifier.
    static func applications(withBundleIdentifier bundleIdentifier: String) -> [AXUIElement] {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).map(application(_:))
    }
    
    /// Returns the accessibility objects for the running applications with the specified name.
    static func applications(named name: String) -> [AXUIElement] {
        NSRunningApplication.runningApplications(named: name).map(application(_:))
    }

    /// Returns the accessibility object for the running application with the specified process identifier.
    static func application(processIdentifier: pid_t) -> AXUIElement {
        precondition(processIdentifier >= 0)
        return AXUIElementCreateApplication(processIdentifier)
    }
    
    /// Returns the accessibility element for the window with the specified window identifier.
    static func window(for windowNumber: CGWindowID) -> AXUIElement? {
        CGWindowInfo(windowNumber: windowNumber)?.axUIElement()
    }
        
    /// Returns the accessibility object at the specified position in top-left relative screen coordinates.
    static func element(atScreenPosition position: CGPoint) -> AXUIElement? {
        systemWide.element(atScreenPosition: position)
    }
    
    /// Returns the element at the specified position in top-left relative screen coordinates.
    func element(atScreenPosition position: CGPoint) -> AXUIElement? {
        DispatchQueue.main.syncSafely {
            do {
                var element: AXUIElement?
                try AXUIElementCopyElementAtPosition(self, Float(position.x), Float(position.y), &element).throwIfError("element(atScreenPosition: \(position))")
                return element!
            } catch {
                return nil
            }
        }
    }

    /// A Boolean value indicating whether the object is still valid.
    var isValid: Bool {
        do {
            _ = try get(.role)
        } catch AXError.invalidUIElement, AXError.cannotComplete {
            return false
        } catch { }
        return true
    }

    /// Returns an array of all attributes supported by the object.
    var attributes: [AXAttribute] {
        DispatchQueue.main.syncSafely {
            do {
                var names: CFArray?
                try AXUIElementCopyAttributeNames(self, &names).throwIfError("attributes")
                return (names! as [AnyObject]).map { AXAttribute(rawValue: $0 as! String) }
            } catch {
                AXLogger.print("attributes", error, "\n  ", self)
                return []
            }
        }
    }
    
    /// Returns an array of all attributes supported by the element that can be changed.
    var settableAttributes: [AXAttribute] {
        attributes.filter(isAttributeSettable)
    }

    /**
     Returns the values of all supported attributes.
     
     - Parameter includeNilValues: A Boolean value that determines whether attributes with `nil` values should be included in the result. If `true`, `nil` values are included and represented by ``AXNilValue``.
     */
    func attributeValues(includeNilValues: Bool = true) -> [AXAttribute: Any] {
        do {
            return try get(attributes, includeNilValues: includeNilValues)
        } catch {
            AXLogger.print(error, "attributeValues()")
            return [:]
        }
    }

    /// Returns an array of all parameterized attributes supported by the object.
    var parameterizedAttributes: [AXParameterizedAttribute] {
        DispatchQueue.main.syncSafely {
            do {
                var names: CFArray?
                try AXUIElementCopyParameterizedAttributeNames(self, &names).throwIfError("parameterizedAttributes")
                return (names! as [AnyObject]).map { AXParameterizedAttribute(rawValue: $0 as! String) }
            } catch {
                return []
            }
        }
    }
    
    /// The values of the object's attributes.
    var values: AXUIElementValues {
        .init(self)
    }
    
    /// A Boolean value indicating whether the specificed attribute is settable.
    func isAttributeSettable(_ attribute: AXAttribute) -> Bool {
        DispatchQueue.main.syncSafely {
            do {
                var settable: DarwinBoolean = false
                try AXUIElementIsAttributeSettable(self, attribute.rawValue as CFString, &settable).throwIfError("isAttributeSettable(\(attribute))")
                return settable.boolValue
            } catch {
                return false
            }
        }
    }
    
    /// The number of elements if the attribute is an array attribute, or `nil` otherwise.
    func count(of attribute: AXAttribute) -> Int? {
        DispatchQueue.main.syncSafely {
            do {
                var count = 0
                try AXUIElementGetAttributeValueCount(self, attribute.rawValue as CFString, &count).throwIfError("count(of: \(attribute))")
                return count
            } catch {
                return nil
            }
        }
    }

    // MARK: Notifications
    
    /// Returns a new publisher for a notification emitted by this element.
    func publisher(for notification: AXNotification) -> AnyPublisher<AXUIElement, Error> {
        do {
            return try AXNotificationObserver.shared(for: processIdentifier())
                .publisher(for: notification, element: self)
                .handleEvents(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        AXLogger.print(error, "publisher(for: \(notification))")
                    }
                })
                .eraseToAnyPublisher()
        } catch {
            return Fail<AXUIElement, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    /// Returns a observer for the specified notification that calls the specified handler-
    func observe(_ notification: AXNotification, handler: @escaping (_ element: AXUIElement)->()) -> AXNotificationToken? {
        do {
            return try AXNotificationObserver.shared(for: processIdentifier()).observation(notification, element: self, handler: handler)
        } catch {
            return nil
        }
    }
    
    // MARK: Metadata

    /// The process ID associated with this accessibility object.
    func processIdentifier() throws -> pid_t {
        var pid: pid_t = -1
        try AXUIElementGetPid(self, &pid).throwIfError()
        guard pid > 0 else {
            AXLogger.print(AXError.invalidPid(pid))
            throw AXError.invalidPid(pid)
        }
        return pid
    }
    
    /// The role of the object.
    var role: AXRole? {
        try? get(.role)
    }

    /// The subrole of the object.
    var subrole: AXSubrole? {
        try? get(.subrole)
    }
    
    /// The parent of the object.
    var parent: AXUIElement? {
        try? get(.parent)
    }
    
    /// Returns all parents.
    var allParents: [AXUIElement] {
        var parents: [AXUIElement] = []
        var current = parent
        while let parent = current {
            parents.append(parent)
            current = parent.parent
        }
        return parents
    }
    
    /// The path of the object.
    var path: String {
        var strings: [String] = []
        for parent in ([self] + allParents) {
            if let role = parent.role {
                if let title = parent.values.title {
                    strings.append("\(role)[\(title)]")
                } else {
                    strings.append("\(role)")
                }
            }
        }
        return strings.reversed().joined(separator: " -> ")
    }
    
    /// The level of the element.
    var level: Int {
        allParents.count
    }

    /// Returns an array of all the actions the element can perform.
    var actions: [AXAction] {
        DispatchQueue.main.syncSafely {
            do {
                var names: CFArray?
                try AXUIElementCopyActionNames(self, &names).throwIfError()
                guard let names = names as? [String] else {
                    throw AXError.actionUnsupported
                }
                return names.compactMap({ AXAction($0, try? actionDescription($0)) })
            } catch {
                AXLogger.print(error, "actions", error)
                return []
            }
        }
    }
    
    /// Returns a localized description for the specified action.
    private func actionDescription(_ action: String) throws -> String {
        try DispatchQueue.main.syncSafely {
            var desc: CFString?
            try AXUIElementCopyActionDescription(self, action as CFString, &desc).throwIfError("actionDescription(\(action))")
            return desc! as String
        }
    }
    
    /// Performs the specified action.
    func perform(_ action: AXAction) throws {
        try DispatchQueue.main.syncSafely {
            try AXUIElementPerformAction(self, action.rawValue as CFString).throwIfError()
        }
    }
    
    /**
     Sets the timeout value for the element used in the accessibility API.
     
     The default value is `0`, which makes the element use the current global timeout value.
     
     - Returns: `true` if the timeout value has changed successfuly, otherwise `false`.
     */
    @discardableResult
    func setMessagingTimeout(_ timeoutInSeconds: Float) -> Bool {
        AXUIElementSetMessagingTimeout(self, timeoutInSeconds) == .success
    }
    
    /**
     Sets the global timeout value used in the accessibility API.
     
     Setting the value to `0` resets the global timeout to its default value.
     
     - Returns: `true` if the timeout value has changed successfuly, otherwise `false`.
     */
    @discardableResult
    static func setMessagingTimeout(_ timeoutInSeconds: Float) -> Bool {
        AXUIElementSetMessagingTimeout(systemWide, timeoutInSeconds) == .success
    }
    
    /**
     Replaces the text `range` with the given `replacement`.
     
     The location of the current selection is adjusted to stay on the same line, even if the replacement is smaller than the original content.
     
     Note that this won't be correct for selections larger than a single character. In practice we don't need it.
     */
    func replaceText(in range: NSRange, with replacement: String) throws {
        guard var selection = values.selectedTextRange,
              let selectionStartLine = values.line(forIndex: selection.location)
        else { return }

        try set(.selectedTextRange, to: range.cfRange)
        try set(.selectedText, to: replacement)

        // Adjust and restore the original selection.
        if let lineRange = values.range(forLine: selectionStartLine),
            selection.location >= lineRange.location + lineRange.length {
            selection.location = lineRange.location + lineRange.length - 1
        }
        try set(.selectedTextRange, to: selection.cfRange)
    }
}

@_silgen_name("_AXUIElementGetWindow") @discardableResult
func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ wid: inout CGWindowID) -> ApplicationServices.AXError
#endif
