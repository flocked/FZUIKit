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
    internal class StateDictionary<Value> {
        var dictionary: [NSControl.StateValue: Value] = [:]
        var hasValues: Bool {
            dictionary.values.isEmpty == false
        }

        subscript(state: NSControl.StateValue) -> Value? {
            get { dictionary[state] }
            set { dictionary[state] = newValue }
        }
    }

    internal var stateContentTintColor: StateDictionary<NSColor> {
        if let value: StateDictionary<NSColor> = getAssociatedValue(key: "_NSButton_stateContentTintColor", object: self) {
            return value
        }
        let value = StateDictionary<NSColor>()
        set(associatedValue: StateDictionary<NSColor>(), key: "_NSButton_stateContentTintColor", object: self)
        return value
    }

    @available(macOS 11.0, *)
    internal var stateSymbolConfiguration: StateDictionary<NSImage.SymbolConfiguration> {
        if let value: StateDictionary<NSImage.SymbolConfiguration> = getAssociatedValue(key: "_NSButton_stateSymbolConfiguration", object: self) {
            return value
        }
        let value = StateDictionary<NSImage.SymbolConfiguration>()
        set(associatedValue: StateDictionary<NSImage.SymbolConfiguration>(), key: "_NSButton_stateSymbolConfiguration", object: self)
        return value
    }

    func setContentTintColor(_ color: NSColor?, for state: NSControl.StateValue) {
        stateContentTintColor[state] = color
        stateContentTintColor[state] = color
        updateButtonStateObserver()
        if self.state == state, let color = color {
            contentTintColor = color
        }
    }

    func contentTintColor(for state: NSControl.StateValue) -> NSColor? {
        return stateContentTintColor[state]
    }

    @available(macOS 11.0, *)
    func setSymbolConfiguration(_ configuration: NSImage.SymbolConfiguration?, for state: NSControl.StateValue) {
        stateSymbolConfiguration[state] = configuration
        stateSymbolConfiguration[state] = configuration
        updateButtonStateObserver()
        if self.state == state, let configuration = configuration {
            symbolConfiguration = configuration
        }
    }

    @available(macOS 11.0, *)
    func symbolConfiguration(for state: NSControl.StateValue) -> NSImage.SymbolConfiguration? {
        stateSymbolConfiguration[state]
    }

    internal var buttonStateObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_NSButton_stateObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_NSButton_stateObserver", object: self) }
    }

    internal func updateButtonStateObserver() {
        let shouldObserveState: Bool
        if #available(macOS 11.0, *) {
            shouldObserveState = self.stateContentTintColor.hasValues || self.stateSymbolConfiguration.hasValues
        } else {
            shouldObserveState = stateContentTintColor.hasValues
        }

        if shouldObserveState == false {
            if let stateObserver = buttonStateObserver {
                removeObserver(stateObserver, forKeyPath: "state")
                buttonStateObserver = nil
            }
        } else {
            if buttonStateObserver == nil {
                buttonStateObserver = observeChange(\.cell?.state) { [weak self] _,_, _ in
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
