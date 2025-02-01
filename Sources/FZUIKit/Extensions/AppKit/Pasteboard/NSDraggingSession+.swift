//
//  NSDraggingSession+.swift
//
//
//  Created by Florian Zand on 01.02.25.
//

#if os(macOS)
import AppKit

extension NSDraggingSession {
    /// The source of the drag.
    public var source: NSDraggingSource {
        value(forKey: "_source") as! NSDraggingSource
    }
    
    /// The start location of the drag.
    public var startLocation: CGPoint {
        value(forKey: "startLocation") as! CGPoint
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
    /// The handler that gets called when the dragging source will begin a drag.
    public var willBegin: ((_ session: NSDraggingSession, _ screenLocation: CGPoint)->())?
    /// The handler that gets called when the drag of the dragging source did move to a new location.
    public var didUpdate: ((_ session: NSDraggingSession, _ screenLocation: CGPoint)->())?
    /// The handler that gets called when the drag of the dragging source did end.
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
    
    var didSwizzleDraggingSourceWillBegin: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceWillBegin") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceWillBegin") }
    }
    
    var didSwizzleDraggingSourceDidUpdate: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceDidUpdate") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceDidUpdate") }
    }
    
    var didSwizzleDraggingSourceDidEnd: Bool {
        get { getAssociatedValue("didSwizzleDraggingSourceDidEnd") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleDraggingSourceDidEnd") }
    }
    
    func swizzleDraggingSource() {
        
    }
    
    func swizzleDraggingSourceWillBegin() {
        guard !didSwizzleDraggingSourceWillBegin else { return }
        didSwizzleDraggingSourceWillBegin = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:willBeginAt:))) {
            do {
               try replaceMethod(
                #selector(NSDraggingSource.draggingSession(_:willBeginAt:)),
               methodSignature: (@convention(c)  (AnyObject, Selector, NSDraggingSession, NSPoint) -> ()).self,
               hookSignature: (@convention(block)  (AnyObject, NSDraggingSession, NSPoint) -> ()).self) { store in {
                   object, session, screenLocation in
                   (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.willBegin?(session, screenLocation)
                   store.original(object,  #selector(NSDraggingSource.draggingSession(_:willBeginAt:)), session, screenLocation)
                   }
               }
            } catch {
               debugPrint(error)
            }
        } else {
            let selector = #selector(NSDraggingSource.draggingSession(_:willBeginAt:))
            let block: @convention(block) (AnyObject, NSDraggingSession, NSPoint) -> Void = { [weak self] _self, session, screenLocation in
                guard let self = self else { return }
                self.draggingSourceHandlers.willBegin?(session, screenLocation)
            }
            let methodIMP = imp_implementationWithBlock(block)
            class_addMethod(object_getClass(self), selector, methodIMP, "v@:@{CGPoint=dd}")
        }
    }
    
    func swizzleDraggingSourcedidUpdate() {
        Swift.print("swizzleDraggingSourcedidUpdate", didSwizzleDraggingSourceDidUpdate)
        guard !didSwizzleDraggingSourceDidUpdate else { return }
        didSwizzleDraggingSourceDidUpdate = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:movedTo:))) {
            do {
               try replaceMethod(
                #selector(NSDraggingSource.draggingSession(_:movedTo:)),
               methodSignature: (@convention(c)  (AnyObject, Selector, NSDraggingSession, NSPoint) -> ()).self,
               hookSignature: (@convention(block)  (AnyObject, NSDraggingSession, NSPoint) -> ()).self) { store in {
                   object, session, screenLocation in
                   (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.didUpdate?(session, screenLocation)
                   store.original(object, #selector(NSDraggingSource.draggingSession(_:movedTo:)), session, screenLocation)
                   }
               }
            } catch {
               debugPrint(error)
            }
        } else {
            let selector = #selector(NSDraggingSource.draggingSession(_:movedTo:))
            let block: @convention(block) (AnyObject, NSDraggingSession, NSPoint) -> Void = { [weak self] _self, session, screenLocation in
                Swift.print("movedTo", self != nil)
                guard let self = self else { return }
                self.draggingSourceHandlers.didUpdate?(session, screenLocation)
            }
            let methodIMP = imp_implementationWithBlock(block)
            Swift.print("swizzle", class_addMethod(object_getClass(self), selector, methodIMP, "v@:@{CGPoint=dd}Q"))
        }
    }
    
    func swizzleDraggingSourcedidEnd() {
        guard !didSwizzleDraggingSourceDidEnd else { return }
        didSwizzleDraggingSourceDidEnd = true
        if responds(to: #selector(NSDraggingSource.draggingSession(_:endedAt:operation:))) {
            do {
               try replaceMethod(
                #selector(NSDraggingSource.draggingSession(_:endedAt:operation:)),
               methodSignature: (@convention(c)  (AnyObject, Selector, NSDraggingSession, NSPoint, NSDragOperation) -> ()).self,
               hookSignature: (@convention(block)  (AnyObject, NSDraggingSession, NSPoint, NSDragOperation) -> ()).self) { store in {
                   object, session, screenLocation, operation in
                   (object as? NSDraggingSource & NSObject)?.draggingSourceHandlers.didEnd?(session, screenLocation, operation)
                   store.original(object, #selector(NSDraggingSource.draggingSession(_:endedAt:operation:)), session, screenLocation, operation)
                   }
               }
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
            class_addMethod(object_getClass(self), selector, methodIMP, "v@:@{CGPoint=dd}Q")
        }
    }
}

#endif
