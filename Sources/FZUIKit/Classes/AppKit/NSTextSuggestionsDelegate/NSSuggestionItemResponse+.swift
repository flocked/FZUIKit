//
//  NSSuggestionItemResponse+.swift
//  
//
//  Created by Florian Zand on 25.10.25.
//

/*
#if os(macOS)
import AppKit

@available(macOS 15.0, *)
 extension NSSuggestionItemResponse {
     /// Creates a response with a single section with the specified title and items.
     public init(title: String, items: [Item]) {
         self = .init(itemSections: [ItemSection(title: title, items: items)])
     }
     
     /// Sets the phase of results which specifies whether this batch of items represents an intermediate set of results–and more are coming, or whether these results are complete/final. Defaults to .final.
     public func phase(_ phase: Phase) -> Self {
         .init(itemSections: itemSections, phase: phase, preferredHighlight: preferredHighlight)
     }
     
     /// Sets the preferred response that the control should take when this batch of results comes in (like whether or not to highlight the first selectable item).
     public func preferredHighlight(_ highlight: Highlight) -> Self {
         .init(itemSections: itemSections, phase: phase, preferredHighlight: highlight)
     }
     
     private init(itemSections: [ItemSection], phase: Phase, preferredHighlight: Highlight) {
         self = .init(itemSections: itemSections)
         self.phase = phase
         self.preferredHighlight = preferredHighlight
     }
 }
#endif
*/
