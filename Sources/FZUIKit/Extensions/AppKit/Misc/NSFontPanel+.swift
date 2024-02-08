//
//  NSFontPanel+.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSFontPanel {
    /// The handler that gets called when the selected font changes.
    public var selectedFontHandler: ((NSFont?)->())? {
        get { getAssociatedValue(key: "selectedFontHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "selectedFontHandler", object: self)
            if newValue != nil {
                setupFontPanelTarget()
            }
        }
    }
    
    func setupFontPanelTarget() {
        fontPanelTarget = FontPanelTarget(self)
    }
    
    /// The currently selected font.
    public var selectedFont: NSFont? {
        NSFontManager.shared.convert(.body)
    }
    
    var fontPanelTarget: FontPanelTarget? {
        get {getAssociatedValue(key: "fontPanelTarget", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "fontPanelTarget", object: self) }
    }
    
    class FontPanelTarget: NSObject, NSFontChanging {
        weak var fontPanel: NSFontPanel!
        init(_ fontPanel: NSFontPanel?) {
            self.fontPanel = fontPanel
            super.init()
            NSFontManager.shared.target = self
        }
        
        func changeFont(_ sender: NSFontManager?) {
            guard let fontManager = sender else { return }
            if let textView = NSApp.keyWindow?.firstResponder as? NSTextView, textView.changeFontAutomaticallyViaFontPanel {
                let newFont = fontManager.convert(textView.font ?? .body)
                textView.font = newFont
            }
            let newFont = fontManager.convert(.body)
            self.fontPanel.selectedFontHandler?(newFont)
        }
    }
}

#endif
