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
        /// Handlers for editing the text of a text view.
        public struct EditingHandler {
            /// Handler that gets called whenever editing the text did begin.
            public var didBegin: (() -> Void)?
            
            /// Handler that determines whether the text should change. If you provide ``AppKit/NSTextField/minimumNumberOfCharacters``, ``AppKit/NSTextField/maximumNumberOfCharacters`` or ``AppKit/NSTextField/allowedCharacters-swift.property`` the handler is called after checking the string against the specified property conditions.
            public var shouldEdit: ((String) -> (Bool))?
            
            /// Handler that gets called whenever the text did change.
            public var didEdit: (() -> Void)?
            
            /// Handler that gets called whenever editing the text did end.
            public var didEnd: (() -> Void)?
            
            var needsObservation: Bool {
                didBegin != nil || shouldEdit != nil || didEdit != nil || didEnd != nil
            }
        }
        
        /// The handlers for editing the text.
        public var editingHandlers: EditingHandler {
            get { getAssociatedValue("editingHandlers", initialValue: EditingHandler()) }
            set {
                setAssociatedValue(newValue, key: "editingHandlers")
                observeEditing()
            }
        }
        
        var editingNotificationTokens: [NotificationToken] {
            get { getAssociatedValue("editingNotificationTokens", initialValue: []) }
            set { setAssociatedValue(newValue, key: "editingNotificationTokens") }
        }
        
        var previousString: String {
            get { getAssociatedValue("previousString", initialValue: string) }
            set { setAssociatedValue(newValue, key: "previousString") }
        }
        
        func observeEditing() {
            if editingHandlers.needsObservation {
                previousString = string
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidBeginEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.previousString = self.string
                    self.editingHandlers.didBegin?()
                })
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidChangeNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    if let shouldEdit = editingHandlers.shouldEdit {
                        if shouldEdit(self.string) {
                            self.previousString = string
                        } else {
                            self.string = self.previousString
                        }
                    }
                    self.editingHandlers.didEdit?()
                })
                editingNotificationTokens.append(NotificationCenter.default.observe(NSTextField.textDidEndEditingNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    self.editingHandlers.didEnd?()
                })
            } else {
                editingNotificationTokens = []
            }
        }
        
        /// Creates a text view with an enclosing scroll view.
        public static func scrolling() -> NSTextView {
            let textView = NSTextView()
            textView.addEnclosingScrollView()
            return textView
        }
        
        /// Sets the Boolean value that indicates whether the text view draws its background.
        @discardableResult
        public func drawsBackground(_ draws: Bool) -> Self {
            drawsBackground = draws
            return self
        }
        
        /// Sets the text view’s background color.
        @discardableResult
        public func backgroundColor(_ color: NSColor?) -> Self {
            backgroundColor = color ?? .clear
            drawsBackground = color != nil
            return self
        }
        
        /// Sets the text.
        @discardableResult
        public func string(_ string: String) -> Self {
            self.string = string
            return self
        }
        
        /// Sets the delegate for all text views sharing the receiver’s layout manager.
        @discardableResult
        public func delegate(_ delegate: NSTextViewDelegate?) -> Self {
            self.delegate = delegate
            return self
        }
        
        /// Sets the empty space the receiver leaves around its associated text container.
        @discardableResult
        public func textContainerInset(_ inset: CGSize) -> Self {
            self.textContainerInset = inset
            return self
        }
        
        /// Sets the Boolean value that indicates whether the receiver allows its background color to change.
        @discardableResult
        public func allowsDocumentBackgroundColorChange(_ allows: Bool) -> Self {
            self.allowsDocumentBackgroundColorChange = allows
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager allow the user to edit text.
        @discardableResult
        public func isEditable(_ isEditable: Bool) -> Self {
            self.isEditable = isEditable
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager allow the user to select text.
        @discardableResult
        public func isSelectable(_ isSelectable: Bool) -> Self {
            self.isSelectable = isSelectable
            return self
        }
        
        /// Sets the Boolean value that indicates whether the receiver allows undo.
        @discardableResult
        public func allowsUndo(_ allows: Bool) -> Self {
            self.allowsUndo = allows
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager allow the user to apply attributes to specific ranges of text.
        @discardableResult
        public func isRichText(_ isRichText: Bool) -> Self {
            self.isRichText = isRichText
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager allow the user to import files by dragging.
        @discardableResult
        public func importsGraphics(_ importsGraphics: Bool) -> Self {
            self.importsGraphics = importsGraphics
            return self
        }
        
        /// Sets the Boolean value that indicates whether image attachments should permit editing of their images.
        @discardableResult
        public func allowsImageEditing(_ allows: Bool) -> Self {
            self.allowsImageEditing = allows
            return self
        }
        
        /// Sets the Boolean value that enables and disables automatic quotation mark substitution.
        @discardableResult
        public func isAutomaticQuoteSubstitutionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticQuoteSubstitutionEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that enables or disables automatic link detection.
        @discardableResult
        public func isAutomaticLinkDetectionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticLinkDetectionEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that indicates whether the text view supplies autocompletion suggestions as the user types.
        @discardableResult
        public func isAutomaticTextCompletionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticTextCompletionEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that indicates whether automatic text replacement is enabled.
        @discardableResult
        public func isAutomaticTextReplacementEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticTextReplacementEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that indicates whether automatic spelling correction is enabled.
        @discardableResult
        public func isAutomaticSpellingCorrectionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticSpellingCorrectionEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that indicates whether automatic data detection is enabled.
        @discardableResult
        public func isAutomaticDashSubstitutionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticDashSubstitutionEnabled = enabled
            return self
        }
        
        /// Sets the Boolean value that indicates whether automatic text replacement is enabled.
        @discardableResult
        public func isAutomaticDataDetectionEnabled(_ enabled: Bool) -> Self {
            self.isAutomaticDataDetectionEnabled = enabled
            return self
        }
                
        /// Sets the Boolean value that indicates whether the text view automatically supplies the destination of a link as a tooltip for text that has a link attribute.
        @discardableResult
        public func displaysLinkToolTips(_ displays: Bool) -> Self {
            self.displaysLinkToolTips = displays
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager use a ruler.
        @discardableResult
        public func usesRuler(_ usesRuler: Bool) -> Self {
            self.usesRuler = usesRuler
            return self
        }
        
        /// Sets the Boolean value that controls whether the scroll view enclosing text views sharing the receiver’s layout manager displays the ruler.
        @discardableResult
        public func isRulerVisible(_ isRulerVisible: Bool) -> Self {
            self.isRulerVisible = isRulerVisible
            return self
        }
        
        /// Sets the Boolean value that indicates whether this text view uses the inspector bar.
        @discardableResult
        public func usesInspectorBar(_ usesInspectorBar: Bool) -> Self {
            self.usesInspectorBar = usesInspectorBar
            return self
        }
        
        /// Sets the Boolean value that controls whether the text views sharing the receiver’s layout manager use the Font panel and Font menu.
        @discardableResult
        public func usesFontPanel(_ usesFontPanel: Bool) -> Self {
            self.usesFontPanel = usesFontPanel
            return self
        }
        
        /// Sets the Boolean value that indicates whether to use a rollover button for selecton.
        @discardableResult
        public func usesRolloverButtonForSelection(_ uses: Bool) -> Self {
            self.usesRolloverButtonForSelection = uses
            return self
        }
        
        
        /// Sets the Boolean value that indicates whether the receiver allows for a find panel.
        @discardableResult
        public func usesFindPanel(_ usesFindPanel: Bool) -> Self {
            self.usesFindPanel = usesFindPanel
            return self
        }
                
                
        /// The attributed string.
        public var attributedString: NSAttributedString! {
            set {
                let len = textStorage?.length ?? 0
                let range = NSRange(location: 0, length: len)
                textStorage?.replaceCharacters(in: range, with: newValue)
            }
            get { textStorage?.copy() as? NSAttributedString }
        }
        
        /// Sets the attributed text.
        @discardableResult
        public func attributedString(_ attributedString: NSAttributedString) -> Self {
            self.attributedString = attributedString
            return self
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
                guard let textStorage = textStorage else { return }
                for (index, range) in selectedRanges.compactMap({$0.rangeValue}).enumerated() {
                    if let font = newValue[safe: index] ?? newValue.last {
                        textStorage.addAttribute(.font, value: font, range: range)
                    }
                }
            }
        }
        
        var selectionHasStrikethrough: Bool {
            guard let textStorage = textStorage else { return false }
            var selectionHasStrikethrough = false
            for range in selectedRanges.compactMap({$0.rangeValue}) {
                textStorage.enumerateAttribute(.strikethroughStyle, in: range, using: { strikethrough, range, fu in
                    if let strikethrough = strikethrough as? Int, strikethrough != 0 {
                        selectionHasStrikethrough = true
                    }
                })
            }
            return selectionHasStrikethrough
        }
        
        var selectionHasUnderline: Bool {
            guard let textStorage = textStorage else { return false }
            var selectionHasUnderline = false
            for range in selectedRanges.compactMap({$0.rangeValue}) {
                textStorage.enumerateAttribute(.underlineStyle, in: range, using: { underline, range, fu in
                    if let underline = underline as? Int, underline != 0 {
                        selectionHasUnderline = true
                    }
                })
            }
            return selectionHasUnderline
        }
        
        var typingIsUnderline: Bool {
            if let underline = typingAttributes[.underlineStyle] as? Int, underline != 0 {
                return true
            }
            return false
        }
        
        var typingIsStrikethrough: Bool {
            if let underline = typingAttributes[.strikethroughStyle] as? Int, underline != 0 {
                return true
            }
            return false
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
            get { getAssociatedValue("_delegate") }
            set { setAssociatedValue(newValue, key: "_delegate") }
        }
        
        /// A Boolean value that indicates whether the text view should stop editing when the user clicks outside the text view.
        public var endsEditingOnOutsideClick: Bool {
            get { getAssociatedValue("endsEditingOnOutsideClick", initialValue: false) }
            set {
                guard newValue != endsEditingOnOutsideClick else { return }
                setAssociatedValue(newValue, key: "endsEditingOnOutsideClick")
                setupMouseMonitor()
            }
        }
        
        /// Sets the Boolean value that indicates whether the text view should stop editing when the user clicks outside the text view.
        @discardableResult
        public func endsEditingOnOutsideClick(_ endsEditing: Bool) -> Self {
            self.endsEditingOnOutsideClick = endsEditing
            return self
        }
        
        var mouseDownMonitor: NSEvent.Monitor? {
            get { getAssociatedValue("mouseDownMonitor") }
            set { setAssociatedValue(newValue, key: "mouseDownMonitor") }
        }

        func setupMouseMonitor() {
            if endsEditingOnOutsideClick {
                if mouseDownMonitor == nil {
                    mouseDownMonitor = NSEvent.localMonitor(for: .leftMouseDown) { [weak self] event in
                        guard let self = self, self.endsEditingOnOutsideClick, self.isFirstResponder else { return event }
                        if self.bounds.contains(event.location(in: self)) == false {
                            self.resignFirstResponding()
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
            get { getAssociatedValue("actionOnEnterKeyDown", initialValue: .none) }
            set {
                guard actionOnEnterKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEnterKeyDown")
                swizzleTextView()
            }
        }
        
        /// Sets the action to perform when the user pressed the enter key.
        @discardableResult
        public func actionOnEnterKeyDown(_ enterAction: EnterKeyAction) -> Self {
            actionOnEnterKeyDown = enterAction
            return self
        }

        /// The action to perform when the user presses the escape key.
        public var actionOnEscapeKeyDown: EscapeKeyAction {
            get { getAssociatedValue("actionOnEscapeKeyDown", initialValue: .none) }
            set {
                guard actionOnEscapeKeyDown != newValue else { return }
                setAssociatedValue(newValue, key: "actionOnEscapeKeyDown")
                swizzleTextView()
            }
        }

        /// Sets the action to perform when the user pressed the escape key.
        @discardableResult
        public func actionOnEscapeKeyDown(_ escapeAction: EscapeKeyAction) -> Self {
            actionOnEscapeKeyDown = escapeAction
            return self
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
            
            func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
                delegate?.textView?(textView, clickedOn: cell, in: cellFrame, at: charIndex)
            }
            
            func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
                delegate?.textView?(textView, doubleClickedOn: cell, in: cellFrame, at: charIndex)
            }
            
            func textView(_ view: NSTextView, draggedCell cell: NSTextAttachmentCellProtocol, in rect: NSRect, event: NSEvent, at charIndex: Int) {
                delegate?.textView?(view, draggedCell: cell, in: rect, event: event, at: charIndex)
            }
            
            func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
                switch commandSelector {
                case #selector(NSControl.cancelOperation(_:)):
                    switch textView.actionOnEscapeKeyDown {
                    case .endEditingAndReset:
                        textView.string = string
                        textView.resignFirstResponding()
                        return true
                    case .endEditing:
                        textView.resignFirstResponding()
                    case .none:
                        break
                    }
                case #selector(NSControl.insertNewline(_:)):
                    switch textView.actionOnEnterKeyDown {
                    case .endEditing:
                        textView.resignFirstResponding()
                    case .none: break
                    }
                default: break
                }
                return delegate?.textView?(textView, doCommandBy: commandSelector) ?? true
            }
            
            func textDidBeginEditing(_ notification: Notification) {
                string = (notification.object as? NSText)?.string ?? ""
                delegate?.textDidBeginEditing?(notification)
            }
            
            func textDidChange(_ notification: Notification) {
                delegate?.textDidChange?(notification)
            }
            
            func textDidEndEditing(_ notification: Notification) {
                delegate?.textDidEndEditing?(notification)
            }
            
            weak var delegate: NSTextViewDelegate?
            var delegateObservation: KeyValueObservation?
            init(_ textView: NSTextView) {
                delegate = textView.delegate
                self.string = textView.string
                super.init()
                textView.delegate = self
                delegateObservation = textView.observeChanges(for: \.delegate) { [weak self] _, new in
                    guard let self = self, new !== self else { return }
                    self.delegate = new
                    textView.delegate = self
                }
            }
        }
    }

#endif
