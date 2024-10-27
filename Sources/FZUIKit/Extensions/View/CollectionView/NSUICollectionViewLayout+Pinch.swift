//
//  NSUICollectionViewLayout+Pinch.swift
//  
//
//  Created by Florian Zand on 27.10.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import FZSwiftUtils
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

protocol InteractiveCollectionViewLayout: NSUICollectionViewLayout {
    var columns: Int { get set }
    var columnRange: ClosedRange<Int> { get }
    var isPinchable: Bool { get }
    #if os(macOS)
    var keyDownColumnChangeAmount: Int { get }
    var keyDownColumnChangeAmountAlt: Int { get }
    var keyDownColumnChangeAmountShift: Int { get }
    #endif
    func invalidateLayout(animated: Bool)
}

extension InteractiveCollectionViewLayout {
    var needsGestureRecognizer: Bool {
        #if os(macOS)
        isPinchable || keyDownColumnChangeAmount != 0 || keyDownColumnChangeAmountAlt != 0 || keyDownColumnChangeAmountShift != 0
        #else
        isPinchable
        #endif
    }
}

#if os(macOS) || os(iOS)
extension NSUICollectionView {
    var columnInteractionGestureRecognizer: ColumnInteractionGestureRecognizer? {
        get { getAssociatedValue("columnInteractionGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "columnInteractionGestureRecognizer") }
    }
    
    func setupColumnInteractionGestureRecognizer(_ needsRecognizer: Bool) {
        if needsRecognizer {
            if columnInteractionGestureRecognizer == nil {
                columnInteractionGestureRecognizer = .init()
                addGestureRecognizer(columnInteractionGestureRecognizer!)
            }
            #if os(macOS)
            columnInteractionGestureRecognizer!.setupKeyDownMonitor()
            #endif
        } else if !needsRecognizer {
            columnInteractionGestureRecognizer?.removeFromView()
            columnInteractionGestureRecognizer = nil
        }
    }
    
    class ColumnInteractionGestureRecognizer: NSUIMagnificationGestureRecognizer {
        
        var initalColumns: Int = 0
        var displayingIndexPaths: [IndexPath] = []
        
        #if os(macOS)
        var keyDownMonitor: NSEvent.Monitor?

        func setupKeyDownMonitor() {
            if let interactiveLayout = interactiveLayout, interactiveLayout.keyDownColumnChangeAmount != 0 || interactiveLayout.keyDownColumnChangeAmountShift != 0 || interactiveLayout.keyDownColumnChangeAmountAlt != 0 {
                guard keyDownMonitor == nil else { return }
                keyDownMonitor = NSEvent.localMonitor(for: .keyDown) { event in
                    guard event.keyCode == 44 || event.keyCode == 30, self.collectionView?.isFirstResponder == true else { return event }
                    self.updateColumns(with: event)
                    return nil
                }
            } else {
                keyDownMonitor = nil
            }
        }
        
        func updateColumns(with event: NSEvent) {
            guard event.keyCode == 44 || event.keyCode == 30, collectionView?.isFirstResponder == true, let interactiveLayout = interactiveLayout else { return }
            let addition = event.modifierFlags.contains(.shift) ? interactiveLayout.keyDownColumnChangeAmountShift : event.modifierFlags.contains(.command) ? interactiveLayout.keyDownColumnChangeAmountAlt : interactiveLayout.keyDownColumnChangeAmount
            displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
            if addition == -1 {
                columns = event.keyCode == 44 ? columnRange.upperBound : columnRange.lowerBound
            } else {
                columns += event.keyCode == 44 ? addition : -addition
            }
            scrollToDisplayingIndexPaths()
        }
        #endif
        
        var collectionView: NSUICollectionView? {
            view as? NSUICollectionView
        }
        
        var collectionViewLayout: NSUICollectionViewLayout? {
            collectionView?.collectionViewLayout
        }
        
        var interactiveLayout: InteractiveCollectionViewLayout? {
            collectionViewLayout as? InteractiveCollectionViewLayout
        }
        
        var columnRange: ClosedRange<Int> {
            interactiveLayout?.columnRange ?? 1...12
        }
        
        var isPinchable: Bool {
            interactiveLayout?.isPinchable ?? false
        }
                
        var columns: Int {
            get { interactiveLayout?.columns ?? 2 }
            set {
                let newValue = newValue.clamped(to: columnRange)
                guard newValue != columns, let interactiveLayout = interactiveLayout else { return }
                interactiveLayout.columns = newValue
                interactiveLayout.invalidateLayout(animated: true)
            }
        }
               
        override var state: NSUIGestureRecognizer.State {
            didSet {
                guard isPinchable else { return }
                switch state {
                case .began:
                    initalColumns = columns
                    // displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
                case .changed:
                    #if os(macOS)
                    columns = initalColumns + Int((magnification/(-0.5)).rounded())
                    #else
                    columns = initalColumns + Int((scale/(-0.5)).rounded())
                    #endif
                    // scrollToDisplayingIndexPaths()
                default: break
                }
            }
        }
        
        func scrollToDisplayingIndexPaths() {
            guard !displayingIndexPaths.isEmpty, let collectionView = collectionView else { return }
            #if os(macOS)
            collectionView.scrollToItems(at: Set(displayingIndexPaths), scrollPosition: .centeredVertically)
            #else
            collectionView.scrollToItems(at: Set(displayingIndexPaths), at: .centeredVertically)
            #endif
        }
    }
}
#endif

#endif
