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

/// A view controller that manages and displays swipeable pages.
public class PageController<ViewController: NSViewController, Element>: NSPageController, NSPageControllerDelegate {
    
    /// The handler that configurates the view controller for each element.
    public typealias PageHandler = (_ viewController: ViewController, _ element: Element) -> Void
    
    /// The arranged elements.
    public var elements: [Element] {
        get { return arrangedObjects.isEmpty ? [] : (arrangedObjects as! [Element]) }
        set { arrangedObjects = newValue }
    }
    
    /// A Boolean value that indicates whether the user can swipe between displayed pages.
    public var isSwipeable = true
    
    /// A value that specifies if the displayed page is controllable by keyboard input.
    public var keyboardControl: KeyboardControlOption = .enabled {
        didSet { setupKeyDownMonitor() }
    }
    
    private var keyDownMonitor: NSEvent.Monitor? = nil
    private func setupKeyDownMonitor() {
        if keyboardControl.isEnabled == true {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.localMonitor(for: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    let firstResponder = self.view.window?.firstResponder
                    if firstResponder == self || firstResponder == self.view {
                        _ = self.performKeyEquivalent(with: event)
                        return nil
                    }
                    return event
                })
            }
        } else {
            keyDownMonitor = nil
        }
    }
    
    /**
     Returns a page controller with the specified elements and page handler.
     
     - Parameters:
        - elements: The elements of the page controller.
        - pageHandler: The handler that configurates the view controller for each element.
     */
    public init(elements: [Element] = [], pageHandler: @escaping PageHandler) {
        self.handler = pageHandler
        super.init(nibName: nil, bundle: nil)
        guard elements.isEmpty == false else { return }
        self.arrangedObjects = elements
        self.setupKeyDownMonitor()
    }
        
    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        if self.elements.isEmpty == false, self.keyboardControl.isEnabled {
            var type: AdvanceOption? = nil
            switch event.keyCode {
            case 123:
                if event.modifierFlags.contains(.command) {
                    type = .first
                } else {
                    type = keyboardControl.isLooping ? .previousLooping :  .previous
                }
            case 124:
                if event.modifierFlags.contains(.command) {
                    type = .last
                } else {
                    type = keyboardControl.isLooping ? .nextLooping : .next
                }
            default: break
            }
            if let type = type {
                self.advancePage(to: type, animationDuration: self.keyboardControl.transitionDuration)
                return true
            }
        }
        return false
    }
    
    override public func scrollWheel(with event: NSEvent) {
        if isSwipeable {
            super.scrollWheel(with: event)
        }
    }
    
    private let handler: PageHandler
    private var pageVCIndex: Int = 0
    private lazy var pageVCs = [pageVC(), pageVC(),pageVC()]
    private func pageVC() -> ViewController {
        if ViewController.responds(to: #selector(NSViewController.init(nibName:bundle:))) {
            return ViewController(nibName: nil, bundle: nil)
        } else {
            return ViewController()
        }
    }
    
    public func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        if let color = object as? NSColor, let colors = self.arrangedObjects as? [NSColor], let index =  colors.firstIndex(of: color) {
            return "\(index)"
        }
        return "PageViewController"
    }
    
    public func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        pageVCIndex = pageVCIndex + 1
        if pageVCIndex >= pageVCs.count {
            pageVCIndex = 0
        }
        return pageVCs[pageVCIndex]
    }
    
    public func pageController(_ pageController: NSPageController, prepare viewController: NSViewController, with object: Any?) {
        guard let element = object as? Element, let itemVC = viewController as? ViewController else { return }
        handler(itemVC, element)
    }
    
    public func pageControllerDidEndLiveTransition(_: NSPageController) {
        completeTransition()
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        (view as? ObserverView)?.keyHandlers.keyDown = { event in
            return self.performKeyEquivalent(with: event)
        }
        delegate = self
        transitionStyle = .horizontalStrip
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        guard arrangedObjects.count > 1 else { return }
        self.selectedIndex = 1
        self.selectedIndex = 0
    }
    
    public override func loadView() {
        self.view = ObserverView()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
#endif
