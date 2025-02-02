//
//  NSUIImage+Tiles.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIImage {
    /// Defines different vertical tile order options for layout.
    enum VerticalTileOrder: Int {
        /// Bottom to top.
        case bottomToTop
        /// Top to bottom.
        case topToBottom
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    
    /// Defines different horizontal tile order options for layout.
    enum HorizontalTileOrder: Int {
        /// Left to right.
        case leftToRight
        /// Right to left.
        case rightToLeft
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    
    /**
     Splits the image to tiles with the specified vertical and horizontal count.

     - Parameters:
        - horizontalCount: The amount of horizontal tiles.
        - verticalCount: The amount of vertical tiles.
        - horizontalOrder: The horizontal order of the tiles.
        - verticalOrder: The horizontal order of the tiles.
     
     - Returns: An array with the tile images.
     */
    func splitToTiles(horizontalCount: Int, verticalCount: Int, horizontalOrder: HorizontalTileOrder = .leftToRight, verticalOrder: VerticalTileOrder = .bottomToTop) -> [NSUIImage] {
        splitToTiles(size: CGSize(size.width / CGFloat(horizontalCount), size.height / CGFloat(verticalCount)), horizontalOrder: horizontalOrder, verticalOrder: verticalOrder)
    }
    
    /**
     Splits the image to tiles with the specified size.

     - Parameters:
        - size: The size of an tile.
        - horizontalOrder: The horizontal order of the tiles.
        - verticalOrder: The horizontal order of the tiles.
     
     - Returns: An array with the tile images.
     */
    func splitToTiles(size: CGSize, horizontalOrder: HorizontalTileOrder = .leftToRight, verticalOrder: VerticalTileOrder = .bottomToTop) -> [NSUIImage] {
        guard let cgImage = cgImage else { return [] }
        return CGRect(.zero, self.size).splitted(by: size, horizontalOrder: .init(rawValue: horizontalOrder.rawValue)!, verticalOrder: .init(rawValue: verticalOrder.rawValue)!).compactMap({ cgImage.cropping(to: $0)?.nsUIImage })
    }

    /// Returns the image cropped to the specified rect.
    func cropped(to rect: CGRect) -> NSUIImage {
        cgImage?.cropping(to: rect)?.nsUIImage ?? self
    }
}

extension CGImage {
    /// Defines different vertical tile order options for layout.
    enum VerticalTileOrder: Int {
        /// Bottom to top.
        case bottomToTop
        /// Top to bottom.
        case topToBottom
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    
    /// Defines different horizontal tile order options for layout.
    enum HorizontalTileOrder: Int {
        /// Left to right.
        case leftToRight
        /// Right to left.
        case rightToLeft
        /// Towards the center.
        case towardsCenter
        /// Towards the edges.
        case towardsEdges
        /// Random order.
        case random
    }
    
    /**
     Splits the image to tiles with the specified vertical and horizontal count.

     - Parameters:
        - horizontalCount: The amount of horizontal tiles.
        - verticalCount: The amount of vertical tiles.
        - horizontalOrder: The horizontal order of the tiles.
        - verticalOrder: The horizontal order of the tiles.
     
     - Returns: An array with the tile images.
     */
    func splitToTiles(horizontalCount: Int, verticalCount: Int, horizontalOrder: HorizontalTileOrder = .leftToRight, verticalOrder: VerticalTileOrder = .bottomToTop) -> [CGImage] {
        splitToTiles(size: CGSize(size.width / CGFloat(horizontalCount), size.height / CGFloat(verticalCount)), horizontalOrder: horizontalOrder, verticalOrder: verticalOrder)
    }
    
    /**
     Splits the image to tiles with the specified size.

     - Parameters:
        - size: The size of an tile.
        - horizontalOrder: The horizontal order of the tiles.
        - verticalOrder: The horizontal order of the tiles.
     
     - Returns: An array with the tile images.
     */
    func splitToTiles(size: CGSize, horizontalOrder: HorizontalTileOrder = .leftToRight, verticalOrder: VerticalTileOrder = .bottomToTop) -> [CGImage] {
        CGRect(.zero, self.size).splitted(by: size, horizontalOrder: .init(rawValue: horizontalOrder.rawValue)!, verticalOrder: .init(rawValue: verticalOrder.rawValue)!).compactMap({ cropping(to: $0) })
    }
}
