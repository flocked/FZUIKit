//
//  NSView+MouseHandlers.swift
//
//
//  Created by Florian Zand on 08.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension NSView {
        var mouseHandlers: MouseHandlers {
            get { associatedValue.get("", initialValue: MouseHandlers(self)) }
            set { associatedValue[""] = newValue }
        }

        struct MouseHandlers {
            public var mouseClick: ((_ point: CGPoint, _ event: NSEvent) -> Void)?
            public var rightMouseClick: ((_ point: CGPoint, _ event: NSEvent) -> Void)?
            public var mouseDragged: ((_ point: CGPoint, _ event: NSEvent) -> Void)?
            public var mouseEntered: ((_ point: CGPoint, _ event: NSEvent) -> Void)?
            public var mouseMoved: ((CGPoint) -> Void)?
            public var mouseExited: ((_ point: CGPoint, _ event: NSEvent) -> Void)?
            internal weak var view: NSView!
            internal init(_ view: NSView) {
                self.view = view
            }
        }
    }
#endif

/*
 public struct MouseHandlers<E> {
     public var mouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> ())? = nil
     public var rightMouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> ())? = nil
     public var mouseDragged: ((_ point: CGPoint, _ element: E?) -> ())? = nil
 //   var mouseEntered: ((CGPoint) -> ())? = nil
     public var mouseMoved: ((CGPoint) -> ())? = nil
  //   var mouseExited: ((CGPoint) -> ())? = nil
 }
 */
