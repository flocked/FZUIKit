//
//  NSPasteboard+.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers
import FZSwiftUtils

extension NSPasteboard {
    /// Returns a concatenation of the strings for the specified type from all the items in the receiver that contain the type.
    @_disfavoredOverload
    public func string(forType type: UTType) -> String? {
        string(forType: PasteboardType(type.identifier))
    }
    
    /// Returns the data for the specified type from the first item in the receiver that contains the type.
    @_disfavoredOverload
    public func data(forType type: UTType) -> Data? {
        data(forType: PasteboardType(type.identifier))
    }
    
    /// Returns the property list for the specified type from the first item in the receiver that contains the type.
    @_disfavoredOverload
    public func propertyList(forType type: UTType) -> Any? {
        propertyList(forType: PasteboardType(type.identifier))
    }
    
    /**
     Sets the data as the representation for the specified type for the first item on the receiver.
     
     - Parameters:
        - data: The data containing the value for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the data was written successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setData(_ data: Data, forType type: UTType) -> Bool {
        setData(data, forType: PasteboardType(type.identifier))
    }
    
    /**
     Sets the given property list as the representation for the specified type for the first item on the receiver.
     
     - Parameters:
        - propertyList: A property list object containing the value for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the data was written successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setPropertyList(_ propertyList: Any, forType type: UTType) -> Bool {
        setPropertyList(propertyList, forType: PasteboardType(type.identifier))
    }
    
    /**
     Sets the given string as the representation for the specified type for the first item on the receiver.
     
     - Parameters:
        - string: A string for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the data was written successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setString(_ string: String, forType type: UTType) -> Bool {
        setString(string, forType: PasteboardType(type.identifier))
    }
    
    /**
     The strings of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var strings: [String] {
        get { read(String.self) }
        set { write(newValue) }
    }
    
    /**
     The attributed strings of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var attributedStrings: [NSAttributedString] {
        get { read(NSAttributedString.self) }
        set { write(newValue) }
    }
    
    /**
     The images of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var images: [NSImage] {
        get { read(NSImage.self) }
        set { write(newValue) }
    }
    
    /**
     The file urls of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var fileURLs: [URL] {
        get { read(URL.self).filter({ $0.isFileURL }) }
        set { write(newValue) }
    }
    
    /**
     The urls of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var urls: [URL] {
        get { read(URL.self) }
        set { write(newValue) }
    }
    
    /**
     The colors of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var colors: [NSColor] {
        get { read(NSColor.self) }
        set { write(newValue) }
    }
    
    /**
     The sounds of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var sounds: [NSSound] {
        get { read(NSSound.self) }
        set { write(newValue) }
    }
    
    /// The file promise receivers of the pasteboard.
    public var filePromiseReceivers: [NSFilePromiseReceiver] {
        get { read(NSFilePromiseReceiver.self) }
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func read<T>(_ type: T.Type) -> [T] where T: NSPasteboardReading {
        readObjects(forClasses: [type]) as? [T] ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func read<T>(_ type: T.Type) -> [T] where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        readObjects(forClasses: [T._ObjectiveCType.self]) as? [T] ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` types.
    public func read(_ types: [(any NSPasteboardReading).Type], options: [NSPasteboard.ReadingOptionKey : Any]? = nil) -> [Any] {
        readObjects(forClasses: types, options: options) ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `PasteboardReading` types.
    @_disfavoredOverload
    public func read(_ types: [(any PasteboardReading).Type], options: [NSPasteboard.ReadingOptionKey : Any]? = nil) -> [Any] {
        readObjects(forClasses: types.map({$0.PasteboardReadingType}), options: options) ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` types.
    public func canRead(_ types: [(any NSPasteboardReading).Type], options: [NSPasteboard.ReadingOptionKey : Any]? = nil) -> Bool {
        canReadObject(forClasses: types, options: options)
    }
    
    /// Returns the objects on the pasteboard for the specified `PasteboardReading` types.
    @_disfavoredOverload
    public func canRead(_ types: [(any PasteboardReading).Type], options: [NSPasteboard.ReadingOptionKey : Any]? = nil) -> Bool {
        canReadObject(forClasses: types.map({$0.PasteboardReadingType}), options: options)
    }
    
    /// Returns a Boolean value that indicates whether the receiver contains any items that can be represented as an instance of the specified class.
    public func canRead<T>(_ type: T.Type) -> Bool where T: NSPasteboardReading {
        canReadObject(forClasses: [type])
    }
    
    /// Returns a Boolean value that indicates whether the receiver contains any items that can be represented as an instance of the specified type.
    public func canRead<T>(_ type: T.Type) -> Bool where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        canReadObject(forClasses: [T._ObjectiveCType.self])
    }
    
    /// Returns a Boolean value indicating whether the receiver contains any items that conform to the specified content types.
    func canReadItem(withDataConformingToTypes types: [UTType]) -> Bool {
        canReadItem(withDataConformingToTypes: types.map({ $0.identifier }))
    }
    
    /**
     Writes the specified objects to the pasteboard.

     If `preservingExisting` is `true`, existing pasteboard items whose types overlap with any of the writable types provided by `values` are removed, while all other items are preserved. The resulting pasteboard contents consist of the preserved items followed by the new objects.

     For example, writing an `NSString` with `replace` set to `true` replaces existing string representations on the pasteboard while preserving unrelated content such as colors, images, or file URLs.

     - Parameters:
       - values: The objects to write to the pasteboard.
       - preservingExisting: A Boolean value indicating whether existing items with matching pasteboard types should be replaced while preserving unrelated items.
     - Returns: `true` if the array was successfully added, otherwise `false`.
     */
    @discardableResult
    func write(_ values: [any NSPasteboardWriting], preservingExisting: Bool = true) -> Bool {
        var keptItems: [NSPasteboardItem] = []
        if preservingExisting {
            let replacementTypes = Set(values.flatMap { $0.writableTypes(for: self) })
            keptItems = pasteboardItems?.filter({ Set($0.types).isDisjoint(with: replacementTypes) }).map({$0.copied()}) ?? []
        }
        clearContents()
        return writeObjects(keptItems + values)
    }
    
    /**
     Writes the specified objects to the pasteboard.

     If `preservingExisting` is `true`, existing pasteboard items whose types overlap with any of the writable types provided by `values` are removed, while all other items are preserved. The resulting pasteboard contents consist of the preserved items followed by the new objects.

     For example, writing an `NSString` with `replace` set to `true` replaces existing string representations on the pasteboard while preserving unrelated content such as colors, images, or file URLs.

     - Parameters:
       - values: The objects to write to the pasteboard.
       - preservingExisting: A Boolean value indicating whether existing items with matching pasteboard types should be replaced while preserving unrelated items.
     - Returns: `true` if the array was successfully added, otherwise `false`.
     */
    @discardableResult
    @_disfavoredOverload
    func write(_ values: [any PasteboardWriting], preservingExisting: Bool = true) -> Bool {
        write(values.map({$0.pasteboardWriting}), preservingExisting: preservingExisting)
    }

    /**
     Observes changes to the pasteboard.
     
     To stop the observation of the property, either call ``PasteboardObservation/invalidate()`` on the returned object, or deinitialize it.
     
     - Parameter handler: The handler that is called whenenver the pasteboard changes.
     - Returns: The ``PasteboardObservation`` object for the observation.
     */
    public func observeChanges(handler: @escaping (_ pasteboard: NSPasteboard)->()) -> PasteboardObservation {
        PasteboardObservation(for: self, handler: handler)
    }
    
    /**
     An object that observes changes to a pasteboard.
     
     To stop the observation of the property, either call ``invalidate()``, or deinitialize the object.
     */
    public class PasteboardObservation {
        let id = UUID()
        let handler: (NSPasteboard)->()
        
        /// The pasteboard that is observered.
        public let pasteboard: NSPasteboard
        
        /// A Boolean value indicating whether the observation is active.
        public var isActive: Bool {
            get { pasteboard.observations[id] != nil }
            set {
                guard newValue != isActive else { return }
                pasteboard.observations[id] = newValue ? self : nil
            }
        }
        
        /// Invalidates the pasteboard observation.
        public func invalidate() {
            isActive = false
        }
        
        init(for pasteboard: NSPasteboard, handler: @escaping (NSPasteboard)->()) {
            self.pasteboard = pasteboard
            self.handler = handler
            pasteboard.observations[id] = self
        }
        
        deinit {
            invalidate()
        }
    }
    
    private var lastChangeCount: Int {
        get { getAssociatedValue("lastChangeCount") ?? -1 }
        set { setAssociatedValue(newValue, key: "lastChangeCount") }
    }
    
    private var observationTimer: Timer? {
        get { getAssociatedValue("observationTimer") }
        set { setAssociatedValue(newValue, key: "observationTimer") }
    }
    
    var observations: [UUID: PasteboardObservation] {
        get { getAssociatedValue("observations") ?? [:] }
        set {
            setAssociatedValue(newValue, key: "observations")
            if newValue.isEmpty {
                observationTimer?.invalidate()
                observationTimer = nil
            } else if observationTimer == nil {
                lastChangeCount = changeCount
                observationTimer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                    guard let self = self, self.lastChangeCount != self.changeCount else { return }
                    self.lastChangeCount = self.changeCount
                    self.observations.values.forEach({ $0.handler(self) })
                }
            }
        }
    }
}

extension NSPasteboard.PasteboardType {
    ///Promised files.
    public static let fileReceiver = Self(kPasteboardTypeFileURLPromise)
    
    /// Source app bundle identifier.
    public static let sourceAppBundleIdentifier = Self("org.nspasteboard.source")
    
    /// The `UTType` that the pasteboard type represents.
    public var uttype: UTType? {
        UTType(rawValue)
    }
    
    /// Creates a Pasteboard type with the speicifed `UTType`.
    public init(_ type: UTType) {
        self.init(type.identifier)
    }
}

fileprivate extension NSPasteboardItem {
    func copied() -> NSPasteboardItem {
        let copy = NSPasteboardItem()
        for type in types {
            if let data = data(forType: type) {
                copy.setData(data, forType: type)
            } else if let string = string(forType: type) {
                copy.setString(string, forType: type)
            } else if let propertyList = propertyList(forType: type) {
                copy.setPropertyList(propertyList, forType: type)
            }
        }
        return copy
    }
}
#endif
