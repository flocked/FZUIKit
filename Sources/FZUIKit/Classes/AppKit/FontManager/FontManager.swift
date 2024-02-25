//
//  FontManager.swift
//  
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public class FontManager: NSObject {
    /// The selected font.
    @objc dynamic public var selectedFont: NSFont? {
        get { _selectedFont }
        set {
            guard newValue != selectedFont else { return }
            selectFont(newValue)
        }
    }
    
    /// The selected font size.
    @objc dynamic public var fontSize: CGFloat = 12 {
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
    
    var targetObservation: NSKeyValueObservation?
    var targetFontObservation: Any?
    
    /**
     A Boolean value that indicates whether the target is automatically updated.

     if `true`, the target is automatically updates based on the first responder of the window that displays ``fontFamilyPopUpButton``.
     */
    public var automaticallyManagesTarget: Bool = false {
        didSet {
            guard oldValue != automaticallyManagesTarget else { return }
            setupAutomaticTargetObservation()
        }
    }
    
    func setupAutomaticTargetObservation() {
        if automaticallyManagesTarget, let fontFamilyPopUpButton = fontFamilyPopUpButton {
            func checkFirstResponder(_ firstResponder: NSResponder?) {
           //     Swift.print("firstResponder", firstResponder ?? "nil", firstResponder == fontSizeTextField)
                if let textView = firstResponder as? NSTextView {
                    if textView.isFieldEditor == false {
                        self.target = textView
                    }
                } else if firstResponder != self.fontSizeTextField, firstResponder != fontFamilyPopUpButton.window {
                    self.target = nil
                }
            }
            checkFirstResponder(fontFamilyPopUpButton.window?.firstResponder)
            targetObservation = fontFamilyPopUpButton.observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                guard self != nil, old != new else { return }
                checkFirstResponder(new)
            }
        } else {
            targetObservation = nil
        }
    }
    
    /**
     The target object that updates and receives the selected font.
     
     ``selectedFont`` reflects the font of the target. If the target changes it's font, ``selectedFont`` is updated, and viceversa.
     
     The target has to be either `NSTextView`, `NSTextField` or any `NSControl`.
     */
    public var target: AnyObject? {
        didSet {
            if let textView = target as? NSTextView {
                updateSelectedFont(for: textView)
                targetFontObservation = NotificationCenter.default.observe(NSTextView.didChangeSelectionNotification, object: textView) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateSelectedFont(for: textView)
                }
            } else if let control = target as? NSControl {
                selectedFont = control.font
                targetFontObservation = control.observeChanges(for: \.font) { [weak self] old, new in
                    guard let self = self, old != new else { return  }
                    self.selectedFont = new
                }
            } else {
                target = nil
                targetFontObservation = nil
                selectedFont = nil
            }
        }
    }
    
    func updateSelectedFont(for textView: NSTextView) {
        let fonts = textView.selectionFonts
        if fonts.count == 1 {
           selectedFont = fonts.first
        } else if fonts.count > 1 {
            let sameFamily = fonts.compactMap({$0.familyName}).uniqued().count == 1
            let sameTraits = sameFamily ? fonts.compactMap({$0.fontDescriptor.symbolicTraits}).uniqued().count == 1 : false
            let sameSize = fonts.compactMap({$0.pointSize}).uniqued().count == 1
            selectedFont = nil
        } else {
            selectedFont = textView.typingAttributes[.font] as? NSFont
        }
    }
    
    /// The popup button for selecting the font family.
    public weak var fontFamilyPopUpButton: NSPopUpButton? {
        didSet {
            guard oldValue != fontFamilyPopUpButton else { return }
            setupAutomaticTargetObservation()
            guard let fontFamilyPopUpButton = fontFamilyPopUpButton else { return }
            fontFamilyPopUpButton.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self._currentFamilyIndex = fontFamilyPopUpButton.indexOfSelectedItem
                self.updateMembers()
                self.updateSelectedFont()
            }
            fontFamilyPopUpButton.isEnabled = isEnabled
            updateFontFamiliesPopUpButton()
            fontFamilyPopUpButton.selectItem(at: _currentFamilyIndex)
            updatePopUpButtonFonts()
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
            updatePopUpButtonFonts()
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
    
    /// The segmented control for selecting the font traits.
    public weak var fontTraitsSegmentedControl: NSSegmentedControl? {
        didSet {
            guard oldValue != fontTraitsSegmentedControl, let segmentedControl = fontTraitsSegmentedControl else { return }
            segmentedControl.trackingMode = .selectAny
            segmentedControl.isEnabled = isEnabled
            segmentedControl.segments {
                if #available(macOS 11.0, *) {
                    NSSegment(symbolName: "bold")?.tag(11)
                    NSSegment(symbolName: "italic")?.tag(22)
                    NSSegment(symbolName: "underline")?.tag(33)
                    NSSegment(symbolName: "strikethrough")?.tag(44)
                } else {
                    NSSegment("B").font(.systemFont.bold).tag(11)
                    NSSegment("I").font(.systemFont.italic).tag(22)
                }
            }
            segmentedControl.actionBlock = { [weak self] segmentedControl in
                guard let self = self, let selectedFont = self.selectedFont else { return }
                guard let boldSeg = segmentedControl.segment(withTag: 11), let italicSeg = segmentedControl.segment(withTag: 22) else { return }
                var traits = selectedFont.fontDescriptor.symbolicTraits
                if boldSeg.isSelected {
                    traits.insert(.bold)
                } else {
                    traits.remove(.bold)
                }
                if italicSeg.isSelected {
                    traits.insert(.italic)
                } else {
                    traits.remove(.italic)
                }
                if traits != selectedFont.fontDescriptor.symbolicTraits {
                    
                }
            }
        }
    }
    
    func updateSegmented() {
        if let selectedFont = selectedFont {
            let traits = selectedFont.fontDescriptor.symbolicTraits
            fontTraitsSegmentedControl?.segment(withTag: 11)?.isSelected = traits.contains(.bold)
            fontTraitsSegmentedControl?.segment(withTag: 22)?.isSelected = traits.contains(.italic)
        } else {
            fontTraitsSegmentedControl?.deselectAll()
        }
    }
    
    /// A Boolean value that indicates whether the selected font is displayed on the popup buttons.
    public var showsFontAppearanceOnPopUpButtons: Bool = false {
        didSet {
            guard oldValue != showsFontAppearanceOnPopUpButtons else { return }
            updatePopUpButtonFonts()
        }
    }
    
    func updatePopUpButtonFonts() {
        if let fontFamilyPopUpButton = fontFamilyPopUpButton {
            if showsFontAppearanceOnPopUpButtons, let selectedFont = selectedFont {
                fontFamilyPopUpButton.font = selectedFont.withSize(NSFont.systemFontSize(for: fontFamilyPopUpButton.controlSize))
            } else {
                fontFamilyPopUpButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: fontFamilyPopUpButton.controlSize))
            }
        }
        if let fontMemberPopUpButton = fontMemberPopUpButton {
            if showsFontAppearanceOnPopUpButtons, let selectedFont = selectedFont {
                fontMemberPopUpButton.font = selectedFont.withSize(NSFont.systemFontSize(for: fontMemberPopUpButton.controlSize))
            } else {
                fontMemberPopUpButton.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: fontMemberPopUpButton.controlSize))
            }
        }
    }
    
    /// A Boolean value that indicates whether the font names are presented with the system standard font or their font.
    public var showsFontAppearanceWhenSelecting: Bool = true {
        didSet {
            guard oldValue != showsFontAppearanceWhenSelecting else { return }
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
            fontTraitsSegmentedControl?.isEnabled = isEnabled
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
    
    var availableFontsObservation: NotificationToken?
    
    let specialFontNames: Set<String> = [
        "Bodoni Ornaments", "Webdings", "Wingdings", "Wingdings2", "Wingdings3"
    ]
    
    var _selectedFont: NSFont? = .systemFont(ofSize: NSFont.systemFontSize) {
        didSet {
            guard oldValue != _selectedFont else { return }
            updateTargetFont()
            updatePopUpButtonFonts()
            selectedFontHandler?(_selectedFont)
            fontTraitsSegmentedControl?.segment(withTag: 22)?.isSelected = _selectedFont?.fontDescriptor.symbolicTraits.contains(.bold) ?? false
            fontTraitsSegmentedControl?.segment(withTag: 33)?.isSelected = _selectedFont?.fontDescriptor.symbolicTraits.contains(.italic) ?? false
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
        // selectFont(Self.defaultFont)
        availableFontsObservation = NotificationCenter.default.observe(NSFont.fontSetChangedNotification, object: nil) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvailableFontFamilies()
        }
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
            if showsFontAppearanceWhenSelecting {
                let itemView = FontMenuItemView(font: font, title: $0.localizedName)
                item.view = itemView
            }
            fontFamilyPopUpButton.menu?.addItem(item)
        }
    }
    
    private func updateMembers() {
        guard selectedFontFamily != nil else {
            return
        }
        updateMembersPopUpButton()
        fontSizeTextField?.isEnabled = isEnabled
        fontSizeStepper?.isEnabled = isEnabled
        fontTraitsSegmentedControl?.isEnabled = isEnabled
    }
    
    func updateMembersPopUpButton() {
        guard let fontMemberPopUpButton = fontMemberPopUpButton, let fontFamily = selectedFontFamily else { return }
        let isSpecial = specialFontNames.contains(fontFamily.name)
        fontMemberPopUpButton.removeAllItems()
        fontMemberPopUpButton.isEnabled = isEnabled
        for member in currentFontMembers {
            let font: NSFont
            if isSpecial {
                font = adjustFont(NSFont.systemFont(ofSize: NSFont.systemFontSize), string: member.fontName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(NSFont(name: member.fontName, size: NSFont.systemFontSize)!, string: member.faceName, height: popUpButtonItemHeight)
            }
            let item = NSMenuItem(member.faceName)
            item.tag = UUID().hashValue
            if showsFontAppearanceWhenSelecting {
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
            updateSelectedFont()
        } else {
            currentFamilyIndex = -1
            currentMemberIndex = -1
            _selectedFont = nil
            fontMemberPopUpButton?.menu?.removeAllItems()
            fontMemberPopUpButton?.isEnabled = false
            fontSizeTextField?.stringValue = ""
            fontSizeTextField?.isEnabled = false
            fontSizeStepper?.isEnabled = false
            fontTraitsSegmentedControl?.isEnabled = false
        }
    }
    
    func updateSelectedFont() {
        guard let fontName = currentFontMembers[safe: currentMemberIndex]?.fontName, let font = NSFont(name: fontName, size: fontSize) else { return }
        fontSizeTextField?.doubleValue = font.pointSize
        _selectedFont = font
    }
    
    func updateTargetFont() {
        guard let selectedFont = selectedFont else { return }
        if let textView = target as? NSTextView {
            textView.selectionFonts = [selectedFont]
        } else if let control = target as? NSControl {
            control.font = selectedFont
        }
    }
    
    func selectFontFamily(_ family: NSFont.FontFamily) {
        guard let index = availableFontFamilies.firstIndex(where: {$0 == family}) else { return }
        currentFamilyIndex = index
        updateMembers()
        updateSelectedFont()
    }
    
    func selectFontFamily(named name: String) {
        guard let index = availableFontFamilies.firstIndex(where: {$0.name == name}) else { return }
        currentFamilyIndex = index
        updateMembers()
        updateSelectedFont()
    }
    
    var allAvailableFontNames: [String] {
        availableFontFamilies.flatMap({$0.members.compactMap({$0.fontName})})
    }
}

/*
extension FontManager {
    class DelegateProxy: NSObject, NSTextDelegate, NSTextViewDelegate {
        weak var textDelegate: NSTextDelegate?
        weak var textViewDelegate: NSTextViewDelegate?
        weak var fontManager: FontManager?
        func textDidBeginEditing(_ notification: Notification) {
            textDelegate?.textDidBeginEditing?(notification)
        }
        
        func textDidChange(_ notification: Notification) {
            textDelegate?.textDidChange?(notification)
        }
        
        func textDidEndEditing(_ notification: Notification) {
            textDelegate?.textDidEndEditing?(notification)
        }
        
        func textShouldBeginEditing(_ textObject: NSText) -> Bool {
            textDelegate?.textShouldBeginEditing?(textObject) ?? true
        }
        
        func textShouldEndEditing(_ textObject: NSText) -> Bool {
            textDelegate?.textShouldEndEditing?(textObject) ?? true
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            textViewDelegate?.textViewDidChangeSelection?(notification)
        }
    }
}
 */


#endif
