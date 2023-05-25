//
//  PagingView.swift
//  PageController
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation

    public class PagingView<View: NSView, Element>: NSView {
        private typealias ViewController = TypedViewController<View>
        typealias Handler = (View, Element) -> Void

        private let pageController: PageController<ViewController, Element>

        func select(_ index: Int, duration: CGFloat = 0.0) {
            pageController.select(index, duration: duration)
        }

        func advance(to type: NSPageController.AdvanceType, duration: CGFloat = 0.0) {
            pageController.advance(to: type, duration: duration)
        }

        var transitionStyle: NSPageController.TransitionStyle {
            get { pageController.transitionStyle }
            set { pageController.transitionStyle = newValue }
        }

        var keyControllable: NSPageController.KeyboardControl {
            get { pageController.keyboardControl }
            set { pageController.keyboardControl = newValue }
        }

        var swipeControllable: Bool {
            get { pageController.isSwipeable }
            set { pageController.isSwipeable = newValue }
        }

        var selectedIndex: Int {
            get { return pageController.selectedIndex }
            set { pageController.selectedIndex = newValue }
        }

        var elements: [Element] {
            get { return pageController.elements }
            set { pageController.elements = newValue }
        }

        init(frame: CGRect, elements: [Element] = [], handler: @escaping Handler) {
            pageController = PageController<ViewController, Element>(handler: {
                viewController, element in
                handler(viewController.typedView, element)
            })
            pageController.elements = elements
            super.init(frame: frame)
            addSubview(withConstraint: pageController.view)
        }

        convenience init(elements: [Element] = [], handler: @escaping Handler) {
            self.init(frame: .zero, elements: elements, handler: handler)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    internal class TypedViewController<View: NSView>: NSViewController {
        override func loadView() {
            view = View()
        }

        var typedView: View {
            return view as! View
        }
    }
#endif
