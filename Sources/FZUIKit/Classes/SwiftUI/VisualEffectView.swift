//
//  VisualEffectView.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
import AppKit

extension View {
    /// Adds a visual effect background to the view.
    @ViewBuilder
    public func visualEffect(_ configuration: VisualEffectConfiguration?) -> some View  {
        if let configuration = configuration {
            self.background(VisualEffectView(configuration))
        } else {
            self
        }
        
    }
    
    /// Adds a visual effect background with the specified appearance to the view.
    public func visualEffect(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        emphasized: Bool = false,
        state: NSVisualEffectView.State = .followsWindowActiveState,
        appearance: NSAppearance? = nil
    ) -> some View {
        background(
            VisualEffectView(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized,
                state: state,
                appearance: appearance
            )
        )
    }
}

/// A `SwiftUI` view with a visual effect.
public struct VisualEffectView: NSViewRepresentable {
    /// The material shown by the visual effect view.
    @State public private(set) var material: NSVisualEffectView.Material
    
    /// A value indicating how the view’s contents blend with the surrounding content.
    @State public private(set) var blendingMode: NSVisualEffectView.BlendingMode
    
    /// A Boolean value indicating whether to emphasize the look of the material.
    @State public private(set) var isEmphasized: Bool
    
    /// The appearance of the visual effect.
    @State public private(set) var appearance: NSAppearance?
    
    /// A value that indicates whether a view has a visual effect applied.
    @State public private(set) var state: NSVisualEffectView.State
    
    /// The visual effect configuration of the view.
    public var configuration: VisualEffectConfiguration {
        get { VisualEffectConfiguration(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized) }
        set {
            material = newValue.material
            blendingMode = newValue.blendingMode
            isEmphasized = newValue.isEmphasized
            appearance = newValue.appearance
            state = newValue.state
        }
    }
    
    /// Sets the material shown by the visual effect view.
    public func material(_ material: NSVisualEffectView.Material) -> Self {
        self.material = material
        return self
    }
    
    /// Sets the value indicating how the view’s contents blend with the surrounding content.
    public func blendingMode(_ mode: NSVisualEffectView.BlendingMode) -> Self {
        self.blendingMode = mode
        return self
    }
    
    /// Sets the Boolean value indicating whether to emphasize the look of the material.
    public func isEmphasized(_ isEmphasized: Bool) -> Self {
        self.isEmphasized = isEmphasized
        return self
    }
    
    /// Sets the appearance of the visual effect.
    public func appearance(_ appearance: NSAppearance?) -> Self {
        self.appearance = appearance
        return self
    }
    
    /// Sets value that indicates whether a view has a visual effect applied.
    public func state(_ state: NSVisualEffectView.State) -> Self {
        self.state = state
        return self
    }
    
    /// Sets the visual effect configuration of the view.
    public func configuration(_ configuration: VisualEffectConfiguration) -> Self {
        material = configuration.material
        blendingMode = configuration.blendingMode
        isEmphasized = configuration.isEmphasized
        appearance = configuration.appearance
        state = configuration.state
        return self
    }
    
    /**
     Creates a visual effect view with the specified properties.
     
     - Parameters:
        - material: The material shown by the visual effect view.
        - blendingMode: A value indicating how the view’s contents blend with the surrounding content.
        - emphasized: A Boolean value indicating whether to emphasize the look of the material.
        - state: A value that indicates whether a view has a visual effect applied.
        - appearance: The appearance of the visual effect.

     */
    public init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        emphasized: Bool = false,
        state: NSVisualEffectView.State = .followsWindowActiveState,
        appearance: NSAppearance? = nil
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
        self.appearance = appearance
        self.state = state
    }
    
    /**
     Creates a visual effect view with the specified configuration.
     
     - Parameter configuration: The visual effect configuration,
     */
    public init(_ configuration: VisualEffectConfiguration) {
        self.material = configuration.material
        self.blendingMode = configuration.blendingMode
        self.isEmphasized = configuration.isEmphasized
        self.appearance = configuration.appearance
        self.state = configuration.state
    }
        
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.appearance = appearance
        view.blendingMode = blendingMode
        view.isEmphasized = isEmphasized
        view.state = state
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.appearance = appearance
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
        nsView.state = state
    }
}

#elseif os(iOS) || os(tvOS)
    import UIKit

    @available(iOS 13, *)
    public struct EffectView: UIViewRepresentable {
        public typealias UIViewType = UIVisualEffectView
        private var effect: UIVisualEffect?

        public init(effect: UIVisualEffect?) {
            self.effect = effect
        }

        public func makeUIView(context _: Context) -> UIVisualEffectView {
            UIVisualEffectView(effect: effect)
        }

        public func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
            uiView.effect = effect
        }
    }
#endif
