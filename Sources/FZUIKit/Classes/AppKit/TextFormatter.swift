//
//  TextFormatter.swift
//
//
//  Created by Florian Zand on 13.08.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A formatter that formats text based on various properties like minimum & maximum number of characters.
open class TextFormatter: Formatter {
    
    private var cachedValidation: (string: String, isValid: Bool)? = nil
    
    /// The minimum numbers of characters required when the user edits the string value.
    open var minimumNumberOfCharacters: Int? = nil {
        didSet { cachedValidation = oldValue != minimumNumberOfCharacters ? nil : cachedValidation  }
    }
    
    /// Sets the minimum numbers of characters required when the user edits the string value.
    @discardableResult
    open func minimumNumberOfCharacters(_ minimum: Int?) -> Self {
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
    open var allowedCharacters: AllowedCharacters = .all {
        didSet { cachedValidation = oldValue != allowedCharacters ? nil : cachedValidation  }
    }
    
    /// Sets the allowed characters the user can enter when editing.
    @discardableResult
    open func allowedCharacters(_ allowedCharacters: AllowedCharacters) -> Self {
        self.allowedCharacters = allowedCharacters
        return self
    }
    
    /// The allowed characters the user can enter when editing.
    public struct AllowedCharacters: OptionSet {
        public let rawValue: UInt
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = AllowedCharacters(rawValue: 1 << 0)
        /// Allows all letter characters.
        public static let letters: AllowedCharacters = [.lowercaseLetters, .uppercaseLetters]
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = AllowedCharacters(rawValue: 1 << 1)
        /// Allows alphabetic uppercase characters (like A, B, C, etc.)
        public static let uppercaseLetters = AllowedCharacters(rawValue: 1 << 2)
        /// Allows all alphanumerics characters.
        public static let alphanumerics: AllowedCharacters = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = AllowedCharacters(rawValue: 1 << 3)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = AllowedCharacters(rawValue: 1 << 4)
        /// Allows whitespace characters.
        public static let whitespaces = AllowedCharacters(rawValue: 1 << 5)
        /// Allows new line characters.
        public static let newLines = AllowedCharacters(rawValue: 1 << 6)
        /// Allows all characters.
        public static let all: AllowedCharacters = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines]
            
        var needsSwizzling: Bool {
            self != AllowedCharacters.all
        }
            
        func isValid(_ string: String) -> Bool {
            trimString(string) == string
        }

        func trimString(_ string: String) -> String {
            guard self != .all else { return string }
            var string = string
            var characterSet = CharacterSet()
            if !contains(.lowercaseLetters) { characterSet += .lowercaseLetters }
            if !contains(.uppercaseLetters) { characterSet += .uppercaseLetters }
            if !contains(.digits) { characterSet += .decimalDigits }
            if !contains(.symbols) { characterSet += .symbols}
            if !characterSet.isEmpty { string = string.trimmingCharacters(in: characterSet) }
            if !contains(.newLines) { string = string.replacingOccurrences(of: "\n", with: "") }
            if !contains(.whitespaces) { string = string.replacingOccurrences(of: " ", with: "") }
            if !contains(.emojis) { string = string.trimmingEmojis() }
            return string
        }

        /// Creates a allowed characters structure with the specified raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
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
        obj as? String
    }
    
    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        obj as? NSAttributedString
    }
    
    open override func getObjectValue(_  obj:AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }
        
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
        if let minimumCharacters = minimumNumberOfCharacters, string.count < minimumCharacters {
            return false
        }
        if let maximumCharacters = maximumNumberOfCharacters, string.count > maximumCharacters {
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
