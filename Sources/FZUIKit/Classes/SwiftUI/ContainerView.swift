//
//  File.swift
//  
//
//  Created by Florian Zand on 09.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

/// A SwiftUI view that displays a NSView / UIView.
public struct ContainerView<Content: NSUIView>: NSViewRepresentable {
    public let view: Content
    
    public init(view: Content) {
        self.view = view
    }
    
  public func makeNSView(context: Context) -> Content {
      return view
  }
  
  public func updateNSView(_ nsView: Content, context: Context) {
   
  }
}
