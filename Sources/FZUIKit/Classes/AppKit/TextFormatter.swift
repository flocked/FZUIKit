//
//  TextFormatter.swift
//
//
//  Created by Florian Zand on 13.08.24.
//

#if os(macOS)
import AppKit

/// A formatter that formats text based on various properties like minimum & maximum number of characters.
open class TextFormatter: Formatter {
    
    /// The minimum numbers of characters required when the user edits the string value.
    public var minimumNumberOfCharacters: Int? = nil {
        didSet { cachedValidation = oldValue != minimumNumberOfCharacters ? nil : cachedValidation  }
    }
    
    /// Sets the minimum numbers of characters required when the user edits the string value.
    @discardableResult
    public func minimumNumberOfCharacters(_ minimum: Int?) -> Self {
        self.minimumNumberOfCharacters = minimum
        return self
    }
    
    /// The maximum numbers of characters allowed when the user edits the string value.
    open var maximumNumberOfCharacters: Int? = nil {
        didSet { cachedValidation = oldValue != maximumNumberOfCharacters ? nil : cachedValidation  }
    }
    
    /// Sets the maximum numbers of characters allowed when the user edits the string value.
    @discardableResult
    open func maximumNumberOfCharacters(_ maximum: Int?) -> Self {
        self.maximumNumberOfCharacters = maximum
        return self
    }
    
    /// The allowed characters the user can enter when editing.
    open var allowedCharacters: NSTextField.AllowedCharacters = .all {
        didSet { cachedValidation = oldValue != allowedCharacters ? nil : cachedValidation  }
    }
    
    /// Sets the allowed characters the user can enter when editing.
    @discardableResult
    open func allowedCharacters(_ allowedCharacters: NSTextField.AllowedCharacters) -> Self {
        self.allowedCharacters = allowedCharacters
        return self
    }
    
    /// The handler to validate a string.
    @objc open var validationHandler: ((String)->(Bool))? = nil {
        didSet { cachedValidation = nil }
    }
    
    /// Sets the handler to validate a string.
    @discardableResult
    @objc open func validationHandler(_ handler: ((String)->(Bool))?) -> Self {
        self.validationHandler = handler
        return self
    }
    
    /// The number formatter.
    @objc open var numberFormatter: NumberFormatter? = nil
    
    /// Sets the number formatter.
    @discardableResult
    @objc open func numberFormatter(_ formatter: NumberFormatter?) -> Self {
        self.numberFormatter = formatter
        return self
    }
    
    /// The additional formatters.
    @objc open var subFormatters: [Formatter] = []
    
    /// Sets the additional formatters.
    @discardableResult
    @objc open func subFormatters(_ subFormatters: [Formatter]) -> Self {
        self.subFormatters = subFormatters
        return self
    }
    
    open override func string(for obj: Any?) -> String? {
        return obj as? String
    }
    
    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        return obj as? NSAttributedString
    }
    
    open override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }
    
    var cachedValidation: (string: String, isValid: Bool)? = nil
    
    open override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let string = partialStringPtr.pointee as String
        if let cachedValidation = cachedValidation, cachedValidation.string == string {
            return cachedValidation.isValid
        }
        cachedValidation = (string, false)
        var subFormatters = subFormatters
        if let numberFormatter = numberFormatter {
            subFormatters.append(numberFormatter)
        }
        if subFormatters.contains(where: { !$0.isPartialStringValid(partialStringPtr, proposedSelectedRange: proposedSelRangePtr, originalString: origString, originalSelectedRange: origSelRange, errorDescription: error) }) {
            return false
        }
        
        if validationHandler?(string) == false {
            return false
        }
        if let minimumCharacters = minimumNumberOfCharacters, string.length < minimumCharacters {
            return false
        }
        if let maximumCharacters = maximumNumberOfCharacters, string.length > maximumCharacters {
            return false
        }
        if allowedCharacters != .all, !allowedCharacters.isValid(string) {
            return false
        }
        cachedValidation = (string, true)
        return true
    }
}

#endif
