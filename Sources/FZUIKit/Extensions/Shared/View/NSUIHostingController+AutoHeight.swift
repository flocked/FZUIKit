//
//  NSUIHostingController+AutoHeight.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// Creates a hosting controller object that automatically adjusts it height to fit the it's SwiftUI view.
public class AutoHeightHostingController<Content>: NSUIHostingController<Content> where Content: View {
    public override init(rootView: Content) {
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
        #if os(macOS)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        #endif
        self.heightAnchor.isActive = true
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// A Boolean value that indicates whether the view's height should be adjusted to fit the SwiftUI's view.
    public var autoAdjustHeight: Bool = true {
        didSet {
            self.heightAnchor.isActive = self.autoAdjustHeight
        }
    }
    
    internal var previousWidth: CGFloat = 0.0
    internal lazy var heightAnchor = self.view.heightAnchor.constraint(equalToConstant: 1000)
    
    #if os(macOS)
    public override func viewDidLayout() {
        if self.view.frame.size.width != previousWidth {
            previousWidth = self.view.frame.size.width
            let fittingSize = self.sizeThatFits(CGSize(width: previousWidth, height: 10000))
            self.heightAnchor.constant = fittingSize.height
        }
    }
    #elseif canImport(UIKit)
    public override func viewDidLayoutSubviews() {
        if self.view.frame.size.width != previousWidth {
            previousWidth = self.view.frame.size.width
            let fittingSize = self.sizeThatFits(in: CGSize(width: previousWidth, height: 10000))
            self.heightAnchor.constant = fittingSize.height
        }
    }
    #endif
}

/*
#if os(macOS)
public class AutoHeightHostingView<Content>: NSHostingView<Content> where Content: View {
    internal var previousWidth: CGFloat = 0.0
    internal lazy var height = self.heightAnchor.constraint(equalToConstant: 1000)

    public required init(rootView: Content) {
        super.init(rootView: rootView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.height.activate()
    }
    
    /// A Boolean value that indicates whether the view's height should be adjusted to fit the SwiftUI's view.
    public var autoAdjustHeight: Bool = true {
        didSet {
            self.height.isActive = self.autoAdjustHeight
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        super.layout()
        
        if self.frame.size.width != previousWidth {
            previousWidth = self.frame.size.width
            var widthAnc: NSLayoutConstraint? = self.constraints.first(where: {$0.firstAttribute == .width || $0.secondAttribute == .width })
            
            if widthAnc == nil {
                
            }
            
            let previousWidthAnchor = self.widthAnchor
            let widthAn =
            let fittingSize = self.sizeThatFits(CGSize(width: previousWidth, height: 10000))
            self.height.constant = fittingSize.height
        }
    }
}
#endif
*/
