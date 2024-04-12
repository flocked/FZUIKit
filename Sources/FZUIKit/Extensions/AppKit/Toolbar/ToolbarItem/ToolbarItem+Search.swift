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

         The item can be used with ``Toolbar``.
         */
        class Search: ToolbarItem, NSSearchFieldDelegate, NSTextFieldDelegate {
            typealias SearchHandler = (String, SearchState) -> Void

            lazy var searchItem = NSSearchToolbarItem(identifier)
            override var item: NSToolbarItem {
                searchItem
            }

            /// State of the searching.
            public enum SearchState {
                /// Searching did start.
                case didStart
                /// Searching did update.
                case didUpdate
                /// Searching did emd.
                case didEnd
            }

            var searchHandler: SearchHandler?

            /// The action handler getting called when the search string value changes.
            @discardableResult
            public func onSearch(_ action: @escaping ((_ stringValue: String, _ state: SearchState) -> Void)) -> Self {
                searchHandler = action
                return self
            }

            /// The search field of the toolbar item.
            public var searchField: NSSearchField {
                get { searchItem.searchField }
                set {
                    guard newValue != searchField else { return }
                    searchItem.searchField = newValue
                    newValue.translatesAutoresizingMaskIntoConstraints = false
                    setupSearchField()
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
                set(\.searchField.placeholderString, to: placeholder)
            }

            ///  /// The placeholder attributed string of the search field.
            @discardableResult
            public func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
                set(\.searchField.placeholderAttributedString, to: placeholder)
            }

            /// The action to perform when the user pressed the enter key.
            @discardableResult
            public func actionOnEnterKeyDown(_ action: NSTextField.EnterKeyAction) -> Self {
                set(\.searchField.actionOnEnterKeyDown, to: action)
            }

            /// /// The action to perform when the user pressed the escape key.
            @discardableResult
            public func actionOnEscapeKeyDown(_ action: NSTextField.EscapeKeyAction) -> Self {
                set(\.searchField.actionOnEscapeKeyDown, to: action)
            }
            
            public func allowedCharacters(_ allowedCharacters: NSTextField.AllowedCharacters) -> Self {
                set(\.searchField.allowedCharacters, to: allowedCharacters)
            }
            
            public init(_ identifier: NSToolbarItem.Identifier? = nil, maxWidth: CGFloat) {
                super.init(identifier)
                searchField.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
                searchField.delegate = self
                searchField.translatesAutoresizingMaskIntoConstraints = false
                searchField.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
            }

            func setupSearchField() {
                searchField.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
                searchField.delegate = self
            }

            /**
             Creates a search toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - searchField: The search field of the item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, searchField: NSSearchField) {
                super.init(identifier)
                searchField.translatesAutoresizingMaskIntoConstraints = false
                self.searchField = searchField
                setupSearchField()
            }

            /**
             Creates a search toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
             */
            override public init(_ identifier: NSToolbarItem.Identifier? = nil) {
                super.init(identifier)
                setupSearchField()
            }

            public func searchFieldDidStartSearching(_: NSSearchField) {
                searchHandler?(stringValue, .didStart)
            }

            public func searchFieldDidEndSearching(_: NSSearchField) {
                searchHandler?(stringValue, .didEnd)
            }

            public func controlTextDidChange(_: Notification) {
                searchHandler?(stringValue, .didUpdate)
            }
        }
    }

#endif
