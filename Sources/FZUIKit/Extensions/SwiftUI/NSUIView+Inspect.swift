//
//  File.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

#if os(iOS) || os(macOS)
import SwiftUI
internal extension NSUIView {
    func ancestor<ViewType: NSUIView>(ofType _: ViewType.Type) -> ViewType? {
        var view = superview

        while let s = view {
            if let typed = s as? ViewType {
                return typed
            }
            view = s.superview
        }

        return nil
    }

    var host: NSUIView? {
        var view = superview

        while let s = view {
            if NSStringFromClass(type(of: s)).contains("ViewHost") {
                return s
            }
            view = s.superview
        }

        return nil
    }

    func sibling<ViewType: NSUIView>(ofType type: ViewType.Type) -> ViewType? {
        guard let superview = superview, let index = superview.subviews.firstIndex(of: self) else { return nil }

        var views = superview.subviews
        views.remove(at: index)

        for subview in views.reversed() {
            if let typed = subview as? ViewType {
                return typed
            } else if let typed = subview.child(ofType: type) {
                return typed
            }
        }

        return nil
    }

    func child<ViewType: NSUIView>(ofType type: ViewType.Type) -> ViewType? {
        for subview in subviews {
            if let typed = subview as? ViewType {
                return typed
            } else if let typed = subview.child(ofType: type) {
                return typed
            }
        }

        return nil
    }
}

internal struct Inspector {
    var hostView: NSUIView
    var sourceView: NSUIView
    var sourceController: NSUIViewController

    func ancestor<ViewType: NSUIView>(ofType _: ViewType.Type) -> ViewType? {
        hostView.ancestor(ofType: ViewType.self)
    }

    func sibling<ViewType: NSUIView>(ofType _: ViewType.Type) -> ViewType? {
        hostView.sibling(ofType: ViewType.self)
    }

    func child<ViewType: NSUIView>(ofType _: ViewType.Type) -> ViewType? {
        hostView.child(ofType: ViewType.self)
    }
}

extension View {
    private func inject<Wrapped>(_ content: Wrapped) -> some View where Wrapped: View {
        overlay(content.frame(width: 0, height: 0))
    }

    func inspect<ViewType: NSUIView>(selector: @escaping (_ inspector: Inspector) -> ViewType?, customize: @escaping (ViewType) -> Void) -> some View {
        inject(InspectionView(selector: selector, customize: customize))
    }

    func controller(_ customize: @escaping (NSUIViewController?) -> Void) -> some View {
        inspect { inspector in
            inspector.sourceController.view
        } customize: { view in
            customize(view.parentController)
        }
    }
}

private struct InspectionView<ViewType: NSUIView>: View {
    let selector: (Inspector) -> ViewType?
    let customize: (ViewType) -> Void

    var body: some View {
        Representable(parent: self)
    }
}

private class SourceView: NSUIView {
    required init() {
        super.init(frame: .zero)
        isHidden = true
        #if os(iOS)
        isUserInteractionEnabled = false
        #endif
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif

#if os(iOS)
private extension InspectionView {
    struct Representable: UIViewRepresentable {
        let parent: InspectionView

        func makeUIView(context _: Context) -> UIView { .init() }
        func updateUIView(_ view: UIView, context _: Context) {
            DispatchQueue.main.async {
                guard let host = view.host else { return }

                let inspector = Inspector(
                    hostView: host,
                    sourceView: view,
                    sourceController: view.parentController
                        ?? view.window?.rootViewController
                        ?? UIViewController()
                )

                guard let targetView = parent.selector(inspector) else { return }
                parent.customize(targetView)
            }
        }
    }
}

#elseif os(macOS)
private extension InspectionView {
    struct Representable: NSViewRepresentable {
        let parent: InspectionView

        func makeNSView(context _: Context) -> NSView {
            .init(frame: .zero)
        }

        func updateNSView(_ view: NSView, context _: Context) {
            DispatchQueue.main.async {
                guard let host = view.host else { return }

                let inspector = Inspector(
                    hostView: host,
                    sourceView: view,
                    sourceController: view.parentController ?? NSViewController(nibName: nil, bundle: nil)
                )

                guard let targetView = parent.selector(inspector) else { return }
                parent.customize(targetView)
            }
        }
    }
}
#endif
