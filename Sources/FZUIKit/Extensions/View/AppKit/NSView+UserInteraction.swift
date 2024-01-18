//
//  NSView+UserInteraction.swift
//
//
//  Created by Florian Zand on 09.11.23.
//


 #if os(macOS)

 import AppKit
 import FZSwiftUtils

 public extension NSView {
     /**
      A Boolean value that determines whether user events are ignored and removed from the event queue.

      When set to false`, mouse and keyboard events intended for the view are ignored and removed from the event queue. When set to `true`, events are delivered to the view normally. The default value of this property is `true`.
      */
     var isUserInteractionEnabled: Bool {
         get { getAssociatedValue(key: "isUserInteractionEnabled", object: self, initialValue: true) }
         set {
             guard newValue != isUserInteractionEnabled else { return }
             set(associatedValue: newValue, key: "isUserInteractionEnabled", object: self)
             swizzleUserInteraction()
         }
     }

      func swizzleUserInteraction() {
          if isUserInteractionEnabled {
              guard didSwizzleUserInteraction == false else { return }
              didSwizzleUserInteraction = true
              Swift.debugPrint("swizzleUserInteraction")
              do {
                  try self.replaceMethod(
                    #selector(NSView.mouseDown(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        Swift.print("mouseDown")
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseDown(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.mouseUp(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        Swift.print("mouseUp")
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseUp(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.mouseDragged(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseDragged(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.rightMouseDown(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.rightMouseDown(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.rightMouseUp(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.rightMouseUp(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.rightMouseDragged(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.rightMouseDragged(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.keyDown(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.keyDown(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.keyUp(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.keyUp(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.flagsChanged(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.flagsChanged(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.magnify(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.magnify(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.scrollWheel(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.scrollWheel(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.mouseMoved(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseMoved(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.mouseEntered(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseEntered(with:)), event)
                    }
                    }
                  try self.replaceMethod(
                    #selector(NSView.mouseExited(with:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in { object, event in
                        let view = (object as! NSView)
                        guard view.isUserInteractionEnabled else { return }
                        store.original(object, #selector(NSView.mouseExited(with:)), event)
                    }
                    }
              } catch {
                  Swift.debugPrint(error)
              }
          } else if didSwizzleUserInteraction {
              didSwizzleUserInteraction = false
              resetMethod(#selector(NSView.mouseDown(with:)))
              resetMethod(#selector(NSView.mouseUp(with:)))
              resetMethod(#selector(NSView.mouseDragged(with:)))
              resetMethod(#selector(NSView.rightMouseDown(with:)))
              resetMethod(#selector(NSView.rightMouseUp(with:)))
              resetMethod(#selector(NSView.rightMouseDragged(with:)))
              resetMethod(#selector(NSView.keyDown(with:)))
              resetMethod(#selector(NSView.keyUp(with:)))
              resetMethod(#selector(NSView.flagsChanged(with:)))
              resetMethod(#selector(NSView.magnify(with:)))
              resetMethod(#selector(NSView.scrollWheel(with:)))
              resetMethod(#selector(NSView.mouseMoved(with:)))
              resetMethod(#selector(NSView.mouseExited(with:)))
              resetMethod(#selector(NSView.mouseEntered(with:)))
          }
     }

     var didSwizzleUserInteraction: Bool {
         get { getAssociatedValue(key: "didSwizzleUserInteraction", object: self, initialValue: false) }
         set { set(associatedValue: newValue, key: "didSwizzleUserInteraction", object: self) }
     }
 }

 internal class UserInteractionMonitor {
     static let shared = UserInteractionMonitor()

     var views: [Weak<NSView>] = []

     func addView(_ view: NSUIView) {
         guard allViews.contains(view) == false else { return }
         views.append(Weak(view))
         setupMonitor()
     }

     func removeView(_ view: NSUIView) {
         if let index = views.firstIndex(where: { $0.object == view }) {
             views.remove(at: index)
             setupMonitor()
         }
     }

     var eventMonitor: NSEvent.Monitor? = nil

     func setupMonitor() {
         Swift.debugPrint("setupMonitor")
         if allViews.isEmpty == false {
             if eventMonitor == nil {
                 eventMonitor = NSEvent.Monitor.local(for: .allUserInteractions) { event in

                     if let firstResponder = NSApp.keyWindow?.firstResponder as? NSUIView {
                         for view in self.allViews {
                             if firstResponder == view || firstResponder.isDescendant(of: view) {
                                 return nil
                             }
                         }
                     }

                     if NSEvent.EventType.mouse.contains(event.type) {
                         if let contentView = NSApp.keyWindow?.contentView {
                             let mousePoint = event.location(in: contentView)
                             if let hitView = contentView.hitTest(mousePoint) {
                                 for view in self.allViews {
                                     if hitView == view || hitView.isDescendant(of: view) {
                                         return nil
                                     }
                                 }
                             }
                         }
                     }
                     return event
                 }
             }
         } else {
             eventMonitor = nil
         }
     }

     var allViews: [NSUIView] {
         views.compactMap({$0.object})
     }
 }

 #endif
 
