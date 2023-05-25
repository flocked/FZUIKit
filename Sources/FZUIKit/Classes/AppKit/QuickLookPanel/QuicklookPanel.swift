//
//  QuicklookPanel.swift
//  FZExtensions
//
//  Created by Florian Zand on 08.05.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import Quartz

/**
  QuicklookPanel presents Quick Look previews of files to a panel simliar to Finder's Quick Look.

  Every application has a single shared instance of QuicklookPanel accessible through *shared*.

  QuicklookPanel previews any object conforming to QLPreviable. The protocol requires a file URL *quicklookURL* and optionally a title *quicklookTitle*.

  ```
 struct Item: QLPreviable {
 let quicklookURL: URL
 let quicklookTitle: String?
 }
  ```

  NSCollectionView can present Quick Look previews of selected items that conform to QLPreviable.

  ```
  MyCollectionItem: NSCollectionViewItem, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  collectionView.quicklookItems(itemsToPreview)
  // or preview selected items
  collectionView.quicklookSelectedItems()
  ```

  NSTableView can  preset Quick Look previews of selected rows that conform to QLPreviable.

  ```
  MyTableRowView: NSTableRowView, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  tableView.quicklookRows(rowsToPreview)
  // or preview selected rows
  tableView.quicklookSelectedRows()
  ```
  */
public class QuicklookPanel: NSResponder {
    /**
     The singleton quicklook panel instance.
     */
    public static let shared = QuicklookPanel()

    /**
     The responder to handle keyDown events.

     The responder that handles events whenever the user presses keys when the panel is open.

     When using NSTableView's quicklookRows(_:) the table view will be automatically assigned to it. When using NSCollectionView's quicklookItems(_:) the collection view will be automatically assigned to it.
     */
    public weak var keyDownResponder: NSResponder? = nil

    internal weak var itemsProviderWindow: NSWindow? = nil

    internal var items = [QLPreviewable]() {
        didSet {
            let oldPreviewableMedia = oldValue.compactMap { $0 as? QLTemporaryFile }
            deleteTemporaryMediaFiles(for: oldPreviewableMedia)
        }
    }

    internal func deleteTemporaryMediaFiles(for mediaItems: [QLTemporaryFile]) {
        let newItemURLs = items.compactMap { ($0 as? QLTemporaryFile)?.previewURL }
        let mediaItems = mediaItems.filter {
            guard let previewURL = $0.previewURL else { return false }
            return newItemURLs.contains(previewURL)
        }
        mediaItems.forEach { try? $0.deleteTemporaryQLFile() }
    }

    override public func acceptsPreviewPanelControl(_: QLPreviewPanel!) -> Bool {
        return true
    }

    override public func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = self
        panel.delegate = self
    }

    override public func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = nil
        panel.delegate = nil
    }

    internal var previewPanel: QLPreviewPanel {
        QLPreviewPanel.shared()
    }

    /**
     A Boolean value that indicates whether the panel is visible onscreen (even when it’s obscured by other windows).

     The value of this property is true when the panel is onscreen (even if it’s obscured by other windows); otherwise, false.
     */
    public var isVisible: Bool {
        return previewPanel.isVisible
    }

    /**
     The index of the current preview item.
     */
    public var currentItemIndex: Int {
        get { previewPanel.currentPreviewItemIndex }
        set { previewPanel.currentPreviewItemIndex = newValue.clamped(max: items.count - 1) }
    }

    /**
     The currently previewed item.

     The value is nil if there’s no current preview item.
     */
    public var currentItem: QLPreviewable? {
        if items.isEmpty == false, currentItemIndex < items.count {
            return items[currentItemIndex]
        }
        return nil
    }

    /**
     A Boolean value that indicates whether the panel is removed from the screen when its application becomes inactive.

     The value of this property is true if the panel is removed from the screen when its application is deactivated; false if it remains onscreen. The default value is true.
     */
    public var hidesOnAppDeactivate: Bool {
        get { previewPanel.hidesOnDeactivate }
        set { previewPanel.hidesOnDeactivate = newValue }
    }

    /**
     Enters the panel in full screen mode.

     - Parameters items: true if the panel was able to enter full screen mode; otherwise, false.
     - Parameters currentItemIndex: true if the panel was able to enter full screen mode; otherwise, false.
     - Parameters currentItemIndex: true if the panel was able to enter full screen mode; otherwise, false.

     */
    public func present(_ items: [QLPreviewable], currentItemIndex: Int = 0) {
        DispatchQueue.main.async {
            self.items = items.filter { $0.previewItemURL != nil }
            self.open()
            self.previewPanel.reloadData()
            if items.isEmpty == false {
                self.currentItemIndex = currentItemIndex
            }
        }
    }

    public func present(content: QLPreviewableContent, frame: CGRect? = nil) {
        present([QuicklookItem(content: content, frame: frame)])
    }

    public func present(contents: [QLPreviewableContent], frame: CGRect? = nil, currentItemIndex: Int = 0) {
        present(contents.compactMap { QuicklookItem(content: $0, frame: frame) }, currentItemIndex: currentItemIndex)
    }

    public func open(frame _: CGRect? = nil, image _: NSImage? = nil) {
        if previewPanel.isVisible == false {
            itemsProviderWindow = NSApp.keyWindow
            /*
             let frame = frame ?? currentItem?.previewItemFrame ?? self.itemsProviderWindow?.frame
             if let frame = frame {
                 if let currentItem = self.currentItem {
                     let currentItem = QuicklookItem(url: currentItem.previewItemURL, frame: frame)
                     self.items.replaceSubrange(self.currentItemIndex...self.currentItemIndex, with: [currentItem])
                 }
             }
              */
            NSApp.nextResponder = self
            previewPanel.updateController()
            previewPanel.makeKeyAndOrderFront(nil)
        }
    }

    public func close(frame: CGRect? = nil, image _: NSImage? = nil) {
        if previewPanel.isVisible == true {
            let frame = frame ?? currentItem?.previewItemFrame ?? itemsProviderWindow?.frame
            if let frame = frame {
                if let currentItem = currentItem {
                    let currentItem = QuicklookItem(currentItem.previewContent, frame: frame)
                    items.replaceSubrange(currentItemIndex ... currentItemIndex, with: [currentItem])
                }
            }
            previewPanel.orderOut(nil)
            items.removeAll()
            itemsProviderWindow = nil
            keyDownResponder = nil
        }
    }

    /**
     Recomputes the preview of the current preview item.
     */
    public func refreshCurrentPreviewItem() {
        previewPanel.refreshCurrentPreviewItem()
    }

    /**
     Enters the panel in full screen mode.

     - Returns: true if the panel was able to enter full screen mode; otherwise, false.
     */
    public func enterFullScreen() -> Bool {
        return previewPanel.enterFullScreenMode(nil)
    }

    /**
     Exists the panels full screen mode.
     */
    public func exitFullScreen() {
        previewPanel.exitFullScreenMode()
    }

    /**
     The property that indicates whether the panel is in full screen mode.

     The value is true if the panel is currently open and in full screen mode; otherwise it’s false.
     */
    public var isInFullScreen: Bool {
        return previewPanel.isInFullScreenMode
    }

    internal func temporaryURL() -> URL {
        if let temporaryDirectory: URL = getAssociatedValue(key: "_QuicklookPanel_temporaryURL", object: self) {
            return temporaryDirectory
        } else {
            let temporaryDirectory = FileManager.default.createTemporaryDirectory()
            set(associatedValue: temporaryDirectory, key: "_QuicklookPanel_temporaryURL", object: self)
            return temporaryDirectory
        }
    }

    override internal init() {
        super.init()
    }

    @available(*, unavailable)
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuicklookPanel: QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    public func previewPanel(_: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if items.count > 1 && (event.keyCode == 123 || event.keyCode == 124) {
            return true
        }
        if let keyDownResponder = keyDownResponder, event.type == .keyDown || event.type == .keyUp, event.keyCode != 49 {
            if event.type == .keyDown {
                keyDownResponder.keyDown(with: event)
            }
            return true
        } else {
            return true
        }
    }

    public func previewPanel(_: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        if let previewItemFrame = (item as? QLPreviewable)?.previewItemFrame {
            return previewItemFrame
        }

        if let itemsProviderWindow = itemsProviderWindow {
            return itemsProviderWindow.frame
        }

        if let screenFrame = NSScreen.main?.visibleFrame {
            var frame = CGRect(origin: .zero, size: screenFrame.size * 0.5)
            frame.center = screenFrame.center
            return frame
        }

        return .zero
    }

    public func previewPanel(_: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return items[index]
    }

    public func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
        return items.count
    }

    public func previewPanel(_: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect _: UnsafeMutablePointer<NSRect>!) -> Any! {
        return (item as? QLPreviewable)?.previewItemTransitionImage
    }
}

#endif
