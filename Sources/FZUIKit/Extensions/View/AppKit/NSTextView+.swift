//
//  NSTextView+.swift
//
//  Parts taken from:
//  Taken from: https://github.com/boinx/BXUIKit
//  Copyright ©2017-2018 Peter Baumgartner. All rights reserved.
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

    import AppKit
import FZSwiftUtils

    extension NSTextView {
        /// The attributed string.
        public var attributedString: NSAttributedString! {
            set {
                let len = textStorage?.length ?? 0
                let range = NSRange(location: 0, length: len)
                textStorage?.replaceCharacters(in: range, with: newValue)
            }
            get { textStorage?.copy() as? NSAttributedString }
        }
        
        /// The ranges of characters selected in the text view.
        public var selectedStringRanges: [Range<String.Index>] {
            get { selectedRanges.compactMap({$0.rangeValue}).compactMap({ Range($0, in: string) }) }
            set { selectedRanges = newValue.compactMap({NSRange($0, in: string).nsValue}) }
        }
        
        /// The fonts of the selected text.
        public var selectionFonts: [NSFont] {
            get {
                guard let textStorage = textStorage else { return [] }
                var fonts: [NSFont] = []
                for range in selectedRanges.compactMap({$0.rangeValue}) {
                    textStorage.enumerateAttribute(.font, in: range, using: { font, range, fu in
                        if let font = font as? NSFont {
                            fonts.append(font)
                        }
                    })
                }
                return fonts
            }
            set {
                guard let font = newValue.first, let textStorage = textStorage else { return }
                for range in selectedRanges.compactMap({$0.rangeValue}) {
                    textStorage.addAttribute(.font, value: font, range: range)
                }
            }
        }
        
        /// Deselects all text.
        public func deselectAll() {
            selectedStringRanges = []
        }
        
        /// Selects all text.
        public func selectAll() {
            select(string)
        }
        
        /// Selects the specified string.
        public func select(_ string: String) {
            guard let range = string.range(of: string), !selectedStringRanges.contains(range) else { return }
            selectedStringRanges.append(range)
        }
        
        /// Selects the specified range.
        public func select(_ range: Range<String.Index>) {
            guard !selectedStringRanges.contains(range) else { return }
            selectedStringRanges.append(range)
        }
        
        /// Selects the specified range.
        public func select(_ range: ClosedRange<String.Index>) {
            select(range.lowerBound..<range.upperBound)
        }
        
        var _delegate: TextViewDelegate? {
            get { getAssociatedValue(key: "_delegate", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "_delegate", object: self) }
        }
        
        /// A Boolean value that indicates whether the button is enabled.
        public var changeFontAutomaticallyViaFontPanel: Bool {
            get {getAssociatedValue(key: "changeFontAutomaticallyViaFontPanel", object: self, initialValue: false) }
            set {
                guard changeFontAutomaticallyViaFontPanel != newValue else { return }
                set(associatedValue: newValue, key: "changeFontAutomaticallyViaFontPanel", object: self)
                if newValue {
                    NSFontPanel.shared.setupFontPanelTarget()
                }
            }
        }
        
        /// A Boolean value that indicates whether the text view should stop editing when the user clicks outside the text view.
        public var endEditingOnOutsideMouseDown: Bool {
            get { getAssociatedValue(key: "endEditingOnOutsideMouseDown", object: self, initialValue: false) }
            set {
                guard newValue != endEditingOnOutsideMouseDown else { return }
                set(associatedValue: newValue, key: "endEditingOnOutsideMouseDown", object: self)
                setupMouseMonitor()
            }
        }
        
        var mouseDownMonitor: NSEvent.Monitor? {
            get { getAssociatedValue(key: "mouseDownMonitor", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "mouseDownMonitor", object: self) }
        }

        func setupMouseMonitor() {
            if endEditingOnOutsideMouseDown {
                if mouseDownMonitor == nil {
                    mouseDownMonitor = NSEvent.localMonitor(for: .leftMouseDown) { [weak self] event in
                        guard let self = self, self.endEditingOnOutsideMouseDown, self.isFirstResponder else { return event }
                        if self.bounds.contains(event.location(in: self)) == false {
                            self.resignFirstResponder()
                        }
                        return event
                    }
                }
            } else {
                mouseDownMonitor = nil
            }
        }
        
        /// The action to perform when the user presses the escape key.
        public enum EscapeKeyAction {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            /// Ends editing the text and resets it to the the state before editing.
            case endEditingAndReset
            
            var needsSwizzling: Bool {
                switch self {
                case .none: return false
                default: return true
                }
            }
        }

        /// The action to perform when the user presses the enter key.
        public enum EnterKeyAction {
            /// No action.
            case none
            /// Ends editing the text.
            case endEditing
            
            var needsSwizzling: Bool {
                switch self {
                case .none: return false
                case .endEditing: return true
                }
            }
        }
        
        /// The action to perform when the user presses the enter key.
        public var actionOnEnterKeyDown: EnterKeyAction {
            get { getAssociatedValue(key: "actionOnEnterKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEnterKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEnterKeyDown", object: self)
                swizzleTextView()
            }
        }

        /// The action to perform when the user presses the escape key.
        public var actionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue(key: "actionOnEscapeKeyDown", object: self, initialValue: .none) }
            set {
                guard actionOnEscapeKeyDown != newValue else { return }
                set(associatedValue: newValue, key: "actionOnEscapeKeyDown", object: self)
                swizzleTextView()
            }
        }
        
        var needsSwizzling: Bool {
            actionOnEscapeKeyDown.needsSwizzling || actionOnEnterKeyDown.needsSwizzling
        }
        
        func swizzleTextView() {
            if needsSwizzling {
                if _delegate == nil {
                    _delegate = TextViewDelegate(self)
                }
            } else {
                _delegate = nil
            }
        }
        
        class TextViewDelegate: NSObject, NSTextViewDelegate {
            var string: String
            
            func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
                switch commandSelector {
                case #selector(NSControl.cancelOperation(_:)):
                    switch textView.actionOnEscapeKeyDown {
                    case .endEditingAndReset:
                        textView.string = string
                        textView.resignFirstResponder()
                        return true
                    case .endEditing:
                        textView.resignFirstResponder()
                    case .none:
                        break
                    }
                case #selector(NSControl.insertNewline(_:)):
                    switch textView.actionOnEnterKeyDown {
                    case .endEditing:
                        textView.resignFirstResponder()
                    case .none: break
                    }
                default: break
                }
                return true
            }
            
            func textDidBeginEditing(_ notification: Notification) {
                string = (notification.object as? NSText)?.string ?? ""
            }
            
            func textDidChange(_ notification: Notification) {
                
            }
            
            func textDidEndEditing(_ notification: Notification) {
                
            }
            
            init(_ textView: NSTextView) {
                self.string = textView.string
                super.init()
                textView.delegate = self
            }
        }
    }

#endif
