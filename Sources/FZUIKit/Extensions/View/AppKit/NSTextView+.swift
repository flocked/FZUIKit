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
    }

#endif
