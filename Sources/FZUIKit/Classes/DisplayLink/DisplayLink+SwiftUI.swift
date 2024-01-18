//
//  DisplayLink+SwiftUI.swift
//
//
//  Created by Florian Zand on 31.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Combine
    import SwiftUI

    public extension SwiftUI.View {
        /// A handler that is called whenever the system is about to update the display.
        func onFrame(isActive: Bool = true, displayLink: DisplayLink = .shared, _ action: @escaping (DisplayLink.Frame) -> Void) -> some View {
            let publisher = isActive ? displayLink.eraseToAnyPublisher() : Empty<DisplayLink.Frame, Never>().eraseToAnyPublisher()
            return SubscriptionView(content: self, publisher: publisher, action: action)
        }
    }
#endif
