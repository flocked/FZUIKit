//
//  NSTextView+.swift
//
//  Parts taken from:
//  Taken from: https://github.com/boinx/BXUIKit
//  Copyright ©2017-2018 Peter Baumgartner. All rights reserved.
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

    import AppKit

    public extension NSTextView {
        /// The attributed string.
        var attributedString: NSAttributedString! {
            set {
                let len = textStorage?.length ?? 0
                let range = NSRange(location: 0, length: len)
                textStorage?.replaceCharacters(in: range, with: newValue)
            }
            get { textStorage?.copy() as? NSAttributedString }
        }
        
        /// The ranges of characters selected in the text view.
        var selectedStringRanges: [Range<String.Index>] {
            get { selectedRanges.compactMap({$0.rangeValue}).compactMap({ Range($0, in: string) }) }
            set { selectedRanges = newValue.compactMap({NSRange($0, in: string).nsValue}) }
        }
        
        /// Deselects all text.
        func deselectAll() {
            selectedStringRanges = []
        }
        
        /// Selects all text.
        func selectAll() {
            select(string)
        }
        
        /// Selects the specified string.
        func select(_ string: String) {
            guard let range = string.range(of: string), !selectedStringRanges.contains(range) else { return }
            selectedStringRanges.append(range)
        }
        
        /// Selects the specified range.
        func select(_ range: Range<String.Index>) {
            guard !selectedStringRanges.contains(range) else { return }
            selectedStringRanges.append(range)
        }
        
        /// Selects the specified range.
        func select(_ range: ClosedRange<String.Index>) {
            select(range.lowerBound..<range.upperBound)
        }
    }

#endif
