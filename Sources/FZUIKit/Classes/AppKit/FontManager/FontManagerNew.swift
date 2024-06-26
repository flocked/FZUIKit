//
//  FontManagerNew.swift
//
//
//  Created by Florian Zand on 02.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

class FontManagerNew {
    var fontFamilyIndex = -1 {
        didSet {
            guard oldValue != fontFamilyIndex else { return }
            fontFamilyPopUpButton?.menu?.items.forEach({$0.state = .off})
            fontFamilyPopUpButton?.selectItem(at: fontFamilyIndex)
            fontMemberIndex = -1
            updateMemberButton()
        }
    }
    var fontMemberIndex = -1 {
        didSet {
            guard oldValue != fontMemberIndex else { return }
            fontMemberPopUpButton?.selectItem(at: fontMemberIndex)
        }
    }
    
    public internal(set) var availableFontFamilies = NSFont.availableFontFamilies
    
    public var selectedFontFamily: NSFont.FontFamily? {
        availableFontFamilies[safe: fontFamilyIndex]
    }
    
    var currentFontMembers: [NSFont.FontMember] {
        selectedFontFamily?.members ?? []
    }
    
    public var selectedFont: NSFont? {
        get { _selectedFont }
        set {
            guard newValue != selectedFont else { return }
            selectFont(newValue)
        }
    }
    
    var _selectedFont: NSFont?
    
    public var fontSize: CGFloat = 12
    
    func selectFont(_ newFont: NSFont?) {
        if let newFont = newFont, let familyIndex = availableFontFamilies.firstIndex(where: {$0.name == newFont.familyName}) {
            fontFamilyIndex = familyIndex
            fontMemberIndex = currentFontMembers.firstIndex(where: {$0.fontName == newFont.fontName}) ?? 0
            fontSize = newFont.pointSize
        } else {
            fontFamilyIndex = -1
            fontMemberIndex = -1
        }
    }
    
    public var isEnabled: Bool = true
    public var showsFontAppearanceWhenSelecting: Bool = true
    
    func updateSelectedFont(for textView: NSTextView) {
        fontFamilyPopUpButton?.menu?.handlers = .init()
        fontMemberPopUpButton?.menu?.handlers = .init()
        var fonts = textView.selectionFonts
        if fonts.isEmpty, let font = textView.typingAttributes[.font] as? NSFont {
            fonts = [font]
        }
        if fonts.count == 1 {
           selectedFont = fonts.first
        } else if fonts.count > 1 {
            selectedFont = nil
            let familyIndexes = fonts.compactMap({$0.familyName}).uniqued().compactMap({ name in availableFontFamilies.firstIndex(where: {$0.name == name }) }).sorted()
            if familyIndexes.count == 1 {
                fontFamilyIndex = familyIndexes.first!
                if let fontMemberPopUpButton = fontMemberPopUpButton {
                    let memberIndexes = fonts.compactMap({$0.fontName}).uniqued().compactMap({name in currentFontMembers.firstIndex(where: {$0.fontName == name }) }).sorted()
                    if memberIndexes.count == 1 {
                        fontMemberIndex = memberIndexes.first!
                    } else if memberIndexes.count > 1 {
                        setupMultipleItem(for: fontMemberPopUpButton, indexes: memberIndexes)
                    }
                }
            } else if familyIndexes.count > 1, let fontFamilyPopUpButton = fontFamilyPopUpButton {
                setupMultipleItem(for: fontFamilyPopUpButton, indexes: familyIndexes)
            }
            let pointSizes = fonts.compactMap({$0.pointSize}).uniqued()
            if let pointSize = pointSizes.first {
                fontSizeTextField?.isEnabled = true
                if pointSizes.count == 1 {
                    fontSizeTextField?.doubleValue = pointSize
                } else {
                    fontSizeTextField?.stringValue = ""
                    fontSizeTextField?.placeholderString = "\(pointSize)"
                }
            }
        }
    }
    
    func setupMultipleItem(for popUpButton: NSPopUpButton, indexes: [Int]) {
        if let item = popUpButton.item(at: indexes.first!) {
            item.representedObject(item.title).tag(555).title("Multiple")
            popUpButton.selectItem(withTag: 555)
            popUpButton.menu?.handlers.willOpen = {
                if let item = popUpButton.item(withTag: 555), let title = item.representedObject as? String {
                    item.title = title
                }
            }
            popUpButton.menu?.handlers.didClose = {
                popUpButton.item(withTag: 555)?.title = "Multiple"
            }
        }
        for index in indexes {
            popUpButton.menu?.items[safe: index]?.state = .mixed
        }
    }
    
    func updateFamiliesButton() {
        guard let fontFamilyPopUpButton = fontFamilyPopUpButton else { return }
        fontFamilyPopUpButton.removeAllItems()
        for family in availableFontFamilies {
            guard let font = family.font() else { return }
            let item = NSMenuItem(family.localizedName)
            if showsFontAppearanceWhenSelecting {
                item.view = FontMenuItemView(font: font, title: family.localizedName)
            }
            fontFamilyPopUpButton.menu?.addItem(item)
        }
        fontFamilyPopUpButton.selectItem(at: fontFamilyIndex)
    }
    
    func updateMemberButton() {
        guard let fontMemberPopUpButton = fontMemberPopUpButton else { return }
        fontMemberPopUpButton.removeAllItems()
        fontMemberPopUpButton.isEnabled = isEnabled
        for member in currentFontMembers {
            guard let font = member.font() else { return }
            let item = NSMenuItem(member.localizedFaceName)
            if showsFontAppearanceWhenSelecting {
                item.view = FontMenuItemView(font: font, title: member.localizedFaceName)
            }
            fontMemberPopUpButton.menu?.addItem(item)
        }
        fontMemberPopUpButton.selectItem(at: fontMemberIndex)
    }
    
    public weak var fontFamilyPopUpButton: NSPopUpButton?
    public weak var fontMemberPopUpButton: NSPopUpButton?
    public weak var fontSizeTextField: NSTextField?
    public weak var fontSizePopUpButton: NSPopUpButton?
    public weak var fontSizeStepper: NSStepper?
}
#endif
