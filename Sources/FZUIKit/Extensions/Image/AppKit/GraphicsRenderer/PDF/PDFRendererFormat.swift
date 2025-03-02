//
//  PDFGraphicsRendererFormat.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import Foundation

public class PDFGraphicsRendererFormat: GraphicsRendererFormat {
    public static func `default`() -> Self {
        Self()
    }
    
    /// Returns the bounds for this format
    public internal(set) var bounds: CGRect = .zero
    
    /// Returns the associated document info
    public var documentInfo: [String: Any] = [:]
    
    public var isFlipped: Bool = false
    
    /// Creates a new format with the specified document info and whether or not the context should be flipped
    ///
    /// - Parameters:
    ///   - documentInfo: The associated PSD document info
    ///   - flipped: If true, the context drawing will be flipped
    public required init(documentInfo: [String: Any] = [:], flipped: Bool = true) {
        self.bounds = .zero
        self.documentInfo = documentInfo
        self.isFlipped = flipped
    }
}

#endif
