//
//  NSFontManager+.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSFontManager {
    /// The handler that gets called when the selected font changes.
    public var selectedFontHandler: ((NSFont?)->())? {
        get { getAssociatedValue(key: "selectedFontHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "selectedFontHandler", object: self)
            if newValue == nil {
                selectedFontTarget = nil
            } else if selectedFontTarget == nil {
                selectedFontTarget = SelectedFontTarget()
            }
        }
    }
    
    var selectedFontTarget: SelectedFontTarget? {
        get {getAssociatedValue(key: "selectedFontTarget", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "selectedFontTarget", object: self) }
    }
    
    class SelectedFontTarget: NSObject {
        var selectedFont: NSFont? = nil
        override init() {
            super.init()
            NSFontManager.shared.target = self
            NSFontManager.shared.action = #selector(changeFont(_:))
            selectedFont = NSFontManager.shared.selectedFont
        }
        
        @objc func changeFont(_ sender: NSFontManager?) {
            guard let fontManager = sender else { return }
            let newFont = fontManager.convert(.body)
            guard selectedFont != newFont else { return }
            selectedFont = newFont
            sender?.selectedFontHandler?(newFont)
            if let textView = NSApp.keyWindow?.firstResponder as? NSTextView, textView.usesFontPanel {
                textView.font = newFont
            }
        }
    }
}

#endif
