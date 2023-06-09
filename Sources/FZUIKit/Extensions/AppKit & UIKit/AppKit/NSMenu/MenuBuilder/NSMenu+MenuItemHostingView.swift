#if os(macOS)
import Cocoa
import SwiftUI

public extension NSMenu {    
    /// A custom menu item view that manages highlight state and renders
    /// an appropriate backdrop behind the view when highlighted
    class MenuItemHostingView<Content: View>: NSView {
        public var contentView: Content
        public var showsHighlight: Bool
        private let hostView: NSHostingView<AnyView>

        private lazy var effectView: NSVisualEffectView = {
            var effectView = NSVisualEffectView()
            effectView.state = .active
            effectView.material = .selection
            effectView.isEmphasized = true
            effectView.blendingMode = .behindWindow
            effectView.wantsLayer = true
            effectView.layer?.cornerRadius = 4
            effectView.layer?.cornerCurve = .continuous
            return effectView
        }()

        init(showsHighlight: Bool, contentView: Content) {
            self.contentView = contentView
            self.hostView = NSHostingView(rootView: AnyView(contentView))
            self.showsHighlight = showsHighlight

            super.init(frame: CGRect(origin: .zero, size: hostView.fittingSize))
            self.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(effectView)
            self.addSubview(withConstraint: hostView)
            self.setupConstraints()

        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func draw(_ dirtyRect: NSRect) {
            let highlighted = enclosingMenuItem!.isHighlighted
            effectView.isHidden = !showsHighlight || !highlighted
            hostView.rootView = AnyView(contentView.environment(\.menuItemIsHighlighted, highlighted))
            super.draw(dirtyRect)
        }

        private func setupConstraints() {
            effectView.translatesAutoresizingMaskIntoConstraints = false

            let margin: CGFloat = 5
            effectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin).isActive = true
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin).isActive = true
        }
    }
}

extension EnvironmentValues {
    private struct HighlightedKey: EnvironmentKey {
        static let defaultValue = false
    }

    /// Only updated inside of a `MenuItem(...).view { ... }` closure.
    /// Use this to adjust your content to look good in front of the selection background
    public var menuItemIsHighlighted: Bool {
        get {
            return self[HighlightedKey.self]
        }
        set {
            self[HighlightedKey.self] = newValue
        }
    }
}
#endif
