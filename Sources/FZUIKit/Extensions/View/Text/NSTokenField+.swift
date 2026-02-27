//
//  NSTokenField+.swift
//
//
//  Created by Florian Zand on 26.02.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTokenField {
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
        }
    }
    
    private var tokenFieldDeleaate: TokenFieldDelegate? {
        get { getAssociatedValue("tokenFieldDeleaate") }
        set {  setAssociatedValue(newValue, key: "tokenFieldDeleaate") }
    }
    
    private class TokenFieldDelegate: NSObject, NSTokenFieldDelegate {
        var delegate: (any NSTokenFieldDelegate)?
        var observation: KeyValueObservation?
        weak var tokenField: NSTokenField?
        
        func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
            tokenField.handlers.hasMenu?(representedObject) ?? delegate?.tokenField?(tokenField, hasMenuForRepresentedObject: representedObject) ?? false
        }
        
        func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
            tokenField.handlers.menu?(representedObject) ?? delegate?.tokenField?(tokenField, menuForRepresentedObject: representedObject) ?? nil
        }
        
        func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
            tokenField.handlers.style?(representedObject) ?? delegate?.tokenField?(tokenField, styleForRepresentedObject: representedObject) ?? tokenField.tokenStyle
        }
        
        
        
        init(for tokenField: NSTokenField) {
            super.init()
            self.tokenField = tokenField
            delegate = tokenField.delegate
            tokenField.delegate = self
            
            observation = tokenField.observeChanges(for: \.delegate) { [weak self] _, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.tokenField?.delegate = self
            }
        }
    }
    
    public struct Handlers {
        /// The handler that provides the represented object for a given editing string.
        public var representedObject: ((_ editingString: String)->(Any?))?
        /// The handler that provides a string to be edited as proxy for a given represented object.
        public var editingString: ((_ representedObject: Any)->(String?))?
        /// The handler that provides a string to be displayed as a proxy for the given represented object.
        public var displayString: ((_ representedObject: Any)->(String?))?
        /// The handlers that provides the token style for a represented object.
        public var style: ((_ representedObject: Any)->(TokenStyle))?
        /// The handlers that determinates whether the represented object provides a menu.
        public var hasMenu: ((_ representedObject: Any)->(Bool))?
        /// The handlers that provides the menu for a represented object.
        public var menu: ((_ representedObject: Any)->(NSMenu?))?
        /// The handlers that determinates whether tokens should be added at a particular location.
        public var shouldAdd: ((_ tokens: [Any], _ index: Int)->([Any]))?
        /// The handler that provides the objects representing the data read from the specified pasteboard.
        public var readFromPasteboard: ((_ pasteboard: NSPasteboard)->([Any]?))?
        /// The handlers that determinates whether the handler can write represented objects to the pasteboard corresponding to a given array of display strings.
        public var writePasteboard: ((_ representedObjects: [Any], _ pasteboard: NSPasteboard)->(Bool))?
        
        var needsDelegate: Bool {
            representedObject != nil || editingString != nil || displayString != nil || style != nil || hasMenu != nil || menu != nil || shouldAdd != nil || readFromPasteboard != nil || writePasteboard != nil
        }
    }
}

#endif
