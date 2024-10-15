//
//  NSUITextView+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension NSUITextView {
            /**
             Initializes a text view.
             
             - Parameters:
                - frame: The frame rectangle of the text view.
                - layoutManager: The layout manager of the text view.

             */
            convenience init(frame: CGRect, layoutManager: NSLayoutManager) {
                let textStorage = NSTextStorage()
                textStorage.addLayoutManager(layoutManager)
                #if os(macOS)
                let textContainer = NSTextContainer(containerSize: frame.size)
                #else
                let textContainer = NSTextContainer(size: frame.size)
                #endif
                layoutManager.addTextContainer(textContainer)
                self.init(frame: frame, textContainer: textContainer)
            }
        
        /// Text line.
        struct TextLine {
            /// The frame of the text line.
            public let frame: CGRect
            
            /// The text of the line.
            public let text: String
            
            /// The frame of the text.
            public let textFrame: CGRect
            
            /// The range of the string.
            public let textRange: Range<String.Index>
            
            init(frame: CGRect, textFrame: CGRect, text: String, textRange: Range<String.Index>) {
                self.frame = frame
                self.textFrame = textFrame
                self.text = text
                self.textRange = textRange
            }
        }
        
        /**
         The text lines of the text view.
         
         The text view needs to have a layout manager, text container and text storage, or else an empty array is returned.
         */
        var textLines: [TextLine] {
            
            #if os(macOS)
            guard let layoutManager = layoutManager, let textStorage = textStorage, textContainer != nil else { return [] }
            #endif
            
            var textLines: [TextLine] = []
            layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: textStorage.length)) { (rect, usedRect, textContainer, glyphRange, stop) in
                #if os(macOS)
                textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.string[glyphRange]), textRange: Range(glyphRange, in: self.string)!))
                #else
                textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.text[glyphRange]), textRange: Range(glyphRange, in: self.text)!))
                #endif
            }
            return textLines
        }
        
        
        #if os(macOS)
            /**
             The font size of the text.

             The value can be animated via `animator()`.
             */
            @objc var fontSize: CGFloat {
                get { font?.pointSize ?? 0.0 }
                set { NSView.swizzleAnimationForKey()
                    font = font?.withSize(newValue)
                }
            }

        #elseif canImport(UIKit)
            /// The font size of the text.
            @objc var fontSize: CGFloat {
                get { font?.pointSize ?? 0.0 }
                set { font = font?.withSize(newValue) }
            }
        #endif
    }

#endif
