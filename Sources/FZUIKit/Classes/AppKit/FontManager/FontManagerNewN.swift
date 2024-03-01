//
//  FontManagerNewN.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public class FontManagerNewN: NSObject {
    /// The selected font.
    @objc dynamic public var selectedFont: NSFont? {
        get { _selectedFont }
        set {
            guard newValue != selectedFont else { return }
            selectFont(newValue)
        }
    }
    
    var selectedFonts: [NSFont] = []
    
    /// The selected font size.
    @objc dynamic public var fontSize: CGFloat = 12 {
        didSet {
            guard oldValue != fontSize else { return }
            fontSize = fontSize.clamped(min: 0.5)
            fontSizeStepper?.doubleValue = fontSize
            fontSizeTextField?.doubleValue = fontSize
            if let index = fontSizePopUpButton?.items.firstIndex(where: {$0.title.doubleValues.contains(fontSize)}) {
                fontSizePopUpButton?.selectItem(at: index)
            }
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
    
    var targetIsFirstResonder: Bool = false {
        didSet {
            Swift.print("targetIsFirstResonder", targetIsFirstResonder)
        }
    }
    var _targetIsFirstResonder: Bool = false
    var targetWindowObserver: NSKeyValueObservation? = nil
    
    /**
     The target object that updates and receives the selected font.
     
     ``selectedFont`` reflects the font of the target. If the target changes it's font, ``selectedFont`` is updated, and viceversa.
     
     The target has to be either `NSTextView`, `NSTextField` or any `NSControl`.
     */
    public var target: AnyObject? {
        didSet {
            if let textView = target as? NSTextView {
                targetIsFirstResonder = textView.isFirstResponder
                targetWindowObserver = textView.observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    if let self = self, let new = new {
                        Swift.print("firstResponder", new != self.fontSizeTextField, new != self.fontSizeTextField?.currentEditor(), (new != self.fontSizeTextField && new != self.fontSizeTextField?.currentEditor()),  self.fontSizeTextField ?? "nil", new)
                    }
                    guard let self = self, (new != self.fontSizeTextField && new != self.fontSizeTextField?.currentEditor()) else { return }
                    self.targetIsFirstResonder = textView.isFirstResponder
                }
                updateSelectedFont(for: textView)
                targetFontObservation = NotificationCenter.default.observe(NSTextView.didChangeSelectionNotification, object: textView) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateSelectedFont(for: textView)
                    self.updateSegmentedTextViewAttributes()
                }
            } else if let control = target as? NSControl {
                targetIsFirstResonder = control.isFirstResponder
                targetWindowObserver = control.observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    if let self = self, let new = new {
                        Swift.print("firstResponder", new != self.fontSizeTextField, new != self.fontSizeTextField?.currentEditor(), (new != self.fontSizeTextField && new != self.fontSizeTextField?.currentEditor()),  self.fontSizeTextField ?? "nil", new)
                    }
                    guard let self = self, (new != self.fontSizeTextField && new != self.fontSizeTextField?.currentEditor()) else { return }
                    self.targetIsFirstResonder = control.isFirstResponder
                }
                selectedFont = control.font
                targetFontObservation = control.observeChanges(for: \.font) { [weak self] old, new in
                    guard let self = self, old != new else { return  }
                    self.selectedFont = new
                }
            } else {
                targetWindowObserver = nil
                target = nil
                targetFontObservation = nil
                selectedFont = nil
            }
            updateSegmented()
            updateSegmentedTextViewAttributes()
        }
    }
    
    var multipleFamiles: Bool {
        guard let textView = target as? NSTextView else { return false }
        return textView.selectionFonts.compactMap({$0.familyName}).uniqued().compactMap({ name in  availableFontFamilies.firstIndex(where: {$0.name == name }) }).count > 1
    }
    
    var multipleMembers: Bool {
        guard let textView = target as? NSTextView else { return false }
        let selectionFonts = textView.selectionFonts
        if selectionFonts.compactMap({$0.familyName}).uniqued().compactMap({ name in  availableFontFamilies.firstIndex(where: {$0.name == name }) }).count == 1 {
            return selectionFonts.compactMap({$0.fontName}).uniqued().count > 1
        }
        return false
    }
    
    func updateSelectedFont(for textView: NSTextView) {
        fontFamilyPopUpButton?.menu?.handlers.didClose = nil
        fontMemberPopUpButton?.menu?.handlers.didClose = nil
        var fonts = textView.selectionFonts
        if fonts.isEmpty, let font = textView.typingAttributes[.font] as? NSFont {
            fonts = [font]
        }
        if fonts.count == 1 {
           selectedFont = fonts.first
        } else if fonts.count > 1 {
            selectedFont = nil
            let familyIndexes = fonts.compactMap({$0.familyName}).uniqued().compactMap({ name in  availableFontFamilies.firstIndex(where: {$0.name == name }) })
            if familyIndexes.count == 1 {
                fontFamilyPopUpButton?.selectItem(at: familyIndexes.first!)
                let memberIndexes = fonts.compactMap({$0.fontName}).uniqued().compactMap({name in currentFontMembers.firstIndex(where: {$0.fontName == name }) })
                updateMembersPopUpButton(for: availableFontFamilies[familyIndexes.first!])
                if memberIndexes.count == 1 {
                    fontMemberPopUpButton?.selectItem(at: memberIndexes.first!)
                } else if memberIndexes.count > 1 {
                    fontMemberPopUpButton?.selectItem(at: memberIndexes.first!)
                    for index in memberIndexes {
                        fontMemberPopUpButton?.menu?.items[safe: index]?.state = .mixed
                    }
                    fontMemberPopUpButton?.textField?.stringValue = "Multiple"
                    fontMemberPopUpButton?.menu?.handlers.didClose = { [weak self] in
                        guard let self = self else { return }
                        if self.multipleMembers {
                            self.fontMemberPopUpButton?.textField?.stringValue = "Multiple"
                        }
                    }
                }
            } else if familyIndexes.count > 1 {
                for index in familyIndexes {
                    fontFamilyPopUpButton?.menu?.items[safe: index]?.state = .mixed
                }
                fontFamilyPopUpButton?.textField?.stringValue = "Multiple"
                fontFamilyPopUpButton?.menu?.handlers.didClose = { [weak self] in
                    guard let self = self else { return }
                    if self.multipleFamiles {
                        self.fontFamilyPopUpButton?.textField?.stringValue = "Multiple"
                    }
                }
            }
            let pointSizes = fonts.compactMap({$0.pointSize}).uniqued()
            if let pointSize = pointSizes.first {
                if pointSizes.count == 1 {
                    fontSizeTextField?.doubleValue = pointSize
                } else {
                    fontSizeTextField?.stringValue = ""
                    fontSizeTextField?.placeholderString = "\(pointSize)"
                }
            }
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
                if let textView = self.target as? NSTextView, textView.selectionFonts.count > 1 {
                  //  if self.multipleMembers
                } else {
                    self._currentMemberIndex = fontMemberPopUpButton.indexOfSelectedItem
                    self.updateSelectedFont()
                }
            }
            fontMemberPopUpButton.isEnabled = isEnabled
            updateMembersPopUpButton()
            fontMemberPopUpButton.selectItem(at: _currentMemberIndex)
            updatePopUpButtonFonts()
        }
    }
    
    var firstResponderObserver: NSKeyValueObservation? = nil
    func makeTargetFirstResponder() {
        guard _targetIsFirstResonder else { return }
        if let textView = target as? NSTextView {
            textView.window?.makeFirstResponder(textView)
            textView.selectedRanges = textView.selectedRanges
        } else if let textField = target as? NSTextField {
            textField.window?.makeFirstResponder(textField)
        }
    }
    
    /// The text field for changing the font size.
    public weak var fontSizeTextField: NSTextField? {
        didSet {
            guard oldValue != fontSizeTextField, let fontSizeTextField = fontSizeTextField else { return }
            fontSizeTextField.doubleValue = fontSize
         //   fontSizeTextField.editingHandlers
            fontSizeTextField.actionOnEnterKeyDown = .endEditing
            fontSizeTextField.actionOnEscapeKeyDown = .endEditingAndReset
            fontSizeTextField.editingHandlers.didBegin = { [weak self] in
                guard let self = self else { return }
                self._targetIsFirstResonder = self.targetIsFirstResonder
            }
            fontSizeTextField.editingHandlers.didEnd = { [weak self] in
                guard let self = self, let fontSizeTextField = self.fontSizeTextField else { return  }
                if let textView = self.target as? NSTextView, textView.selectionFonts.count > 1 {
                    textView.selectionFonts = textView.selectionFonts.compactMap({$0.withSize(fontSizeTextField.doubleValue)})
                } else {
                    self.fontSize = fontSizeTextField.doubleValue
                }
                Swift.print("fontSizeTextField end", self.targetIsFirstResonder)
                self.makeTargetFirstResponder()
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
    
    /// The popup button for changing the font size.
    public weak var fontSizePopUpButton: NSPopUpButton? {
        didSet {
            guard oldValue != fontSizePopUpButton, let fontSizePopUpButton = fontSizePopUpButton else { return }
            let index = fontSizePopUpButton.items.firstIndex(where: {$0.title.doubleValues.contains(fontSize)}) ?? 0
            fontSizePopUpButton.selectItem(at: index)
            fontSizePopUpButton.actionBlock = { [weak self] _ in
                guard let self = self, let fontSize = fontSizePopUpButton.titleOfSelectedItem?.doubleValues.first else { return }
                self.fontSize = fontSize
            }
            fontSizePopUpButton.isEnabled = isEnabled
            fontSizePopUpButton.isEnabled = isEnabled
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
                    NSSegment(symbolName: "underline")?.tag(33).isEnabled(target is NSTextView)
                    NSSegment(symbolName: "strikethrough")?.tag(44).isEnabled(target is NSTextView)
                } else {
                    NSSegment("B").font(.systemFont.bold).tag(11)
                    NSSegment("I").font(.systemFont.italic).tag(22)
                }
            }
            segmentedControl.sizeToFit()
            segmentedControl.actionBlock = { [weak self] segmentedControl in
                guard let self = self, let selectedFont = self.selectedFont else { return }
                switch segmentedControl.indexOfSelectedItem {
                case 0: self.isBold = self.boldSegment?.isSelected ?? false
                case 1: self.isItalic = self.italicSegment?.isSelected ?? false
                case 2: self.isUnderline = self.underlineSegment?.isSelected ?? false
                case 3: self.isStrikethrough = self.strikeSegment?.isSelected ?? false
                default: break
                }
            }
            updateSegmented()
            updateSegmentedTextViewAttributes()
        }
    }
    
    var boldSegment: NSSegment? {
        fontTraitsSegmentedControl?.segment(withTag: 11)
    }
    var italicSegment: NSSegment? {
        fontTraitsSegmentedControl?.segment(withTag: 22)
    }
    var underlineSegment: NSSegment? {
        fontTraitsSegmentedControl?.segment(withTag: 33)
    }
    var strikeSegment: NSSegment? {
        fontTraitsSegmentedControl?.segment(withTag: 44)
    }
    
    var isBold: Bool {
        get { selectedFont?.fontDescriptor.symbolicTraits.contains(.bold) ?? false }
        set {
            if newValue {
                selectedFont = selectedFont?.includingSymbolicTraits(.bold)
            } else {
                selectedFont = selectedFont?.withoutSymbolicTraits(.bold)
            }
        }
    }
    
    var isItalic: Bool {
        get { selectedFont?.fontDescriptor.symbolicTraits.contains(.italic) ?? false }
        set {
            if newValue {
                selectedFont = selectedFont?.includingSymbolicTraits(.italic)
            } else {
                selectedFont = selectedFont?.withoutSymbolicTraits(.italic)
            }
        }
    }
    
    var isStrikethrough: Bool {
        get {
            guard let textView = target as? NSTextView else { return false }
            return textView.typingIsStrikethrough || textView.selectionHasStrikethrough
        }
        set {
            guard let textView = target as? NSTextView else { return }
            textView.typingAttributes[.strikethroughStyle] = newValue ? 1 : 0
            guard let textStorage = textView.textStorage else { return }
            for range in textView.selectedRanges.compactMap({$0.rangeValue}) {
                textStorage.addAttribute(.strikethroughStyle, value: newValue ? 1 : 0, range: range)
            }
        }
    }
    
    var isUnderline: Bool {
        get {
            guard let textView = target as? NSTextView else { return false }
            return textView.typingIsUnderline || textView.selectionHasUnderline
        }
        set {
            guard let textView = target as? NSTextView else { return }
            textView.typingAttributes[.underlineStyle] = newValue ? 1 : 0
            guard let textStorage = textView.textStorage else { return }
            for range in textView.selectedRanges.compactMap({$0.rangeValue}) {
                textStorage.addAttribute(.underlineStyle, value: newValue ? 1 : 0, range: range)
            }
        }
    }
    
    func updateSegmented() {
        if let selectedFont = selectedFont {
            let traits = selectedFont.fontDescriptor.symbolicTraits
            boldSegment?.isSelected = traits.contains(.bold)
            italicSegment?.isSelected = traits.contains(.italic)
        } else {
            fontTraitsSegmentedControl?.deselectAll()
        }
    }
    
    func updateSegmentedTextViewAttributes() {
        guard let segmentedControl = fontTraitsSegmentedControl else { return }
        if let textView = target as? NSTextView {
            underlineSegment?.isEnabled(true).isSelected(isUnderline)
            strikeSegment?.isEnabled(true).isSelected(isStrikethrough)
        } else {
            underlineSegment?.isEnabled(false).isSelected(false)
            strikeSegment?.isEnabled(false).isSelected(false)
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
            fontSizePopUpButton?.isEnabled = isEnabled
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
        .userFont(ofSize: 12) ?? NSFont(name: "HelveticaNeue", size: 12) ?? .systemFont(ofSize: NSFont.systemFontSize)
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
        fontSizePopUpButton?.isEnabled = isEnabled
        fontSizeStepper?.isEnabled = isEnabled
        fontTraitsSegmentedControl?.isEnabled = isEnabled
    }
    
    func updateMembersPopUpButton(for fontFamily: NSFont.FontFamily? = nil) {
        let fontFamily = fontFamily ?? selectedFontFamily
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
            fontSizePopUpButton?.isEnabled = false
            fontSizeStepper?.isEnabled = false
            fontTraitsSegmentedControl?.isEnabled = false
        }
        fontSizeTextField?.placeholderString = nil
    }
    
    func updateSelectedFont() {
        guard let fontName = currentFontMembers[safe: currentMemberIndex]?.fontName, let font = NSFont(name: fontName, size: fontSize) else { return }
        fontSizeTextField?.doubleValue = font.pointSize
        if let index = fontSizePopUpButton?.items.firstIndex(where: {$0.title.doubleValues.contains(fontSize)}) {
            fontSizePopUpButton?.selectItem(at: index)
        }
        _selectedFont = font
    }
    
    func updateTargetFont() {
        guard let selectedFont = selectedFont else { return }
        if let textView = target as? NSTextView {
            if textView.selectionFonts.isEmpty {
                textView.typingAttributes[.font] = selectedFont
            } else {
                textView.selectionFonts = [selectedFont]
            }
        } else if let control = target as? NSControl {
            control.font = selectedFont
        }
    }
    
    var availableFontNames: [String] {
        availableFontFamilies.flatMap({$0.members.compactMap({$0.fontName})})
    }
}



#endif
