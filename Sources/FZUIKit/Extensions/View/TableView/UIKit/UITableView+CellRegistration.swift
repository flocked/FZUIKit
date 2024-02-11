//
//  UITableView+CellRegistration.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension UITableView {
    /**
     A registration for the table view’s cells.

     Use a cell registration to register table cell views with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.

     The following example creates a cell registration for cells of type `UITableViewCell`. Each cells textfield displays its item.

     ```swift
     let cellRegistration = UITableView.CellRegistration<UITableViewCell, String> { cell, indexPath, string in
        var contentConfiguration = cell.defaultContentConfiguration()

        contentConfiguration.text = string
        contentConfiguration.textProperties.color = .lightGray

        cell.contentConfiguration = contentConfiguration
     }
     ```

     After you create a cell registration, you pass it in to ``UIKit/UITableView/dequeueConfiguredReusableCell(using:for:item:)``, which you call from your data source’s cell provider.

     ```swift
     dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) {
     tableView, indexPath, item in
        return tableView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
     }
     ```

     `UITableViewDiffableDataSource` provides a convenient initalizer:

     ```swift
     dataSource = UITableViewDiffableDataSource(collectionView: collectionView, cellRegistration: cellRegistration)
     ```

     You don’t need to call table views  `register(_:forIdentifier:)`. The table view registers your cell automatically when you pass the cell registration to ``UIKit/UITableView/dequeueConfiguredReusableCell(using:for:item:)``.

     ## Column Identifiers

     With `columnIdentifiers` you can restrict the cell to specific table columns when used with ``TableViewDiffableDataSource`` using ``TableViewDiffableDataSource/init(tableView:cellRegistrations:)``. You only have to provide column identifiers when your table view has multiple columns and the columns should use different types of table cells. The data source will use the matching cell registration for each column.

     - Important: Do not create your cell registration inside a `UITableViewDiffableDataSource.CellProvider` closure; doing so prevents cell reuse.
     */
    struct CellRegistration<Cell, Item> where Cell: UITableViewCell {
        let identifier: String
        let nib: UINib?
        let handler: Handler

        // MARK: Creating a cell registration

        /**
         Creates a cell registration with the specified registration handler.

         - Parameters:
            - handler: The handler to configurate the cell.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            nib = nil
            identifier = UUID().uuidString
            UITableView.swizzleReconfigureRow()
        }

        /**
         Creates a cell registration with the specified registration handler and nib file.

         - Parameters:
            - nib: The nib of the cell.
            - columnIdentifiers: The identifiers of the table columns. The default value is `nil`, which indicates that the cell isn't restricted to specific columns when used with ``TableViewDiffableDataSource``.
            - handler: The handler to configurate the cell.
         */
        public init(nib: UINib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            identifier = UUID().uuidString
            UITableView.swizzleReconfigureRow()
        }

        /// A closure that handles the cell registration and configuration.
        public typealias Handler = (_ cellView: Cell, _ indexPath: IndexPath
                                    , _ item: Item) -> Void

        func makeCellView(_ tableView: UITableView, _ indexPath: IndexPath, _ item: Item) -> Cell {
            register(tableView)
            if tableView.reconfigureIndexPaths.contains(indexPath), let cell = tableView.cellForRow(at: indexPath) as? Cell {
                handler(cell, indexPath, item)
                return cell
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell {
                handler(cell, indexPath, item)
                return cell
            }
            return Cell()
        }

        func register(_ tableView: UITableView) {
            if tableView.registeredCellIdentifiers.contains(identifier) == false {
                if let nib = nib {
                    tableView.register(nib, forCellReuseIdentifier: identifier)
                } else {
                    tableView.register(Cell.self, forCellReuseIdentifier: identifier)
                }
            }
        }
    }
}

public extension UITableView {
    func dequeueConfiguredReusableCell<Cell, Item>(using registration: UITableView.CellRegistration<Cell, Item>, for indexPath: IndexPath, item: Item) -> Cell where Cell : UITableViewCell {
        registration.makeCellView(self, indexPath, item)
    }
}

extension UITableView {
    static func swizzleReconfigureRow() {
        guard didSwizzleReconfigureRow == false else { return }
        didSwizzleReconfigureRow = true
        if #available(iOS 15.0, tvOS 15.0, *) {
            do {
                try Swizzle(UITableView.self) {
                    #selector(UITableView.reconfigureRows(at:)) <->  #selector(UITableView.swizzled_reconfigureRows(at:))
                }
            } catch {
                Swift.print(error)
            }
        }
    }
    
    static var didSwizzleReconfigureRow: Bool {
        get { getAssociatedValue(key: "didSwizzleReconfigureRow", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleReconfigureRow", object: self) }
    }
    
    @objc func swizzled_reconfigureRows(at indexPaths: [IndexPath]) {
        reconfigureIndexPaths = indexPaths
        self.swizzled_reconfigureRows(at: indexPaths)
        reconfigureIndexPaths = []
    }
    
    var reconfigureIndexPaths: [IndexPath] {
        get { getAssociatedValue(key: "reconfigureIndexPaths", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "reconfigureIndexPaths", object: self) }
    }
    
    var registeredCellIdentifiers: [String] {
        get { getAssociatedValue(key: "registeredCellIdentifiers", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "registeredCellIdentifiers", object: self) }
    }
}
#endif
