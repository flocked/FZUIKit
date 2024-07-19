//
//  TextSuggestionsDelegate.swift
//  
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

public protocol NSTextSuggestionsDelegate: AnyObject {
    func textField(_ textField: NSTextField, didSelect item: SuggestionItem)
    func textField(_ textField: NSTextField, textCompletionFor item: SuggestionItem) -> String?
    func suggestions(for textField: NSTextField) -> SuggestionItemResponse
}

extension NSTextSuggestionsDelegate {
    public func textField(_ textField: NSTextField, textCompletionFor item: SuggestionItem) -> String? {
        suggestions(for: textField).highlightedItem(for: textField.stringValue)?.title
    }
    
    public func textField( _ textField: NSTextField, didSelect item: SuggestionItem) {
        
    }
}

@available(macOS 11.0, *)
extension NSTextField {
    public weak var suggestionsTableView: NSTableView? {
        get { getAssociatedValue("suggestionsTableView") }
        set { setAssociatedValue(newValue, key: "suggestionsTableView") }
    }
    
    var suggestionsTokens: [NotificationToken] {
        get { getAssociatedValue("suggestionsTokens", initialValue: []) }
        set { setAssociatedValue(newValue, key: "suggestionsTokens") }
    }
    
    /// The delegate that provides text suggestions.
    public weak var suggestionsDelegate: NSTextSuggestionsDelegate? {
        get { getAssociatedValue("suggestionsDelegate") }
        set {
            setAssociatedValue(newValue, key: "suggestionsDelegate")
            Swift.print("suggestionsDelegate set", newValue != nil, textSuggestionController == nil)
            if newValue != nil, textSuggestionController == nil {
                let textSuggestionController = TextSuggestionController(textField: self)
                suggestionsTableView = textSuggestionController.tableView
                editingHandlers.didEdit = {
                    textSuggestionController.reload()
                }
                suggestionsTokens = [
                    NotificationCenter.default.observe(NSTextField.textDidBeginEditingNotification, object: self) { [weak self] _ in
                        guard let self = self else { return }
                        Swift.print("didBegin")
                        textSuggestionController.popover.show(self, preferredEdge: .bottom, hideArrow: true, tracksView: true)
                    },
                    NotificationCenter.default.observe(NSTextField.textDidEndEditingNotification, object: self) { _ in
                        textSuggestionController.popover.close()
                    }]
                self.textSuggestionController = textSuggestionController
                suggestionsObserver = KeyValueObserver(self)
                suggestionsObserver?.add(\.stringValue) { old, new in
                    guard old != new else { return }
                    textSuggestionController.reload()
                }
                suggestionsObserver?.add(\.attributedStringValue) { old, new in
                    guard old != new else { return }
                    textSuggestionController.reload()
                }
                textSuggestionController.reload()
            } else if newValue == nil {
                suggestionsTokens = []
                textSuggestionController = nil
                suggestionsObserver = nil
                suggestionsTableView = nil
            }
        }
    }
    
    var textSuggestionController: TextSuggestionController? {
        get { getAssociatedValue("textSuggestionController") }
        set { setAssociatedValue(newValue, key: "textSuggestionController") }
    }
    
    var suggestionsObserver: KeyValueObserver<NSTextField>? {
        get { getAssociatedValue("suggestionsObserver") }
        set { setAssociatedValue(newValue, key: "suggestionsObserver") }
    }
}


@available(macOS 11.0, *)
class TextSuggestionController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    let tableView = NSTableView() { NSTableColumn("suggestion") }
    weak var textField: NSTextField?
    var suggestions: SuggestionItemResponse = .empty
    let popover = NSPopover()
    let window = NSWindow()
    
    func reload() {
        guard let textField = textField else { return }
        suggestions = textField.suggestionsDelegate?.suggestions(for: textField) ?? .empty
        tableView.reloadData()
        guard let scrollView = tableView.enclosingScrollView else { return }
        scrollView.frame.size.height = tableView.fittingSize.height.clamped(to: 22...600)
        window.setContentSize(scrollView.frame.size)
        scrollView.frame.origin.x = textField.frame.x
        scrollView.frame.origin.y = textField.frame.y - scrollView.frame.size.height
    }
    
    init(textField: NSTextField) {
        super.init()
        self.textField = textField
        let scrollView = tableView.addEnclosingScrollView()
        scrollView.frame.size = CGSize(300, 22)
        popover.contentView = scrollView
        popover.isResizingAutomatically = true
        tableView.style = .fullWidth
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnReordering = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = false
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.floatsGroupRows = false
        tableView.backgroundColor = .clear
      //  window.contentView = scrollView
      //  window.setContentSize(scrollView.frame.size)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let textField = textField, tableView.selectedRow != -1, let item = suggestions.item(at: tableView.selectedRow) else  { return }
        textField.suggestionsDelegate?.textField(textField, didSelect: item)
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return suggestions.isGroupRow(row)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return suggestions.rows.count
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return !suggestions.isGroupRow(row)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return suggestions.cellView(for: row, in: tableView)
    }
}

#endif
