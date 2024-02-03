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
    /// The presentation or dismissal of the sheet/alert has been suppressed, because the user already did opt of showing it again  (see `NSAlert/supressionKey` for more information).
    static let suppress: NSApplication.ModalResponse = .init((1 << 14))
}

extension NSAlert {
    /**
     The key for suppressing the alert.
     
     Provide this key to allow the user to opt out of showing the alert again. The alert shows a suppression checkbox.
     
     If the user opts out, the alert won't be shown again and will instead return as response `suppress`.
     
     ```swift
     let response = myAlert.runModal()
     
     // Handle supression if needed
     if response == .suppress {
     
     }
     ```
     
     ### Reset the supression key

     To reset the supression of the alert and to show it again regardless if the user already did opt out, use ``resetSupression(for:)``
     
     ```swift
     NSAlert.resetSupression(for: "mySuppressionKey")
     ```
     */
    public var suppressionKey: String? {
        get { getAssociatedValue(key: "suppressionKey", object: self, initialValue: nil) }
        set {
            self.swizzleRunModal()
            set(associatedValue: newValue, key: "suppressionKey", object: self)
        }
    }
    
    /// Resets the supression for alerts with the specified key. It allows showing the alerts again, regardless if the user already did opt out of showing them.
    public static func resetSupression(for suppressionKey: String) {
        UserDefaults.standard.set(nil, forKey: suppressionKey)
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
                    store.original(object, #selector(self.beginSheetModal(for:completionHandler:)), window, newHandler)
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
