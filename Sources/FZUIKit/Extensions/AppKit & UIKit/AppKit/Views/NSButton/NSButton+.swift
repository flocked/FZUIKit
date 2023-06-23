//
//  NSButton.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

public extension NSButton {
    /**
     Sets the content tint color to use for the specified state.
     - Parameters color: The content tint color to use for the specified state.
     - Parameters state: The state that uses the specified color. The possible values are described in NSControl.StateValue.
     
     If a color is not specified for a state, it defaults to the contentTintColor value.
     */
    func setContentTintColor(_ color: NSColor?, for state: NSControl.StateValue) {
        stateContentTintColor[state] = color
        stateContentTintColor[state] = color
        updateButtonStateObserver()
        if self.state == state, let color = color {
            contentTintColor = color
        }
    }

    /**
     Returns the content tint color used for a state.
     - Parameters state: The state that uses the specified color. The possible values are described in NSControl.StateValue.
     - Returns: The color of the content tint for the specified state.
     */
    func contentTintColor(for state: NSControl.StateValue) -> NSColor? {
        return stateContentTintColor[state]
    }

    @available(macOS 11.0, *)
    /**
     Sets the symbol configuration for a button state.
     - Parameters color: The symbol configuration for the specified state.
     - Parameters configuration: The state that uses the specified symbol configuration. The possible values are described in NSControl.StateValue.
     
     If a symbol configuration is not specified for a state, it defaults to the symbolConfiguration value.
     */
    func setSymbolConfiguration(_ configuration: NSImage.SymbolConfiguration?, for state: NSControl.StateValue) {
        stateSymbolConfiguration[state] = configuration
        stateSymbolConfiguration[state] = configuration
        updateButtonStateObserver()
        if self.state == state, let configuration = configuration {
            symbolConfiguration = configuration
        }
    }

    @available(macOS 11.0, *)
    /**
     Returns the symbol configuration used for a state.
     - Returns: The symbol configuration for the specified state.
     */
    func symbolConfiguration(for state: NSControl.StateValue) -> NSImage.SymbolConfiguration? {
        stateSymbolConfiguration[state]
    }
    
    internal var stateContentTintColor:  [NSControl.StateValue : NSColor] {
        get { return getAssociatedValue(key: "_NSButton_stateContentTintColor", object: self, initialValue:  [NSControl.StateValue : NSColor].init()) }
        set { set(associatedValue: newValue, key: "_NSButton_stateContentTintColor", object: self) }
    }
    
    @available(macOS 11.0, *)
    internal var stateSymbolConfiguration:  [NSControl.StateValue : NSImage.SymbolConfiguration] {
        get { return getAssociatedValue(key: "_NSButton_stateSymbolConfiguration", object: self, initialValue:  [NSControl.StateValue : NSImage.SymbolConfiguration].init()) }
        set { set(associatedValue: newValue, key: "_NSButton_stateSymbolConfiguration", object: self) }
    }

    internal var buttonStateObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_NSButton_stateObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_NSButton_stateObserver", object: self) }
    }

    internal func updateButtonStateObserver() {
        let shouldObserveState: Bool
        if #available(macOS 11.0, *) {
            shouldObserveState = !self.stateContentTintColor.isEmpty || !self.stateSymbolConfiguration.isEmpty
        } else {
            shouldObserveState = !stateContentTintColor.isEmpty
        }

        if shouldObserveState == false {
            if let stateObserver = buttonStateObserver {
                removeObserver(stateObserver, forKeyPath: "state")
                buttonStateObserver = nil
            }
        } else {
            if buttonStateObserver == nil {
                buttonStateObserver = observeChanges(for: \.cell?.state) { [weak self] _, _ in
                    guard let self = self else { return }
                    if let contentTintColor = self.contentTintColor(for: state) {
                        self.contentTintColor = contentTintColor
                    }
                    if #available(macOS 11.0, *) {
                        if let symbolConfiguration = self.symbolConfiguration(for: state) {
                            self.symbolConfiguration = symbolConfiguration
                        }
                    }
                }
            }
        }
    }
}

#endif
