//
//  DropInfo.swift
//
//
//  Created by Florian Zand on 15.03.25.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

/// An object that provides information about a drop session.
public class DropInfo: NSObject {
    let draggingInfo: NSDraggingInfo
    weak var view: NSView?
    
    /// The current location of the mouse pointer inside the destination view.
    public var draggingLocation: CGPoint { view != nil ? draggingInfo.location(in: view!) : draggingInfo.draggingLocation }
    /**
     The source, or owner, of the dragged data.
     
     This method returns `nil` if the source is not in the same application as the destination.
     */
    public var draggingSource: NSDraggingSource? { draggingInfo.draggingSource as? NSDraggingSource }
    /**
     Information about the dragging operation and the data it contains.
     
     The dragging source (`NSDraggingSource`) declares the dragging operation mask through `draggingSession(_:sourceOperationMaskFor:)`.
     
     Returns the dragging operations that the dragging source (`NSDraggingSource`)  permits.
     
     If the user holds down a modifier key during the dragging session and the dragging source allows modifier keys to affect the drag operation, the system combines the dragging source operation mask with the value that corresponds to the modifier key:
     - option: `copy`
     - command: `move`
     - option and command: `link`
     */
    public var draggingSourceOperationMask: NSDragOperation { draggingInfo.draggingSourceOperationMask }
    
    /// The pasteboard that holds the dragged data.
    public var pasteboard: NSPasteboard { draggingInfo.draggingPasteboard }
    
    /// The content of the pasteboard that holds the dragged data.
    public var content: NSPasteboardContent { draggingInfo.pasteboardContent }
    
    /**
     The number of valid items for the drop information.
     
     During `draggingEntered` or `draggingUpdated`, you are responsible for returning the drag operation. In some cases, you may accept some, but not all items on the dragging pasteboard. (For example, your application may only accept image files.)
     
     If you only accept some of the items, set this property to the number of items accepted so the drag manager can update the drag count badge.
     
     When `updateDraggingItemsForDrag(_:)` is called, you should set the image of non-valid dragging items to `nil`. If none of the drag items are valid then you should not updateItems:, simply return none from your implementation of draggingEntered: and, or `draggingUpdated` and do not modify any drag item properties.
     */
    public var numberOfValidItemsForDrop: Int {
        get { draggingInfo.numberOfValidItemsForDrop }
        set { draggingInfo.numberOfValidItemsForDrop = newValue }
    }
    
    /**
     Sets the image that visually represents the pasteboard content during the drop operation.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    @MainActor
    public func setDraggedImage(_ image: NSImage, frame: CGRect? = nil) {
        draggingInfo.setDraggedImage(image, frame: frame)
    }
    
    /// Sets the image that visually represents the pasteboard content during the drop operation using the specified view.
    @MainActor
    public func setDraggedImage(view: NSView) {
        draggingInfo.setDraggedImage(view: view)
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
    public func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions = [], for view: NSView? = nil, classes: [NSPasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], using block: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        draggingInfo.enumerateItems(options: options, for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, using: block)
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
    public func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions = [], for view: NSView? = nil, classes: [PasteboardReading.Type], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], using block: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        draggingInfo.enumerateItems(options: options, for: view, classes: classes.map({$0.PasteboardReadingType}), fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, using: block)
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
    public func firstDraggingItem(for view: NSView? = nil, classes: [NSPasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], clearOtherItems: Bool = false, handler: @escaping (_ item: NSDraggingItem)->()) {
        draggingInfo.firstDraggingItem(for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, handler: handler)
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
    public func firstDraggingItem(for view: NSView? = nil, classes: [PasteboardReading.Type] = [NSPasteboardItem.self], fileURLsOnly: Bool = false, contentTypes: [UTType] = [], clearOtherItems: Bool = false, handler: @escaping (_ item: NSDraggingItem)->()) {
        draggingInfo.firstDraggingItem(for: view, classes: classes, fileURLsOnly: fileURLsOnly, contentTypes: contentTypes, handler: handler)
    }
    
    init(for draggingInfo: NSDraggingInfo, view: NSView) {
        self.draggingInfo = draggingInfo
        self.view = view
        super.init()
    }
}

extension NSDraggingInfo {
    public func dropInfo(for view: NSView) -> DropInfo {
        DropInfo(for: self, view: view)
    }
}

/*
public class DropItem<Content: PasteboardReading> {
    /// The content of the drop item.
    public var content: Content { draggingItem.item as! Content }
    
    /**
     The frame of the dragging item.
     
     The dragging frame provides the spatial relationship between ``DropItem`` instances when you set the dragging formation to `NSDraggingFormation.none`.
     */
    public var draggingFrame: CGRect {
        get { draggingItem.draggingFrame }
        set { draggingItem.draggingFrame = newValue }
    }
    
    /**
     Sets the item’s dragging image.
     
     - Parameters:
     - image: The dragging image.
     - frame: The dragging image frame.
     */
    public func setDraggingImage(_ image: NSImage, frame: CGRect? = nil) {
        draggingItem.setDraggingImage(image, frame: frame)
    }
    
    /// Sets the item’s dragging image to display to preview the specified view.
    public func setDraggingImage(view: NSView, frame: CGRect? = nil) {
        draggingItem.setDraggingImage(view: view)
    }
    
    /// The image components to use to create the drag image.
    public var imageComponents: [NSDraggingImageComponent]? {
        draggingItem.imageComponents
    }
    
    /**
     The handler that provides the image components to use to create the drag image.
     
     The dragging image is the composite of the array provided.
     
     You can set the block to `nil`, meaning that the drag item has no image.
     */
    public var imageComponentsProvider: (()->([NSDraggingImageComponent]))? {
        get { draggingItem.imageComponentsProvider }
        set { draggingItem.imageComponentsProvider = newValue }
    }
    
    let draggingItem: NSDraggingItem
    init(_ draggingItem: NSDraggingItem) {
        self.draggingItem = draggingItem
    }
}
*/

#endif
