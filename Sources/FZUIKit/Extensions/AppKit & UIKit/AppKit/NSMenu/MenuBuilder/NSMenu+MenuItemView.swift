//
//  NSMenu+MenuItemView.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//


/*
 #if os(macOS)
 import Cocoa
public extension NSMenu {
    /// A custom menu item view that manages highlight state and renders
    /// an appropriate backdrop behind the view when highlighted
    class MenuItemView: NSView {
        let view: NSView
        let showsHighlight: Bool
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
        
        init(view: NSView, showsHighlight: Bool) {
            self.view = view
            self.showsHighlight = showsHighlight
            
            super.init(frame: CGRect(origin: .zero, size: self.view.fittingSize))
            self.addSubview(effectView)
            self.addSubview(withConstraint: view)
            self.setupConstraints()
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override public func draw(_ dirtyRect: NSRect) {
            let highlighted = enclosingMenuItem!.isHighlighted
            effectView.isHidden = !showsHighlight || !highlighted
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
#endif
*/
