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
        background(VisualEffectView(.init(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: emphasized)))
    }
}

/// A `SwiftUI` view with a visual effect.
public struct VisualEffectView: NSViewRepresentable {
    
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var isEmphasized: Bool
    var appearance: NSAppearance?
    var state: NSVisualEffectView.State
    
    /// The visual effect configuration of the view.
    public var configuration: VisualEffectConfiguration {
        VisualEffectConfiguration(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized)
    }
    
    /// Sets the material shown by the visual effect view.
    public func material(_ material: NSVisualEffectView.Material) -> Self {
        var view = self
        view.material = material
        return view
    }
    
    /// Sets the value indicating how the view’s contents blend with the surrounding content.
    public func blendingMode(_ mode: NSVisualEffectView.BlendingMode) -> Self {
        var view = self
        view.blendingMode = mode
        return view
    }
    
    /// Sets the Boolean value indicating whether to emphasize the look of the material.
    public func isEmphasized(_ isEmphasized: Bool) -> Self {
        var view = self
        view.isEmphasized = isEmphasized
        return view
    }
    
    /// Sets the appearance of the visual effect.
    public func appearance(_ appearance: NSAppearance?) -> Self {
        var view = self
        view.appearance = appearance
        return view
    }
    
    /// Sets value that indicates whether a view has a visual effect applied.
    public func state(_ state: NSVisualEffectView.State) -> Self {
        var view = self
        view.state = state
        return view
    }
    
    /// Sets the visual effect configuration of the view.
    public func configuration(_ configuration: VisualEffectConfiguration) -> Self {
        var view = self
        view.material = configuration.material
        view.blendingMode = configuration.blendingMode
        view.isEmphasized = configuration.isEmphasized
        view.appearance = configuration.appearance
        view.state = configuration.state
        return view
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
