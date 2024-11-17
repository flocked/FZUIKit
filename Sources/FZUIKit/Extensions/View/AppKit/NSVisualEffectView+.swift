//
//  NSVisualEffectView+.swift
//
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSVisualEffectView {
        /**
         Applies a mask image with the specified corner radius.

         - Parameters: The corner radius to apply.
         */
        func roundCorners(withRadius cornerRadius: CGFloat) {
            maskImage = (cornerRadius != 0.0) ? .maskImage(cornerRadius: cornerRadius) : nil
        }
        
        /// Sets the material shown by the visual effect view.
        @discardableResult
        func material(_ material: Material) -> Self {
            self.material = material
            return self
        }
        
        /// Sets the value indicating how the view’s contents blend with the surrounding content.
        @discardableResult
        func blendingMode(_ blendingMode: BlendingMode) -> Self {
            self.blendingMode = blendingMode
            return self
        }
        
        /// Sets the Boolean value indicating whether to emphasize the look of the material.
        @discardableResult
        func isEmphasized(_ isEmphasized: Bool) -> Self {
            self.isEmphasized = isEmphasized
            return self
        }
        
        /// Sets the value that indicates whether a view has a visual effect applied.
        @discardableResult
        func state(_ state: State) -> Self {
            self.state = state
            return self
        }
        
        /// Sets the image whose alpha channel masks the visual effect view's material.
        @discardableResult
        func maskImage(_ maskImage: NSImage?) -> Self {
            self.maskImage = maskImage
            return self
        }
    }

    extension NSVisualEffectView.Material: Codable { }
    extension NSVisualEffectView.State: Codable { }
    extension NSVisualEffectView.BlendingMode: Codable { }

#endif
