//
//  SuggestionResponse.swift
//  
//
//  Created by Florian Zand on 19.07.24.
//

/*
#if os(macOS)
import Foundation
import FZSwiftUtils


public struct NSSuggestionItemResponse<SuggestionItemType>: Hashable {
    
    /// The item of the response.
    public typealias Item = NSSuggestionItem<SuggestionItemType>
    /// The section of the response.
    public typealias Section = NSSuggestionItemSection<SuggestionItemType>
    
    /// The sections of the response.
    public var itemSections: [Section] = []
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
    
    /// Creates a response with the specified item sectons.
    public init(itemSections: [Section]) {
        self.itemSections = itemSections
    }
    
    /// Creates a response with the specified items.
    public init(items: [Item]) {
        self.itemSections = [Section(items: items)]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(itemSections)
        hasher.combine(preferredHighlight)
    }
    
    var rowsCount: Int {
        if itemSections.count == 1, let section = itemSections.first {
            return section.title != nil ? section.items.count + 1 : section.items.count
        }
        return itemSections.count + itemSections.flatMap({$0.items}).count
    }
    
    func item(at index: Int) -> Item? {
        if itemSections.count == 1, let section = itemSections.first {
            return section.items[safe: section.title != nil ? index + 1 : index]
        }
        var count = -1
        for section in itemSections {
            count += 1
            for item in section.items {
                count += 1
                if index == count {
                    return item
                }
            }
        }
        return nil
    }
    
    func section(at index: Int) -> Section? {
        var count = -1
        for section in itemSections {
            count += 1
            if index == count {
                return section
            }
            count += section.items.count
        }
        return nil
    }
    
    func isGroupRow(_ index: Int) -> Bool {
        if itemSections.count == 1 {
            return itemSections.first?.title != nil
        } else if itemSections.count > 1 {
            var count = -1
            for section in itemSections {
                count += 1
                if count == index {
                    return true
                }
                count += section.items.count
            }
        }
        return false
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
 

#endif
*/
