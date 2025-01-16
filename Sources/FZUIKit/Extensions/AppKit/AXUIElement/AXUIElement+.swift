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
    
    /// Creates and returns the accessibility object for the frontmost app, which is the app that receives key events.
    static var frontMostApplication: AXUIElement? {
        guard let runningApplication = NSWorkspace.shared.frontmostApplication else { return nil }
        return application(runningApplication)
    }
    
    /// Creates and returns the accessibility object for the app that owns the currently displayed menu bar.
    static var menuBarOwningApplication: AXUIElement? {
        guard let runningApplication = NSWorkspace.shared.menuBarOwningApplication else { return nil }
        return application(runningApplication)
    }
    
    /// Creates and returns the accessibility object for the specified running application.
    static func application(_ application: NSRunningApplication) -> AXUIElement {
        self.application(pid: application.processIdentifier)
    }
    
    /// Creates and returns the accessibility object for the application with the specified localized name.
    static func application(named name: String) -> AXUIElement? {
        guard let runningApplication = NSRunningApplication.runningApplications(withName: name).first else { return nil}
        return application(runningApplication)
    }
    
    /// Creates and returns the accessibility object for the application with the specified bundle identifier.
    static func application(bundleIdentifier: String) -> AXUIElement? {
        guard let runningApplication = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first else { return nil}
        return application(runningApplication)
    }

    /// Creates and returns the accessibility object for the application with the specified process ID.
    static func application(pid: pid_t) -> AXUIElement {
        precondition(pid >= 0)
        return AXUIElementCreateApplication(pid)
    }
    
    /// Creates and returns the accessibility object at the specified position in top-left relative screen coordinates.
    static func positioned(at position: CGPoint) -> AXUIElement? {
        systemWide.getElementAtPosition(position)
    }

    /// A Boolean value indicating whether the object is valid.
    var isValid: Bool {
        do {
            _ = try get(.role) as String?
        } catch AXError.invalidUIElement, AXError.cannotComplete {
            return false
        } catch {}
        return true
    }

    /// Returns an array of all the attributes supported by the object.
    func attributes() -> [AXAttribute] {
        do {
            var names: CFArray?
            try AXUIElementCopyAttributeNames(self, &names).throwIfError("attributes()")
            return (names! as [AnyObject]).map { AXAttribute(rawValue: $0 as! String) }
        } catch {
            return []
        }
    }

    /// Returns a dictionary of all the object's attributes and their values.
    func attributeValues() -> [AXAttribute: Any] {
        do {
            let attributes = attributes()
            let values = try get(attributes)
            guard attributes.count == values.count else {
                throw AXError.unexpectedValueCount(values)
            }
            var dict = Dictionary(zip(attributes, values), uniquingKeysWith: { _, b in b })
            for attribute in AXAttribute.boolAttributes {
                if let value = dict[attribute] as? Int {
                    dict[attribute] = value == 1
                }
            }
            return dict
        } catch {
            AXLogger.print(error, "attributeValues()")
            return [:]
        }
    }

    /// Returns an array of all the parameterized attributes supported by the object.
    func parameterizedAttributes() -> [AXAttribute] {
        do {
            var names: CFArray?
            try AXUIElementCopyParameterizedAttributeNames(self, &names).throwIfError("parameterizedAttributes()")
            return (names! as [AnyObject]).map { AXAttribute(rawValue: $0 as! String) }
        } catch {
            return []
        }
    }

    /// Returns the count of the array of tne specified attribute.
    func count(of attribute: AXAttribute) -> Int {
        do {
            var count = 0
            try AXUIElementGetAttributeValueCount(self, attribute.rawValue as CFString, &count).throwIfError("count() of `\(attribute)`")
            return count
        } catch {
            return 0
        }
    }

    /// Gets/sets the value for the specified attribute.
    subscript<Value>(_ attribute: AXAttribute) -> Value? {
        get { try? get(attribute) }
        set(value) { try? set(attribute, to: value) }
    }

    /// Gets/sets the value for the specified attribute.
    subscript<Value: RawRepresentable>(_ attribute: AXAttribute) -> Value? {
        get { try? get(attribute) }
        set(value) { try? set(attribute, to: value) }
    }

    /// Returns the value for the specified attribute.
    func get<Value>(_ attribute: AXAttribute) throws -> Value? {
        precondition(Thread.isMainThread)
        if attribute == .frame, let position: CGPoint = try get(.position), let size: CGSize = try get(.size) {
            return CGRect(origin: position, size: size) as? Value
        }
        var value: AnyObject?
        let code = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
        if let error = AXError(code: code) {
            switch error {
            case .attributeUnsupported, .noValue, .cannotComplete:
                return nil
            default:
                AXLogger.print(error, "get(\(attribute))")
                throw error
            }
        }
        return try unpack(value!) as? Value
    }

    /// Returns the value for the specified attribute.
    func get<Value: RawRepresentable>(_ attribute: AXAttribute) throws -> Value? {
        let rawValue = try get(attribute) as Value.RawValue?
        return rawValue.flatMap(Value.init(rawValue:))
    }

    /// Returns the value for the specified parameterized attribute and parameter.
    func get<Value, Parameter>(_ attribute: AXAttribute, with parameter: Parameter) throws -> Value? {
        precondition(Thread.isMainThread)

        guard let param = pack(parameter) else {
            let error = AXError.packFailure(parameter)
            AXLogger.print(error, "get(\(attribute), with:): pack failure", ["param": String(reflecting: parameter)])
            throw error
        }

        var value: AnyObject?
        let code = AXUIElementCopyParameterizedAttributeValue(self, attribute.rawValue as CFString, param, &value)
        if let error = AXError(code: code) {
            switch error {
            case .attributeUnsupported, .parameterizedAttributeUnsupported, .noValue, .cannotComplete:
                return nil
            default:
                AXLogger.print(error, "(parameterized) get(\(attribute))", ["parameter": String(reflecting: param)])
                throw error
            }
        }
        return try unpack(value!) as? Value
    }

    private func get(_ attributes: [AXAttribute]) throws -> [Any] {
        precondition(Thread.isMainThread)
        let cfAttributes = attributes.map(\.rawValue) as CFArray
        var values: CFArray?
        try AXUIElementCopyMultipleAttributeValues(self, cfAttributes, AXCopyMultipleAttributeOptions(), &values).throwIfError("get(\(attributes))")
        return try (values! as [AnyObject]).map(unpack)
    }
    
    /// Returns the element at the specified position in top-left relative screen coordinates.
    internal func getElementAtPosition(_ position: CGPoint) -> AXUIElement? {
        do {
            var element: AXUIElement?
            try AXUIElementCopyElementAtPosition(self, Float(position.x), Float(position.y), &element).throwIfError("getElementAtPosition(\(position))")
            return element!
        } catch {
            return nil
        }
    }

    private func unpack(_ value: AnyObject) throws -> Any {
        switch CFGetTypeID(value) {
        case AXUIElementGetTypeID():
            return value as! AXUIElement
        case CFArrayGetTypeID():
            return try (value as! [AnyObject]).map(unpack)
        case AXValueGetTypeID():
            return unpackValue(value as! AXValue)
        default:
            return value
        }
    }

    private func unpackValue(_ value: AXValue) -> Any {
        func getValue<Value>(_ value: AnyObject, type: AXValueType, result: inout Value) {
            withUnsafeMutablePointer(to: &result) { pointer in
                let success = AXValueGetValue(value as! AXValue, type, pointer)
                assert(success, "Failed to get value for type: \(type)")
            }
        }

        let type = AXValueGetType(value)
        switch type {
        case .cgPoint:
            var result: CGPoint = .zero
            getValue(value, type: .cgPoint, result: &result)
            return result
        case .cgSize:
            var result: CGSize = .zero
            getValue(value, type: .cgSize, result: &result)
            return result
        case .cgRect:
            var result: CGRect = .zero
            getValue(value, type: .cgRect, result: &result)
            return result
        case .cfRange:
            var result: CFRange = .init()
            getValue(value, type: .cfRange, result: &result)
            return result
        case .axError:
            var result: ApplicationServices.AXError = .success
            getValue(value, type: .axError, result: &result)
            return AXError(code: result) as Any
        case .illegal:
            return value
        @unknown default:
            return value
        }
    }

    /// A Boolean value indicating whether the specificed attribute is settable.
    func isSettable(_ attribute: AXAttribute) -> Bool {
        precondition(Thread.isMainThread)
        do {
            if attribute == .frame {
                let positionIsSettable = try isSettable(.position)
                let sizeIsSettable = try isSettable(.size)
                return positionIsSettable && sizeIsSettable
            }
            var settable: DarwinBoolean = false
            try AXUIElementIsAttributeSettable(self, attribute.rawValue as CFString, &settable).throwIfError("isSettable(\(attribute))")
            return settable.boolValue
        } catch {
            return false
        }
    }

    /// Sets the specified attribute to the specified value.
    func set<Value>(_ attribute: AXAttribute, to value: Value) throws {
        precondition(Thread.isMainThread)
        if attribute == .frame, let value = value as? CGRect {
            try set(.position, to: value.origin)
            try set(.size, to: value.size)
        } else {
            guard let value = pack(value) else {
                let error = AXError.packFailure(value)
                AXLogger.print(error, "set(\(attribute)): pack failure", ["value": String(reflecting: value)])
                throw error
            }
            
            try AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value).throwIfError("set(\(attribute))", ["value": String(reflecting: value)])
        }
    }

    /// Sets the specified attribute to the specified value.
    func set<Value: RawRepresentable>(_ attribute: AXAttribute, to value: Value) throws {
        try set(attribute, to: value.rawValue)
    }

    private func pack(_ value: Any) -> AnyObject? {
        switch value {
        case var value as CGPoint:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &value)
        case var value as CGSize:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &value)
        case var value as CGRect:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGRectType)!, &value)
        case var value as CFRange:
            return AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &value)
        case let value as [Any]:
            return value.compactMap(pack) as CFArray
        case let value as AXUIElement:
            return value
        default:
            return value as AnyObject
        }
    }

    // MARK: Notifications
    
    /// Returns a new publisher for a notification emitted by this element.
    func publisher(for notification: AXNotification) -> AnyPublisher<AXUIElement, Error> {
        do {
            return try AXNotificationObserver.shared(for: pid())
                .publisher(for: notification, element: self)
                .handleEvents(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        AXLogger.print(error, "publisher(for: \(notification))")
                    }
                    let view = NSView()
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
            return try AXNotificationObserver.shared(for: pid()).observation(notification, element: self, handler: handler)
        } catch {
            return nil
        }
    }
    
    // MARK: Metadata

    /// The process ID associated with this accessibility object.
    func pid() throws -> pid_t {
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

    /**
     Returns the children of the object.

     - Parameters:
        - role: The role of the children, or `nil` for all children.
        - subrole: The subrole of the children, or `nil` for all children.
     */
    func children(role: AXRole? = nil, subrole: AXSubrole? = nil) -> [AXUIElement] {
        children(maxDepth: nil, role: role, subrole: subrole)
    }

    /**
     Returns all children of the object recursively.

     - Parameters:
        - maxDepth: The maximum depth of recursion.
        - role: The role of the children, or `nil` for all children.
        - subrole: The subrole of the children, or `nil` for all children.
     */
    func allChildren(maxDepth: Int, role: AXRole? = nil, subrole: AXSubrole? = nil) -> [AXUIElement] {
        children(maxDepth: maxDepth, role: role, subrole: subrole)
    }
    
    /**
     Returns all children of the object recursively.

     - Parameters:
        - role: The role of the children, or `nil` for all children.
        - subrole: The subrole of the children, or `nil` for all children.
     */
    func allChildren(role: AXRole? = nil, subrole: AXSubrole? = nil) -> [AXUIElement] {
        children(maxDepth: .max, role: role, subrole: subrole)
    }
    
    internal func children(level: Int = 0, maxDepth: Int?, role: AXRole? = nil, subrole: AXSubrole?) -> [AXUIElement] {
        let next = level+1 <= maxDepth ?? 0
        let children: [AXUIElement] = (try? get(.children)) ?? []
        var results: [AXUIElement] = []
        for child in children {
            results.append(child)
            if next {
                results.append(contentsOf: child.children(level: level+1, maxDepth: maxDepth, role: role, subrole: subrole))
            }
        }
        if let role = role {
            results = results.filter({ $0.role == role })
        }
        if let subrole = subrole {
            results = results.filter({ $0.subrole == subrole })
        }
        return results
    }
    
    /// Returns an array of all the actions the element can perform.
    func actions() -> [AXAction] {
        do {
            var names: CFArray?
            try AXUIElementCopyActionNames(self, &names).throwIfError()
            guard let names = names as? [String] else {
                throw AXError.actionUnsupported
            }
            return names.compactMap({ AXAction($0, try? actionDescription($0)) })
        } catch {
            AXLogger.print(error, "actions()")
            return []
        }
    }
    
    /// Returns a localized description for the specified action.
    internal func actionDescription(_ action: String) throws -> String {
        var desc: CFString?
        try AXUIElementCopyActionDescription(self, action as CFString, &desc).throwIfError()
        return desc! as String
    }
    
    /// Performs the specified action.
    func perform(_ action: AXAction) throws {
        try AXUIElementPerformAction(self, action.rawValue as CFString).throwIfError()
    }
    
    /**
     Replaces the text `range` with the given `replacement`.
     
     The location of the current selection is adjusted to stay on the same line, even if the replacement is smaller than the original content.
     
     Note that this won't be correct for selections larger than a single character. In practice we don't need it.
     */
    func replaceText(in range: CFRange, with replacement: String) throws {
        guard
            var selection: CFRange = try get(.selectedTextRange),
            let selectionStartLine: Int = try get(.lineForIndex, with: selection.location)
        else {
            return
        }

        try set(.selectedTextRange, to: range)
        try set(.selectedText, to: replacement)

        // Adjust and restore the original selection.
        if
            let lineRange: CFRange = try get(.rangeForLine, with: selectionStartLine),
            selection.location >= lineRange.location + lineRange.length
        {
            selection.location = lineRange.location + lineRange.length - 1
        }
        try set(.selectedTextRange, to: selection)
    }
    
    /// The values of the object's attributes.
    var values: AXUIElementValues {
        .init(self)
    }
}

extension AXUIElement: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let pid = values.pID ?? 0
        if let description = values.description, description != "" {
            return "\(role) #\(id) \(description) (pid: \(pid))"
        }
        return "\(role) #\(id) (pid: \(pid))"
    }
    
    public var debugDescription: String {
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let pid = values.pID ?? 0
        var string = "\(role) #\(id) "
        if let subrole = values.subrole?.rawValue {
            string = "\(role)/\(subrole) #\(id) "
        }
        if let description = values.description, description != "" {
            string += "\(description) (pid: \(pid))"
        } else {
            string += "(pid: \(pid))"
        }
        return string
    }
    
    /**
     Returns a string with a visual description of the object.
     
     - Parameters:
        - options: Options for the description.
        - attributes: The attributes to include.
        - maxDepth: The maximum depth of children to include.
     */
    public func visualDescription(options: DescriptionOptions = .detailedLong, attributes: [AXAttribute] = [], maxDepth: Int? = nil) -> String {
        strings(maxDepth: maxDepth, options: options, attributes: attributes).joined(separator: "\n")
    }
    
    /// Options for a description of an accessibility object.
    public struct DescriptionOptions: OptionSet, Sendable {
        /// Role of the object.
        public static var role = Self(rawValue: 1 << 0)
        /// Subrole of the object.
        public static var subrole = Self(rawValue: 1 << 1)
        /// pid of the object.
        public static var pid = Self(rawValue: 1 << 2)
        /// Identifier of the object.
        public static var identifier = Self(rawValue: 1 << 3)
        /// Description of the object.
        public static var description = Self(rawValue: 1 << 4)
         /// Title of the object.
         public static var title = Self(rawValue: 1 << 5)
         /// Value of the object.
         public static var value = Self(rawValue: 1 << 6)
         /// Attributes of the object.
         public static var attributes = Self(rawValue: 1 << 7)
         /// Parameterized attributes of the object.
         public static var parameterizedAttributes = Self(rawValue: 1 << 8)
         /// Actions of the object.
         public static var actions = Self(rawValue: 1 << 9)
         
         /// Full description of the object.
         public static let all: Self = [.role, .subrole, .pid, .identifier, .description, .actions, .title, .value, .parameterizedAttributes, .attributes]
         /// Very detailed description of the object.
         public static let detailedLong: Self = [.role, .subrole, .pid, .identifier, .description, .actions, .title, .value]
         /// Detailed description of the object.
         public static let detailed: Self = [.role, .subrole, .description, .actions, .title, .value]
         /// Short description of the object.
         public static let short: Self = [.role, .subrole, .description]
         
         var attributes: Set<AXAttribute> {
             var attributes: Set<AXAttribute> = [.children, .parent]
             if contains(.title) { attributes += .title }
             if contains(.description) { attributes += .description }
             if contains(.value) { attributes += .value }
             if contains(.role) { attributes += .role }
             if contains(.subrole) { attributes += .subrole }
             return attributes
         }
         
        /// Creates the print options.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public let rawValue: Int
    }
    
    func strings(level: Int = 0, maxDepth: Int?, options: DescriptionOptions, attributes: [AXAttribute]) -> [String] {
        var strings: [String] = []
        strings += (String(repeating: "  ", count: level) + string(level: level+1, maxDepth: maxDepth, options: options, attributes: attributes))
        if level+1 <= maxDepth ?? .max {
            children().forEach({ strings += $0.strings(level: level+1, maxDepth: maxDepth, options: options, attributes: attributes) })
        }
        return strings
    }
    
    func string(level: Int, maxDepth: Int?, options: DescriptionOptions, attributes: [AXAttribute]) -> String {
        let intendString = String(repeating: "  ", count: level) + "- "
        let id = hashValue
        let role = values.role?.rawValue ?? "AXUnknown"
        let subrole = values.subrole?.rawValue
        let pid = values.pID
        let title = values.title
        let description = values.description
        var strings: [String] = []
        if options.contains([.role, .subrole]), let subrole = subrole {
            strings.append("\(role)/\(subrole)")
        } else if options.contains(.subrole), let subrole = subrole {
            strings.append("\(subrole)")
        } else if options.contains(.role) {
            strings.append("\(role)")
        } else {
            strings.append("AXUIElement")
        }

        if options.contains([.title, .description]) {
            if let title = title, title != "", let description = description, description != "" {
                strings[0] = strings[0] + " \"\(description)\""
                if title != description {
                    strings.append(intendString + "title: \"\(title)\"")
                }
            } else if let title = title, title != "" {
                strings[0] = strings[0] + " \"\(title)\""
            } else if let description = description, description != "" {
                strings[0] = strings[0] + " \"\(description)\""
            }
        } else if options.contains(.description), let description = description, description != "" {
            strings[0] = strings[0] + " \"\(description)\""
        } else if options.contains(.title), let title = title, title != "" {
            strings[0] = strings[0] + " \"\(title)\""
        }
        
        if options.contains(.value), let value: Any = try? get(.value) {
            strings.append(intendString + "value: \(value)")
        }
        
        if options.contains([.identifier, .pid]), let pid = pid {
            strings += (intendString + "id: \(id), pID: \(pid)")
        } else if options.contains(.identifier) {
            strings += (intendString + "id: \(id)")
        } else if options.contains(.pid), let pid = pid {
            strings += (intendString + "pID: \(pid)")
        }
        
        let skipping = options.attributes
        var attributeValues = (options.contains(.attributes) ? attributeValues() : attributes.reduce(into: [AXAttribute: Any]()) {  dict, attribute in dict[attribute] = try? get(attribute) }).filter({ !skipping.contains($0.key) && ($0.value is Optional<AXValue>) })
        if !attributeValues.isEmpty {
            strings += (intendString + "attributes:")
            let intendString = "\(String(repeating: "  ", count: level+1))- "
            strings += attributeValues.sorted(by: \.key.rawValue).compactMap({ intendString + "\($0.key): \($0.value)" })
        }
        
        if options.contains(.parameterizedAttributes) {
            let attributes = parameterizedAttributes()
            if !attributes.isEmpty {
                strings += (intendString + "parameterizedAttributes:")
                let intendString = "\(String(repeating: "  ", count: level+1))- "
                strings += attributes.compactMap({ intendString + $0.rawValue })
            }
        }
        
        if options.contains(.actions) {
            let actions = actions()
            if !actions.isEmpty {
                strings += (intendString + "actions:")
                let intendString = "\(String(repeating: "  ", count: level+1))- "
                strings += actions.compactMap({ intendString + $0.description })
            }
        }
        return strings.joined(separator: "\n")
    }
}

public extension AXUIElement {
    /**
     A Boolean value indicating whether the current process is a trusted accessibility client.
     
     - Parameter prompt: Indicates whether the user will be informed if the current process is untrusted. This could be used, for example, on application startup to always warn a user if accessibility is not enabled for the current process. Prompting occurs asynchronously and does not affect the return value.
     */
    @discardableResult
    static func isProcessTrusted(prompt: Bool = false) -> Bool {
        AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): prompt,
        ] as CFDictionary)
    }
}

/*
extension AXUIElement {
    func childrenAlt() -> ChildrenSequence {
        .init(self)
    }
    
    func childrenAlt(predicate: @escaping ((AXUIElement)->(Bool))) -> ChildrenSequence {
        .init(self, filter: predicate)
    }

    /// A sequence of children.
    struct ChildrenSequence: Sequence {
        let element: AXUIElement
        var role: AXRole?
        var subrole: AXSubrole?
        var maxDepth: Int = 0
        var filter: ((AXUIElement)->(Bool))?
        
        init(_ element: AXUIElement, filter: ((AXUIElement)->(Bool))? = nil) {
            self.element = element
            self.filter = filter
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// The role of the children.
        public func role(_ role: AXRole) -> Self {
            var sequence = self
            sequence.role = role
            return sequence
        }
        
        /// The subrole of the children.
        public func subrole(_ subrole: AXSubrole) -> Self {
            var sequence = self
            sequence.subrole = subrole
            return sequence
        }
        
        /// Includes the children of each child.
        public var recursive: Self {
            recursive(maxDepth: .max)
        }
                
        /**
         Includes the children of each child upto the specified maximum depth.
         
         - Parameter maxDepth: The maximum depth of enumeration. A value of `0` enumerates only the children of the object.
         */
        public func recursive(maxDepth: Int) -> Self {
            var sequence = self
            sequence.maxDepth = maxDepth.clamped(min: 0)
            return sequence
        }
        
        /// Iterator of a url sequence.
        public struct Iterator: IteratorProtocol {
            let children: [(element: AXUIElement, level: Int)]
            var index = -1
            
            init(_ sequence: ChildrenSequence) {
                children = sequence.element._children(maxDepth: sequence.maxDepth, role: sequence.role, subrole: sequence.subrole, filter: sequence.filter)
            }

            public mutating func next() -> AXUIElement? {
                guard let child = children[safe: index+1] else { return nil }
                index += 1
                return child.element
            }
            
            /// The number of levels deep the iterator is in the children hierarchy being enumerated.
            public var level: Int {
                children[safe: index]?.level ?? 0
            }

            /*
            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                directoryEnumerator?.skipDescendants()
            }
             */
        }
    }
    
    func _children(level: Int = 0, maxDepth: Int, role: AXRole? = nil, subrole: AXSubrole?, filter: ((AXUIElement)->(Bool))?) -> [(element: AXUIElement, level: Int)] {
        let next = level+1 <= maxDepth
        var children: [AXUIElement] = (try? get(.children)) ?? []
        if let role = role {
            children = children.filter({(try? $0.role()) == role })
        }
        if let subrole = subrole {
            children = children.filter({(try? $0.subrole()) == subrole })
        }
        if let filter = filter {
            children = children.filter(filter)
        }
        var results: [(element: AXUIElement, level: Int)] = []
        for child in children {
            results.append((child, level))
            if next {
                results.append(contentsOf: child._children(level: level+1, maxDepth: maxDepth, role: role, subrole: subrole, filter: filter))
            }
        }
        return results
    }
}
*/

@_silgen_name("_AXUIElementGetWindow") @discardableResult
func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ wid: inout CGWindowID) -> ApplicationServices.AXError
#endif
