//
//  NSSavePanel+.swift
//  
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import AppKit
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

extension NSSavePanel {
    /// Sets the title of the panel.
    @discardableResult
    @objc open func title(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    /// Sets the message text displayed in the panel.
    @discardableResult
    @objc open func message(_ message: String?) -> Self {
        self.message = message
        return self
    }
    
    /// Sets the text to display in the default button.
    @discardableResult
    @objc open func prompt(_ prompt: String?) -> Self {
        self.prompt = prompt
        return self
    }
    
    /// Sets the delegate to manage interactions with an open or save panel.
    @discardableResult
    @objc open func delegate(_ delegate: NSOpenSavePanelDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    /// Sets the Boolean value that indicates whether the panel displays UI for creating directories.
    @discardableResult
    @objc open func canCreateDirectories(_ canCreate: Bool) -> Self {
        self.canCreateDirectories = canCreate
        return self
    }
    
    /// Sets the Boolean value that indicates whether the panel displays files that are normally hidden from the user.
    @discardableResult
    @objc open func showsHiddenFiles(_ shows: Bool) -> Self {
        self.showsHiddenFiles = shows
        return self
    }
    
    /// Sets the Boolean value that indicates whether the panel allows the user to save files with a filename extension that’s not in the list of allowed types.
    @discardableResult
    @objc open func allowsOtherFileTypes(_ allows: Bool) -> Self {
        self.allowsOtherFileTypes = allows
        return self
    }
    
    /// Sets the Boolean value that indicates whether the panel displays file packages as directories.
    @discardableResult
    @objc open func treatsFilePackagesAsDirectories(_ treats: Bool) -> Self {
        self.treatsFilePackagesAsDirectories = treats
        return self
    }
            
    /// Sets the Boolean value that indicates whether the panel displays the Tags field.
    @discardableResult
    @objc open func showsTagField(_ shows: Bool) -> Self {
        self.showsTagField = shows
        return self
    }
    
    /// Sets the tag names that you want to include on a saved file.
    @discardableResult
    @objc open func tagNames(_ tagNames: [String]?) -> Self {
        self.tagNames = tagNames
        return self
    }
    
    /// Sets the user-editable filename currently shown in the name field.
    @discardableResult
    @objc open func nameFieldStringValue(_ stringValue: String) -> Self {
        self.nameFieldStringValue = stringValue
        return self
    }
    
    /// Sets the label text displayed in front of the filename text field.
    @discardableResult
    @objc open func nameFieldLabel(_ nameFieldLabel: String?) -> Self {
        self.nameFieldLabel = nameFieldLabel
        return self
    }
        
    /// Sets the custom accessory view for the current app.
    @discardableResult
    @objc open func accessoryView(_ view: NSView?) -> Self {
        self.accessoryView = view
        return self
    }
    
    /// Sets the Boolean value that indicates whether to display filename extensions.
    @discardableResult
    @objc open func isExtensionHidden(_ isExtensionHidden: Bool) -> Self {
        self.isExtensionHidden = isExtensionHidden
        return self
    }
    
    /// Sets the Boolean value that indicates whether the panel displays UI for hiding or showing filename extensions.
    @discardableResult
    @objc open func canSelectHiddenExtension(_ canSelectHiddenExtension: Bool) -> Self {
        self.canSelectHiddenExtension = canSelectHiddenExtension
        return self
    }
    
    /// Sets the files types to which you can save.
    @available(macOS 11.0, *)
    @discardableResult
    @objc open func allowedContentTypes(_ allowedContentTypes: [UTType]) -> Self {
        self.allowedContentTypes = allowedContentTypes
        return self
    }
}


#endif
