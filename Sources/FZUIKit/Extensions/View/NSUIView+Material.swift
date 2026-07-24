//
//  NSUIView+Material.swift
//
//
//  Created by Florian Zand on 08.12.24.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

public extension NSUIView {
    /// Sets the material of the view background.
    @discardableResult
    func material(_ material: Material?) -> Self {
        self.material = material
        return self
    }
    
    /// The material of the view background.
    var material: Material? {
        get { materialView?._material }
        set {
            guard newValue != material else { return }
            if let newValue = newValue {
                if let materialView = materialView {
                    materialView._material = newValue
                } else {
                    materialView = .init(material: newValue)
                }
            } else {
                materialView?.removeFromSuperview()
                materialView = nil
            }
        }
    }
    
    fileprivate var materialView: MaterialView? {
        get { subviews.first(where: { $0.tag == 2_443_024 && $0 is MaterialView }) as? MaterialView }
        set {
            materialView?.removeFromSuperview()
            if let newValue = newValue {
                insertSubview(withConstraint: newValue, at: 0)
            }
        }
    }
}

fileprivate class MaterialView: NSUIView {
    var hostingController: NSUIHostingController<MaterialView>!
    
    var _material: Material = .thinMaterial {
        didSet {
            guard oldValue != _material else { return }
            hostingController.rootView = MaterialView(material: _material)
        }
    }
    
    init(material: Material = .thinMaterial) {
        super.init(frame: .zero)
        #if !os(macOS)
        tag = 2_443_024
        #endif
        _material = material
        hostingController = NSUIHostingController(rootView: MaterialView(material: material))
        addSubview(withConstraint: hostingController.view)
        zPosition = -.greatestFiniteMagnitude
        clipsToBounds = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
    override var acceptsFirstResponder: Bool { false }
    override var tag: Int { 2_443_024 }
    #else
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { nil }
    #endif
    
    struct MaterialView: View {
        let material: Material
        
        var body: some View {
            Rectangle()
                .fill(material)
                .ignoresSafeArea()
        }
    }
}
#endif
