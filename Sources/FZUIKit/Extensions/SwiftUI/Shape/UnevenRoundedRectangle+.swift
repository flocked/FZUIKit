//
//  UnevenRoundedRectangle+.swift
//  
//
//  Created by Florian Zand on 28.07.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
import SwiftUI

@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
extension UnevenRoundedRectangle {
    /// Creates a new rounded rectangle shape with uneven corners.
    public init(cornerRadius: CGFloat, roundedCorners: CACornerMask, style: RoundedCornerStyle = .continuous) {
        self.init(topLeadingRadius: roundedCorners.contains(.topLeft) ? cornerRadius : 0, bottomLeadingRadius: roundedCorners.contains(.bottomLeft) ? cornerRadius : 0, bottomTrailingRadius: roundedCorners.contains(.bottomRight) ? cornerRadius : 0, topTrailingRadius: roundedCorners.contains(.topRight) ? cornerRadius : 0, style: style)
    }
}
#endif
