#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import FZUIKitTests
#endif

public extension RatingViewNew {
    /// This struct can be used to configure StarRating's style.
    struct Configuration: Hashable {
        public var numberOfSteps: Int = 5
        public var hasHalfSteps: Bool = false
        
        public var stepSystemImageName: String = "star.filled"
        public var stepBorderWidth: CGFloat = 0.0
        public var stepBorderColor: NSUIColor? = nil
        public var stepColor: NSUIColor = .systemYellow
        public var stepEmptyColor: NSUIColor = .systemGray
        public var stepShadow: ContentConfiguration.Shadow = .none()
    }
}
