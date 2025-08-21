//
//  UITableView+.swift
//  
//
//  Created by Florian Zand on 19.07.24.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension UITableView {
    internal var indexPaths: [IndexPath] {
        (0..<numberOfSections).flatMap({indexPaths(for: $0)})
    }
    
    /**
     Selects rows at the specified index paths, with an option to animate the selection.
     
     - Parameters:
        - indexPaths: The index paths of the rows.
        - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
        - scrollPosition: A constant that identifies a relative position in the table view (top, middle, bottom) for the rows when scrolling concludes.
     */
    func selectRows<C: Sequence<IndexPath>>(at indexPaths: C, animated: Bool = false, scrollPosition: ScrollPosition) {
        indexPaths.forEach({ selectRow(at: $0, animated: animated, scrollPosition: scrollPosition) })
    }
    
    /**
     Deselects rows at the specified index paths, with an option to animate the deselection.
     
     - Parameters:
        - indexPaths: The index paths of the rows.
        - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
     */
    func deselectRows<C: Sequence<IndexPath>>(at indexPaths: C, animated: Bool = false) {
        indexPaths.forEach({ deselectRow(at: $0, animated: animated) })
    }
    
    /**
     Selects all rows.
     
     - Parameters:
        - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
        - scrollPosition: A constant that identifies a relative position in the table view (top, middle, bottom) for the rows when scrolling concludes.
     */
    func selectAllRows(animated: Bool = false, scrollPosition: ScrollPosition) {
        selectRows(at: indexPaths, animated: animated, scrollPosition: scrollPosition)
    }
    
    /**
     Deselects all rows.
     
     - Parameter animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
     */
    func deselectAllRows(animated: Bool = false) {
        deselectRows(at: indexPathsForSelectedRows ?? [], animated: animated)
    }
    
    /**
     The row index paths for the specified section.
     
     - Parameter section: The section.
     - Returns: The row index paths.
     */
    func indexPaths(for section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        if numberOfSections > section {
            let numberOfRows = numberOfRows(inSection: section)
            for item in 0 ..< numberOfRows {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }
    
    /**
     Selects the row after the currently selected rows.
     
     If no rows are currently selected, the first row is selected.
     
     - Parameters:
        - extend: A Boolean value indicating whether the selection should be extended.
        - scrollPosition: A constant that identifies a relative position in the table view (top, middle, bottom) for the row when scrolling concludes.
     */
    func selectNextRow(byExtendingSelection extend: Bool = false, scrollPosition: ScrollPosition) {
        let allIndexPaths = indexPaths
        let selectionIndexPaths = (indexPathsForSelectedRows ?? []).sorted()
        var nextIndexPath: IndexPath? = nil
        if let indexPath = selectionIndexPaths.last, let index = allIndexPaths.firstIndex(of: indexPath), let next = allIndexPaths[safe: index + 1] {
            nextIndexPath = next
        } else if selectionIndexPaths.isEmpty, let next = allIndexPaths.first {
            nextIndexPath = next
        }
        guard let nextIndexPath = nextIndexPath else { return }
        var indexPaths: Set<IndexPath> = [nextIndexPath]
        if extend {
            indexPaths += selectionIndexPaths
        }
        selectRows(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /**
     Selects the row before the currently selected rows.
     
     If no rows are currently selected, the last row is selected.
     
     - Parameters:
        - extend: A Boolean value indicating whether the selection should be extended.
        - scrollPosition: A constant that identifies a relative position in the table view (top, middle, bottom) for the row when scrolling concludes.
     */
    func selectPreviousRow(byExtendingSelection extend: Bool = false, scrollPosition: ScrollPosition) {
        let allIndexPaths = indexPaths
        let selectionIndexPaths = (indexPathsForSelectedRows ?? []).sorted()
        var previousIndexPath: IndexPath? = nil
        if let indexPath = selectionIndexPaths.sorted().first, let index = allIndexPaths.firstIndex(of: indexPath), let previous = allIndexPaths[safe: index - 1] {
            previousIndexPath = previous
        } else if selectionIndexPaths.isEmpty, let previous = allIndexPaths.last {
            previousIndexPath = previous
        }
        guard let previousIndexPath = previousIndexPath else { return }
        var indexPaths: Set<IndexPath> = [previousIndexPath]
        if extend {
            indexPaths += selectionIndexPaths
        }
        selectRows(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /**
     Returns the table cell at the specified point.
     
     - Parameter point: A point in the local coordinate system of the table view (the table view’s bounds).
     - Returns: The cell object at the corresponding point. In versions of iOS earlier than iOS 15, this method returns `nil` if the cell isn’t visible. In iOS 15 and later, this method returns a non-`nil` cell if the table view retains a prepared cell at the specified location, even if the cell isn’t currently visible.
     */
    func cell(at point: CGPoint) -> UITableViewCell? {
        guard let indexPath = indexPathForRow(at: point) else { return nil }
        return cellForRow(at: indexPath)
    }
    
    /**
     The dictionary of all registered cell nib files.
     
     Each key in the dictionary is the reuse identifier used to register the nib file in the `register(_:forCellReuseIdentifier:)` method. The value of each key is the corresponding UINib object.
     */
    internal var registeredCellNibs: [String: UINib] {
        let dict = value(forKeySafely: "_nibMap") as? [String: UINib]
        return dict ?? [:]
    }

    /**
     The dictionary of all registered cell classes.
     
     Each key in the dictionary is the reuse identifier used to register the class in the `register(_:forCellReuseIdentifier:)` method. The value of each key is the corresponding class.
     */
    internal var registeredCellClasses: [String: Any] {
        let dict = value(forKeySafely: "_cellClassDict") as? [String: Any]
        return dict ?? [:]
    }
    
    /**
     The dictionary of all registered header/footer view nib files.
     
     Each key in the dictionary is the reuse identifier used to register the nib file in the `register(_:forHeaderFooterViewReuseIdentifier:)` method. The value of each key is the corresponding UINib object.
     */
    internal var registeredHeaderFooterNibs: [String: UINib] {
        let dict = value(forKeySafely: "_headerFooterNibMap") as? [String: UINib]
        return dict ?? [:]
    }

    /**
     The dictionary of all registered header/footer view classes.
     
     Each key in the dictionary is the reuse identifier used to register the class in the `register(_:forHeaderFooterViewReuseIdentifier:)` method. The value of each key is the corresponding class.
     */
    internal var registeredHeaderFooterClasses: [String: Any] {
        let dict = value(forKeySafely: "_headerFooterClassDict") as? [String: Any]
        return dict ?? [:]
    }
}
#endif
