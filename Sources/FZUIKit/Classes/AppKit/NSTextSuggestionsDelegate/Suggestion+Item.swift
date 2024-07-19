//
//  Suggestion+Item.swift
//
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import AppKit
import SwiftUI

public struct SuggestionItem: Hashable {
    /// The title of the item.
    public var title: String
    /// The attributed title of the item.
    public var attributedTitle: NSAttributedString?
    /// The secondary title of the item.
    public var secondaryTitle: String?
    /// The attributed secondary title of the item.
    public var attributedSecondaryTitle: NSAttributedString?
    /// The image of the item.
    public var image: NSImage?
    /// The tool tip of the item.
    public var toolTip: String?
    
    public init(_ title: String) {
        self.title = title
    }
    
    public init(_ attributedTitle: NSAttributedString) {
        self.title = attributedTitle.string
        self.attributedTitle = attributedTitle
    }
}

extension SuggestionItemCellView {
    struct ContentView: View {
        var title: String
        var attributedTitle: NSAttributedString?
        var secondaryTitle: String?
        var attributedSecondaryTitle: NSAttributedString?
        var image: NSImage?
        var toolTip: String?
        let item: SuggestionItem
        
        public init(item: SuggestionItem) {
            self.title = item.title
            self.attributedTitle = item.attributedTitle
            self.attributedSecondaryTitle = item.attributedSecondaryTitle
            self.image = item.image
            self.secondaryTitle = item.secondaryTitle
            self.toolTip = item.toolTip
            self.item = item
        }
        
        @ViewBuilder
        var titleItem: some View {
            if let attributedTitle = attributedTitle, #available(macOS 12, *) {
                Text(AttributedString(attributedTitle))
            } else  {
                Text(title)
                    .foregroundColor(.primary)
            }
        }
        
        @ViewBuilder
        var secondaryTitleItem: some View {
            if let attributedSecondaryTitle = attributedSecondaryTitle, #available(macOS 12, *) {
                Text(AttributedString(attributedSecondaryTitle))
            } else if let secondaryTitle = secondaryTitle {
                Text(secondaryTitle)
                    .foregroundColor(.secondary)
            }
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = image {
                Image(image)
                    .resizable()
                    .scaledToFit()
            }
        }
        
        public var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0.0) {
                    titleItem
                    secondaryTitleItem
                }
                Spacer()
            }
            .frame(width: 300)
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 6))
                .background(RoundedRectangle(cornerRadius: 6.0).foregroundColor(.red))
        }
    }
}

class SuggestionItemCellView: NSTableCellView {
    let stackView = NSStackView()
    
    let hostingView: NSHostingView<ContentView>
    
    var item: SuggestionItem {
        get { hostingView.rootView.item }
        set {
            guard newValue != item else { return }
            hostingView.rootView = ContentView(item: newValue)
        }
    }

    init(item: SuggestionItem) {
        self.hostingView = NSHostingView(rootView: ContentView(item: item))
        super.init(frame: .zero)
        stackView.addArrangedSubview(hostingView)
        addSubview(withConstraint: stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
