//
//  EffectView.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
import AppKit

struct VisualEffectBackground: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    private let appearance: NSAppearance?
    private let state: NSVisualEffectView.State
    
    init(_ configuration: VisualEffectConfiguration) {
        self.material = configuration.material
        self.blendingMode = configuration.blendingMode
        self.isEmphasized = configuration.isEmphasized
        self.appearance = configuration.appearance
        self.state = configuration.state
    }
        
    init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        emphasized: Bool,
        state: NSVisualEffectView.State,
        appearance: NSAppearance?
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.isEmphasized = emphasized
        self.appearance = appearance
        self.state = state
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        
        // Not certain how necessary this is
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.appearance = appearance
        view.blendingMode = blendingMode
        view.state = state
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
     //   nsView.material = context.environment.visualEffectMaterial ?? material
      //  nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
    //    nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
    }
}

extension View {
    /// Adds a visual effect to the background for the specified configuration.
    public func visualEffect(_ configuration: VisualEffectConfiguration) -> some View  {
        background(
            VisualEffectBackground(
                material: configuration.material,
                blendingMode: configuration.blendingMode,
                emphasized: configuration.isEmphasized,
                state: configuration.state,
                appearance: configuration.appearance
            )
        )
    }
    
    /// Adds a visual effect to the background.
    public func visualEffect(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false,
        state: NSVisualEffectView.State = .followsWindowActiveState,
        appearance: NSAppearance? = nil
    ) -> some View {
        background(
            VisualEffectBackground(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized,
                state: state,
                appearance: appearance
            )
        )
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
