//
//  NSUIView+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIView {
    func removeAllConstraints() {
        var _superview = superview
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? NSUIView, first == self {
                    superview.removeConstraint(constraint)
                }

                if let second = constraint.secondItem as? NSUIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }

            _superview = superview.superview
        }
        removeConstraints(constraints)
    }

    func sendToFront() {
        if let superview = superview {
            superview.addSubview(self)
        }
    }

    func sendToBack() {
        if let superview = superview {
            #if os(macOS)
            superview.addSubview(self, positioned: .below, relativeTo: nil)
            #else
            superview.insertSubview(self, at: 0)
            #endif
        }
    }
    
    func enclosingRect(for subviews: [NSUIView]) -> CGRect {
        var enlosingFrame = CGRect.zero
        for subview in subviews {
            let frame = convert(subview.bounds, from: subview)
            enlosingFrame = CGRectUnion(enlosingFrame, frame)
        }
        return enlosingFrame
    }

    func insertSubview(_ view: NSUIView, at index: Int) {
        guard index < self.subviews.count else { return }
        #if os(macOS)
        var subviews = self.subviews
        subviews.insert(view, at: index)
        self.subviews = subviews
        #elseif canImport(UIKit)
        insertSubview(view, belowSubview: self.subviews[index])
        #endif
    }

    func moveSubview(_ view: NSUIView, to toIndex: Int) {
        if let index = subviews.firstIndex(of: view) {
            moveSubview(at: index, to: toIndex)
        }
    }

    func moveSubviews(_ views: [NSUIView], to toIndex: Int, reorder: Bool = false) {
        var indexSet = IndexSet()
        for view in views {
            if let index = subviews.firstIndex(of: view), indexSet.contains(index) == false {
                indexSet.insert(index)
            }
        }
        if indexSet.isEmpty == false {
            moveSubviews(at: indexSet, to: toIndex, reorder: reorder)
        }
    }

    func moveSubview(at index: Int, to toIndex: Int) {
        moveSubviews(at: IndexSet(integer: index), to: toIndex)
    }

    func moveSubviews(at indexes: IndexSet, to toIndex: Int, reorder: Bool = false) {
        let subviewsCount = subviews.count
        if subviews.isEmpty == false {
            if toIndex >= 0, toIndex < subviewsCount {
                let indexes = IndexSet(Array(indexes).filter { $0 < subviewsCount })
                #if os(macOS)
                var subviews = self.subviews
                if reorder {
                    for index in indexes.reversed() {
                        subviews.move(from: IndexSet(integer: index), to: toIndex)
                    }
                } else {
                    subviews.move(from: indexes, to: toIndex)
                }
                self.subviews = subviews
                #elseif canImport(UIKit)
                var below = self.subviews[toIndex]
                let subviewsToMove = (reorder == true) ? self.subviews[indexes].reversed() : self.subviews[indexes]
                for subviewToMove in subviewsToMove {
                    insertSubview(subviewToMove, belowSubview: below)
                    below = (reorder == true) ? subviews[toIndex] : subviewToMove
                }
                #endif
            }
        }
    }

    func firstSuperview<V: NSUIView>(for viewClass: V.Type) -> V? {
        return self.firstSuperview(where: {$0 is V}) as? V
    }
    
    func firstSuperview(where predicate: (NSUIView)->(Bool)) -> NSUIView? {
        if let superview = superview {
            if predicate(superview) == true {
                return superview
            }
            return superview.firstSuperview(where: predicate)
        }
        return nil
    }

    
    func subviews<V>(type _: V.Type, depth: Int? = nil) -> [V] {
        self.subviews(depth: depth ?? 0).compactMap({$0 as? V})
    }
    
    func subviews(where predicate: (NSUIView)->(Bool), depth: Int? = nil) -> [NSUIView] {
        self.subviews(depth: depth ?? 0).filter({predicate($0) == true})
    }
    
    func removeSubviews(type: NSUIView.Type, depth: Int? = nil) {
        subviews(type: type, depth: depth).forEach { $0.removeFromSuperview() }
    }
    
    func removeSubviews(where predicate: (NSUIView)->(Bool), depth: Int? = nil) {
        subviews(where: predicate, depth: depth).forEach { $0.removeFromSuperview() }
    }
    
    func firstSubview<V>(type _: V.Type, depth: Int? = nil) -> V? {
        self.firstSuperview(where: { $0 is V }) as? V
    }
    
    func firstSubview(where predicate: (NSUIView)->(Bool), depth: Int? = nil) -> NSUIView? {
        let depth = depth ?? 0
        
        if let found = subviews.first(where: predicate) {
            return found
        }
        
        if depth > 0 {
            for subview in self.subviews {
                if let found = subview.firstSubview(where: predicate, depth: depth - 1) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    func subviews(depth: Int) -> [NSUIView] {
        if depth > 0 {
            return subviews + subviews.flatMap { $0.subviews(depth: depth - 1) }
        } else {
            return subviews
        }
    }
}
