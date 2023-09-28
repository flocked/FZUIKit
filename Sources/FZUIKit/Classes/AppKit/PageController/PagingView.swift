//
//  PagingView.swift
//  
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
import AppKit
import Foundation
import FZSwiftUtils

/// A view that displays swipeable pages.
public class PagingView<View: NSView, Element>: NSView, CAAnimationDelegate {
    /// The handler that configurates the view for each element.
    public typealias PageHandler = (_ view: View, _ element: Element) -> Void

    /**
     Selects the page at the specified index.
     
     - Parameters:
        - index: The index of the page.
        - animationDuration: The animation duration for transitioning to the new page. A value of `0.0` won't animate the transition. The default value is `0.2`.
     */
    public func selectPage(at index: Int, animationDuration: CGFloat = 0.2) {
        pageController.selectPage(at: index, animationDuration: animationDuration)
    }

    /**
     Advances to the page for the specified advance option.
     
     - Parameters:
        - option: The value that specifies the advance option.
        - animationDuration: The animation duration for transitioning to the new page. A value of `0.0` won't animate the transition. The default value is `0.2`.
     */
    public func advancePage(to option: AdvanceOption, animationDuration: CGFloat = 0.2) {
        pageController.advancePage(to: option, animationDuration: animationDuration)
    }

    /// The transition style the view uses when changing pages.
    public var transitionStyle: NSPageController.TransitionStyle {
        get { pageController.transitionStyle }
        set { pageController.transitionStyle = newValue }
    }

    /// A value that specifies if the displayed page is controllable by keyboard input.
    public var keyControllable: NSPageController.KeyboardControlOption {
        get { pageController.keyboardControl }
        set { pageController.keyboardControl = newValue }
    }

    /// A Boolean value that indicates whether the user can swipe between displayed pages.
    public var isSwipeable: Bool {
        get { pageController.isSwipeable }
        set { pageController.isSwipeable = newValue }
    }

    /**
     The index of the currently selected element.
     
     The value is animatable via  `animator()`.
     */
    @objc dynamic public var selectedIndex: Int {
        get { return pageController.selectedIndex }
        set {
            if needsIndexAnimator {
                self.pageController.animator().selectedIndex = newValue
            } else {
                self.pageController.selectedIndex = newValue
            }
             }
    }
    
    /// The arranged elements.
    public var elements: [Element] {
        get { return pageController.elements }
        set { pageController.elements = newValue }
    }
    
    /**
     Returns a paging view with the specified frame, elements and page handler.
     
     - Parameters:
        - frame: The frame rectangle for the view.
        - elements: The elements of the paging view.
        - pageHandler: The handler that configurates the view for each element.
     */
    public init(frame: CGRect, elements: [Element] = [], pageHandler: @escaping PageHandler) {
        pageController = PageController<ViewController, Element>(elements: elements,  pageHandler: {
            viewController, element in
            pageHandler(viewController.typedView, element)
        })
        super.init(frame: frame)
        addSubview(pageController.view)
    }

    /**
     Returns a paging view with the specified elements and page handler.
     
     - Parameters:
        - elements: The elements of the paging view.
        - pageHandler: The handler that configurates the view for each element.
     */
    public convenience init(elements: [Element] = [], pageHandler: @escaping PageHandler) {
        self.init(frame: .zero, elements: elements, pageHandler: pageHandler)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.selectedIndexAnimation = nil
        self.needsIndexAnimator = false
    }
    
    private var needsIndexAnimator = false
    private var selectedIndexAnimation: CAAnimation? = nil
    public override func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
        needsIndexAnimator = key == "selectedIndex"
        if key == "selectedIndex" {
            let animation = CABasicAnimation()
            animation.delegate = self
            selectedIndexAnimation = animation
            return animation
        }
        return  super.animation(forKey: key)
    }
    
    public override func layout() {
        super.layout()
        pageController.view.frame = self.bounds
    }
    
    public override func keyDown(with event: NSEvent) {
        guard keyControllable.isEnabled else {
            keyDown(with: event)
            return
        }
        var type: AdvanceOption? = nil
        switch event.keyCode {
        case 123:
            if event.modifierFlags.contains(.command) {
                type = .first
            } else {
                type = keyControllable.isLooping ? .previousLooping :  .previous
            }
        case 124:
            if event.modifierFlags.contains(.command) {
                type = .last
            } else {
                type = keyControllable.isLooping ? .nextLooping : .next
            }
        default:
            super.keyDown(with: event)
        }
        
        if let type = type {
            self.advancePage(to: type, animationDuration: keyControllable.transitionDuration)
        }
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }

    @available(*, unavailable)
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private typealias ViewController = TypedViewController<View>
    private let pageController: PageController<ViewController, Element>
}

internal class TypedViewController<View: NSView>: NSViewController {
    override func loadView() {
        view = View()
    }

    var typedView: View {
        return view as! View
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
