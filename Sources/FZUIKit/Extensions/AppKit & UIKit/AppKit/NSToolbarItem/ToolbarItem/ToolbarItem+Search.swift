//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import Cocoa

@available(macOS 11.0, *)
public extension ToolbarItem {
    class Search: ToolbarItem, NSSearchFieldDelegate, NSTextFieldDelegate {
        internal typealias SearchHandler = (NSSearchField, String, SearchState) -> Void

        internal lazy var searchItem = NSSearchToolbarItem(identifier)
        override public var item: NSToolbarItem {
            return searchItem
        }

        public enum SearchState {
            case didStart
            case didUpdate
            case didEnd
        }

        internal var searchHandler: SearchHandler? = nil

        @discardableResult
        public func onSearch(_ action: @escaping ((_ searchfield: NSSearchField, _ stringValue: String, _ state: SearchState) -> Void)) -> Self {
            searchHandler = action
            return self
        }

        public var searchField: NSSearchField {
            get { searchItem.searchField }
            set { searchItem.searchField = newValue }
        }

        public var stringValue: String {
            get { searchField.stringValue }
            set { searchField.stringValue = newValue }
        }

        public var placeholderString: String? {
            get { searchField.placeholderString }
            set { searchField.placeholderString = newValue }
        }

        @discardableResult
        public func placeholderString(_ placeholder: String?) -> Self {
            searchField.placeholderString = placeholder
            return self
        }

        @discardableResult
        public func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
            searchField.placeholderAttributedString = placeholder
            return self
        }
        
        public init(_ identifier: NSToolbarItem.Identifier, maxWidth: CGFloat) {
            super.init(identifier)
            self.searchField.translatesAutoresizingMaskIntoConstraints = false
            self.searchField.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
        }

        public init(_ identifier: NSToolbarItem.Identifier, searchField: NSSearchField) {
            super.init(identifier)
            searchField.translatesAutoresizingMaskIntoConstraints = false
            self.searchField = searchField
            self.searchField.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.item.actionBlock?(self.item)
            }
            self.searchField.delegate = self
        }

        override public init(_ identifier: NSToolbarItem.Identifier) {
            super.init(identifier)
            searchField.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.item.actionBlock?(self.item)
            }
            searchField.delegate = self
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
