//
//  NSDraggingSession+.swift
//
//
//  Created by Florian Zand on 01.02.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSDraggingSession {
    /// The source of the drag.
    public var source: NSDraggingSource {
        value(forKey: "_source") as! NSDraggingSource
    }
    
    /// The start location of the drag.
    public var startLocation: CGPoint {
        value(forKeySafely: "startLocation") as? CGPoint ?? .zero
    }

    /// The current destination window of the drag.
    public var destinationWindow: NSWindow? {
        NSApp.windows.first(where: { $0.frame.contains(draggingLocation)})
    }
    
    /// The current destination window location of the drag.
    public var destinationWindowLocation: CGPoint? {
        guard let window = destinationWindow else { return nil }
        return window.convertPoint(fromScreen: draggingLocation)
    }
    
    /// The current destination view of the drag.
    public var destinationView: NSView? {
        guard let window = destinationWindow, let contentView = window.contentView else { return nil }
        return contentView.hitTest(contentView.convertFromWindow(window.convertPoint(fromScreen: draggingLocation))) ?? contentView
    }
    
    /// The current destination view location of the drag.
    public var destinationViewLocation: CGPoint? {
        guard let window = destinationWindow, let contentView = window.contentView else { return nil }
        let location = contentView.convertFromWindow(window.convertPoint(fromScreen: draggingLocation))
        if let view = contentView.hitTest(location) {
            return contentView.convert(location, to: view)
        }
        return location
    }
    
    /// The destination of a drag.
    public enum Destination {
        /// Source view.
        case source
        /// Application.
        case application
        /// Outside application.
        case outsideApplication
    }
    
    /// The current destination of the drag.
    public var destination: Destination {
        guard destinationWindow != nil else { return .outsideApplication }
        if let view = destinationView, (source as? NSView) === view {
            return .source
        }
        return .application
    }
    
    /**
     Sets the image components of the dragging items provided by the handler.
     
     - Parameters:
        - readings: The types that the dragging items represent.
        - handler: The handler that provides image components for the dragging items.
     */
    public func setDraggingItemImageComponents(for types: [PasteboardReading.Type]? = nil, handler: @escaping (_ item: NSDraggingItem, _ imageComponents: [NSDraggingImageComponent]?)->([NSDraggingImageComponent]?)) {
        var classes: [AnyClass] = []
            for reading in types ?? [] {
                if let reading = reading as? NSPasteboardReading.Type {
                    classes.append(reading)
                } else if reading is String.Type {
                    classes.append(NSString.self)
                } else if reading is URL.Type {
                    classes.append(NSURL.self)
                }
                if #available(macOS 12, *) {
                    if reading is AttributedString.Type {
                        classes.append(NSString.self)
                    }
                }
            }
        if classes.isEmpty {
            classes.append(NSPasteboardItem.self)
        }
        enumerateDraggingItems(for: nil, classes: classes) { item, index, shouldStop in
            if let imageComponents = handler(item, item.imageComponents) {
                item.imageComponentsProvider = { imageComponents }
            }
        }
    }
}

/// Handlers of a dragging source.
public struct NSDraggingSourceHandlers {
    /// The handler that is called when the dragging source will begin a drag.
    public var willBegin: ((_ session: NSDraggingSession, _ screenLocation: CGPoint)->())?
    /// The handler that is called when the drag of the dragging source did move to a new location.
    public var didUpdate: ((_ session: NSDraggingSession, _ screenLocation: CGPoint)->())?
    /// The handler that is called when the drag of the dragging source did end.
    public var didEnd: ((_ session: NSDraggingSession, _ screenLocation: CGPoint, _  operation: NSDragOperation)->())?
}

extension NSDraggingSource where Self: NSObject {
    /// The handlers of the dragging source.
    public var draggingSourceHandlers: NSDraggingSourceHandlers {
        get { getAssociatedValue("draggingSourceHandlers") ?? .init() }
        set {
            setAssociatedValue(newValue, key: "draggingSourceHandlers")
            if newValue.willBegin != nil {
                swizzleDraggingSourceWillBegin()
            }
            if newValue.didUpdate != nil {
                swizzleDraggingSourcedidUpdate()
            }
            if newValue.didEnd != nil {
                swizzleDraggingSourcedidEnd()
            }
        }
    }
    
    private var didSwizzleDraggingSourceWillBegin: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceWillBegin") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceWillBegin") }
    }
    
    private var didSwizzleDraggingSourceDidUpdate: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceDidUpdate") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceDidUpdate") }
    }
    
    private var didSwizzleDraggingSourceDidEnd: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceDidEnd") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceDidEnd") }
    }
    
    private func swizzleDraggingSourceWillBegin() {
        guard !didSwizzleDraggingSourceWillBegin else { return }
        didSwizzleDraggingSourceWillBegin = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:willBeginAt:))) {
            do {
                try hook(#selector(NSDraggingSource.draggingSession(_:willBeginAt:)), closure: { original, object, sel, session, screenLocation in
                    (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.willBegin?(session, screenLocation)
                    original(object, sel, session, screenLocation)
                } as @convention(block) (
                    (AnyObject, Selector, NSDraggingSession, NSPoint) -> Void,
                    AnyObject, Selector, NSDraggingSession, NSPoint) -> Void)
            } catch {
               debugPrint(error)
            }
        } else {
            do {
                try addMethod(#selector(NSDraggingSource.draggingSession(_:willBeginAt:)), closure: { [weak self] session, screenLocation in
                    guard let self = self else { return }
                    self.draggingSourceHandlers.willBegin?(session, screenLocation)
                } as @convention(block) (NSDraggingSession, NSPoint) -> Void)
            } catch {
                Swift.print(error)
            }
            let selector = #selector(NSDraggingSource.draggingSession(_:willBeginAt:))
            let block: @convention(block) (AnyObject, NSDraggingSession, NSPoint) -> Void = { [weak self] _self, session, screenLocation in
                guard let self = self else { return }
                self.draggingSourceHandlers.willBegin?(session, screenLocation)
            }
            let methodIMP = imp_implementationWithBlock(block)
            class_addMethod(object_getClass(self), selector, methodIMP, method_getTypeEncoding(methodIMP))
        }
    }
    
    private func swizzleDraggingSourcedidUpdate() {
        guard !didSwizzleDraggingSourceDidUpdate else { return }
        didSwizzleDraggingSourceDidUpdate = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:movedTo:))) {
            do {
                try hook(#selector(NSDraggingSource.draggingSession(_:movedTo:)), closure: { original, object, sel, session, screenLocation in
                    (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.didUpdate?(session, screenLocation)
                    original(object, sel, session, screenLocation)
                } as @convention(block) (
                    (AnyObject, Selector, NSDraggingSession, NSPoint) -> Void,
                    AnyObject, Selector, NSDraggingSession, NSPoint) -> Void)
            } catch {
               debugPrint(error)
            }
        } else {
            /*
            let selector = #selector(NSDraggingSource.draggingSession(_:movedTo:))
            let block: @convention(block) (AnyObject, NSDraggingSession, NSPoint) -> Void = { [weak self] _self, session, screenLocation in
                guard let self = self else { return }
                self.draggingSourceHandlers.didUpdate?(session, screenLocation)
            }
            let methodIMP = imp_implementationWithBlock(block)
             */
        }
    }
    
    private func swizzleDraggingSourcedidEnd() {
        guard !didSwizzleDraggingSourceDidEnd else { return }
        didSwizzleDraggingSourceDidEnd = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:endedAt:operation:))) {
            do {
                try hook(#selector(NSDraggingSource.draggingSession(_:endedAt:operation:)), closure: { original, object, sel, session, screenLocation, operation in
                    (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.didEnd?(session, screenLocation, operation)
                    original(object, sel, session, screenLocation, operation)
                } as @convention(block) (
                    (AnyObject, Selector, NSDraggingSession, NSPoint, NSDragOperation) -> Void,
                    AnyObject, Selector, NSDraggingSession, NSPoint, NSDragOperation) -> Void)
            } catch {
               debugPrint(error)
            }
        } else {
            let selector = #selector(NSDraggingSource.draggingSession(_:endedAt:operation:))
            let block: @convention(block) (AnyObject, NSDraggingSession, NSPoint, NSDragOperation) -> Void = { [weak self] _self, session, screenLocation, operation in
                guard let self = self else { return }
                self.draggingSourceHandlers.didEnd?(session, screenLocation, operation)
            }
            let methodIMP = imp_implementationWithBlock(block)
            class_addMethod(object_getClass(self), selector, methodIMP, method_getTypeEncoding(methodIMP))
        }
    }
}

#endif
