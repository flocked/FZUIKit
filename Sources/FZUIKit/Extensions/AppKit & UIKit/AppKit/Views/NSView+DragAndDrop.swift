//
//  NSView+DragDrop.swift
//  Tester
//
//  Created by Florian Zand on 05.04.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public protocol DragAndDropView {
    var dragAndDrop: DragAndDropConfiguration { get set }
}

public extension DragAndDropView where Self: NSView {
    var dragAndDrop: DragAndDropConfiguration {
        get { getAssociatedValue(key: "_ViewDragAndDrop", object: self, initialValue: DragAndDropConfiguration()) }
        set { set(associatedValue: newValue, key: "_ViewDragAndDrop", object: self)
            if newValue.needsSwizzle {
                Self.swizzleDragDropView()
            }
        }
    }
}

public struct DragAndDropConfiguration {
    public typealias DropFilesValidationHandler = ([URL]) -> NSDragOperation
    public typealias DropFilesHandler = ([URL]) -> (Bool)

    public enum FileDropOption: Int {
        case disabled
        case single
        case multiple
    }

    internal var needsSwizzle: Bool {
        option != .disabled && validateFilesHandler != nil && didDropFilesHandler != nil
    }

    public var option: FileDropOption = .disabled
    public var validateFilesHandler: DropFilesValidationHandler? = nil
    public var didDropFilesHandler: DropFilesHandler? = nil
}

internal extension NSView {
    @objc func swizzled_prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let dragDropView = self as? DragAndDropView, dragDropView.dragAndDrop.option != .disabled, let validator = dragDropView.dragAndDrop.validateFilesHandler,
              let files = filesOnPasteboard(for: sender)
        else {
            return swizzled_prepareForDragOperation(sender)
        }
        return validator(files) != []
    }

    @objc func swizzled_draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let dragDropView = self as? DragAndDropView, dragDropView.dragAndDrop.option != .disabled, let files = filesOnPasteboard(for: sender) else {
            return swizzled_draggingEntered(sender)
        }

        if dragDropView.dragAndDrop.option != .multiple, files.count != 1 {
            return []
        }

        var dragOperation: NSDragOperation = []
        if let validator = dragDropView.dragAndDrop.validateFilesHandler {
            dragOperation = validator(files)
        }

        return dragOperation
    }

    @objc func swizzled_draggingExited(_ sender: NSDraggingInfo?) {
        //    self.outerBoundary.strokeColor = self.backgroundStrokeColor()
        //  self.outerBoundary.fillColor = self.backgroundColor()
        //  self.stopAnimation()
        swizzled_draggingExited(sender)
    }

    @objc func swizzled_performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let dragDropView = self as? DragAndDropView, dragDropView.dragAndDrop.option != .disabled else {
            return swizzled_performDragOperation(sender)
        }

        if let didDropFiles = dragDropView.dragAndDrop.didDropFilesHandler,
           let files = filesOnPasteboard(for: sender)
        {
            return didDropFiles(files)
        }

        return false
    }

    func filesOnPasteboard(for sender: NSDraggingInfo) -> [URL]? {
        let pb = sender.draggingPasteboard
        guard let objs = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
            return nil
        }
        let urls = objs.compactMap { $0 as URL }
        return urls.count == 0 ? nil : urls
    }

    static var didSwizzleDragDropView: Bool {
        get { getAssociatedValue(key: "_didSwizzleDragDropView", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "_didSwizzleDragDropView", object: self) }
    }

    @objc static func swizzleDragDropView() {
        if didSwizzleDragDropView == false {
            didSwizzleDragDropView = true
            do {
                try Swizzle(NSView.self) {
                    #selector(draggingEntered) <-> #selector(swizzled_draggingEntered)
                    #selector(prepareForDragOperation) <-> #selector(swizzled_prepareForDragOperation)
                    #selector(draggingExited) <-> #selector(swizzled_draggingExited)
                    #selector(performDragOperation) <-> #selector(swizzled_performDragOperation)
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}

#endif
