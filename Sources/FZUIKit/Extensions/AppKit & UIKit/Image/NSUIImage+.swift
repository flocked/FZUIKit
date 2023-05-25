//
//  File.swift
//
//
//  Created by Florian Zand on 18.05.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension NSUIImage {
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
