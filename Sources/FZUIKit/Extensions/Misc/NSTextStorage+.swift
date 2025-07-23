//
//  NSTextStorage+.swift
//
//
//  Created by Florian Zand on 22.07.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSTextStorage {
    /// Sets the layout managers for the text storage.
    @discardableResult
    public func layoutManagers(_ layoutManagers: [NSLayoutManager]) -> Self {
        layoutManagersWritable = layoutManagers
        return self
    }
    
    fileprivate var layoutManagersWritable: [NSLayoutManager] {
        get { layoutManagers }
        set {
            layoutManagers.forEach({ removeLayoutManager($0)})
            newValue.forEach({ addLayoutManager($0) })
        }
    }
    
    #if os(macOS)
    /**
     Sets the text storage contents as an array of attribute runs.
     
     Unless you’re dealing with scriptability, you shouldn’t use this method.
     */
    @discardableResult
    public func attributeRuns(_ attributeRuns: [NSTextStorage]) -> Self {
        self.attributeRuns = attributeRuns
        return self
    }
    
    /**
     Sets the text storage contents as an array of paragraphs.
     
     Unless you’re dealing with scriptability, you shouldn’t use this method.
     */
    @discardableResult
    public func paragraphs(_ paragraphs: [NSTextStorage]) -> Self {
        self.paragraphs = paragraphs
        return self
    }
    
    /**
     Sets the text storage contents as an array of words.
     
     Unless you’re dealing with scriptability, you shouldn’t use this method.
     */
    @discardableResult
    public func words(_ words: [NSTextStorage]) -> Self {
        self.words = words
        return self
    }
    
    /**
     Sets the text storage contents as an array of characters.
     
     Unless you’re dealing with scriptability, you shouldn’t use this method.
     */
    @discardableResult
    public func characters(_ characters: [NSTextStorage]) -> Self {
        self.characters = characters
        return self
    }
    #endif
}

#endif
