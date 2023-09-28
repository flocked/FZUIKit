//
//  PageController.swift
//
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
import AppKit
import Foundation
import FZSwiftUtils

public class PageController<ViewController: NSViewController, Element>: NSPageController, NSPageControllerDelegate {
    override public func loadView() {
        view = ObservingView()
    }

    public var isSwipeable = true
    public var isLooping = false
    public var keyboardControl: KeyboardControl = .disabled
    public var isKeyboardControllable = false
    public var keyboardTransitionDuration: TimeInterval = 0.0

    public typealias Handler = (_ viewController: ViewController, _ element: Element) -> Void
    private let handler: Handler

    public init(elements: [Element] = [], handler: @escaping Handler) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
        self.arrangedObjects = elements
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        if self.elements.isEmpty == false, self.keyboardControl.isEnabled {
            var type: AdvanceOption? = nil
            if event.keyCode == 123 {
                if event.modifierFlags.contains(.command) {
                    type = .first
                } else {
                    type = .previous
                }
            } else {
                if event.modifierFlags.contains(.command) {
                    type = .last
                } else {
                    type = .next
                }
            }
            if let type = type {
                self.advance(to: type, duration: self.keyboardControl.transitionDuration)
                return true
            }
        }
        return false
    }

    override public var acceptsFirstResponder: Bool {
        return true
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        (view as? ObservingView)?.keyHandlers.keyDown = { event in
            return self.performKeyEquivalent(with: event)
        }
        delegate = self
        transitionStyle = .horizontalStrip
    }

    override public func scrollWheel(with event: NSEvent) {
        if isSwipeable {
            super.scrollWheel(with: event)
        }
    }

    public var elements: [Element] {
        get { return arrangedObjects.isEmpty ? [] : (arrangedObjects as! [Element]) }
        set { arrangedObjects = newValue }
    }

    public func pageController(_: NSPageController, viewControllerForIdentifier _: String) -> NSViewController {
        return ViewController()
    }

    public func pageController(_: NSPageController, identifierFor _: Any) -> String {
        return "ViewController"
    }

    func prepare(viewController: ViewController, with element: Element) {
        handler(viewController, element)
    }

    public func pageController(_: NSPageController, prepare viewController: NSViewController, with object: Any?) {
        guard let element = object as? Element, let itemVC = viewController as? ViewController else { return }
        prepare(viewController: itemVC, with: element)
    }

    public func pageControllerDidEndLiveTransition(_: NSPageController) {
        completeTransition()
    }
}
#endif
