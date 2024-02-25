//
//  FontManager.swift
//  Icon Extractor
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit

public class FontManager: NSObject {
    /// The selected font.
    public var selectedFont: NSFont? {
        get { _selectedFont }
        set {
            guard newValue != selectedFont else { return }
            selectFont(newValue)
        }
    }
    
    /// The selected font size.
    public var fontSize: CGFloat = 12 {
        didSet {
            guard oldValue != fontSize else { return }
            fontSize = fontSize.clamped(min: 0.5)
            fontSizeStepper?.doubleValue = fontSize
            fontSizeTextField?.doubleValue = fontSize
            updateSelectedFont()
        }
    }
        
    /// The handler that gets called whenever the selected font changes.
    public var selectedFontHandler: ((NSFont?)->())?
    
    /// The available font families.
    public internal(set) var availableFontFamilies: [NSFont.FontFamily] = []
    
    /// The selected font family.
    public var selectedFontFamily: NSFont.FontFamily? {
        availableFontFamilies[safe: currentFamilyIndex]
    }
    
    /// The selected font member.
    public var selectedFontMember: NSFont.FontMember? {
        currentFontMembers[safe: currentMemberIndex]
    }
    
    var currentFontMembers: [NSFont.FontMember] {
        selectedFontFamily?.members ?? []
    }
    
    /// The popup button for selecting the font family.
    public weak var fontFamilyPopUpButton: NSPopUpButton? {
        didSet {
            guard oldValue != fontFamilyPopUpButton, let fontFamilyPopUpButton = fontFamilyPopUpButton else { return }
            fontFamilyPopUpButton.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self._currentFamilyIndex = fontFamilyPopUpButton.indexOfSelectedItem
                self.updateMembers()
                self.updateSelectedFont()
            }
            fontFamilyPopUpButton.isEnabled = isEnabled
            updateFontFamiliesPopUpButton()
            fontFamilyPopUpButton.selectItem(at: _currentFamilyIndex)
        }
    }
    
    /// The popup button for selecting the font member.
    public weak var fontMemberPopUpButton: NSPopUpButton? {
        didSet {
            guard oldValue != fontMemberPopUpButton, let fontMemberPopUpButton = fontMemberPopUpButton else { return }
            fontMemberPopUpButton.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self._currentMemberIndex = fontMemberPopUpButton.indexOfSelectedItem
                self.updateSelectedFont()
            }
            fontMemberPopUpButton.isEnabled = isEnabled
            updateMembersPopUpButton()
            fontMemberPopUpButton.selectItem(at: _currentMemberIndex)
        }
    }
    
    /// The text field for changing the font size.
    public weak var fontSizeTextField: NSTextField? {
        didSet {
            guard oldValue != fontSizeTextField, let fontSizeTextField = fontSizeTextField else { return }
            fontSizeTextField.doubleValue = fontSize
            fontSizeTextField.editingHandlers.didEnd = { [weak self] in
                guard let self = self, let fontSizeTextField = self.fontSizeTextField else { return  }
                self.fontSize = fontSizeTextField.doubleValue
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            if let minFontSize = minFontSize {
                formatter.minimum = NSNumber(minFontSize)
            }
            if let maxFontSize = maxFontSize {
                formatter.maximum = NSNumber(maxFontSize)
            }
            fontSizeTextField.formatter = formatter
            fontSizeTextField.isEnabled = isEnabled
        }
    }
    
    /// The stepper for changing the font size.
    public weak var fontSizeStepper: NSStepper? {
        didSet {
            guard oldValue != fontSizeStepper, let fontSizeStepper = fontSizeStepper else { return }
            fontSizeStepper.maxValue = maxFontSize ?? 100000
            fontSizeStepper.minValue = minFontSize ?? 1
            fontSizeStepper.doubleValue = fontSize
            fontSizeStepper.increment = 1
            fontSizeStepper.isEnabled = isEnabled
            fontSizeStepper.autorepeat = false
            fontSizeStepper.valueWraps = true
            fontSizeStepper.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.fontSize = fontSizeStepper.doubleValue
            }
        }
    }
    
    /*
    /// The segmented control for selecting the font traits.
    public weak var fontTraitsSegmentedControl: NSSegmentedControl? {
        didSet {
            guard oldValue != fontTraitsSegmentedControl, let segmentedControl = fontTraitsSegmentedControl else { return }
            segmentedControl.trackingMode = .selectAny
            segmentedControl.segments = [NSSegment("B").font(.systemFont.bold), NSSegment("I").font(.systemFont.italic)]
            segmentedControl.actionBlock = { [weak self] _ in
                guard let self = self else { return }
            }
        }
    }
    */
    
    /// A Boolean value that indicates whether the font names are presented with the system standard font or their font.
    public var showFontAppearanceWhenSelecting: Bool = true {
        didSet {
            guard oldValue != showFontAppearanceWhenSelecting else { return }
            updateAvailableFontFamilies()
            updateMembers()
            fontFamilyPopUpButton?.selectItem(at: currentFamilyIndex)
            fontMemberPopUpButton?.selectItem(at: currentMemberIndex)
        }
    }
    
    /// A Boolean value that indicates whether the font selection user interface objects are enabled.
    public var isEnabled = true {
        didSet {
            fontFamilyPopUpButton?.isEnabled = isEnabled
            fontMemberPopUpButton?.isEnabled = isEnabled
            fontSizeTextField?.isEnabled = isEnabled
            fontSizeStepper?.isEnabled = isEnabled
        }
    }
    
    public var minFontSize: CGFloat? = nil {
        didSet {
            fontSizeStepper?.minValue = minFontSize ?? 1
            (fontSizeTextField?.formatter as? NumberFormatter)?.minimum = nil
            if let minFontSize = minFontSize {
                (fontSizeTextField?.formatter as? NumberFormatter)?.minimum = NSNumber(minFontSize)
                if fontSize < minFontSize {
                    fontSize = minFontSize
                }
            }
        }
    }
    
    public var maxFontSize: CGFloat? = nil {
        didSet {
            fontSizeStepper?.maxValue = maxFontSize ?? 100000
            (fontSizeTextField?.formatter as? NumberFormatter)?.maximum = nil
            if let maxFontSize = maxFontSize {
                (fontSizeTextField?.formatter as? NumberFormatter)?.maximum = NSNumber(maxFontSize)
                if fontSize > maxFontSize {
                    fontSize = maxFontSize
                }
            }
        }
    }
    
    private var currentFamilyIndex: Int {
        get { fontFamilyPopUpButton?.indexOfSelectedItem ?? _currentFamilyIndex }
        set {
            _currentFamilyIndex = newValue
            fontFamilyPopUpButton?.selectItem(at: newValue)
        }
    }
    var _currentFamilyIndex: Int = -1
    
    private var currentMemberIndex: Int {
        get { fontMemberPopUpButton?.indexOfSelectedItem ?? _currentMemberIndex }
        set {
            _currentMemberIndex = newValue
            fontMemberPopUpButton?.selectItem(at: newValue)
        }
    }
    
    var _currentMemberIndex: Int = -1
    
    /// The default selected font.
    static var defaultFont: NSFont {
        NSFont(name: "HelveticaNeue", size: 12) ?? .systemFont(ofSize: NSFont.systemFontSize)
    }
    
    let popUpButtonItemHeight: CGFloat = 28
    
    let specialFontNames: Set<String> = [
        "Bodoni Ornaments", "Webdings", "Wingdings", "Wingdings2", "Wingdings3"
    ]
    
    var _selectedFont: NSFont? = .systemFont(ofSize: NSFont.systemFontSize) {
        didSet {
            guard oldValue != _selectedFont else { return }
            selectedFontHandler?(_selectedFont)
        }
    }
    
    public override init() {
        super.init()
        sharedInit()
    }
    
    public init(font: NSFont) {
        super.init()
        sharedInit()
        selectFont(font)
    }
    
    func sharedInit() {
        updateAvailableFontFamilies()
        selectFont(Self.defaultFont)
    }
    
    func updateAvailableFontFamilies() {
        let selectedFontFamily = selectedFontFamily
        availableFontFamilies = NSFontManager.shared.availableFontFamilies.compactMap({NSFont.FontFamily($0)})
        updateFontFamiliesPopUpButton()
        if let selectedFontFamily = selectedFontFamily, availableFontFamilies[safe: currentFamilyIndex] != selectedFontFamily {
            if let index = availableFontFamilies.firstIndex(of: selectedFontFamily) {
                currentFamilyIndex = index
            } else {
                selectedFont = nil
            }
        }
    }
    
    func updateFontFamiliesPopUpButton() {
        guard let fontFamilyPopUpButton = fontFamilyPopUpButton else { return }
        fontFamilyPopUpButton.removeAllItems()
        availableFontFamilies.forEach {
            guard var font = NSFont(name: $0.name, size: NSFont.systemFontSize) else {
                return
            }
            
            if specialFontNames.contains($0.name) {
                font = adjustFont(NSFont.systemFont(ofSize: NSFont.systemFontSize), string: $0.localizedName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(font, string: $0.localizedName, height: popUpButtonItemHeight)
            }
            
            
            let item = NSMenuItem($0.localizedName)
            item.tag = UUID().hashValue
            if showFontAppearanceWhenSelecting {
                let itemView = FontMenuItemView(font: font, title: $0.localizedName)
                item.view = itemView
            }
            fontFamilyPopUpButton.menu?.addItem(item)
        }
    }
    
    private func updateMembers() {
        guard let fontFamily = selectedFontFamily, !fontFamily.members.isEmpty else {
            fontMemberPopUpButton?.removeAllItems()
            fontMemberPopUpButton?.isEnabled = false
            return
        }
        updateMembersPopUpButton()
    }
    
    func updateMembersPopUpButton() {
        guard let fontMemberPopUpButton = fontMemberPopUpButton, let fontFamily = selectedFontFamily else { return }
        let isSpecial = specialFontNames.contains(fontFamily.name)
        fontMemberPopUpButton.removeAllItems()
        fontMemberPopUpButton.isEnabled = true
        for member in currentFontMembers {
            let font: NSFont
            if isSpecial {
                font = adjustFont(NSFont.systemFont(ofSize: NSFont.systemFontSize), string: member.fontName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(NSFont(name: member.fontName, size: NSFont.systemFontSize)!, string: member.faceName, height: popUpButtonItemHeight)
            }
            let item = NSMenuItem(member.faceName)
            item.tag = UUID().hashValue
            if showFontAppearanceWhenSelecting {
                let itemView = FontMenuItemView(font: font, title: member.faceName)
                item.view = itemView
            }
            fontMemberPopUpButton.menu?.addItem(item)
        }
        if fontMemberPopUpButton.numberOfItems > 0 {
            currentMemberIndex = 0
        }
    }
    
    private func adjustFont(_ font: NSFont, string: String, height: CGFloat) -> NSFont {
        var current = font
        let margin: CGFloat = 4
        while current.pointSize > 1 {
            let attrStr = NSMutableAttributedString(string: string, attributes: [.font: current])
            let rect = attrStr.boundingRect(with: NSSize(width: 0, height: height), options: [.usesDeviceMetrics, .usesFontLeading])
            
            if rect.height + margin <= height {
                break
            }
            current = current.withSize(current.pointSize - 1)
        }
        return current
    }
    
    private func selectFont(_ font: NSFont?) {
        if let font = font {
            guard let familyName = font.familyName, let index = availableFontFamilies.firstIndex(where: {$0.name == familyName}) else {
                return
            }
            currentFamilyIndex = index
            updateMembers()
            if let index = currentFontMembers.firstIndex(where: {$0.fontName == font.fontName }) {
                currentMemberIndex = index
            }
            fontSize = font.pointSize
            fontSizeTextField?.doubleValue = font.pointSize
            updateSelectedFont()
        } else {
            currentFamilyIndex = -1
            currentMemberIndex = -1
            fontMemberPopUpButton?.menu?.removeAllItems()
            fontSizeTextField?.stringValue = ""
            _selectedFont = nil
        }
    }
    
    func updateSelectedFont() {
        guard let fontName = currentFontMembers[safe: currentMemberIndex]?.fontName, let font = NSFont(name: fontName, size: fontSize) else { return }
        fontSizeTextField?.doubleValue = font.pointSize
        _selectedFont = font
    }
}

extension NSFont {
    /// the font families available in the system.
    public static var availableFontFamilies: [FontFamily] {
        NSFontManager.shared.availableFontFamilies.compactMap({FontFamily($0)})
    }
    
    /// Font family.
    public struct FontFamily: Hashable {
        
        /// The name of the font family.
        public let name: String
        
        /// The localized name of the font family.
        public let localizedName: String
        
        /// The members of the font family (e.g. `regular`, `light` or `bold`).
        public let members: [FontMember]
        
        init(_ name: String) {
            self.name = name
            let localizedName = NSFontManager.shared.localizedName(forFamily: name, face: nil)
            self.localizedName = localizedName
            self.members = (NSFontManager.shared.availableMembers(ofFontFamily: name) ?? []).compactMap({FontMember($0, name, localizedName)})
        }
    }
    
    /// A member of a font family.
    public struct FontMember: Hashable {
        /// The full name of the font, as used in PostScript language code—for example, “Times-Roman” or “Helvetica-Oblique.”
        public let fontName: String
        
        /// The family name of the font—for example, “Times” or “Helvetica.”
        public let familyName: String
        
        /// The localized family name.
        public let localizedFamilyName: String
        
        /// The face name of the font—for example, “Regular”, "Light" or “Bold”.
        public let faceName: String
        
        /// The localized face name of the font.
        public let localizedFaceName: String
        
        /**
         The approximated weight of the font.
         
         An approximation of the weight of the given font, where `0` indicates the lightest possible weight, `5` indicates a normal or book weight, and `9` or more indicates a bold or heavier weight.
         */
        public let weight: CGFloat
        
        /// The traits of the font.
        public let traits: NSFontDescriptor.SymbolicTraits
        
        /// The font with the specified size.
        public func font(size: CGFloat = NSFont.systemFontSize) -> NSFont? {
            NSFont(name: fontName, size: size)
        }
        
        init?(_ value: [Any], _ familyName: String, _ localizedFamilyName: String) {
            guard let fontName = value[safe: 0] as? String, let faceName = value[safe: 1] as? String, let weight = value[safe: 2] as? CGFloat, let traits = value[safe: 3] as? UInt32 else {
                return nil
            }
            self.fontName = fontName
            self.faceName = faceName
            self.familyName = familyName
            self.localizedFamilyName = localizedFamilyName
            self.traits = .init(rawValue: traits)
            self.weight = weight
            self.localizedFaceName = NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
        }
    }
}

extension NSTextField {
    /// The number formatting for a text field.
    public struct NumberFormatting {
        /// The formatting style.
        var style: NumberFormatter.Style = .decimal
        /// The rounding mode.
        var roundingMode: NumberFormatter.RoundingMode = .halfEven
        /// A Boolean value that indicates whether the text field will use heuristics to guess at the number which is intended by a string.
        var isLenient: Bool = false
        /// The minimum number.
        var minValue: Double? = nil
        /// The maximum number.
        var maxValue: Double? = nil
    }
    
    /// The number formatting for the text field.
    public var numberFormatting: NumberFormatting? {
        get {
            guard let formatter = formatter as? NumberFormatter else { return nil }
            return NumberFormatting(formatter)
        }
        set {
            if let newValue = newValue {
                formatter = NumberFormatter(newValue)
            } else if formatter is NumberFormatter {
                formatter = nil
            }
        }
    }
}

extension NSTextField.NumberFormatting {
    init(_ formatter: NumberFormatter) {
        style = formatter.numberStyle
        roundingMode = formatter.roundingMode
        isLenient = formatter.isLenient
        minValue = formatter.minValue
        maxValue = formatter.maxValue
    }
}

extension NumberFormatter {
    convenience init(_ formatting: NSTextField.NumberFormatting) {
        self.init()
        numberStyle = formatting.style
        roundingMode = formatting.roundingMode
        isLenient = formatting.isLenient
        minValue = formatting.minValue
        maxValue = formatting.maxValue
    }
}

#endif
