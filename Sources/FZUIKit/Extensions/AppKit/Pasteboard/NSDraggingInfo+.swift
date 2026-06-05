//
//  NSDraggingInfo+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

public extension NSDraggingInfo {
    /**
     The current location of the mouse pointer in the specified view.
     
     - Parameter view: The view for the location.
     */
    func location(in view: NSView) -> CGPoint {
        view.convert(draggingLocation, from: nil)
    }
        
    /**
     Sets the image that visually represents the pasteboard content during the drag operation.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    @MainActor
    func setDraggedImage(_ image: NSImage, frame: CGRect? = nil) {
        firstDraggingItem(clearOtherItems: true) {
            $0.setDraggingImage(image, frame: frame)
        }
    }
    
    /// Sets the image that visually represents the pasteboard content during the drag operation using the specified view.
    @MainActor
    func setDraggedImage(view: NSView) {
        setDraggedImage(view.renderedImage)
    }
    
    /**
     Sets the images that visually represent the pasteboard content of each dragging item during the drag operation.
     
     - Parameter images: The dragging images.
     */
    @MainActor
    func setDraggedImages(_ images: [NSImage]) {
        guard !images.isEmpty else { return }
        enumerateDraggingItems(options: .clearNonenumeratedImages) { draggingItem, index, shouldStop in
            guard let image = images[safe: index] else {
                shouldStop = true
                return
            }
            draggingItem.setDraggingImage(image)
        }
    }
    
    /**
     Sets the images that visually represent the pasteboard content of each dragging item during the drag operation.
     
     - Parameter images: The dragging images and their frames.
     */
    @MainActor
    func setDraggedImages(_ images: [(image: NSImage, frame: CGRect)]) {
        guard !images.isEmpty else { return }
        enumerateDraggingItems(options: .clearNonenumeratedImages) { draggingItem, index, shouldStop in
            guard let value = images[safe: index] else {
                shouldStop = true
                return
            }
            draggingItem.setDraggingImage(value.image, frame: value.frame)
        }
    }
    
    /**
     Enumerates through each dragging item.
     
     - Parameters:
        - options: The enumeration options. See NSDraggingItemEnumerationOptions for the supported values.
        - view: The view to use as the base coordinate system for the NSDraggingItem instances.
        - classes: An array of class objects. Arrange classes in the array in the preferred order of representation. Classes in the array must conform to the NSPasteboardReading protocol.
        - fileURLsOnly: A Boolean value for reading URLs to restrict the results to file URLs only.
        - contentTypes: The content types for reading URLs to restrict the results to URLs with contents that conform to any of the provided UTI types.
        - block: The block to execute for the enumeration. The block takes three arguments:
     
            - draggingItem: A reference to the dragging item. The draggingFrame of the dragging item is in the coordinate space of the view that view specifies. A view value of nil means the screen coordinate space.
            - index: The index of the element in the classes.
            - shouldStop: A reference to a Boolean value that the block can use to stop the enumeration by setting *stop to true.

     Enumerate through dragging items to modify their properties, such as the drag image or size, to indicate that the user has dragged the items over a possible destination. Changes you make in this method on behalf of the dragging destination override changes from the source’s drag session.
     
     To get dragging items in a data type that you expect while enumerating, specify classes in the classesArray parameter that implement the NSPasteboardReading protocol, such as NSImage, NSString, NSURL, NSColor, NSAttributedString, or NSPasteboardItem. For each item in the dragging pasteboard, the system performs the following steps:
     
     1. The systems calls readableTypes(for:) on the item to determine the types of data the item conforms to.
     It attempts to create an instance of a matching class from the dragging pasteboard data, using the class order you specify in the classesArray parameter.
     2. If it can create an instance of a matching class, the system creates an instance of NSDraggingItem with the class instance and the dragging properties of that item.
     3. The system passes the NSDraggingItem to the block you provide as the draggingItem parameter.
     4. If the system can’t create an instance of one of the classes you specify in classesArray with an item, the system skips the item without calling block and proceeds to the next item.
     
     - Tip: Ensure you receive one object per item on the pasteboard by including the NSPasteboardItem class in the array of classes.
     When the system provides a draggingItem to your block, modify the item’s properties to change how the user sees the item while dragging. Provide a view to this method if you want to express each dragging item’s draggingFrame relative to that view.
     
     - Warning: The `draggingItem` object is only valid for the current iteration of the enumeration block. Never store the `draggingItem` or change it outside of the block iteration.

       Don't reference `draggingItem` inside an `imageComponentsProvider` block for the following reasons:

       - When the system calls the `imageComponentsProvider` block, the enumeration block is out of scope and the `draggingItem` is no longer valid.

       - Referencing `draggingItem` in an `imageComponentsProvider` block creates a retain cycle because `draggingItem` retains `imageComponentsProvider`, and `imageComponentsProvider` retains `draggingItem`.

       Assign `draggingItem.item` to an object pointer or variable outside of the `imageComponentsProvider` block definition instead, and use that object pointer or variable inside the `imageComponentsProvider` block definition.
     
     Current page is enumerateDraggingItems(options:for:classes:searchOptions:using:)
     */
    @MainActor
    func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions = [], for view: NSView? = nil, classes: [NSPasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], using block: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        enumerateItems(options: options, for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, using: block)
    }
    
    /**
     Enumerates through each dragging item.
     
     - Parameters:
        - options: The enumeration options. See NSDraggingItemEnumerationOptions for the supported values.
        - view: The view to use as the base coordinate system for the NSDraggingItem instances.
        - classes: An array of class objects. Arrange classes in the array in the preferred order of representation. Classes in the array must conform to the NSPasteboardReading protocol.
        - fileURLsOnly: A Boolean value for reading URLs to restrict the results to file URLs only.
        - contentTypes: The content types for reading URLs to restrict the results to URLs with contents that conform to any of the provided UTI types.
        - block: The block to execute for the enumeration. The block takes three arguments:
     
            - draggingItem: A reference to the dragging item. The draggingFrame of the dragging item is in the coordinate space of the view that view specifies. A view value of nil means the screen coordinate space.
            - index: The index of the element in the classes.
            - shouldStop: A reference to a Boolean value that the block can use to stop the enumeration by setting *stop to true.
     */
    @MainActor
    @_disfavoredOverload
    func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions = [], for view: NSView? = nil, classes: [PasteboardReading.Type], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], using block: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        enumerateItems(options: options, for: view, classes: classes.map({$0.PasteboardReadingType}), fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, using: block)
    }
    
    /**
     Updates the first dragging item matching with the specified handler.
     
     - Parameters:
        - view: The view to use as the base coordinate system for the NSDraggingItem instances.
        - classes: An array of class objects. Arrange classes in the array in the preferred order of representation. Classes in the array must conform to the NSPasteboardReading protocol.
        - fileURLsOnly: A Boolean value for reading URLs to restrict the results to file URLs only.
        - contentTypes: The content types for reading URLs to restrict the results to URLs with contents that conform to any of the provided UTI types.
        - clearOtherItems: A Boolean value indicating whether the image components provider should be cleared for all other dragging items.
        - handler: The handler to update the dragging item.
     */
    @MainActor
    func firstDraggingItem(for view: NSView? = nil, classes: [NSPasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], clearOtherItems: Bool = false, handler: @escaping (_ item: NSDraggingItem)->()) {
        enumerateDraggingItems(options: clearOtherItems ? [.clearNonenumeratedImages] : [], for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes) { item, _, shouldStop in
            handler(item)
            shouldStop = true
        }
    }
    
    /**
     Updates the first dragging item matching with the specified handler.
     
     - Parameters:
        - view: The view to use as the base coordinate system for the NSDraggingItem instances.
        - classes: An array of class objects. Arrange classes in the array in the preferred order of representation. Classes in the array must conform to the NSPasteboardReading protocol.
        - fileURLsOnly: A Boolean value for reading URLs to restrict the results to file URLs only.
        - contentTypes: The content types for reading URLs to restrict the results to URLs with contents that conform to any of the provided UTI types.
        - clearOtherItems: A Boolean value indicating whether the image components provider should be cleared for all other dragging items.
        - handler: The handler to update the dragging item.
     */
    @MainActor
    @_disfavoredOverload
    func firstDraggingItem(for view: NSView? = nil, classes: [PasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], clearOtherItems: Bool = false, handler: @escaping (_ item: NSDraggingItem)->()) {
        enumerateDraggingItems(options: clearOtherItems ? [.clearNonenumeratedImages] : [], for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes) { item, _, shouldStop in
            handler(item)
            shouldStop = true
        }
    }
    
    @MainActor
    internal func enumerateItems(options: NSDraggingItemEnumerationOptions = [], for view: NSView? = nil, classes: [AnyClass], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], using handler: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        enumerateDraggingItems(options: options, for: view, classes: classes.isEmpty ? [NSPasteboardItem.self] : classes, searchOptions: [.urlReadingFileURLsOnly: fileURLsOnly ? true : nil, .urlReadingContentsConformToTypes: !contentTypes.isEmpty ? contentTypes : nil].nonNil) { item, index, stop in
            var shouldStop = false
            handler(item, index, &shouldStop)
            stop.pointee = shouldStop ? true : false
        }
    }
}

#endif
