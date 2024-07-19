//
//  Suggestion+Response.swift
//
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import Foundation

public struct SuggestionItemResponse: Hashable {
    var rows: [(item: SuggestionItem?, section: SuggestionItemSection?)] = []

    /// The sections of the response.
    public var itemSections: [SuggestionItemSection] = [] {
        didSet { updateRows() }
    }
    /// The preferred highlight of the response.
    public var preferredHighlight: Highlight = .firstSelectableItem
    
    /// Highlight of a item response.
    public enum Highlight: Int, Hashable {
        /// Highlights automatically.
        case automatic
        /// Highlights the first selectable item.
        case firstSelectableItem
    }
    
    /// Creates a response.
    public init() {
        
    }
    
    /// Creates a response with the specified item sections.
    public init(itemSections: [SuggestionItemSection]) {
        self.itemSections = itemSections
        updateRows()
    }
    
    /// Creates a response with the specified items.
    public init(items: [SuggestionItem]) {
        self.itemSections = [SuggestionItemSection(items: items)]
        updateRows()
    }
    
    mutating func updateRows() {
        rows = []
        for section in itemSections {
            if section.title != nil {
                rows.append((nil, section))
            }
            section.items.forEach({ rows.append(($0, nil)) })
        }
    }
        
    func highlightedItem(for string: String) -> SuggestionItem? {
        if preferredHighlight == .firstSelectableItem {
            return rows.first(where: {$0.item != nil })?.item
        } else {
            return rows.first(where: { $0.item?.title.localizedLowercase.hasPrefix(string.localizedLowercase) == true })?.item
        }
    }
    
    func item(at index: Int) -> SuggestionItem? {
        rows[safe: index]?.item
    }
    
    func section(at index: Int) -> SuggestionItemSection? {
        rows[safe: index]?.section

    }
    
    func isGroupRow(_ index: Int) -> Bool {
        rows[safe: index]?.section != nil
    }
    
    public static func == (lhs: SuggestionItemResponse, rhs: SuggestionItemResponse) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(itemSections)
        hasher.combine(preferredHighlight)
    }
}

#endif
