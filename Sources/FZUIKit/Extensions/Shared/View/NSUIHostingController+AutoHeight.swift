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

class AutoHeightHostingController<Content>: NSUIHostingController<Content> where Content: View {
    override init(rootView: Content) {
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
    
    internal var previousWidth: CGFloat = 0.0
    internal lazy var heightAnchor = self.view.heightAnchor.constraint(equalToConstant: 1)
    
    #if os(macOS)
    override func viewDidLayout() {
        if self.view.frame.size.width != previousWidth {
            previousWidth = self.view.frame.size.width
            let fittingSize = self.sizeThatFits(CGSize(width: previousWidth, height: 10000))
            self.heightAnchor.constant = fittingSize.height
        }
    }
    #elseif canImport(UIKit)
    override func viewDidLayoutSubviews() {
        if self.view.frame.size.width != previousWidth {
            previousWidth = self.view.frame.size.width
            let fittingSize = self.sizeThatFits(in: CGSize(width: previousWidth, height: 10000))
            self.heightAnchor.constant = fittingSize.height
        }
    }
    #endif
}

/*
class AutoHeightHostingView<Content>: NSHostingView<Content> where Content: View {
    internal var previousWidth: CGFloat = 0.0
    internal lazy var heightA = self.heightAnchor.constraint(equalToConstant: 1)

    
    override func layout() {
        super.layout()
        
        if self.frame.size.width != previousWidth {
            previousWidth = self.frame.size.width
            var widthAnc: NSLayoutConstraint? = self.constraints.first(where: {$0.firstAttribute == .width || $0.secondAttribute == .width })
            
            if widthAnc == nil {
                
            }
            
            let previousWidthAnchor = self.widthAnchor
            let widthAn =
            let fittingSize = self.sizeThatFits(CGSize(width: previousWidth, height: 10000))
            self.heightA.constant = fittingSize.height
        }
    }
}
 */
