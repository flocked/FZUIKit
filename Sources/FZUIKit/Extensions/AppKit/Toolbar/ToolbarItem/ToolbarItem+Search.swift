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
     
     The item automatically resizes to accommodate typing when the focus switches to the toolbar item. When the toolbar is low on space, the system may collapse the search item into a button representation, which then expands to a full search field when the user clicks on it.
     */
    open class Search: ToolbarItem {
        
        private var widthConstraints: [NSLayoutConstraint] = []
        fileprivate lazy var searchItem = ValidateSearchToolbarItem(for: self)
        override var item: NSToolbarItem {
            searchItem
        }
        
        /// The state of the searching.
        public enum SearchState: String {
            /// Searching did start.
            case didStart
            /// Searching did update.
            case didUpdate
            /// Searching did end.
            case didEnd
        }
        
        /// The handler that gets called when the user changes the text of the search field.
        open var handler: ((_ stringValue: String, _ state: SearchState) -> Void)?
        
        /// Sets the handler that gets called when the user changes the text of the search field.
        @discardableResult
        open func onSearch(_ action: ((_ stringValue: String, _ state: SearchState) -> Void)?) -> Self {
            handler = action
            return self
        }
        
        /// The search field of the toolbar item.
        open internal(set) var searchField: NSSearchField {
            get { searchItem.searchField }
            set { searchItem.searchField = newValue  }
        }
        
        /// The string value of the search field.
        open var stringValue: String {
            get { searchField.stringValue }
            set { searchField.stringValue = newValue }
        }
        
        /// Sets the string value of the search field.
        @discardableResult
        open func stringValue(_ stringValue: String) -> Self {
            self.stringValue = stringValue
            return self
        }
        
        /// The placeholder string of the search field.
        open var placeholderString: String? {
            get { searchField.placeholderString }
            set { searchField.placeholderString = newValue }
        }
        
        /// Sets the placeholder string of the search field.
        @discardableResult
        open func placeholderString(_ placeholder: String?) -> Self {
            placeholderString = placeholder
            return self
        }
        
        /// The preferred width for the toolbar item when it has keyboard focus.
        open var preferredWidthWhenFocused: CGFloat {
            get { searchItem.preferredWidthForSearchField }
            set { searchItem.preferredWidthForSearchField = newValue }
        }
        
        /// Sets the preferred width for the toolbar item when it has keyboard focus.
        @discardableResult
        open func preferredWidthWhenFocused(_ preferredWidth: CGFloat) -> Self {
            self.preferredWidthWhenFocused = preferredWidth
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
        
        /// The action to perform when the user pressed the enter key while searching.
        open var editingActionOnEnterKeyDown: NSTextField.EnterKeyAction {
            get { searchItem.searchField.editingActionOnEnterKeyDown }
            set { searchItem.searchField.editingActionOnEnterKeyDown = newValue }
        }
        
        /// Sets the action to perform when the user pressed the enter key while searching.
        @discardableResult
        open func editingActionOnEnterKeyDown(_ enterAction: NSTextField.EnterKeyAction) -> Self {
            editingActionOnEnterKeyDown = enterAction
            return self
        }
        
        /// The action to perform when the user pressed the escape key while searching.
        open var editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction {
            get { searchItem.searchField.editingActionOnEscapeKeyDown }
            set { searchItem.searchField.editingActionOnEscapeKeyDown = newValue }
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
        
        /**
         Starts a search interaction and moves the keyboard focus to the search field.
         
         If the system displays a compressed search field, starting the search interaction expands the field to the width stored in the ``preferredWidthWhenFocused`` property and moves the keyboard focus into the search field.
         
         Use ``beginSearchInteraction()`` and ``endSearchInteraction()`` to programmatically control a search.
         */
        open func beginSearchInteraction() {
            searchItem.beginSearchInteraction()
        }
        
        /**
         Ends a search interaction by giving up the first responder and adjusting the size of the search field to either ``preferredWidth`` or the available width for the toolbar item if necessary.
         
         Use ``beginSearchInteraction()`` and ``endSearchInteraction()`` to programmatically control a search.
         */
        open func endSearchInteraction() {
            searchItem.endSearchInteraction()
        }
        
        /// The method that is called when the user begins searching.
        open func textDidBeginEditing() {
            handler?(stringValue, .didStart)
        }
        
        /// The method that is called when the user has ended searching.
        open func textDidEndEditing() {
            handler?(stringValue, .didEnd)
        }
        
        /// The method that is called when the search field has changed it's text.
        open func textDidChange() {
            handler?(stringValue, .didUpdate)
        }
        
        /**
         Creates a search toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Search` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - preferredWidth: The preferred width of the search field item.
            - handler: The handler that gets called when the user changes the text of the search field.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, preferredWidth: CGFloat? = nil, handler: ((_ stringValue: String, _ state: SearchState) -> Void)? = nil) {
            super.init(identifier)
            searchField.translatesAutoresizingMaskIntoConstraints = false
            self.preferredWidth = preferredWidth
            self.handler = handler
        }
        
        /**
         Creates a search toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Search` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - searchField: The search field of the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, searchField: NSSearchField) {
            super.init(identifier)
            searchField.translatesAutoresizingMaskIntoConstraints = false
            searchItem.searchField = searchField
        }
    }
}

@available(macOS 11.0, *)
fileprivate class ValidateSearchToolbarItem: NSSearchToolbarItem, NSSearchFieldDelegate{
    weak var item: ToolbarItem.Search?
    var startingString: String?
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        startingString = searchField.stringValue
        item?.textDidBeginEditing()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        item?.textDidChange()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        item?.textDidEndEditing()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSControl.cancelOperation(_:)) {
            if searchField.editingActionOnEscapeKeyDown == .endEditingAndReset {
                searchField.stringValue = startingString ?? searchField.stringValue
                startingString = nil
                searchField.resignFirstResponding()
                return true
            } else if searchField.editingActionOnEscapeKeyDown == .endEditing {
                startingString = nil
                searchField.resignFirstResponding()
                return true
            }
        } else if commandSelector == #selector(NSControl.insertNewline(_:)) {
            if searchField.editingActionOnEnterKeyDown == .endEditing {
                startingString = nil
                searchField.resignFirstResponding()
                return true
            }
        }
        return false
    }
    
    override var searchField: NSSearchField {
        didSet { searchField.delegate = self }
    }
    
    init(for item: ToolbarItem.Search) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
        searchField.delegate = self
    }
    
    override func validate() {
        super.validate()
        item?.validate()
    }
}

#endif
