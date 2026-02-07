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
    public struct AllowedCharacters: Equatable, Hashable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        var set: CharacterSet
        var isEmoji: Bool
        
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = Self(.decimalDigits)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = Self(.lowercaseLetters)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let uppercaseLetters = Self(.uppercaseLetters)
        /// Allows punctuation characters (like …,).
        public static let punctuation = Self(.punctuationCharacters)

        /// Allows all letter characters.
        public static let letters: Self = [.lowercaseLetters, .uppercaseLetters]
        /// Allows all alphanumerics characters.
        public static let alphanumerics: Self = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = Self(.symbols)
        /// Allows whitespace characters.
        public static let whitespaces = Self(.whitespaces)
        /// Allows new line characters.
        public static let newLines = Self(.newlines)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = Self(isEmoji: true)
        /// ALl characters.
        public static let all: Self = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines, .punctuation]
        
        func isValid(_ string: String) -> Bool {
            trimString(string) == string
        }
        
        func trimString(_ string: String) -> String {
            guard set != Self.all.set else { return isEmoji ? string : string.removingEmojis() }
            guard isEmoji else { return string.keepingCharacters(in: set) }
            return String(string.filter { character in
                character.unicodeScalars.allSatisfy { set.contains($0) } || character.isEmoji
            })
        }
        
        public init(_ set: CharacterSet) {
            self.set = set
            self.isEmoji = false
        }
        
        public init(stringLiteral value: String) {
            self.init(value.unicodeScalars)
        }
        
        public init<S: Sequence<Unicode.Scalar>>(_ characters: S) {
            self.init(CharacterSet(characters))
        }
        
        public init(arrayLiteral elements: Self...) {
            set = elements.map({$0.set}).union
            isEmoji = elements.contains(where: {$0.isEmoji })
        }
        
        init(_ set: CharacterSet = .init(), isEmoji: Bool) {
            self.set = set
            self.isEmoji = isEmoji
        }
        
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(lhs.set.union(rhs.set), isEmoji: lhs.isEmoji || rhs.isEmoji)
        }
        
        public static func += (lhs: inout Self, rhs: Self) {
            lhs.set.formUnion(rhs.set)
            lhs.isEmoji = lhs.isEmoji || rhs.isEmoji
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
