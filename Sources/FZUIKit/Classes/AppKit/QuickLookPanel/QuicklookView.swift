//
//  File.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

#if os(macOS)
import AppKit
import Quartz
import FZSwiftUtils

/**
 A Quick Look preview of an item that you can embed into your view hierarchy.
 */
public class QuicklookView: NSView {
    internal var qlPreviewView: QLPreviewView!
    
    /**
    The style of the view.
     */
    public var style: QLPreviewViewStyle = .normal {
        didSet {
            if self.style != oldValue {
                qlPreviewView.removeFromSuperview()
                qlPreviewView = QLPreviewView(frame: .zero, style: self.style)
                self.addSubview(withConstraint: qlPreviewView)
            }
        }
    }
    
    /**
     The item to preview.

     Quick Look requires Items you wish to conform to the QLPreviewable protocol. When you set this property, the QuicklookView loads the preview asynchronously. Due to this asynchronous behavior, don’t assume that the preview is ready immediately after assigning it to this property.
     */
    public var item: QLPreviewable? {
        get { qlPreviewView.previewItem as? QLPreviewable }
        set { qlPreviewView.previewItem = newValue }
    }
    
    /**
     Updates the preview to display the currently previewed item.

     When you modify the object that the item property points to, call this method to generate and display the new preview.
     */
    public func refreshItem() {
        qlPreviewView.refreshPreviewItem()
    }
    
    
    /**
     A Boolean value that determines whether the preview starts automatically.

     Set this property to allow previews of movie files to start playback automatically when displayed.
    */
    public var autostarts: Bool {
        get { qlPreviewView.autostarts }
        set { qlPreviewView.autostarts = newValue }
    }

    /**
     A Boolean value that determines whether the preview should close when its window closes.

     The default value of this property is true, which means that the preview automatically closes when its window closes. If you set this property to false, close the preview by calling the close() method when finished with it. Once you close a QuicklookView, it won’t accept any more preview items.
    */
    public var shouldCloseWithWindow: Bool {
        get { qlPreviewView.shouldCloseWithWindow }
        set { qlPreviewView.shouldCloseWithWindow = newValue }
    }
    
    /**
     Closes the view, releasing the current  item.

     Once a QuicklookView is closed, it won’t accept any more preview items. You only need to call this method if shouldCloseWithWindow is set to false. If you don’t close a QuicklookView when you are done using it, your app will leak memory.
     */
    public func close() {
        qlPreviewView.close()
    }
    
    /**
     Creates a preview view with the provided item and style.
     - Parameter item: The item to preview.
     - Parameter style: The desired style for the QuicklookView object.
     - Returns: Returns a QuicklookView object with the designated item and style.

     */
    public init(item: QLPreviewable, style: QLPreviewViewStyle = .normal) {
        super.init(frame: .zero)
        self.item = item
    }
    
    /**
     Creates a preview view with the provided item and style.
     - Parameter fileURL: The url to the file to preview.
     - Parameter style: The desired style for the QuicklookView object.
     - Returns: Returns a QuicklookView object with the designated item and style.

     */
    public convenience init(fileURL: URL, style: QLPreviewViewStyle = .normal) {
        self.init(item: QuicklookItem(url: fileURL), style: style)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    internal func sharedInit() {
        self.qlPreviewView = QLPreviewView(frame: .zero, style: self.style)
        self.addSubview(withConstraint: self.qlPreviewView)
    }
}

#endif
