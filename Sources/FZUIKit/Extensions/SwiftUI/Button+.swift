//
//  Button+.swift
//  
//
//  Created by Florian Zand on 25.08.24.
//

import SwiftUI

/// A button style that applies standard border artwork based on the button’s context with a clear background.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct RoundedBorderedButtonStyle: ButtonStyle {
    
    /// Creates a rounded bordered button style.
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.init(top: 1, leading: 4, bottom: 1, trailing: 4))
            .foregroundStyle(.tint)
            .background(
                RoundedRectangle(cornerRadius: 4).stroke(.tint, lineWidth: 1.5)
            )
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension ButtonStyle where Self == RoundedBorderedButtonStyle {
    /// A button style that applies standard border artwork based on the button’s context with a clear background.
    static var roundedBordered: Self {
        return .init()
    }
}
