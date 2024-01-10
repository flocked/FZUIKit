//
//  UITableViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 14.09.23.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UITableViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration that creates, configurate and returns each of the cells for the table view from the data the diffable data source provides.
     */
    convenience init<Cell: UITableViewCell>(tableView: UITableView, cellRegistration: UITableView.CellRegistration<Cell, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            return tableView.dequeueReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}
#endif
