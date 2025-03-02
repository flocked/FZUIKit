//
//  PDFGraphicsRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

public final class PDFGraphicsRendererContext: GraphicsRendererContext {
    public let context: NSGraphicsContext
    public let format: PDFGraphicsRendererFormat
    private var hasOpenPage: Bool = false
    
    private var previousContext: NSGraphicsContext?
    
    func begin() {
        previousContext = NSGraphicsContext.current
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func end() {
        endPageIfOpen()
        cgContext.closePDF()
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.current = previousContext
        previousContext = nil
    }
    
    /// Creates a new PDF page. The bounds will be the same as specified by the document
    public func beginPage() {
        beginPage(withBounds: format.bounds, pageInfo: [:])
    }
    
    /// Creates a new PDF page. If an existing page is open, this will also close it for you.
    ///
    /// - Parameters:
    ///   - bounds: The bounds to use for this page
    ///   - pageInfo: The pageInfo associated to be associated with this page
    public func beginPage(withBounds bounds: CGRect, pageInfo: [String : Any]) {
        var info = pageInfo
        info[kCGPDFContextMediaBox as String] = bounds
        
        let pageInfo = info as CFDictionary
        
        endPageIfOpen()
        cgContext.beginPDFPage(pageInfo)
        hasOpenPage = true
        
        if format.isFlipped {
            let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: format.bounds.height)
            cgContext.concatenate(transform)
        }
    }
    
    /// Set the URL associated with `rect' to `url' in the PDF context `context'.
    ///
    /// - Parameters:
    ///   - url: The url to link to
    ///   - rect: The rect representing the link
    public func setURL(_ url: URL, for rect: CGRect) {
        let url = url as CFURL
        cgContext.setURL(url, for: rect)
    }
    
    /// Create a PDF destination named `name' at `point' in the current page of the PDF context `context'.
    ///
    /// - Parameters:
    ///   - name: A destination name
    ///   - point: A location in the current page
    public func addDestination(withName name: String, at point: CGPoint) {
        let name = name as CFString
        cgContext.addDestination(name, at: point)
    }
    
    /// Specify a destination named `name' to jump to when clicking in `rect' of the current page of the PDF context `context'.
    ///
    /// - Parameters:
    ///   - name: A destination name
    ///   - rect: A rect in the current page
    public func setDestinationWithName(_ name: String, for rect: CGRect) {
        let name = name as CFString
        cgContext.setDestination(name, for: rect)
    }
    
    // If a page is currently opened, this will close it. Otherwise it does nothing
    func endPageIfOpen() {
        guard hasOpenPage else { return }
        cgContext.endPDFPage()
        hasOpenPage = false
    }
    
    init(context: NSGraphicsContext, format: PDFGraphicsRendererFormat) {
        self.context = context
        self.format = format
    }
}

#endif
