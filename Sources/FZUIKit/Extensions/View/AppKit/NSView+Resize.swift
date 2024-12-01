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
    
    public enum ResizeMaxOption: Codable, Hashable {
        case size(CGSize)
        case superview
        case superviewPadded(CGFloat)
        case none
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
        var isResizing: Bool = false
        var mouseDownMonitor: NSEvent.Monitor?
        var mouseDraggedMonitor: NSEvent.Monitor?
        var startLocation: CGPoint = .zero
        var resizeEdgeCorner: RectEdgeCorner? {
            didSet {
                guard oldValue != resizeEdgeCorner else { return }
                updateCursor()
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
        
        func updateCursor() {
            guard let view = view else { 
                mouseDraggedMonitor = nil
                return
            }
            switch resizeEdgeCorner {
            case .top, .bottom:
                if view.bounds.height >= maxSize.height {
                    if view.bounds.height <= view.resizeMinSize.height {
                        NSCursor.arrow.set()
                    } else {
                        if resizeEdgeCorner == .top {
                            NSCursor.resizeDown.set()
                        } else {
                            NSCursor.resizeUp.set()
                        }
                    }
                } else if view.bounds.height <= view.resizeMinSize.height {
                    if resizeEdgeCorner == .top {
                        NSCursor.resizeUp.set()
                    } else {
                        NSCursor.resizeDown.set()
                    }
                } else {
                    NSCursor.resizeUpDown.set()
                }
            case .left:
                if view.bounds.width >= maxSize.width {
                    if view.bounds.width <= view.resizeMinSize.width {
                        NSCursor.arrow.set()
                    } else {
                        if resizeEdgeCorner == .left {
                            NSCursor.resizeRight.set()
                        } else {
                            NSCursor.resizeLeft.set()
                        }
                    }
                } else if view.bounds.width <= view.resizeMinSize.width {
                    if resizeEdgeCorner == .left {
                        NSCursor.resizeLeft.set()
                    } else {
                        NSCursor.resizeRight.set()
                    }
                } else {
                    NSCursor.resizeLeftRight.set()
                }
            case .topLeft, .bottomRight: NSCursor.resizeDiagonal?.set()
            case .topRight, .bottomLeft: NSCursor.resizeDiagonalAlt?.set()
            case nil: NSCursor.arrow.set()
            default: break
            }
            guard !isResizing else { return }
            mouseDraggedMonitor = nil
        }
        
        var maxSize: CGSize {
            guard let view = view else { return .zero }
            switch view.resizeMaxSize {
            case .size(let size): return size
            case .superview: return view.superview?.bounds.size ?? .zero
            case .superviewPadded(let padding):
                guard var size = view.superview?.bounds.size else { return .zero }
                size.width -= padding
                size.height -= padding
                return size
            case .none: return CGSize(CGFloat.greatestFiniteMagnitude)
            }
        }
        
        func viewSize(for size: CGSize) -> CGSize {
            guard let view = view else { return .zero }
            var size = view.bounds.size
            guard view.isResizable != .off else { return size }
            if view.resizeMinSize.width > 0.0 {
                size.width = size.width.clamped(min: view.resizeMinSize.width)
            }
            if view.resizeMinSize.height > 0.0 {
                size.height = size.height.clamped(min: view.resizeMinSize.height)
            }
            switch view.resizeMaxSize {
            case .size(let maxSize):
                if maxSize.width > 0.0 {
                    size.width = size.width.clamped(max: maxSize.width)
                }
                if maxSize.height > 0.0 {
                    size.height = size.height.clamped(max: maxSize.height)
                }
            case .superview:
                guard let superview = view.superview else { break }
                size = size.clamped(max: superview.bounds.size)
            case .superviewPadded(let padding):
                guard let superview = view.superview else { break }
                var maxSize = superview.bounds.size
                maxSize.width -= padding.clamped(min: 0)
                maxSize.height -= padding.clamped(min: 0)
                size = size.clamped(max: maxSize)
            case .none: break
            }
            return size
        }
        
        func resizeEdgeCorner(for point: CGPoint) -> RectEdgeCorner? {
            guard let view = view, view.isResizable != .off else { return nil }
            let insideBounds = bounds.insetBy(dx: view.resizeTolerance, dy: view.resizeTolerance)
            if let edgeCorner = insideBounds.edgeOrCorner(containing: point, tolerance: view.resizeTolerance, cornerTolerance: view.resizeCornerTolerance ?? view.resizeTolerance), view.resizingEdges.contains(edgeCorner), view.isResizable == .on || view.isFirstResponder {
                return edgeCorner
            } else {
                return nil
            }
        }
        
        func updateResizeEdgeCorner(for event: NSEvent) {
            guard let view = view, view.isResizable != .off else {
                resizeEdgeCorner = nil
                return
            }
            resizeEdgeCorner = resizeEdgeCorner(for: event.location(in: self))
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override func mouseDragged(with event: NSEvent) {
            guard let view = view, isResizing else { return }
            let location = event.location(in: view)
            let distanceDragged = CGPoint(location.x - startLocation.x, location.y - startLocation.y)
        }
        
        init(for view: NSView) {
            self.view = view
            super.init(frame: .zero)
            updateTrackingAreas()
            frame = view.frame.insetBy(dx: -view.resizeTolerance, dy: -view.resizeTolerance)
            view.superview?.addSubview(self)
            zPosition = -CGFloat.greatestFiniteMagnitude
            sendToBack()
            mouseDownMonitor = .local(for: .leftMouseDown) { [weak self] event in
                guard let self = self else { return event }
                let location = event.location(in: view)
                guard self.resizeEdgeCorner != nil, let view = self.view, view.bounds.contains(location) else {
                    self.mouseDraggedMonitor = nil
                    return event
                }
                self.isResizing = true
                self.startLocation = location
                self.mouseDraggedMonitor = .local(for: .leftMouseDragged) { [weak self] event in
                    guard let self = self, let view = self.view else { return event }
                    
                    return event
                }
                return nil
            }
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
        get { getAssociatedValue("resizeTolerance") ?? 3.0 }
        set { setAssociatedValue(newValue.clamped(min: 1.0), key: "resizeTolerance") }
    }
    
    var resizeCornerTolerance: CGFloat? {
        get { getAssociatedValue("resizeCornerTolerance") }
        set { setAssociatedValue(newValue?.clamped(min: 1.0), key: "resizeCornerTolerance") }
    }
    
    public var resizeMaxSize: ResizeMaxOption {
        get { getAssociatedValue("resizeMaxSize") ?? .none }
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
