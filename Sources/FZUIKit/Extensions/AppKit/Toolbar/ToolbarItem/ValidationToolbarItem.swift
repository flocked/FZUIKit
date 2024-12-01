//
//  ValidationToolbarItem.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

#if os(macOS)
import AppKit

class ValidationToolbarItem: NSToolbarItem {
    var validationHandler: ((ValidationToolbarItem)->())?
    override func validate() {
        validationHandler?(self)
    }
    
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        autovalidates = false
    }
}

#endif
