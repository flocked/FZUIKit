//
//  NSView+Resize.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
    public enum ResizeOption: Int, Codable, Hashable {
        case off
        case on
        case ifFirstResponder
    }
    
    public var isResizable: ResizeOption {
        get { getAssociatedValue("isResizable") ?? .off }
        set {
            guard newValue != isResizable else { return }
            setAssociatedValue(newValue, key: "isResizable")
            if newValue == .off {
                resizeView?.removeFromSuperview()
                resizeView = nil
            } else if resizeView == nil {
                resizeView = ResizeView(for: self)
            }
        }
    }
    
    class ResizeView: NSView {
        weak var view: NSView?
        var superviewObservation: KeyValueObservation?
        var frameObservation: KeyValueObservation?
        var resizeEdgeCorner: RectEdgeCorner? {
            didSet {
                guard oldValue != resizeEdgeCorner else { return }
                Swift.print("resizeEdgeCorner", resizeEdgeCorner?.description ?? "nil")
            }
        }
        lazy var trackingArea = TrackingArea(for: self, options: [.activeInActiveApp, .mouseEnteredAndExited, .mouseMoved])

        override func mouseEntered(with event: NSEvent) {
            updateResizeEdgeCorner(for: event)
        }
        
        override func mouseExited(with event: NSEvent) {
            resizeEdgeCorner = nil
        }
        
        override func mouseMoved(with event: NSEvent) {
            updateResizeEdgeCorner(for: event)
        }
        
        func updateResizeEdgeCorner(for event: NSEvent) {
            guard let view = view, view.isResizable != .off else {
                resizeEdgeCorner = nil
                return
            }
            let insideBounds = bounds.insetBy(dx: view.resizeTolerance, dy: view.resizeTolerance)
            if let edgeCorner = insideBounds.edgeOrCorner(containing: event.location(in: self), tolerance: view.resizeTolerance, cornerTolerance: view.resizeCornerTolerance ?? view.resizeTolerance), view.resizingEdges.contains(edgeCorner) {
                resizeEdgeCorner = edgeCorner
            } else {
                resizeEdgeCorner = nil
            }
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        init(for view: NSView) {
            self.view = view
            super.init(frame: .zero)
            updateTrackingAreas()
            frame = view.frame.insetBy(dx: -view.resizeTolerance, dy: -view.resizeTolerance)
            view.superview?.addSubview(self)
            sendToBack()
            superviewObservation = view.observeChanges(for: \.superview) { [weak self] old, new in
                guard let self = self else { return }
                if let new = new {
                    new.addSubview(self)
                    self.sendToBack()
                } else {
                    self.removeFromSuperview()
                }
            }
            frameObservation = view.observeChanges(for: \.frame) { [weak self] old, new in
                guard let self = self, let view = self.view else { return }
                self.frame = new.insetBy(dx: -view.resizeTolerance, dy: -view.resizeTolerance)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    public var resizingEdges: RectEdgeCorner {
        get { getAssociatedValue("resizingEdges") ?? .all }
        set { setAssociatedValue(newValue, key: "resizingEdges") }
    }
    
    public var resizeMinSize: CGSize {
        get { getAssociatedValue("resizeMinSize") ?? .zero }
        set { setAssociatedValue(newValue, key: "resizeMinSize") }
    }
    
    public var resizeTolerance: CGFloat {
        get { getAssociatedValue("resizeTolerance") ?? 5.0 }
        set { setAssociatedValue(newValue.clamped(min: 1.0), key: "resizeTolerance") }
    }
    
    public var resizeCornerTolerance: CGFloat? {
        get { getAssociatedValue("resizeCornerTolerance") }
        set { setAssociatedValue(newValue?.clamped(min: 1.0), key: "resizeCornerTolerance") }
    }
    
    public var resizeMaxSize: CGSize? {
        get { getAssociatedValue("resizeMaxSize") }
        set { setAssociatedValue(newValue, key: "resizeMaxSize") }
    }
    
    var resizeView: ResizeView? {
        get { getAssociatedValue("resizeView") }
        set { setAssociatedValue(newValue, key: "resizeView") }
    }
}

/*
extension RectEdgeCorner {
    var cursor: NSCursor? {
        switch self {
        case .bottom, .top: return .resizeUpDown
        case .left, .right: return .resizeLeftRight
        case .
        }
    }
}
*/

#endif
