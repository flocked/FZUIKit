//
//  DisplayLinkTimer+SwiftUI.swift
//
//
//  Created by Florian Zand on 14.10.22.
//

import Combine
import SwiftUI

public extension SwiftUI.View {
    func onTimer(isActive: Bool = true, interval _: CGFloat, _ action: @escaping (Date) -> Void) -> some View {
        let publisher = (isActive == false) ? DisplayLinkTimer.publish(every: 1).eraseToAnyPublisher() : Empty<Date, Never>().eraseToAnyPublisher()
        return SubscriptionView(content: self, publisher: publisher, action: action)
    }
}
