//
//  NSSearchField+.swift
//
//
//  Created by Florian Zand on 19.03.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSSearchField {
    /**
     Ensures the search field has a search menu that shows the recent seaches.
     
     If a menu already exists and none of the recent-search items are present, this appends a separator and the recent-search section.
          
     - Parameters:
        - title: The title displayed above the list of recent searches.
        - noResultsTitle: The title displayed when there are no recent searches.
        - clearTitle: The title of the item that clears all recent searches.
        - autosaves: A Boolean value indicating whether the search field autosaves the recent searches.
        - maximumRecents: The maximum number of search strings that can appear in the search menu.
     */
    @discardableResult
    func setupRecentSearchesMenu(title: String = "Recent Searches", noResultsTitle: String = "No Recent Searches", clearTitle: String = "Clear Recent Searches", autosaves: Bool = true, maximumRecents: Int = 10) -> Self {
        self.maximumRecents = maximumRecents
        recentsAutosaveName = autosaves ? "Recent Searches" : nil
        guard searchMenuTemplate?.item(withTag: NSSearchField.recentsTitleMenuItemTag) == nil else { return self }
        let menu = searchMenuTemplate ?? NSMenu(title: "Recent Searches")
        if menu.items.isEmpty || menu.items.last?.isSeparatorItem == false {
            menu.addItem(.separator())
        }
        menu.items += Self.recentSearchesMenuItems(title: title, noResultsTitle: noResultsTitle, clearTitle: clearTitle)
        searchMenuTemplate = menu
        return self
    }
    
    /**
     Returns menu items for displaying recent searches in a search field menu.

     - Parameters:
       - title: The title displayed above the list of recent searches.
       - noResultsTitle: The title displayed when there are no recent searches.
       - clearTitle: The title of the item that clears all recent searches.

     - Returns: An array of menu items representing the recent searches section.
     */
    static func recentSearchesMenuItems(title: String = "Recent Searches", noResultsTitle: String = "No Recent Searches", clearTitle: String = "Clear Recent Searches") -> [NSMenuItem] {
        var items: [NSMenuItem] = []
        items += NSMenuItem(title).tag(NSSearchField.recentsTitleMenuItemTag)
        items += NSMenuItem("").tag(NSSearchField.recentsMenuItemTag)
        items += .separator()
        items += NSMenuItem(noResultsTitle).tag(NSSearchField.noRecentsMenuItemTag)
        items += NSMenuItem(clearTitle).tag(NSSearchField.clearRecentsMenuItemTag)
        return items
    }
    
    /**
     Sets the Boolean value indicating whether the sarch field sends its action immediately as the user types.

     When enabled, the search field invokes its action for each relevant text change.
     When disabled, the search field waits briefly after typing stops before sending its action.

     Delaying the action allows the user to finish typing and can reduce the number of performed searches.
     */
    @discardableResult
    func sendsSearchImmediately(_ sendsImmediately: Bool) -> Self {
        sendsSearchStringImmediately = sendsImmediately
        return self
    }
    
    /// Sets the Boolean value indicating whether the search field calls its search action when the user clicks the search button or presses `Return`, or after each keystroke.
    @discardableResult
    func sendsSearchOnCompletion(_ sendsWholeSearchString: Bool) -> Self {
        self.sendsWholeSearchString = sendsWholeSearchString
        return self
    }
    
    /// Sets the delegate for the search field.
    @discardableResult
    func delegate(_ delegate: (any NSSearchFieldDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }
}
#endif
