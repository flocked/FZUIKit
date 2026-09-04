//
//  TISInputSource+.swift
//
//
//  Created by Florian Zand on 27.08.26.
//

#if os(macOS)
import AppKit
import Carbon
import FZSwiftUtils

extension OSStatus {
    func throwIfError() throws {
        guard self == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(self))
        }
    }
}

public extension TISInputSource {
    /// A category of text input sources.
    struct Category: RawRepresentable, Hashable, CustomStringConvertible {
        /// A keyboard input source.
        public static let keyboard = Self(rawValue: kTISCategoryKeyboardInputSource)
        /// A palette input source.
        public static let palette = Self(rawValue: kTISCategoryPaletteInputSource)
        
        public var description: String {
            switch self {
            case .keyboard: ".keyboard"
            case .palette: ".palette"
            default: "." + (rawValue as String).removingPrefix("TISCategory").lowercasedFirst().removingSuffix("InputSource")
            }
        }

        public let rawValue: CFString

        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
    }

    /// A specific type of text input source.
    struct SourceType: RawRepresentable, Hashable, CustomStringConvertible {
        /// A keyboard layout input source.
        public static let keyboardLayout = Self(rawValue: kTISTypeKeyboardLayout)
        /// A keyboard input method that doesn't use input modes.
        public static let keyboardInputMethodWithoutModes = Self(rawValue: kTISTypeKeyboardInputMethodWithoutModes)
        /// A keyboard input method whose input modes are enabled.
        public static let keyboardInputMethodModeEnabled = Self(rawValue: kTISTypeKeyboardInputMethodModeEnabled)
        /// A keyboard input mode.
        public static let keyboardInputMode = Self(rawValue: kTISTypeKeyboardInputMode)
        /// A keyboard viewer input source.
        public static let keyboardViewer = Self(rawValue: kTISTypeKeyboardViewer)
        /// A character palette input source.
        public static let characterPalette = Self(rawValue: kTISTypeCharacterPalette)
        /// An Ink input source.
        public static let ink = Self(rawValue: kTISTypeInk)
        
        public var description: String {
            "." + (rawValue as String).removingPrefix("TISType").lowercasedFirst()
        }

        public let rawValue: CFString

        public init(rawValue: CFString) {
            self.rawValue = rawValue
        }
    }

    /// The category of the input source.
    var category: Category {
        self[kTISPropertyInputSourceCategory]!
    }

    /// The type of the input source.
    var type: SourceType {
        self[kTISPropertyInputSourceType]!
    }

    /// The unique identifier of the input source.
    var id: String {
        self[kTISPropertyInputSourceID]!
    }

    /// The bundle identifier associated with the input source.
    var bundleID: String? {
        self[kTISPropertyBundleID]
    }

    /// The input mode identifier associated with the input source.
    var modeID: String? {
        self[kTISPropertyInputModeID]
    }

    /// The Unicode keyboard layout data associated with the input source.
    var unicodeKeyLayoutData: Data? {
        self[kTISPropertyUnicodeKeyLayoutData]
    }

    /// The localized display name of the input source.
    var localizedName: String {
        self[kTISPropertyLocalizedName]!
    }

    /// A Boolean value indicating whether the input source is currently selected.
    var isSelected: Bool {
        get { self[kTISPropertyInputSourceIsSelected] ?? false }
        set {
            guard newValue != isSelected, isSelectable else { return }
            if newValue {
                TISSelectInputSource(self)
            } else {
                TISDeselectInputSource(self)
            }
        }
    }

    /// A Boolean value indicating whether the input source can be programmatically selected.
    var isSelectable: Bool {
        self[kTISPropertyInputSourceIsSelectCapable] ?? false
    }

    /// A Boolean value indicating whether the input source is currently enabled.
    var isEnabled: Bool {
        get { self[kTISPropertyInputSourceIsEnabled] ?? false }
        set {
            guard newValue != isEnabled, isEnablable else { return }
            if newValue {
                TISEnableInputSource(self)
            } else {
                TISDisableInputSource(self)
            }
        }
    }

    /// A Boolean value indicating whether the input source can be programmatically enabled.
    var isEnablable: Bool {
        self[kTISPropertyInputSourceIsEnableCapable] ?? false
    }

    /// A Boolean value indicating whether the input source is intended to support ASCII input.
    var isASCIICapable: Bool {
        self[kTISPropertyInputSourceIsASCIICapable] ?? false
    }

    /// The language identifiers associated with the input source.
    var sourceLanguages: [String] {
        self[kTISPropertyInputSourceLanguages] ?? []
    }

    /// The URL of the image used to represent the input source.
    var iconImageURL: URL? {
        self[kTISPropertyIconImageURL]
    }

    /// The icon used to represent the input source.
    var icon: NSImage? {
        guard let value = TISGetInputSourceProperty(self, kTISPropertyIconRef) else { return nil }
        return NSImage(iconRef: OpaquePointer(value))
    }

    /// Returns the value for the specified input source property.
    subscript<Value>(property: CFString) -> Value? {
        guard let cfType = TISGetInputSourceProperty(self, property) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue() as? Value
    }

    /// Returns the value for the specified input source property.
    subscript<Value: RawRepresentable>(property: CFString) -> Value? {
        self[property].flatMap { Value(rawValue: $0) }
    }

    /// Returns the characters produced by the specified key code and modifier flags using the input source.
    func characters(for keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = []) -> String? {
        guard category == .keyboard else { return nil }
        guard keyCode < 128 else { return nil }
        if let characters = Self.specialCharacters[keyCode] {
            return characters
        }
        let key = CharactersKey(id, keyCode, modifierFlags)
        return Self.charactersCache.withLock { cache in
            if let value = cache[key] {
                return value
            }
            guard let data = unicodeKeyLayoutData else {
                cache[key] = .some(nil)
                return nil
            }
            return data.withUnsafeBytes { bytes -> String? in
                var state: UInt32 = 0, length = 0
                var chars = [UniChar](repeating: 0, count: 4)
                guard let address = bytes.baseAddress, UCKeyTranslate(address.assumingMemoryBound(to: UCKeyboardLayout.self), keyCode, UInt16(kUCKeyActionDown), modifierFlags.carbonModifierState, UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysBit), &state, chars.count, &length, &chars) == noErr, length > 0 else {
                    cache[key] = .some(nil)
                    return nil
                }
                let value = String(utf16CodeUnits: chars, count: length)
                cache[key] = value
                return value
            }
        }
    }
    
    private struct CharactersKey: Hashable {
        let keyCode: UInt16
        let flags: UInt
        let id: String

        init(_ id: String, _ keyCode: UInt16, _ flags: NSEvent.ModifierFlags) {
            self.keyCode = keyCode
            self.flags = flags.deviceIndependent.rawValue
            self.id = id
        }
    }
    
    private static var charactersCache = Mutex<[CharactersKey: String?]>([:])

    private static let specialCharacters: [UInt16: String] = [51: String(unicodeScalar: NSDeleteCharacter), 64: String(unicodeScalar: NSF17FunctionKey), 71: String(unicodeScalar: NSClearLineFunctionKey), 79: String(unicodeScalar: NSF18FunctionKey), 80: String(unicodeScalar: NSF19FunctionKey), 90: String(unicodeScalar: 16), 96: String(unicodeScalar: NSF5FunctionKey), 97: String(unicodeScalar: NSF6FunctionKey), 98: String(unicodeScalar: NSF7FunctionKey), 99: String(unicodeScalar: NSF3FunctionKey), 100: String(unicodeScalar: NSF8FunctionKey), 101: String(unicodeScalar: NSF9FunctionKey), 103: String(unicodeScalar: NSF11FunctionKey), 105: String(unicodeScalar: NSF13FunctionKey), 106: String(unicodeScalar: NSF16FunctionKey), 107: String(unicodeScalar: NSF14FunctionKey), 109: String(unicodeScalar: NSF10FunctionKey), 111: String(unicodeScalar: NSF12FunctionKey), 113: String(unicodeScalar: NSF15FunctionKey), 114: String(unicodeScalar: NSHelpFunctionKey), 115: String(unicodeScalar: NSHomeFunctionKey), 116: String(unicodeScalar: NSPageUpFunctionKey), 117: String(unicodeScalar: NSDeleteFunctionKey), 118: String(unicodeScalar: NSF4FunctionKey), 119: String(unicodeScalar: NSEndFunctionKey), 120: String(unicodeScalar: NSF2FunctionKey), 121: String(unicodeScalar: NSPageDownFunctionKey), 122: String(unicodeScalar: NSF1FunctionKey), 123: String(unicodeScalar: NSLeftArrowFunctionKey), 124: String(unicodeScalar: NSRightArrowFunctionKey), 125: String(unicodeScalar: NSDownArrowFunctionKey), 126: String(unicodeScalar: NSUpArrowFunctionKey)]
}

public extension TISInputSource {
    /// Observes changes to the selected keyboard layout using the specified handler.
    static func observeKeyboardSelectionChanges(_ handler: @escaping (_ keyboardLayout: TISInputSource)->()) -> NotificationToken {
        NotificationCenter.default.observe(NSTextInputContext.keyboardSelectionDidChangeNotification) { _ in
            guard let keyboardLayout = TISInputSource.currentKeyboardLayout else { return }
            handler(keyboardLayout)
        }
    }
    
    /// The currently selected keyboard input source.
    static var currentKeyboardInputSource: TISInputSource? {
        TISCopyCurrentKeyboardInputSource()?.takeRetainedValue()
    }

    /// The keyboard layout currently being used.
    static var currentKeyboardLayout: TISInputSource? {
        TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue()
    }

    /// The most recently used ASCII-capable keyboard input source.
    static var currentASCIICapableKeyboardInputSource: TISInputSource? {
        TISCopyCurrentASCIICapableKeyboardInputSource()?.takeRetainedValue()
    }

    /// The most recently used ASCII-capable keyboard layout.
    static var currentASCIICapableKeyboardLayout: TISInputSource? {
        TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue()
    }

    /// The keyboard layout override for the currently selected input method.
    static var inputMethodKeyboardLayoutOverride: TISInputSource? {
        get { TISCopyInputMethodKeyboardLayoutOverride()?.takeRetainedValue() }
        set { TISSetInputMethodKeyboardLayoutOverride(newValue) }
    }

    /// Returns an enabled input source appropriate for the specified BCP 47 language identifier.
    static func inputSource(forLanguage language: String) -> TISInputSource? {
        TISCopyInputSourceForLanguage(language as CFString)?.takeRetainedValue()
    }

    /// Returns an enabled input source appropriate for the specified locale.
    static func inputSource(for locale: Locale) -> TISInputSource? {
        if #available(macOS 13, *) {
            return inputSource(forLanguage: locale.language.minimalIdentifier)
        } else {
            return inputSource(forLanguage: locale.languageCode ?? locale.identifier)
        }
    }

    /// The enabled ASCII-capable keyboard input sources.
    static var asciiCapableKeyboardInputSources: [TISInputSource] {
        TISCreateASCIICapableInputSourceList()?.takeRetainedValue() as? [TISInputSource] ?? []
    }
}

public extension TISInputSource {
    /// Returns the enabled input sources matching the specified search options.
    static func inputSources(matching options: [SearchOption]) -> [TISInputSource] {
        inputSources(matching: options, includeInstalled: false)
    }

    /// Returns the enabled input sources matching the specified search options.
    @_disfavoredOverload
    static func inputSources(matching options: SearchOption...) -> [TISInputSource] {
        inputSources(matching: options, includeInstalled: false)
    }

    /// The enabled input sources.
    static var inputSources: [TISInputSource] {
        inputSources(matching: [])
    }

    /// The enabled keyboard input sources.
    static var keyboardInputSources: [TISInputSource] {
        inputSources(matching: .category(.keyboard))
    }

    /// Returns the installed input sources matching the specified search options.
    static func installedInputSources(matching options: [SearchOption]) -> [TISInputSource] {
        inputSources(matching: options, includeInstalled: true)
    }

    /// Returns the installed input sources matching the specified search options.
    @_disfavoredOverload
    static func installedInputSources(matching options: SearchOption...) -> [TISInputSource] {
        inputSources(matching: options, includeInstalled: true)
    }

    /// The installed input sources.
    static var installedInputSources: [TISInputSource] {
        installedInputSources(matching: [])
    }

    /// The installed keyboard input sources.
    static var installedKeyboardInputSources: [TISInputSource] {
        installedInputSources(matching: .category(.keyboard))
    }

    /// An option for matching input sources.
    struct SearchOption: Hashable {
        /// The Text Input Source Services property used for matching.
        public let property: CFString
        /// The value the input source property must match.
        public let value: AnyHashable

        fileprivate var isLanguage: Bool {
            property == kTISPropertyInputSourceLanguages
        }

        fileprivate var language: String? {
            isLanguage ? value as? String : nil
        }

        /// Creates a search option that matches the specified input source property and value.
        public init(property: CFString, value: AnyHashable) {
            self.property = property
            self.value = value
        }

        private init(_ property: CFString, _ value: AnyHashable) {
            self.init(property: property, value: value)
        }

        /// Matches input sources with the specified category.
        public static func category(_ category: Category) -> Self {
            Self(kTISPropertyInputSourceCategory, category.rawValue)
        }

        /// Matches input sources with the specified source type.
        public static func type(_ type: SourceType) -> Self {
            Self(kTISPropertyInputSourceType, type.rawValue)
        }

        /// Matches input sources with the specified enabled state.
        public static func isEnabled(_ isEnabled: Bool) -> Self {
            Self(kTISPropertyInputSourceIsEnabled, isEnabled)
        }

        /// Matches input sources with the specified selected state.
        public static func isSelected(_ isSelected: Bool) -> Self {
            Self(kTISPropertyInputSourceIsSelected, isSelected)
        }

        /// Matches input sources that can be selected.
        public static func isSelectable(_ isSelectable: Bool) -> Self {
            Self(kTISPropertyInputSourceIsSelectCapable, isSelectable)
        }

        /// Matches input sources with the specified enablability.
        public static func isEnablable(_ isEnablable: Bool) -> Self {
            Self(kTISPropertyInputSourceIsEnableCapable, isEnablable)
        }

        /// Matches input sources with the specified ASCII capability.
        public static func isASCIICapable(_ isASCIICapable: Bool) -> Self {
            Self(kTISPropertyInputSourceIsASCIICapable, isASCIICapable)
        }

        /// Matches the input source with the specified identifier.
        public static func id(_ id: String) -> Self {
            Self(kTISPropertyInputSourceID, id)
        }

        /// Matches input sources with the specified bundle identifier.
        public static func bundleID(_ bundleID: String) -> Self {
            Self(kTISPropertyBundleID, bundleID)
        }

        /// Matches input sources with the specified input mode identifier.
        public static func modeID(_ modeID: String) -> Self {
            Self(kTISPropertyInputModeID, modeID)
        }

        /// Matches input sources with the specified localized name.
        public static func localizedName(_ name: String) -> Self {
            Self(kTISPropertyLocalizedName, name)
        }

        /// Matches input sources associated with the specified language identifier.
        public static func language(_ language: String) -> Self {
            Self(kTISPropertyInputSourceLanguages, language)
        }

        /// Matches input sources associated with the specified language.
        public static func language(_ locale: Locale) -> Self {
            language(locale.languageCode ?? locale.identifier)
        }

        /// Matches selected input sources.
        public static let isSelected = isSelected(true)
        /// Matches input sources that can be selected.
        public static let isSelectable = isSelectable(true)
        /// Matches enabled input sources.
        public static let isEnabled = isEnabled(true)
        /// Matches input sources that can be enabled.
        public static let isEnablable = isEnablable(true)
        /// Matches input sources capable of producing ASCII characters.
        public static let isASCIICapable = isASCIICapable(true)
        /// Matches keyboard input sources.
        public static let keyboard = category(.keyboard)
        /// Matches palette input sources.
        public static let palette = category(.palette)
    }

    private static func inputSources(matching options: [SearchOption], includeInstalled: Bool) -> [TISInputSource] {
        let options = options.uniqued()
        let languages = Set(options.compactMap { $0.language })
        let result = options.filter { !$0.isLanguage }.grouped(by: \.property).reduce([[:]] as [[CFString: Any]]) { queries, group in
            queries.flatMap { query in
                group.value.map(\.value).map { value in
                    var query = query
                    query[group.key] = value
                    return query
                }
            }
        }.flatMap { TISCreateInputSourceList($0 as CFDictionary, includeInstalled)?.takeRetainedValue() as? [TISInputSource] ?? [] }.uniqued(by: \.id)
        return languages.isEmpty ? result : result.filter { !languages.isDisjoint(with: $0.sourceLanguages) }
    }
}

extension TISInputSource: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
        var components = ["\(id)"]
        if localizedName != id {
           components += "\"\(localizedName)\""
          //  components = ["\(id) (\"\(localizedName)\")"]
          //  components = ["\(id) \"\(localizedName)\""]
        }
        components += "type: \(type)"
        if let modeID { components += "modeID: \"\(modeID)\"" }
        if isSelected { components += "selected" }
        if isEnabled { components += "enabled" }
        return "(\(components.joined(separator: ", ")))"
    }

    public var debugDescription: String {
        """
        TISInputSource "\(id)"
         - category: \(category)
         - type: \(type)
         - bundleID: \(bundleID ?? "nil")
         - modeID: \(modeID ?? "nil")
         - localizedName: \(localizedName)
         - isSelected: \(isSelected), isSelectable: \(isSelectable)
         - isEnabled: \(isEnabled), isEnablable: \(isEnablable)
         - isASCIICapable: \(isASCIICapable)
         - sourceLanguages: \(sourceLanguages)
         - unicodeKeyLayoutData: \(unicodeKeyLayoutData.map { "\($0.count) bytes" } ?? "nil")
         - iconImageURL: \(iconImageURL?.path ?? "nil")
         - icon: \(icon.map({ "\($0.size)" }) ?? "nil")
        """
    }
}

extension String {
   init(unicodeScalar: Int) {
       self.init(UnicodeScalar(unicodeScalar)!)
   }
}

extension NSEvent.ModifierFlags {
    /// The device-independent modifier flags.
    var deviceIndependent: Self {
        intersection(.deviceIndependentFlagsMask)
    }
    
    var carbonModifierState: UInt32 {
        (Self.modifiers.reduce(0) { $0 | (contains($1.flags) ? UInt32($1.carbon) : 0) } >> 8) & 0xFF
    }
    
    private static let modifiers: [(flags: Self, carbon: Int)] = [(.shift, shiftKey), (.capsLock, alphaLock), (.option, optionKey), (.control, controlKey), (.command, cmdKey)]
}
#endif
