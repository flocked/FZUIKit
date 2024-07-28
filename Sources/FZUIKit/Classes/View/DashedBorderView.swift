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
        hostingController.rootView = ContentView(border: configuration, cornerRadius: superview?.cornerRadius ?? cornerRadius, cornerCurve: superview?.cornerCurve ?? cornerCurve)
    }
    
    init(configuration: BorderConfiguration = .none()) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        addSubview(withConstraint: hostingController.view)
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
    lazy var hostingController = NSUIHostingController(rootView: ContentView(border: border, cornerRadius: cornerRadius, cornerCurve: cornerCurve))
    
    struct ContentView: View {
        let border: BorderConfiguration
        let cornerRadius: CGFloat
        let cornerCurve: CALayerCornerCurve
        
        var body: some View {
            if let color = border.resolvedColor(), color.alphaComponent != 0.0 {
                RoundedRectangle(cornerRadius: cornerRadius, style: cornerCurve == .continuous ? .continuous : .circular)
                    .stroke(border)
            }
        }
    }
}

#endif
