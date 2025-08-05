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
            setupTextViewDelegate()
        }
    }
        
    /**
     Returns a text view with an enclosing scroll view.
         
     The scroll view can be accessed via the text view's `enclosingScrollView` property.
         
     - Parameters:
        - scrollsHorizontal: A Boolean value indicating whether the text view is horizontal scrollable.
        - bordered: A Boolean value indicating whether the scroll view is bordered.
     - Returns: The scroll view.
          */
    public static func scrollable(scrollsHorizontal: Bool = false, bordered: Bool = false) -> NSTextView {
        let textView = NSTextView()
        textView.addEnclosingScrollView(scrollsHorizontal: scrollsHorizontal, bordered: bordered)
        return textView
    }
        
    /**
     Embeds the text view in a scroll view and returns that scroll view.
         
     If the text view is already emedded in a scroll view, it will return that.

     The scroll view can be accessed via the text view's `enclosingScrollView` property.
         
     - Parameters:
        - scrollsHorizontal: A Boolean value indicating whether the text view is horizontal scrollable.
        - bordered: A Boolean value indicating whether the scroll view is bordered.
     - Returns: The scroll view.
     */
    @discardableResult
    public func addEnclosingScrollView(scrollsHorizontal: Bool, bordered: Bool = false) -> NSScrollView {
        guard enclosingScrollView == nil else { return enclosingScrollView! }
        if !translatesAutoresizingMaskIntoConstraints {
            removeAllConstraints()
            translatesAutoresizingMaskIntoConstraints = true
        }
            
        let scrollView = NSScrollView(frame: bounds)

        textContainer?.containerSize = CGSize(width: scrollsHorizontal ? .greatestFiniteMagnitude : scrollView.contentSize.width, height: .greatestFiniteMagnitude)
        textContainer?.widthTracksTextView = !scrollsHorizontal

        minSize = CGSize(width: 0, height: 0)
        maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        isVerticallyResizable = true
        isHorizontallyResizable = scrollsHorizontal
        frame = CGRect(.zero, scrollView.contentSize)
            
        autoresizingMask = scrollsHorizontal ? [.width, .height] : [.width]

        scrollView.borderType = bordered ? .lineBorder : .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = scrollsHorizontal
        scrollView.documentView = self
        scrollView.drawsBackground = false
        return scrollView
    }
        
    /// The minimum numbers of characters needed when the user edits the string value.
    public var minimumNumberOfCharacters: Int? {
        get { getAssociatedValue("minimumNumberOfCharacters") }
        set {
            guard newValue != minimumNumberOfCharacters else { return }
            setAssociatedValue(newValue, key: "minimumNumberOfCharacters")
            setupTextViewDelegate()
        }
    }
        
    /// Sets the minimum numbers of characters needed when the user edits the string value.
    @discardableResult
    public func minimumNumberOfCharacters(_ minimum: Int?) -> Self {
        minimumNumberOfCharacters = minimum
        return self
    }
        
    /// The maximum numbers of characters allowed when the user edits the string value.
    public var maximumNumberOfCharacters: Int? {
        get { getAssociatedValue("minimumNumberOfCharacters") }
        set { 
            guard newValue != maximumNumberOfCharacters else { return }
            setAssociatedValue(newValue, key: "minimumNumberOfCharacters")
            setupTextViewDelegate()
        }
    }
        
    /// Sets the maximum numbers of characters allowed when the user edits the string value.
    @discardableResult
    public func maximumNumberOfCharacters(_ maximum: Int?) -> Self {
        maximumNumberOfCharacters = maximum
        return self
    }
        
    /// The allowed characters the user can enter when editing.
    public struct AllowedCharacters: OptionSet {
        public let rawValue: UInt
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = AllowedCharacters(rawValue: 1 << 0)
        /// Allows all letter characters.
        public static let letters: AllowedCharacters = [.lowercaseLetters, .uppercaseLetters]
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = AllowedCharacters(rawValue: 1 << 1)
        /// Allows alphabetic uppercase characters (like A, B, C, etc.)
        public static let uppercaseLetters = AllowedCharacters(rawValue: 1 << 2)
        /// Allows all alphanumerics characters.
        public static let alphanumerics: AllowedCharacters = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = AllowedCharacters(rawValue: 1 << 3)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = AllowedCharacters(rawValue: 1 << 4)
        /// Allows whitespace characters.
        public static let whitespaces = AllowedCharacters(rawValue: 1 << 5)
        /// Allows new line characters.
        public static let newLines = AllowedCharacters(rawValue: 1 << 6)
            
        /// Allows all characters.
        public static let all: AllowedCharacters = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines]
            
        var needsDelegate: Bool {
            self != AllowedCharacters.all
        }
            
        func isValid(_ string: String) -> Bool {
            trimString(string) == string
        }

        func trimString(_ string: String) -> String {
            guard self != .all else { return string }
            var string = string
            var characterSet = CharacterSet()
            if !contains(.lowercaseLetters) { characterSet += .lowercaseLetters }
            if !contains(.uppercaseLetters) { characterSet += .uppercaseLetters }
            if !contains(.digits) { characterSet += .decimalDigits }
            if !contains(.symbols) { characterSet += .symbols}
            if !characterSet.isEmpty { string = string.trimmingCharacters(in: characterSet) }
            if !contains(.newLines) { string = string.replacingOccurrences(of: "\n", with: "") }
            if !contains(.whitespaces) { string = string.replacingOccurrences(of: " ", with: "") }
            if !contains(.emojis) { string = string.trimmingEmojis() }
            return string
        }

        /// Creates a allowed characters structure with the specified raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    /// The allowed characters the user can enter when editing.
    public var allowedCharacters: AllowedCharacters {
        get { getAssociatedValue("allowedCharacters", initialValue: .all) }
        set {
            guard newValue != allowedCharacters else { return }
            setAssociatedValue(newValue, key: "allowedCharacters")
            setupTextViewDelegate()
        }
    }
        
    /// Sets the allowed characters the user can enter when editing.
    @discardableResult
    public func allowedCharacters(_ allowedCharacters: AllowedCharacters) -> Self {
        self.allowedCharacters = allowedCharacters
        return self
    }
        
    /// Creates a text view with an enclosing scroll view.
    public static func scrolling() -> NSTextView {
        let textView = NSTextView()
        textView.addEnclosingScrollView()
        return textView
    }
        
    /// Sets the Boolean value indicating whether the text view draws its background.
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
        
    /// Sets the Boolean value indicating whether the receiver allows its background color to change.
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
        
    /// Sets the Boolean value indicating whether the receiver allows undo.
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
        
    /// Sets the Boolean value indicating whether image attachments should permit editing of their images.
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
        
    /// Sets the Boolean value indicating whether the text view supplies autocompletion suggestions as the user types.
    @discardableResult
    public func isAutomaticTextCompletionEnabled(_ enabled: Bool) -> Self {
        self.isAutomaticTextCompletionEnabled = enabled
        return self
    }
        
    /// Sets the Boolean value indicating whether automatic text replacement is enabled.
    @discardableResult
    public func isAutomaticTextReplacementEnabled(_ enabled: Bool) -> Self {
        self.isAutomaticTextReplacementEnabled = enabled
        return self
    }
        
    /// Sets the Boolean value indicating whether automatic spelling correction is enabled.
    @discardableResult
    public func isAutomaticSpellingCorrectionEnabled(_ enabled: Bool) -> Self {
        self.isAutomaticSpellingCorrectionEnabled = enabled
        return self
    }
        
    /// Sets the Boolean value indicating whether automatic data detection is enabled.
    @discardableResult
    public func isAutomaticDashSubstitutionEnabled(_ enabled: Bool) -> Self {
        self.isAutomaticDashSubstitutionEnabled = enabled
        return self
    }
        
    /// Sets the Boolean value indicating whether automatic text replacement is enabled.
    @discardableResult
    public func isAutomaticDataDetectionEnabled(_ enabled: Bool) -> Self {
        self.isAutomaticDataDetectionEnabled = enabled
        return self
    }
                
    /// Sets the Boolean value indicating whether the text view automatically supplies the destination of a link as a tooltip for text that has a link attribute.
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
        
    /// Sets the Boolean value indicating whether this text view uses the inspector bar.
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
        
    /// Sets the Boolean value indicating whether to use a rollover button for selecton.
    @discardableResult
    public func usesRolloverButtonForSelection(_ uses: Bool) -> Self {
        self.usesRolloverButtonForSelection = uses
        return self
    }
        
        
    /// Sets the Boolean value indicating whether the receiver allows for a find panel.
    @discardableResult
    public func usesFindPanel(_ usesFindPanel: Bool) -> Self {
        self.usesFindPanel = usesFindPanel
        return self
    }
                
                
    /// The attributed string.
    public var attributedString: NSAttributedString! {
        get { attributedString() }
        set { textStorage?.setAttributedString(newValue) }
    }
        
    /// Sets the attributed text.
    @discardableResult
    public func attributedString(_ attributedString: NSAttributedString) -> Self {
        self.attributedString = attributedString
        return self
    }
        
    /// A Boolean value indicating whether the text view should stop editing when the user clicks outside the text view.
    public var endsEditingOnOutsideClick: Bool {
        get { firstResponderResignClickCount != 0 }
        set { firstResponderResignClickCount = newValue ? 1 : 0 }
    }
        
    /// Sets the Boolean value indicating whether the text view should stop editing when the user clicks outside the text view.
    @discardableResult
    public func endsEditingOnOutsideClick(_ endsEditing: Bool) -> Self {
        self.endsEditingOnOutsideClick = endsEditing
        return self
    }
        
    /// The action to perform when the user presses the escape key.
    public enum EscapeKeyAction {
        /// No action.
        case none
        /// Ends editing the text.
        case endEditing
        /// Ends editing the text and resets it to the the state before editing.
        case endEditingAndReset
        /// Deletes the text.
        case delete
        /// Resets the text to the the state before editing.
        case reset
            
        var needsDelegate: Bool {
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
            
        var needsDelegate: Bool {
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
            setupTextViewDelegate()
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
            setupTextViewDelegate()
        }
    }

    /// Sets the action to perform when the user pressed the escape key.
    @discardableResult
    public func actionOnEscapeKeyDown(_ escapeAction: EscapeKeyAction) -> Self {
        actionOnEscapeKeyDown = escapeAction
        return self
    }
    
    /**
     Returns the bezier paths for each character in the text view.
     
     - Parameters:
        - onlyVisible: A Boolean value indicating whether to include only the visible characters.
        - useMaximumNumberOfLines: A Boolean value indicating whether to include only characters up to the line specified by ``maximumNumberOfLines``.
     */
    public func characterBezierPaths(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [NSBezierPath] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).characterBezierPaths()
    }
    
    /**
     Returns the bezier path for the text in the text view.
     
     - Parameters:
        - onlyVisible: A Boolean value indicating whether to include only the visible characters.
        - useMaximumNumberOfLines: A Boolean value indicating whether to include only characters up to the line specified by ``maximumNumberOfLines``.
     */
    public func bezierPath(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSBezierPath {
        characterBezierPaths(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).reduce(into: .init()) {
            $0.append($1)
        }
    }
            
    fileprivate var textViewDelegate: TextViewDelegate? {
        get { getAssociatedValue("textViewDelegate") }
        set { setAssociatedValue(newValue, key: "textViewDelegate") }
    }
        
    fileprivate func setupTextViewDelegate() {
        if !actionOnEscapeKeyDown.needsDelegate && !actionOnEnterKeyDown.needsDelegate && !editingHandlers.needsObservation && minimumNumberOfCharacters == nil && maximumNumberOfCharacters == nil && !allowedCharacters.needsDelegate {
            textViewDelegate = nil
        } else if textViewDelegate == nil {
            textViewDelegate = TextViewDelegate(self)
        }
    }
        
    fileprivate class TextViewDelegate: NSObject, NSTextViewDelegate {
        var editingStartString: String
        var editingPreviousString = ""
        weak var delegate: NSTextViewDelegate?
        weak var textView: NSTextView!
        var delegateObservation: KeyValueObservation!
            
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
                    textView.string = editingStartString
                    textView.resignAsFirstResponder()
                    return true
                case .endEditing:
                    textView.resignAsFirstResponder()
                case .delete:
                    textView.string = ""
                    return false
                case .reset:
                    textView.string = editingStartString
                    return false
                case .none:
                    break
                }
            case #selector(NSControl.insertNewline(_:)):
                switch textView.actionOnEnterKeyDown {
                case .endEditing:
                    textView.resignAsFirstResponder()
                case .none: break
                }
            default: break
                
            }
            return delegate?.textView?(textView, doCommandBy: commandSelector) ?? true
        }
            
        func textDidBeginEditing(_ notification: Notification) {
            editingStartString = (notification.object as? NSText)?.string ?? textView.string
            editingPreviousString = editingStartString
            editingRange = textView.selectedRange
            delegate?.textDidBeginEditing?(notification)
            textView?.editingHandlers.didBegin?()
        }
            
        func textDidChange(_ notification: Notification) {
            delegate?.textDidChange?(notification)
            updateString()
        }
            
        func textDidEndEditing(_ notification: Notification) {
            delegate?.textDidEndEditing?(notification)
            textView.editingHandlers.didEnd?()
        }
            
        var editingRange = NSRange(location: 0, length: 0)
            
        func updateString() {
            let newString = textView.allowedCharacters.trimString(textView.string)
            if let maxCharCount = textView.maximumNumberOfCharacters, newString.count > maxCharCount {
                if editingPreviousString.count <= maxCharCount {
                    textView.string = editingPreviousString
                    textView.selectedRange = editingRange
                } else {
                    textView.string = String(newString.prefix(maxCharCount))
                }
            } else if let minCharCount = textView.minimumNumberOfCharacters, newString.count < minCharCount {
                if editingPreviousString.count >= minCharCount {
                    textView.string = editingPreviousString
                    textView.selectedRange = editingRange
                }
            } else if textView.editingHandlers.shouldEdit?(textView.string) == false {
                textView.string = editingPreviousString
                textView.selectedRange = editingRange
            } else {
                textView.string = newString
                if editingPreviousString == newString {
                    textView.selectedRange = editingRange
                }
            }
            editingPreviousString = textView.string
            editingRange = textView.selectedRange
            textView.editingHandlers.didEdit?()
        }
            
        init(_ textView: NSTextView) {
            delegate = textView.delegate
            self.editingStartString = textView.string
            self.textView = textView
            super.init()
            textView.delegate = self
            delegateObservation = textView.observeChanges(for: \.delegate) { [weak self] _, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.textView?.delegate = self
            }
        }
    }
}

extension NSTextView: TextLocationProvider {
    /// A Boolean value indicating whether the specified location is inside the text of text view.
    public func isLocationInsideText(_ location: CGPoint) -> Bool {
        guard bounds.contains(location) else { return false }
        guard let layoutManager = layoutManager, let textContainer = textContainer else { return false  }
        let containerPoint = CGPoint(x: location.x - textContainerOrigin.x, y: location.y - textContainerOrigin.y)
        let glyphIndex = layoutManager.glyphIndex(for: containerPoint, in: textContainer)
        return layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer).contains(containerPoint)
    }
}
#endif
