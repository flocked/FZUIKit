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
                placeholderString = placeholder
                return self
            }

            ///  /// The placeholder attributed string of the search field.
            @discardableResult
            public func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
                placeholderAttributedString = placeholder
                return self
            }

            
            /// Sets the action to perform when the user pressed the enter key.
            @discardableResult
            public func editingActionOnEnterKeyDown(_ enterAction: NSTextField.EnterKeyAction) -> Self {
                editingActionOnEnterKeyDown = enterAction
                return self
            }

            /// Sets the action to perform when the user pressed the escape key.
            @discardableResult
            public func editingActionOnEscapeKeyDown(_ escapeAction: NSTextField.EscapeKeyAction) -> Self {
                editingActionOnEscapeKeyDown = escapeAction
                return self
            }
            
            /// The action to perform when the user presses the enter key while editing.
            var editingActionOnEnterKeyDown: NSTextField.EnterKeyAction = .endEditing

            /// The action to perform when the user presses the escape key while editing.
            var editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction = .endEditingAndReset

            public init(_ identifier: NSToolbarItem.Identifier? = nil, maxWidth: CGFloat) {
                super.init(identifier)
                /*
                searchField.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
                 */
                searchField.delegate = self
                searchField.translatesAutoresizingMaskIntoConstraints = false
                searchField.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
            }

            func setupSearchField() {
                /*
                searchField.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
                 */
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
            
            var startingStringValue: String?
            public func controlTextDidBeginEditing(_ obj: Notification) {
                startingStringValue = searchField.stringValue
            }

            public func controlTextDidChange(_: Notification) {
                searchHandler?(stringValue, .didUpdate)
            }
            
            public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector
            ) -> Bool {
                switch commandSelector {
                case #selector(NSControl.cancelOperation(_:)):
                    if editingActionOnEscapeKeyDown == .endEditingAndReset {
                        searchField.stringValue = startingStringValue ?? searchField.stringValue
                        startingStringValue = nil
                        searchField.resignFirstResponding()
                        return true
                    } else if editingActionOnEscapeKeyDown == .endEditingAndReset {
                        searchField.resignFirstResponding()
                        startingStringValue = nil
                        return true
                    }
                case #selector(NSResponder.insertNewline(_:)):
                    if editingActionOnEnterKeyDown == .endEditing {
                        searchField.resignFirstResponding()
                        startingStringValue = nil
                        return true
                    }
                default: break
                }

                return false
            }
        }
    }

#endif
