//
//  InnerShadowView.swift
//  InnerShadow
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
 
/**
 iOS 16.0+
 iPadOS 16.0+
 macOS 13.0+
 Mac Catalyst 16.0+
 tvOS 16.0+
 watchOS 9.0+
 */

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public class InnerShadowView: NSView {
    
    public var shadowColor: NSColor? = nil {
        didSet { if oldValue != shadowColor {
                self.updateShadow()
            } } }
    
    public var shadowOpacity: CGFloat = 0.7 {
        didSet { if oldValue != shadowOpacity {
                self.updateShadow()
            } } }
    
    public var shadowRadius: CGFloat = 3 {
        didSet { if oldValue != shadowRadius {
                self.updateShadow()
            } } }
    
    public var shadowOffset: CGPoint = CGPoint(x: 1, y: 1) {
        didSet { if oldValue != shadowOffset {
                self.updateShadow()
            } } }
    /*
    public var configuration: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: self.shadowColor, opacity: self.shadowOpacity, radius: self.shadowRadius, offset: self.shadowOffset) }
        set {
            self.shadowColor = newValue.color
            self.shadowOpacity = newValue.opacity
            self.shadowOffset = newValue.offset
            self.shadowRadius = newValue.radius
        }
    }
     */
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initalSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initalSetup()
    }
    
    internal func updateShadow() {
        hostingController.rootView = ShadowView(color: shadowColor?.swiftUI, opacity: shadowOpacity, radius: shadowRadius, offset: shadowOffset)
    }
    
    internal let hostingController = NSHostingController(rootView: ShadowView.black)

   internal func initalSetup() {
       self.addSubview(withConstraint: hostingController.view)
    }
}

@available(macOS 13.0, *)
public struct ShadowView: View {
    public let color: Color?
    public let opacity: CGFloat
    public let radius: CGFloat
    public let offset: CGPoint
    
    public static var black: ShadowView {
        ShadowView(color: .black)
    }
    
    public static var accentColor: ShadowView {
        ShadowView(color: .accentColor)
    }
    
    public init(color: Color?, opacity: CGFloat = 0.7, radius: CGFloat = 3, offset: CGPoint = CGPoint(x: 1, y: 1)) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
    
    public var body: some View {
        if let color = self.color {
            Rectangle()
                .fill(.shadow(.inner(color: color.opacity(opacity), radius: radius, x: offset.x, y: offset.y)))
                .foregroundColor(.red)
            
            /*
                .foregroundStyle(
                    Color.blue.gradient.shadow(.inner(color: color.opacity(opacity), radius: radius, x: offset.x, y: offset.y))
                )
             */
     
                          
        } else {
            Rectangle()
        }
    }
}
