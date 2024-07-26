//
//  QuicklookPreview.swift
//
//
//  Created by Florian Zand on 26.07.24.
//

#if os(macOS)

import QuickLookUI
import SwiftUI

/// `SwiftUI` view that displays a quick look preview of a file.
public struct QuickLookPreview: NSViewRepresentable {
    
    let url: URL?
    let autostarts: Bool
    
    /**
     Creates a quick look preview for the specified file url.
     
     - Parameters:
     - url: The url to the file to preview.
     - autostarts: A Boolean value that determines whether the preview starts automatically.
     
     */
    public init(url: URL?, autostarts: Bool = true) {
        self.url = url
        self.autostarts = autostarts
    }
    
    public func makeNSView(context: Context) -> QLPreviewView {
        let nsView = QLPreviewView()
        nsView.previewItem = url.map({ $0 as QLPreviewItem })
        nsView.autostarts = autostarts
        return nsView
    }
    
    public func updateNSView(_ nsView: QLPreviewView, context: Context) {
        nsView.previewItem = url.map({ $0 as QLPreviewItem })
        nsView.autostarts = autostarts
        nsView.refreshPreviewItem()
    }
}

#endif
