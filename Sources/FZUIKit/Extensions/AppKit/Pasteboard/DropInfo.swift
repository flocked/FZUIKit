//
//  DropInfo.swift
//
//
//  Created by Florian Zand on 15.03.25.
//

#if os(macOS)
import AppKit

/// An object that provides information about a drop session.
public class DropInfo {
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
    public var content: PasteboardContent { draggingInfo.pasteboardContent }
    
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
    
    public func enumerateDropItems<Content: PasteboardReading>(for contentType: Content.Type = NSPasteboardItem.self, using block: @escaping (_ item: DropItem<Content>) -> ()) {
        draggingInfo.enumerateDraggingItems(for: view, classes: [contentType.pasteboardReadingType]) { item, index, stopPointer in
            block(DropItem<Content>(item))
        }
    }
    
    func enumerateDraggingItems(options: NSDraggingItemEnumerationOptions = [], types: [PasteboardReading.Type] = [NSPasteboardItem.self], using block: @escaping (_ draggingItem: NSDraggingItem, _ index: Int, _ shouldStop: inout Bool) -> Void) {
        var stop = false
        draggingInfo.enumerateDraggingItems(options: options, for: view, classes: types.map({ $0.pasteboardReadingType }), using: { item, index, stopPointer in
            block(item, index, &stop)
            if stop {
                stopPointer.pointee = true
            }
        })
    }
    
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
    
    init(for draggingInfo: NSDraggingInfo, view: NSView) {
        self.draggingInfo = draggingInfo
        self.view = view
    }
}

extension NSDraggingInfo {
    func dropInfo(for view: NSView) -> DropInfo {
        DropInfo(for: self, view: view)
    }
}

#endif
