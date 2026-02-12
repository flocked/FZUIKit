//
//  GraphicsPDFRendererFormat.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/// A set of drawing attributes that represents the configuration of a PDF renderer context.
public class GraphicsPDFRendererFormat: GraphicsRendererFormat {
    var renderingBounds: CGRect = .zero
    var isRendering: Bool = false
    
    /// Returns a format that represents the highest fidelity that the current device supports.
    public static func `default`() -> Self {
        Self()
    }
    
    /// Returns the bounds for this format.
    public internal(set) var bounds: CGRect {
        get { isRendering ? renderingBounds : .zero }
        set { renderingBounds = newValue }
    }
    
    /// The PDF document info.
    public var documentInfo: PDFDocumentInfo = .init()
    
    /// A Boolean value indicating the graphics context’s flipped state.
    public var isFlipped: Bool = false
    
    /// Creates a new format with the specified document info and whether or not the context should be flipped
    ///
    /// - Parameters:
    ///   - documentInfo: The associated PSD document info
    ///   - flipped: If true, the context drawing will be flipped
    public required init(documentInfo: PDFDocumentInfo = PDFDocumentInfo(), flipped: Bool = true) {
        self.bounds = .zero
        self.documentInfo = documentInfo
        self.isFlipped = flipped
    }
}

#endif
