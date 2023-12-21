//
//  ToolbarItem+Search.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

@available(macOS 11.0, *)
public extension ToolbarItem {
    /**
     A toolbar item that contains a search field optimized for performing text-based searches.
     
     It can be used as an item of a ``Toolbar``.
     */
    class Search: ToolbarItem, NSSearchFieldDelegate, NSTextFieldDelegate {
        internal typealias SearchHandler = (NSSearchField, String, SearchState) -> Void

        internal lazy var searchItem = NSSearchToolbarItem(identifier)
        override internal var item: NSToolbarItem {
            return searchItem
        }

        public enum SearchState {
            case didStart
            case didUpdate
            case didEnd
        }

        internal var searchHandler: SearchHandler? = nil

        /// The action handler getting called when the search string value changes.
        @discardableResult
        public func onSearch(_ action: @escaping ((_ searchfield: NSSearchField, _ stringValue: String, _ state: SearchState) -> Void)) -> Self {
            searchHandler = action
            return self
        }

        /// The search field of the toolbar item.
        public var searchField: NSSearchField {
            get { searchItem.searchField }
            set { 
                guard newValue != searchField else { return }
                searchItem.searchField = newValue
                self.setupSearchField()
            }
        }

        /// The string value of the search field.
        public var stringValue: String {
            get { searchField.stringValue }
            set { searchField.stringValue = newValue }
        }

        /// The placeholder string of the search field.
        public var placeholderString: String? {
            get { searchField.placeholderString }
            set { searchField.placeholderString = newValue }
        }
        
        /// The placeholder attributed string of the search field.
        public var placeholderAttributedString: NSAttributedString? {
            get { searchField.placeholderAttributedString }
            set { searchField.placeholderAttributedString = newValue }
        }

        /// /// The placeholder string of the search field.
        @discardableResult
        public func placeholderString(_ placeholder: String?) -> Self {
            self.placeholderString = placeholder
            return self
        }

        ///  /// The placeholder attributed string of the search field.
        @discardableResult
        public func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
            self.placeholderAttributedString = placeholder
            return self
        }
        
        /// The action to perform when the user pressed the enter key.
        @discardableResult
        public func actionOnEnterKeyDown(_ enterAction: NSTextField.EnterKeyAction) -> Self {
            searchItem.searchField.actionOnEnterKeyDown = enterAction
            return self
        }
        
        /// /// The action to perform when the user pressed the escape key.
        @discardableResult
        public func actionOnEscapeKeyDown(_ escapeAction: NSTextField.EscapeKeyAction) -> Self {
            searchItem.searchField.actionOnEscapeKeyDown = escapeAction
            return self
        }
        
        public init(_ identifier: NSToolbarItem.Identifier? = nil, maxWidth: CGFloat) {
            super.init(identifier)
            self.searchField.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.item.actionBlock?(self.item)
            }
            self.searchField.delegate = self
            self.searchField.translatesAutoresizingMaskIntoConstraints = false
            self.searchField.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
        }
        
        internal func setupSearchField() {
            self.searchField.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.item.actionBlock?(self.item)
            }
            self.searchField.delegate = self
        }

        public init(_ identifier: NSToolbarItem.Identifier? = nil, searchField: NSSearchField) {
            super.init(identifier)
            searchField.translatesAutoresizingMaskIntoConstraints = false
            self.searchField = searchField
            self.setupSearchField()
        }

        override public init(_ identifier: NSToolbarItem.Identifier? = nil) {
            super.init(identifier)
            self.setupSearchField()
        }

        public func searchFieldDidStartSearching(_: NSSearchField) {
            //    searchState = .isStarted
            searchHandler?(searchField, stringValue, .didStart)
        }

        public func searchFieldDidEndSearching(_: NSSearchField) {
            searchHandler?(searchField, stringValue, .didEnd)
        }

        public func controlTextDidChange(_: Notification) {
            searchHandler?(searchField, stringValue, .didUpdate)
        }
    }
}

#endif
