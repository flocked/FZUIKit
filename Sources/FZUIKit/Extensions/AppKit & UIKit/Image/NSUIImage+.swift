//
//  NSUIImage+.swift
//
//
//  Created by Florian Zand on 18.05.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIImage {
    /// The symbol name of the image.
    var symbolName: String? {
        #if os(macOS)
        let description = String(describing: self)
        return description.substrings(between: "symbol = ", and: ">").first
        #else
        guard isSymbolImage, let strSeq = "\(String(describing: self))".split(separator: ")").first else { return nil }
        let str = String(strSeq)
        guard let name = str.split(separator: ":").last else { return nil }
        return String(name)
        #endif
    }
    
    func color(at location: CGPoint) -> NSUIColor? {
        guard location.x >= 0, location.x < size.width, location.y >= 0, location.y < size.height, let cgImage = cgImage, let provider = cgImage.dataProvider, let providerData = provider.data, let data = CFDataGetBytePtr(providerData) else {
            return nil
        }

        let numberOfComponents = 4
        let pixelData = Int((size.width * location.y) + location.x) * numberOfComponents

        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0

        return NSUIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public extension NSUIImage {
#if os(macOS)
    var dataSize: DataSize? {
        if let bytes = tiffData?.count {
            return DataSize(bytes)
        }
        return nil
    }
#else
    var dataSize: DataSize? {
        if let bytes = self.pngData()?.count {
            return DataSize(bytes)
        }
        return nil
    }
#endif
    
#if os(macOS)
    convenience init(color: NSUIColor, size: CGSize = .init(width: 1.0, height: 1.0)) {
        self.init(size: size, flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
        resizingMode = .stretch
        capInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
#else
    convenience init(color: NSUIColor, size: CGSize = .init(width: 1.0, height: 1.0)) {
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(context.format.bounds)
        }.resizableImage(withCapInsets: .zero)
        self.init(cgImage: image.cgImage!)
    }
#endif
}
