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
    /// The color used to indicate the selection.
    public var selectionColor: NSColor? {
        get { selectedTextAttributes[.backgroundColor] as? NSColor }
        set { selectedTextAttributes[.backgroundColor] = newValue }
    }
    
    /// Sets the color used to indicate the selection.
    @discardableResult
    public func selectionColor(_ color: NSColor?) -> Self {
        self.selectionColor = color
        return self
    }
    
    /// The text color used to indicate the selection.
    public var selectionTextColor: NSColor? {
        get { selectedTextAttributes[.foregroundColor] as? NSColor }
        set { selectedTextAttributes[.foregroundColor] = newValue }
    }
    
    /// Sets the text color used to indicate the selection.
    @discardableResult
    public func selectionTextColor(_ color: NSColor?) -> Self {
        self.selectionTextColor = color
        return self
    }
    
    /// Handlers for editing the text of a text view.
    public struct EditingHandler {
        /// Handler that is called whenever editing the text did begin.
        public var didBegin: (() -> Void)?
            
        /// Handler that determines whether the text should change. If you provide ``AppKit/NSTextField/minimumNumberOfCharacters``, ``AppKit/NSTextField/maximumNumberOfCharacters`` or ``AppKit/NSTextField/allowedCharacters-swift.property`` the handler is called after checking the string against the specified property conditions.
        public var shouldEdit: ((String) -> (Bool))?
            
        /// Handler that is called whenever the text did change.
        public var didEdit: (() -> Void)?
            
        /// Handler that is called whenever editing the text did end.
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
    public struct AllowedCharacters: Equatable, Hashable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        var set: CharacterSet
        var isEmoji: Bool
        
        /// Allows numeric characters (like 1, 2, etc.)
        public static let digits = Self(.decimalDigits)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let lowercaseLetters = Self(.lowercaseLetters)
        /// Allows alphabetic lowercase characters (like a, b, c, etc.)
        public static let uppercaseLetters = Self(.uppercaseLetters)
        /// Allows punctuation characters (like …,).
        public static let punctuation = Self(.punctuationCharacters)

        /// Allows all letter characters.
        public static let letters: Self = [.lowercaseLetters, .uppercaseLetters]
        /// Allows all alphanumerics characters.
        public static let alphanumerics: Self = [.digits, .lowercaseLetters, .uppercaseLetters]
        /// Allows symbols (like !, -, /, etc.)
        public static let symbols = Self(.symbols)
        /// Allows whitespace characters.
        public static let whitespaces = Self(.whitespaces)
        /// Allows new line characters.
        public static let newLines = Self(.newlines)
        /// Allows emoji characters (like 🥰 ❤️, etc.)
        public static let emojis = Self(isEmoji: true)
        /// ALl characters.
        public static let all: Self = [.alphanumerics, .symbols, .emojis, .whitespaces, .newLines, .punctuation]
        
        var needsSwizzling: Bool {
            self != Self.all
        }

        func trimString(_ string: String) -> String {
            guard set != Self.all.set else { return isEmoji ? string : string.removingEmojis() }
            guard isEmoji else { return string.keepingCharacters(in: set) }
            return String(string.filter { character in
                character.unicodeScalars.allSatisfy { set.contains($0) } || character.isEmoji
            })
        }
        
        public init(_ set: CharacterSet) {
            self.set = set
            self.isEmoji = false
        }
        
        public init(stringLiteral value: String) {
            self.init(value.unicodeScalars)
        }
        
        public init<S: Sequence<Unicode.Scalar>>(_ characters: S) {
            self.init(CharacterSet(characters))
        }
        
        public init(arrayLiteral elements: Self...) {
            set = elements.map({$0.set}).union
            isEmoji = elements.contains(where: {$0.isEmoji })
        }
        
        init(_ set: CharacterSet = .init(), isEmoji: Bool) {
            self.set = set
            self.isEmoji = isEmoji
        }
        
        public static func + (lhs: Self, rhs: Self) -> Self {
            .init(lhs.set.union(rhs.set), isEmoji: lhs.isEmoji || rhs.isEmoji)
        }
        
        public static func += (lhs: inout Self, rhs: Self) {
            lhs.set.formUnion(rhs.set)
            lhs.isEmoji = lhs.isEmoji || rhs.isEmoji
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
    public static func scrolling() -> Self {
        Self.scrollableTextView().documentView as! Self
    }
        
    /// Sets the Boolean value indicating whether the text view draws its background.
    @discardableResult
    public func drawsBackground(_ draws: Bool) -> Self {
        drawsBackground = draws
        return self
    }
        
    /// Sets the text view’s background color.
    @discardableResult
    public override func backgroundColor(_ color: NSColor?) -> Self {
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
                
                
    /// The attributed string of the text view.
    public var attributedString: NSAttributedString {
        get { self.attributedString() }
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
     Scrolls to and briefly highlights the first occurrence of the specified string in the text view.

     If the string does not occur in the text view, the method performs no action.

     - Parameters:
       - string: The string to search for in the text view’s contents.
       - options: Options that control how the search is performed.
     */
    func showFindIndicator(for string: String, options: String.CompareOptions = [.caseInsensitive]) {
        guard !string.isEmpty else { return }
        let fullText = self.string
        guard let foundRange = fullText.range(of: string, options: options, range: fullText.range, locale: nil) else {
            return
        }
        let nsRange = NSRange(foundRange, in: fullText)
        scrollRangeToVisible(nsRange)
        showFindIndicator(for: nsRange)
    }
            
    fileprivate var textViewDelegate: TextViewDelegate? {
        get { getAssociatedValue("textViewDelegate") }
        set { setAssociatedValue(newValue, key: "textViewDelegate") }
    }
        
    fileprivate func setupTextViewDelegate() {
        if !actionOnEscapeKeyDown.needsDelegate && !actionOnEnterKeyDown.needsDelegate && !editingHandlers.needsObservation && minimumNumberOfCharacters == nil && maximumNumberOfCharacters == nil && !allowedCharacters.needsSwizzling {
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
        
        override func responds(to aSelector: Selector!) -> Bool {
            switch aSelector {
            case #selector(NSTextDelegate.textDidChange(_:)): true
            case #selector(NSTextDelegate.textDidEndEditing(_:)): true
            case #selector(NSTextDelegate.textDidBeginEditing(_:)): true
            case #selector(NSTextViewDelegate.textView(_:doCommandBy:)): true
            default: delegate?.responds(to: aSelector) ?? false
            }
        }
        
        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            switch aSelector {
            case #selector(NSTextDelegate.textDidChange(_:)): nil
            case #selector(NSTextDelegate.textDidEndEditing(_:)): nil
            case #selector(NSTextDelegate.textDidBeginEditing(_:)): nil
            case #selector(NSTextViewDelegate.textView(_:doCommandBy:)): nil
            default: delegate?.responds(to: aSelector) ?? delegate
            }
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
            self.delegate = textView.delegate
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

extension NSTextView {
    /// The range of the selected line.
    public var selectedLineRange: NSRange? {
        let string = string as NSString
        let selectedRange = selectedRange()
        guard selectedRange.location != NSNotFound, selectedRange.location <= string.length else { return nil
        }
        if string.length == 0 {
            return NSRange(location: 0, length: 0)
        }
        return string.lineRange(for: NSRange(location: min(selectedRange.location, max(string.length - 1, 0)), length: 0))
    }
    
    /// Sets the highlight color used to indicate the selection line.
    @discardableResult
    public func selectionLineHighlightColor(_ color: NSColor?) -> Self {
        selectionLineHighlightColor = color
        return self
    }
    
    /// The highlight color used to indicate the selection line.
    public var selectionLineHighlightColor: NSColor? {
        get { getAssociatedValue("selectionLineHighlightColor") }
        set {
            guard newValue != selectionLineHighlightColor else { return }
            setAssociatedValue(newValue, key: "selectionLineHighlightColor")
            if newValue != nil, currentLineHooks.isEmpty, let layoutManager = layoutManager {
                do {
                    currentLineHooks += try hookAfter(#selector(NSTextView.didChangeText)) { object in
                        object.updateCurrentLineHighlight()
                    }
                    currentLineHooks += try hookAfter(#selector(NSTextView.viewDidMoveToWindow)) { object in
                        object.updateCurrentLineHighlight()
                    }
                    currentLineHooks += try hookAfter(#selector(NSTextView.viewDidChangeEffectiveAppearance)) { object in
                        object.updateCurrentLineHighlight()
                        guard let range = object.currentLineRange else { return }
                        object.layoutManager?.invalidateDisplay(forCharacterRange: range)
                    }
                    currentLineHooks += try hookAfter(#selector(NSTextView.setSelectedRange(_:affinity:stillSelecting:))) { object in
                        object.updateCurrentLineHighlight()
                    }
                    currentLineHooks += try hookAfter(#selector(setter: NSTextView.isEditable)) { object in
                        object.updateCurrentLineHighlight()
                    }
                    currentLineHooks += try hookAfter(#selector(setter: NSTextView.isSelectable)) { object in
                        object.updateCurrentLineHighlight()
                    }
                    currentLineHooks += try layoutManager.hook(#selector(NSLayoutManager.drawBackground(forGlyphRange:at:)), closure: {
                        original, object, selector, glyphsToShow, origin in
                        defer { original(object, selector, glyphsToShow, origin) }
                        guard let textContainer = object.textContainers.first, let textView = textContainer.textView, let color = textView.selectionLineHighlightColor, let characterRange = textView.currentLineRange else { return }
                        let glyphRange = object.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
                        guard NSIntersectionRange(glyphRange, glyphsToShow).length > 0, glyphRange.location != NSNotFound else { return }
                        
                        var rect = object.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                        guard !rect.isEmpty else { return }
                        rect.origin.x = 0
                        rect.size.width = textView.bounds.width - textView.textContainerInset.width
                        rect = rect.offsetBy(origin)
                        textView.effectiveAppearance.performAsCurrentDrawingAppearance {
                            color.setFill()
                        }
                        NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2).fill()
                    } as @convention(block) ((NSLayoutManager, Selector, NSRange, NSPoint) -> (), NSLayoutManager, Selector, NSRange, NSPoint) -> ())
                } catch {
                    Swift.print(error)
                }
            } else {
                currentLineHooks.forEach({ try? $0.revert() })
                currentLineHooks = []
            }
            updateCurrentLineHighlight()
        }
    }
    
    fileprivate var currentLineHooks: [Hook] {
        get { getAssociatedValue("currentLineHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "currentLineHooks") }
    }
    
    fileprivate var currentLineRange: NSRange? {
        get { getAssociatedValue("currentLineRange") }
        set {
            if let oldValue = currentLineRange {
                layoutManager?.invalidateDisplay(forCharacterRange: oldValue)
            }
            setAssociatedValue(newValue, key: "currentLineRange")
            guard let newValue = newValue else { return }
            layoutManager?.invalidateDisplay(forCharacterRange: newValue)
        }
    }
    
    fileprivate func updateCurrentLineHighlight() {
        currentLineRange = isSelectable ? selectedLineRange : nil
    }
    
    fileprivate func highlightedLineRect(for glyphRange: NSRange, in textContainer: NSTextContainer) -> NSRect? {
        guard glyphRange.location != NSNotFound else {
            return nil
        }

        let glyphRect = layoutManager?.boundingRect(forGlyphRange: glyphRange, in: textContainer) ?? .zero
        guard !glyphRect.isEmpty else {
            return nil
        }

        var rect = glyphRect
        rect.origin.x = 0
        rect.size.width = bounds.width
        return rect.integral
    }
}
#endif
