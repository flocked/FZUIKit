//
//  NSTextView+.swift
//  
//
//  Taken from: https://github.com/boinx/BXUIKit
//  Copyright ©2017-2018 Peter Baumgartner. All rights reserved.

#if os(macOS)

import AppKit

public extension NSTextView {
    var attributedString: NSAttributedString! {
            set {
                let len = self.textStorage?.length ?? 0
                let range = NSMakeRange(0,len)
                self.textStorage?.replaceCharacters(in:range,with:newValue)
            }
            get {
                return self.textStorage?.copy() as? NSAttributedString
            }
        }
    
    var textAlignment : NSTextAlignment {
        set {
            if let text = textStorage {
                let all = NSMakeRange(0,text.length)
                text.beginEditing()
                
                text.enumerateAttributes(in:all,options:[]) {
                    (attributes,range,outStop) in
                    
                    if let style = (attributes[.paragraphStyle] as? NSObject)?.mutableCopy() as? NSMutableParagraphStyle {
                        style.alignment = newValue
                        text.removeAttribute(.paragraphStyle, range:range)
                        text.addAttribute(.paragraphStyle, value:style, range:range)
                    }
                }
                text.endEditing()
            }
        }
        get {
            var alignment:NSTextAlignment? = nil
            var n = 0
            
            if let text = textStorage {
                let all = NSMakeRange(0,text.length)
                
                text.enumerateAttributes(in:all,options:[]) {
                    (attributes,range,outStop) in
                    
                    if let style = attributes[.paragraphStyle] as? NSParagraphStyle {
                        if n == 0 {
                            alignment = style.alignment
                        } else if alignment != style.alignment {
                            alignment = nil
                        }
                        n += 1
                    }
                }
            }
            return alignment ?? .center
        }
    }

}

#endif
