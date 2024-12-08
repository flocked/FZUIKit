//
//  MaterialView.swift
//
//
//  Created by Florian Zand on 08.12.24.
//


#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
extension NSUIView {
    /// Sets the material of the background.
    @discardableResult
    public func material(_ material: Material?) -> Self {
        self.material = material
        return self
    }
    
    /// The material of the background.
    public var material: Material? {
        get { materialView?.material }
        set {
            guard newValue != material else { return }
            if let newValue = newValue {
                if materialView == nil {
                    materialView = MaterialView(material: newValue)
                    addSubview(withConstraint: materialView!)
                    materialView?.sendToBack()
                }
                materialView?.material = newValue
            } else {
                materialView?.removeFromSuperview()
                materialView = nil
            }
        }
    }
    
    var materialView: MaterialView? {
        get { getAssociatedValue("materialView") }
        set { setAssociatedValue(newValue, key: "materialView") }
    }
}

/// A view that with a `SwiftUI` material as background.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
class MaterialView: NSUIView {
    var hostingController: NSUIHostingController<MaterialView>!
    
    /// The material of the background.
    public var _material: Material = .thinMaterial {
        didSet {
            // guard oldValue != _material else { return }
            hostingController.rootView = MaterialView(material: _material)
        }
    }
    
    /**
     Creates a view with the specified material.
     
     - Parameter material: The material of the background.
     */
    public init(material: Material = .thinMaterial) {
        super.init(frame: .zero)
        sharedInit()
        _material = material
        hostingController.rootView = MaterialView(material: material)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        hostingController = NSUIHostingController(rootView: MaterialView(material: _material))
        addSubview(withConstraint: hostingController.view)
        zPosition = -CGFloat.greatestFiniteMagnitude
    }
    
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
