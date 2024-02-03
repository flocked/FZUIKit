//
//  NSAlert+.swift
//
//
//  Created by Florian Zand on 03.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSApplication.ModalResponse {
    static let suppress: NSApplication.ModalResponse = .init((1 << 14))
}

extension NSAlert {
    /**
     The key for suppressing the alert.
     
     When the value isn't `nil`, running the alert using `runModal()` or `beginSheetModal(for:completionHandler:)` checks first if the user supressed the alert:
     
     - If the user didn't supress the key, the alerts shows the suppresion key by setting  `showsSuppressionButton` to `true`.
     - If the user did supress the key, the modal returns as `NSApplication.ModalResponse` response ``supress``.
     */
    public var suppressionKey: String? {
        get { getAssociatedValue(key: "suppressionKey", object: self, initialValue: nil) }
        set {
            self.swizzleRunModal()
            set(associatedValue: newValue, key: "suppressionKey", object: self)
        }
    }
    
    func swizzleRunModal() {
        guard didSwizzleRunModal == false else { return }
        do {
            try replaceMethod(
                #selector(self.runModal),
                methodSignature: (@convention(c) (AnyObject, Selector) -> (NSApplication.ModalResponse)).self,
                hookSignature: (@convention(block) (AnyObject) -> (NSApplication.ModalResponse)).self
            ) { store in { object in
                guard let object = object as? NSAlert, let suppressionKey = object.suppressionKey else {
                    return store.original(object, #selector(self.runModal))
                }
                if UserDefaults.standard.bool(forKey: suppressionKey) {
                    return .suppress
                }
                
                object.showsSuppressionButton = true
                let runModal = store.original(object, #selector(self.runModal))
                if let checkbox = object.suppressionButton, checkbox.state == .on {
                    UserDefaults.standard.set(true, forKey: suppressionKey)
                }
                return runModal
            }
            }
            
            try replaceMethod(
                #selector(self.beginSheetModal(for:completionHandler:)),
                methodSignature: (@convention(c) (AnyObject, Selector, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> ()).self,
                hookSignature: (@convention(block) (AnyObject, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> ()).self
            ) { store in { object, window, handler in
                guard let object = object as? NSAlert, let suppressionKey = object.suppressionKey else {
                    store.original(object, #selector(self.beginSheetModal(for:completionHandler:)), window, handler)
                    return
                }
                
                if UserDefaults.standard.bool(forKey: suppressionKey) {
                    handler?(.suppress)
                } else {
                    object.showsSuppressionButton = true
                    let newHandler: ((NSApplication.ModalResponse) -> Void) = { response in
                        if let checkbox = object.suppressionButton, checkbox.state == .on {
                            UserDefaults.standard.set(true, forKey: suppressionKey)
                        }
                        handler?(response)
                    }
                }
            }
            }
            didSwizzleRunModal = true
        } catch {
            Swift.debugPrint()
        }
    }
    
    var didSwizzleRunModal: Bool {
        get { getAssociatedValue(key: "didSwizzleRunModal", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleRunModal", object: self) }
    }
}

#endif
