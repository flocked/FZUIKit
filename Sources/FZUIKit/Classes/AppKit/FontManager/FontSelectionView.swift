//
//  FontSelectionView.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

public class FontSelectionView: NSView, NSTextFieldDelegate, NSMenuDelegate {
    
    let familyPopUpButton = NSPopUpButton()
    let memberPopUpButton = NSPopUpButton()
    let fontSizeTextField = NSTextField(string: "")
    let fontSizeStepper = NSStepper()

    private var familyNames: [String] = []

    private var currentFamilyIndex: Int {
        get { familyPopUpButton.indexOfSelectedItem }
        set { familyPopUpButton.selectItem(at: newValue) }
    }
    
    private var currentMemberIndex: Int {
        get { memberPopUpButton.indexOfSelectedItem }
        set { memberPopUpButton.selectItem(at: newValue) }
    }
    
    private var localizedFamilyNames: [String] = []
    private var currentMembers: [String] = []
    
    static var defaultFont: NSFont {
        NSFont(name: "HelveticaNeue", size: 12) ?? .systemFont(ofSize: NSFont.systemFontSize)
    }

    let padding: CGFloat = 10
    static let minWidth: CGFloat = 120.0
    static let maxWidth: CGFloat = 240
    
    let specialFontNames: Set<String> = [
        "Bodoni Ornaments", "Webdings", "Wingdings", "Wingdings2", "Wingdings3"
    ]
    
    public var canSelectFontMembers: Bool = true {
        didSet { updateViews() } }
    
    public var canSelectFontSize: Bool = true {
        didSet { updateViews() } }
    
    public var fontSize: CGFloat {
        get { fontSizeStepper.doubleValue }
        set {
            guard newValue != fontSize else { return }
            fontSizeStepper.doubleValue = newValue
            fontSizeTextField.doubleValue = newValue
            updatedSelectedFont()
        }
    }
        
    public var maxFontSize: CGFloat = 500 {
        didSet {
            fontSizeStepper.maxValue = maxFontSize
            (fontSizeTextField.formatter as? NumberFormatter)?.maximum = NSNumber(maxFontSize)
            if fontSize > maxFontSize {
                fontSize = maxFontSize
            }
        }
    }
    
    public var isEnabled = true {
        didSet {
            familyPopUpButton.isEnabled = isEnabled
            memberPopUpButton.isEnabled = isEnabled
            fontSizeTextField.isEnabled = isEnabled
            fontSizeStepper.isEnabled = isEnabled
        }
    }
    
    public var selectedFontHandler: ((NSFont?)->())?
    
    public var selectedFont: NSFont? {
        get { _selectedFont }
        set {
            guard newValue != selectedFont else { return }
            selectFont(newValue)
        }
    }
    var _selectedFont: NSFont? = .systemFont(ofSize: NSFont.systemFontSize) {
        didSet {
            guard oldValue != _selectedFont else { return }
            selectedFontHandler?(_selectedFont)
         //   _selectedFont!.fontDescriptor.symbolicTraits.contains(.)
            Swift.print("selectedFont", _selectedFont ?? "nil")
        }
    }

    public init() {
        super.init(frame: CGRect(0, 0, Self.minWidth + 20, 100))
        sharedInit()
    }
    
    public init(font: NSFont) {
        super.init(frame: CGRect(0, 0, Self.minWidth + 20, 100))
        sharedInit(font)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    public func updateViews() {
        var yValue = padding
        
        if canSelectFontSize {
            fontSizeTextField.frame.size.width = 36
            fontSizeTextField.frame.origin = CGPoint(x: padding, y: yValue)
            addSubview(fontSizeTextField)
           
            fontSizeStepper.frame.origin = CGPoint(x: 50, y: yValue-4)
            fontSizeStepper.frame.left = fontSizeTextField.frame.right + 3

            addSubview(fontSizeStepper)
            yValue = yValue + fontSizeTextField.frame.height + 4
        } else {
            fontSizeTextField.removeFromSuperview()
            fontSizeStepper.removeFromSuperview()
        }
        
        if canSelectFontMembers {
            memberPopUpButton.frame.origin = CGPoint(padding, yValue)
            addSubview(memberPopUpButton)
            yValue = yValue + memberPopUpButton.bounds.height + 4
        } else {
            memberPopUpButton.removeFromSuperview()
        }
        
        familyPopUpButton.frame.size.width = frame.width - (2 * padding)
        familyPopUpButton.frame.origin = CGPoint(padding, yValue)
    }
        
    lazy var observer = KeyValueObserver(familyPopUpButton)
    public func sharedInit(_ font: NSFont? = nil) {
        observer.add(\.selectedItem) { old, new in
            guard old != new else { return }
            Swift.print("selectedItem", new ?? "nil")
        }
        observer.add(\.indexOfSelectedItem) { old, new in
            guard old != new else { return }
            Swift.print("indexOfSelectedItem", new)
        }
        observer.add(\.titleOfSelectedItem) { old, new in
            guard old != new else { return }
            Swift.print("titleOfSelectedItem", new)
        }
        
        familyPopUpButton.actionBlock = { [weak self] _ in
            guard let self = self else { return }
            self.updateMembers()
            self.updatedSelectedFont()
        }
        
        memberPopUpButton.actionBlock = { [weak self] _ in
            guard let self = self else { return }
            self.updatedSelectedFont()
        }
        
        fontSizeTextField.actionOnEnterKeyDown = .endEditing
        fontSizeTextField.actionOnEscapeKeyDown = .endEditingAndReset
                
        fontSizeTextField.translatesAutoresizingMaskIntoConstraints = false
        fontSizeTextField.isSelectable = true
        fontSizeTextField.isEditable = true
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximum = NSNumber(maxFontSize)
        fontSizeTextField.formatter = formatter
        fontSizeTextField.delegate = self
        
        fontSizeStepper.maxValue = maxFontSize
        fontSizeStepper.isEnabled = true
        fontSizeStepper.actionBlock = { [weak self] _ in
            guard let self = self else { return }
            self.fontSizeTextField.integerValue = self.fontSizeStepper.integerValue
            self.updatedSelectedFont()
        }
        
        memberPopUpButton.translatesAutoresizingMaskIntoConstraints = false
        memberPopUpButton.sizeToFit()
        memberPopUpButton.frame.origin.x = padding

        familyPopUpButton.translatesAutoresizingMaskIntoConstraints = false
        familyPopUpButton.sizeToFit()
        addSubview(familyPopUpButton)
        
        updateViews()
        updateFontFamilies()
        
        selectFont(Self.defaultFont)
        
        if let font = font {
            selectFont(font)
        }

     //   backgroundColor = .controlAccentColor.withAlphaComponent(0.3)
    }
    
    public override var fittingSize: NSSize {
        return CGSize(Self.minWidth + (2*padding), 100)
    }
        
    public override func layout() {
        super.layout()
        let width = (frame.width - (2 * padding)).clamped(to: Self.minWidth...Self.maxWidth)
        familyPopUpButton.frame.size.width = width
        memberPopUpButton.frame.size.width = (width - 70).clamped(to: Self.minWidth...Self.maxWidth)
        //   familyPopUpButton.frame.size.width = 80
           //   memberPopUpButton.frame.size.width = 70
    }
            
    var fontFamilies: [FontFamily] = []

    func updateFontFamilies() {
        familyPopUpButton.removeAllItems()
        familyNames = NSFontManager.shared.availableFontFamilies
             
        fontFamilies.removeAll()

        /*
        for name in NSFontManager.shared.availableFontFamilies {
            guard var font = NSFont(name: name, size: NSFont.systemFontSize) else {
                return
            }
            
            let fontFamily = FontFamily(name)
            fontFamilies.append(fontFamily)
            
            if specialFontNames.contains(name) {
                font = adjustFont(Self.defaultFont, string: fontFamily.localizedName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(font, string: fontFamily.localizedName, height: popUpButtonItemHeight)
            }
            let itemView = FontMenuItemView(font: font, title: fontFamily.localizedName)
            menuItemViews.append(itemView)

            let item = NSMenuItem(fontFamily.localizedName)
            item.view = itemView
            familyPopUpButton.menu?.addItem(item)
        }
         */
        
        familyNames.forEach {
            guard var font = NSFont(name: $0, size: NSFont.systemFontSize) else {
                return
            }
            let locName = NSFontManager.shared.localizedName(forFamily: $0, face: nil)
            localizedFamilyNames.append(locName)

            if specialFontNames.contains($0) {
                font = adjustFont(NSFont.systemFont(ofSize: NSFont.systemFontSize), string: locName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(font, string: locName, height: popUpButtonItemHeight)
            }
            
            let itemView = FontMenuItemView(font: font, title: locName)

            let item = NSMenuItem(locName)
            item.tag = UUID().hashValue
            item.view = itemView
            item.representedObject = $0
            familyPopUpButton.menu?.addItem(item)
        }
    }
    
    let popUpButtonItemHeight: CGFloat = 28
    
    var selectedFontFamily: FontFamily? {
        fontFamilies[safe: currentFamilyIndex]
    }
    
    var selectedFontFamilyName: String? {
        familyNames[safe: currentFamilyIndex]
    }
    
    private func updateMembers() {
        guard let familyName = selectedFontFamilyName, let members =  NSFontManager.shared.availableMembers(ofFontFamily: familyName) else {
            memberPopUpButton.removeAllItems()
            memberPopUpButton.isEnabled = false
            currentMembers.removeAll()
            return
        }
        
        let isSpecial = specialFontNames.contains(familyName)

        memberPopUpButton.removeAllItems()
        memberPopUpButton.isEnabled = true
        currentMembers.removeAll()
        
        members.forEach {
            let fontName = $0[0] as! String
            var faceName = $0[1] as! String
            faceName = NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
            currentMembers.append(fontName)

            let font: NSFont
            if isSpecial {
                font = adjustFont(NSFont.systemFont(ofSize: NSFont.systemFontSize), string: fontName, height: popUpButtonItemHeight)
            } else {
                font = adjustFont(NSFont(name: fontName, size: NSFont.systemFontSize)!, string: faceName, height: popUpButtonItemHeight)
            }

            let itemView = FontMenuItemView(font: font, title: faceName)
            let item = NSMenuItem(faceName)
            item.tag = UUID().hashValue
            item.view = itemView
            item.representedObject = fontName
            memberPopUpButton.menu?.addItem(item)
        }
        
        if memberPopUpButton.numberOfItems > 0 {
            currentMemberIndex = 0
        }
    }
    
    /*
     func sized(toFit text: String, height: CGFloat) -> NSFont {
         let font = withSize(1)
         var textSize = text.size(withAttributes: [.font: font])
         var newPointSize = font.pointSize

         while textSize.height < height {
             newPointSize += 1
             let newFont = NSFont(name: font.fontName, size: newPointSize)!
             textSize = text.size(withAttributes: [.font: newFont])
         }
         return withSize(newPointSize)
     }
     */
    
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
        guard let font = font else {
            currentFamilyIndex = -1
            memberPopUpButton.menu?.removeAllItems()
            currentMembers.removeAll()
            _selectedFont = nil
            return
        }
        guard let familyName = font.familyName, let index = familyNames.firstIndex(of: familyName) else {
            return
        }
        currentFamilyIndex = index
        updateMembers()
        let name = font.fontName
        if let index = currentMembers.firstIndex(of: name) {
            currentMemberIndex = index
        }
        fontSizeTextField.doubleValue = font.pointSize
        fontSizeStepper.doubleValue = font.pointSize
        updatedSelectedFont()
    }

    func updatedSelectedFont() {
        guard let member = currentMembers[safe: memberPopUpButton.indexOfSelectedItem], let font = NSFont(name: member, size: fontSizeStepper.doubleValue) else { return  }
            _selectedFont = font
    }
        
    public func controlTextDidEndEditing(_ obj: Notification) {
        fontSize = fontSizeTextField.doubleValue
//        window?.makeFirstResponder(self)
    }

}

extension FontSelectionView {
    public struct FontFamily {
        public let name: String
        public let localizedName: String
                
        public lazy var members: [FontMember] = {
            guard let members =  NSFontManager.shared.availableMembers(ofFontFamily: name) else { return [] }
            return members.compactMap({FontMember($0, name)})
        }()
        
        init(_ name: String) {
            self.name = name
            self.localizedName = NSFontManager.shared.localizedName(forFamily: name, face: nil)
        }
    }
    
    public struct FontMember {
          public let name: String
          public let familyName: String
          public var localizedFamilyName: String? {
              let name = NSFontManager.shared.localizedName(forFamily: familyName, face: nil)
              return name != familyName ? name : nil
          }
          public let faceName: String
          public var localizedFaceName: String? {
              let name = NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
              return name != faceName ? name : nil
          }
          public let weight: CGFloat
          public let traits: NSFontDescriptor.SymbolicTraits
          
          public func font(size: CGFloat = NSFont.systemFontSize) -> NSFont? {
              NSFont(name: name, size: size)
          }
          
          init?(_ value: [Any], _ familyName: String) {
              guard let name = value[safe: 0] as? String, let faceName = value[safe: 1] as? String, let weight = value[safe: 2] as? CGFloat, let traits = value[safe: 3] as? UInt32 else {
                  return nil
              }
              self.name = name
              self.faceName = faceName
              self.familyName = familyName
              self.traits = .init(rawValue: traits)
              self.weight = weight
          }
      }
}
#endif
