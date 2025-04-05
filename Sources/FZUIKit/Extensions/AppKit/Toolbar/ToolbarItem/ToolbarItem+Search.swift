//
//  ToolbarItem+Search.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    @available(macOS 11.0, *)
    extension ToolbarItem {
        /**
         A toolbar item that contains a search field optimized for performing text-based searches.

         The item can be used with ``Toolbar``.
         */
        open class Search: ToolbarItem {

            var delegate: Delegate!
            fileprivate lazy var searchItem = ValidateSearchToolbarItem(for: self)
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

            /// The handler that gets called when the user changes the string of the search field.
            open var handler: ((_ stringValue: String, _ state: SearchState) -> Void)?

            /// Sets the handler that gets called when the user changes the string of the search field.
            @discardableResult
            open func onSearch(_ action: ((_ stringValue: String, _ state: SearchState) -> Void)?) -> Self {
                handler = action
                return self
            }

            /// The search field of the toolbar item.
            open internal(set) var searchField: NSSearchField {
                get { searchItem.searchField }
                set {
                    guard newValue != searchField else { return }
                    searchField.delegate = nil
                    searchItem.searchField = newValue
                    searchField.delegate = delegate
                }
            }

            /// The string value of the search field.
            open var stringValue: String {
                get { searchField.stringValue }
                set { searchField.stringValue = newValue }
            }

            /// The placeholder string of the search field.
            open var placeholderString: String? {
                get { searchField.placeholderString }
                set { searchField.placeholderString = newValue }
            }

            /// The placeholder attributed string of the search field.
            open var placeholderAttributedString: NSAttributedString? {
                get { searchField.placeholderAttributedString }
                set { searchField.placeholderAttributedString = newValue }
            }

            /// /// The placeholder string of the search field.
            @discardableResult
            open func placeholderString(_ placeholder: String?) -> Self {
                placeholderString = placeholder
                return self
            }

            ///  /// The placeholder attributed string of the search field.
            @discardableResult
            open func placeholderAttributedString(_ placeholder: NSAttributedString?) -> Self {
                placeholderAttributedString = placeholder
                return self
            }
            
            /// Sets the preferred width for the toolbar item when it has keyboard focus.
            @discardableResult
            open func preferredWidthForSearchField(_ preferredWidth: CGFloat) -> Self {
                searchItem.preferredWidthForSearchField = preferredWidth
                return self
            }
            
            /**
             A Boolean value that enables the cancel button in the search field to resign the first responder in addition to clearing the contents.
             
             The default value is `true`. If set to `false`, the cancel button only clears the contents of the search field.
             */
            open var resignsFirstResponderWithCancel: Bool {
                get { searchItem.resignsFirstResponderWithCancel }
                set { searchItem.resignsFirstResponderWithCancel = newValue }
            }
            
            /// Sets the Boolean value that enables the cancel button in the search field to resign the first responder in addition to clearing the contents.
            @discardableResult
            open func resignsFirstResponderWithCancel(_ resigns: Bool) -> Self {
                resignsFirstResponderWithCancel = resigns
                return self
            }
            
            fileprivate var editingActionSearhField: EditingActionSearchField? {
                searchItem.searchField as? EditingActionSearchField
            }
            
            /// The action to perform when the user pressed the enter key while searching.
            open var editingActionOnEnterKeyDown: NSTextField.EnterKeyAction {
                get { editingActionSearhField?._editingActionOnEnterKeyDown ?? .none }
                set { editingActionSearhField?._editingActionOnEnterKeyDown = newValue }
            }
            
            /// Sets the action to perform when the user pressed the enter key while searching.
            @discardableResult
            open func editingActionOnEnterKeyDown(_ enterAction: NSTextField.EnterKeyAction) -> Self {
                editingActionOnEnterKeyDown = enterAction
                return self
            }
            
            /// The action to perform when the user pressed the escape key while searching.
            open var editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction {
                get { editingActionSearhField?._editingActionOnEscapeKeyDown ?? .none }
                set { editingActionSearhField?._editingActionOnEscapeKeyDown = newValue }
            }
            
            /// Sets the action to perform when the user pressed the escape key while searching.
            @discardableResult
            open func editingActionOnEscapeKeyDown(_ escapeAction: NSTextField.EscapeKeyAction) -> Self {
                editingActionOnEscapeKeyDown = escapeAction
                return self
            }
            
            /// The preferred width of the search field item.
            open var preferredWidth: CGFloat? {
                get { widthConstraints.first?.constant }
                set {
                    widthConstraints.activate(false)
                    widthConstraints = []
                    if let newValue = newValue {
                        widthConstraints = [searchField.widthAnchor.constraint(lessThanOrEqualToConstant: newValue), searchField.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)].activate()
                    }
                }
            }
            
            /// Sets the preferred width of the search field item, or `nil` to automatically adjust the width.
            open func preferredWidth(_ preferredWidth: CGFloat?) -> Self {
                self.preferredWidth = preferredWidth
                return self
            }
            
            private var widthConstraints: [NSLayoutConstraint] = []
            
            /**
             Starts a search interaction and moves the keyboard focus to the search field.
             
             If the system displays a compressed search field, starting the search interaction expands the field to the width stored in the ``preferredWidthForSearchField(_:)`` property and moves the keyboard focus into the search field. Use ``beginSearchInteraction()`` and ``endSearchInteraction()`` to programmatically control a search.
             */
            open func beginSearchInteraction() {
                searchItem.beginSearchInteraction()
            }
            
            /**
             Ends a search interaction by giving up the first responder and adjusting the size of the search field to the available width for the toolbar item if necessary.
             
             Use ``beginSearchInteraction()`` and ``endSearchInteraction()`` to programmatically control a search.
             */
            open func endSearchInteraction() {
                searchItem.endSearchInteraction()
            }
            
            /// The method that is called when the search field begins searching for content.
            open func textDidBeginEditing() {
                handler?(stringValue, .didStart)
            }
            
            /// The method that is called when the search field has ended its search for content.
            open func textDidEndEditing() {
                handler?(stringValue, .didEnd)
            }
            
            /// The method that is called when the search field has changed it's text.
            open func textDidChange() {
                handler?(stringValue, .didUpdate)
            }
            
            class Delegate: NSObject, NSSearchFieldDelegate {
                weak var item: ToolbarItem.Search?
                
                func searchFieldDidStartSearching(_: NSSearchField) {
                    item?.textDidBeginEditing()
                }

                func searchFieldDidEndSearching(_: NSSearchField) {
                    item?.textDidEndEditing()
                }
                
                func controlTextDidBeginEditing(_ obj: Notification) {
                    
                }
                
                func controlTextDidEndEditing(_ obj: Notification) {
                    
                }

                func controlTextDidChange(_: Notification) {
                    item?.textDidChange()
                }
                
                init(for item: ToolbarItem.Search? = nil) {
                    self.item = item
                }
            }
                  
            /**
             Creates a search toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - preferredWidth: The preferred width of the search field item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, preferredWidth: CGFloat? = nil) {
                super.init(identifier)
                delegate = Delegate(for: self)
                searchItem.searchField = EditingActionSearchField()
                searchField.delegate = delegate
                searchField.translatesAutoresizingMaskIntoConstraints = false
                self.preferredWidth = preferredWidth
            }

            /**
             Creates a search toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - searchField: The search field of the item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, searchField: NSSearchField) {
                super.init(identifier)
                delegate = Delegate(for: self)
                searchField.translatesAutoresizingMaskIntoConstraints = false
                searchItem.searchField = searchField
                searchField.delegate = delegate
            }
        }
    }

fileprivate class EditingActionSearchField: NSSearchField, NSTextViewDelegate {
    var _editingActionOnEnterKeyDown: NSTextField.EnterKeyAction = .endEditing
    var _editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction = .endEditing
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var startingString: String?
    override func textDidBeginEditing(_ notification: Notification) {
        startingString = stringValue
    }
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSControl.cancelOperation(_:)):
            if _editingActionOnEscapeKeyDown == .endEditingAndReset {
                stringValue = startingString ?? stringValue
                startingString = nil
                resignFirstResponding()
                return true
            } else if _editingActionOnEscapeKeyDown == .endEditing {
                startingString = nil
                resignFirstResponding()
                return true
            }
        case #selector(NSControl.insertNewline(_:)):
            if _editingActionOnEnterKeyDown == .endEditing {
                startingString = nil
                resignFirstResponding()
                return true
            }
        default: break
        }
        return false
    }
}

@available(macOS 11.0, *)
fileprivate class ValidateSearchToolbarItem: NSSearchToolbarItem {
    weak var item: ToolbarItem?
    
    init(for item: ToolbarItem) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        item?.validate()
    }
}

#endif
