//
//  EffectView.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
    import AppKit

    @available(macOS 11, *)
    public struct EffectView: NSViewRepresentable {
        public typealias NSViewType = NSVisualEffectView

        private var material: NSVisualEffectView.Material
        private var blendingMode: NSVisualEffectView.BlendingMode
        private var emphasized: Bool
        private var state: NSVisualEffectView.State

        public init(
            _ blendingMode: NSVisualEffectView.BlendingMode = .withinWindow)
        {
            self.init(material: NSVisualEffectView.Material(rawValue: 0)!, blendingMode: blendingMode, emphasized: false)
        }

        public init(
            _ blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
            emphasized: Bool = false
        ) {
            self.init(material: NSVisualEffectView.Material(rawValue: 0)!, blendingMode: blendingMode, emphasized: emphasized)
        }

        public init(material: NSVisualEffectView.Material,
                    blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
                    emphasized: Bool = false)
        {
            self.init(material: material, blendingMode: blendingMode, emphasized: emphasized, state: .followsWindowActiveState)
        }

        public init(material: NSVisualEffectView.Material,
                    blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
                    emphasized: Bool = false,
                    state: NSVisualEffectView.State = .followsWindowActiveState)
        {
            self.material = material
            self.blendingMode = blendingMode
            self.emphasized = emphasized
            self.state = state
        }

        public func makeNSView(context _: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = material
            view.blendingMode = blendingMode
            view.isEmphasized = emphasized
            view.state = state
            return view
        }

        public func updateNSView(_ nsView: NSVisualEffectView, context _: Context) {
            nsView.material = material
            nsView.blendingMode = blendingMode
            nsView.isEmphasized = emphasized
        }

        public func material(_ material: NSVisualEffectView.Material) -> EffectView {
            var view = self
            view.material = material
            return view
        }

        public func blendingMode(_ blendingMode: NSVisualEffectView.BlendingMode) -> EffectView {
            var view = self
            view.blendingMode = blendingMode
            return view
        }

        public func emphasized(_ isEmphasized: Bool) -> EffectView {
            var view = self
            view.emphasized = isEmphasized
            return view
        }

        public func state(_ state: NSVisualEffectView.State) -> EffectView {
            var view = self
            view.state = state
            return view
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
