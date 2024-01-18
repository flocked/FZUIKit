//
//  UITableViewCell+.swift
//
//
//  Created by Florian Zand on 18.01.24.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

extension UITableViewCell {
    /// The table view that owns the cell.
    var tableView: UITableView? {
        firstSuperview(for: UITableView.self)
    }
    
    /// The previous cell in the table view, or `nil` if there isn't a previous cell or the cell isn't in a table view.
    @objc open var previousCell: UITableViewCell? {
        if let indexPath = tableView?.indexPath(for: self), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            return tableView?.cellForRow(at: previousIndexPath)
        }
        return nil
    }

    /// The next cell in the table view, or `nil` if there isn't a next cell or the cell isn't in a table view.
    @objc open var nextCell: UITableViewCell? {
        if let indexPath = tableView?.indexPath(for: self), indexPath.item + 1 < (self.tableView?.numberOfRows(inSection: indexPath.section) ?? -10) {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return tableView?.cellForRow(at: nextIndexPath)
        }
        return nil
    }
}

#endif
