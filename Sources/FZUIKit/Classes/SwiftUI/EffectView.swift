//
//  EffectView.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
import AppKit

extension View {
    /// Adds a visual effect background for the specified configuration to the view.
    public func visualEffect(_ configuration: VisualEffectConfiguration) -> some View  {
        background(
            VisualEffectView(
                material: configuration.material,
                blendingMode: configuration.blendingMode,
                emphasized: configuration.isEmphasized,
                state: configuration.state,
                appearance: configuration.appearance
            )
        )
    }
    
    /// Adds a visual effect background with the specified appearance.
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

struct VisualEffectView: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    private let appearance: NSAppearance?
    private let state: NSVisualEffectView.State
            
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
    
    init(_ configuration: VisualEffectConfiguration) {
        self.material = configuration.material
        self.blendingMode = configuration.blendingMode
        self.isEmphasized = configuration.isEmphasized
        self.appearance = configuration.appearance
        self.state = configuration.state
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.appearance = appearance
        view.blendingMode = blendingMode
        view.isEmphasized = isEmphasized
        view.state = state
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.appearance = appearance
        nsView.blendingMode = blendingMode
        nsView.isEmphasized = isEmphasized
        nsView.state = state
        //   nsView.material = context.environment.visualEffectMaterial ?? material
         //  nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
       //    nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
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
