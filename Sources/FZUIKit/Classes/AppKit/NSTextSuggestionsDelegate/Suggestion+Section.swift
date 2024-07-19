//
//  Suggestion+Section.swift
//
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import Foundation
import SwiftUI

public struct SuggestionItemSection: Hashable {
    /// The title of the section.
    public var title: String?
    /// The items of the section.
    public var items: [SuggestionItem] = []
    
    /// Creates a section with the specified items.
    public init(items: [SuggestionItem]) {
        self.title = nil
        self.items = items
    }
    
    /// Creates a section with the specified title and items.
    public init(_ title: String, items: [SuggestionItem]) {
        self.title = title
        self.items = items
    }
}

extension SuggestionItemSectionCellView {
    struct ContentView: View {
        var title: String?
        let section: SuggestionItemSection
        
        init(section: SuggestionItemSection) {
            self.title = section.title
            self.section = section
        }
        
        @ViewBuilder
        var titleItem: some View {
            if let title = title {
                Text(title)
                    .foregroundColor(.primary)
            }
        }
        
        var body: some View {
            titleItem.padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
        }
    }
}

class SuggestionItemSectionCellView: NSTableCellView {
    let hostingView: NSHostingView<ContentView>
    var section: SuggestionItemSection {
        get { hostingView.rootView.section }
        set {
            guard newValue != section else { return }
            hostingView.rootView = ContentView(section: newValue)
        }
    }
    
    init(section: SuggestionItemSection) {
        self.hostingView = NSHostingView(rootView: ContentView(section: section))
        self.hostingView.sizeToFit()
        super.init(frame: .zero)
        addSubview(withConstraint: hostingView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


#endif
