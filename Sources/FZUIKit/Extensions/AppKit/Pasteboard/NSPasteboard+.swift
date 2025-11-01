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
    /**
     The strings of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var strings: [String] {
        get { readObjects(for: String.self) }
        set { write(newValue) }
    }
    
    /**
     The attributed strings of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var attributedStrings: [NSAttributedString] {
        get { readObjects(for: NSAttributedString.self) }
        set { write(newValue) }
    }
    
    /**
     The images of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var images: [NSImage] {
        get { readObjects(for: NSImage.self) }
        set { write(newValue) }
    }
    
    /**
     The file urls of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var fileURLs: [URL] {
        get { readObjects(for: URL.self).filter({ $0.isFileURL }) }
        set { write(newValue) }
    }
    
    /**
     The urls of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var urls: [URL] {
        get { readObjects(for: URL.self) }
        set { write(newValue) }
    }
    
    /**
     The colors of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var colors: [NSColor] {
        get { readObjects(for: NSColor.self) }
        set { write(newValue) }
    }
    
    /**
     The sounds of the pasteboard.
     
     Setting this property replaces all current items in the pasteboard with the new items.
     */
    public var sounds: [NSSound] {
        get { readObjects(for: NSSound.self) }
        set { write(newValue) }
    }
    
    /// The file promise receivers of the pasteboard.
    public var filePromiseReceivers: [NSFilePromiseReceiver] {
        get { readObjects(for: NSFilePromiseReceiver.self) }
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func readObjects<T>(for type: T.Type) -> [T] where T: NSPasteboardReading {
        readObjects(forClasses: [type]) as? [T] ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func readObjects<T>(for type: T.Type) -> [T] where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        readObjects(forClasses: [T._ObjectiveCType.self]) as? [T] ?? []
    }
    
    /// Returns a Boolean value indicating whether the receiver contains any items that conform to the specified content types.
    @available(macOS 11.0, *)
    func canReadItem(withDataConformingToTypes types: [UTType]) -> Bool {
        canReadItem(withDataConformingToTypes: types.compactMap({ $0.identifier }))
    }
    
    func write<Value: NSPasteboardWriting>(_ values: [Value]) {
        guard !values.isEmpty else { return }
        clearContents()
        writeObjects(values)
    }
    
    func readAll() -> [PasteboardReading] {
        var content: [PasteboardReading] = (pasteboardItems ?? []) + strings + urls
        content += images + colors + sounds
        return content + filePromiseReceivers
    }

    /**
     Observes changes to the pasteboard.
     
     - Parameter handler: The handler that is called whenenver the pasteboard changes.
     - Returns: The ``PasteboardObservation`` object for the observation.
     
     */
    public func observeChanges(handler: @escaping ()->()) -> PasteboardObservation {
        PasteboardObservation(for: self, handler: handler)
    }
    
    /**
     An object that observes changes to a pasteboard.
     
     To stop the observation of the property, either call ``invalidate()``, or deinitialize the object.
     */
    public class PasteboardObservation {
        /// The pasteboard that is observered.
        public let pasteboard: NSPasteboard
        let id = UUID()
        let handler: ()->()
        
        /// Invalidates the pasteboard observation.
        public func invalidate() {
            pasteboard.observations.removeFirst(where: { $0.id == id })
        }
        
        init(for pasteboard: NSPasteboard, handler: @escaping ()->()) {
            self.pasteboard = pasteboard
            self.handler = handler
        }
        
        deinit {
            invalidate()
        }
    }
    
    var lastChangeCount: Int {
        get { getAssociatedValue("lastChangeCount") ?? -1 }
        set { setAssociatedValue(newValue, key: "lastChangeCount") }
    }
    
    var observationTimer: Timer? {
        get { getAssociatedValue("observationTimer") }
        set { setAssociatedValue(newValue, key: "observationTimer") }
    }
    
    var observations: [PasteboardObservation] {
        get { getAssociatedValue("observations") ?? [] }
        set {
            setAssociatedValue(newValue, key: "observations")
            if newValue.isEmpty {
                observationTimer = nil
            } else if observationTimer == nil {
                lastChangeCount = changeCount
                observationTimer = .init(timeInterval: 0.5, repeats: true, block: { [weak self] timer in
                    guard let self = self else { return }
                    if self.lastChangeCount != self.changeCount {
                        self.lastChangeCount = self.changeCount
                        self.observations.forEach({ $0.handler() })
                    }
                })
            }
        }
    }
}

extension NSPasteboard.PasteboardType {
    ///Promised files.
    public static let fileReceiver = Self(kPasteboardTypeFileURLPromise)
    
    /// Source app bundle identifier.
    public static let sourceAppBundleIdentifier = Self("org.nspasteboard.source")
    
    @available(macOS 11.0, *)
    /// The `UTType` that the pasteboard type represents.
    public var uttype: UTType? {
        UTType(rawValue)
    }
}

/*
 extension NSPasteboard {
     func readObjects(for classes: [NSPasteboardReading.Type]) -> [NSPasteboardReading] {
         let classReadableTypes = classes.map { ($0, $0.readableTypes(for: self)) }
         return pasteboardItems?.compactMap { item in
             for (type, readableTypes) in classReadableTypes {
                    for readableType in readableTypes {
                     let options = type.readingOptions?(forType: readableType, pasteboard: self) ?? .asData
                      if let data = item.data(forType: readableType, options: options), let object = type.init(pasteboardPropertyList: data, ofType: readableType) {
                         return object
                      } else if options.contains(.asKeyedArchive), let data = item.data(forType: readableType), let object = try? NSKeyedUnarchiver.unarchive(data) as? NSPasteboardReading {
                            return object
                     }
                 }
             }
             return nil
         } ?? []
     }
 }

 extension NSPasteboardItem {
     func data(forType type: NSPasteboard.PasteboardType, options: NSPasteboard.ReadingOptions) -> Any? {
         if options.contains(.asString) {
             return string(forType: type)
         } else if options.contains(.asPropertyList) {
             return propertyList(forType: type)
         } else if options.contains(.asData) {
             return data(forType: type)
         }
         return nil
     }
 }
 */
#endif
