//
//  DashedBorderView.swift
//
//
//  Created by Florian Zand on 28.07.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

/// A layer with a dashed border.
class DashedBorderView: NSUIView {
    
    /// The configuration of the border.
    var configuration: BorderConfiguration {
        didSet {
            guard oldValue != configuration else { return }
            update()
        }
    }
    
    func update() {
        var configuration = configuration
        configuration.insets.bottomTop += configuration.width / 2.0
        configuration.insets.leadingTrailing += configuration.width / 2.0
        let view = superview ?? self
        hostingController.rootView = ContentView(border: configuration, cornerRadius: view.cornerRadius, cornerCurve: view.cornerCurve, roundedCorners: view.roundedCorners)
    }
    
    init(configuration: BorderConfiguration = .none()) {
        self.configuration = configuration
        super.init(frame: .zero)
        hostingController = NSUIHostingController(rootView: ContentView(border: configuration, cornerRadius: cornerRadius, cornerCurve: cornerCurve, roundedCorners: roundedCorners))
        addSubview(withConstraint: hostingController.view)
        update()
        optionalLayer?.zPosition = .greatestFiniteMagnitude
        observation = KeyValueObserver(self)
        #if os(macOS)
        observation.add(\.superview?.layer?.cornerRadius) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.update()
        }
        observation.add(\.superview?.layer?.cornerCurve) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.update()
        }
        #else
        observation.add(\.superview?.layer.cornerRadius) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.update()
        }
        observation.add(\.superview?.layer.cornerCurve) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.update()
        }
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var observation: KeyValueObserver<NSUIView>!
    var hostingController: NSUIHostingController<ContentView>!
    
    struct ContentView: View {
        let border: BorderConfiguration
        let cornerRadius: CGFloat
        let cornerCurve: CALayerCornerCurve
        let roundedCorners: CACornerMask
        @State var phase: CGFloat = 0
        
        @ViewBuilder
        var borderItem: some View {
            if roundedCorners != [] || roundedCorners != .all, #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
                UnevenRoundedRectangle(cornerRadius: cornerRadius, roundedCorners: roundedCorners, style: cornerCurve == .continuous ? .continuous : .circular)
                    .stroke(border, phase: phase)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: cornerCurve == .continuous ? .continuous : .circular)
                    .stroke(border, phase: phase)
            }
        }
        
        var body: some View {
            if let color = border.resolvedColor(), color.alphaComponent != 0.0 {
                if border.dash.animates && border.needsDashedBorderView {
                    borderItem
                        .animation(
                            Animation.linear(duration: border.dash._animationSpeed)
                                .repeatForever(autoreverses: false),
                            value: phase)
                        .onAppear {
                            phase = 8
                        }
                } else {
                    borderItem
                        .onAppear {
                            phase = border.dash.phase
                        }
                }
            }
        }
    }
}

extension Shape {
    @ViewBuilder
    fileprivate func stroke(_ border: BorderConfiguration, phase: CGFloat) -> some View {
        if border.dash.pattern.count <= 1 {
            stroke(Color(border.resolvedColor() ?? .clear), lineWidth: border.width)
                .padding(border.insets.edgeInsets)
        } else {
            stroke(Color(border.resolvedColor() ?? .clear), style: StrokeStyle(lineWidth: border.width, lineCap: border.dash.lineCap, dash: border.dash.pattern, dashPhase: phase))
                .padding(border.insets.edgeInsets)
        }
    }
}

#endif
