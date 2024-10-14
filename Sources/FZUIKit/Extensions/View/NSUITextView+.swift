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
