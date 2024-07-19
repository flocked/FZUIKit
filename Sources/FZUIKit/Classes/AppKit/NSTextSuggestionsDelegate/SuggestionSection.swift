//
//  SuggestionSection.swift
//  
//
//  Created by Florian Zand on 19.07.24.
//

/*
#if os(macOS)
import Foundation
import SwiftUI

public struct NSSuggestionItemSection<SuggestionItemType>: Hashable {
    
    /// The item of the suggestion.
    public typealias Item = NSSuggestionItem<SuggestionItemType>
    
    /// Creates a section with the specified items.
    public init(items: [Item]) {
        self.title = nil
        self.items = items
    }
    
    /// Creates a section with the specified title and items.
    public init(title: String?, items: [Item]) {
        self.title = title
        self.items = items
    }

    /// The title of the section.
    public var title: String?
    /// The items of the section.
    public var items: [Item] = []
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(items)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct SuggestionSectionView: View {
    var title: String?
    
    init(title: String?) {
        self.title = title
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

class SuggestionSectionCellView: NSTableCellView {
    let hostingView: NSHostingView<SuggestionSectionView>
    var title: String? {
        get { hostingView.rootView.title }
        set {
            guard newValue != title else { return }
            hostingView.rootView = SuggestionSectionView(title: newValue)
        }
    }
    
    
    init(title: String?) {
        self.hostingView = NSHostingView(rootView: SuggestionSectionView(title: title))
        self.hostingView.sizeToFit()
        super.init(frame: .zero)
        addSubview(withConstraint: hostingView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
*/
