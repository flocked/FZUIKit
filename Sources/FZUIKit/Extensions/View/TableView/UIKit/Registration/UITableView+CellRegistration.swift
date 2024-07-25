//
//  UITableView+CellRegistration.swift
//
//
//  Created by Florian Zand on 25.07.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UITableView {
    /**
     Dequeues a configured reusable cell object.
     
     - Parameters:
        - registration: The cell registration for configuring the cell object. See ``CellRegistration``.
        - indexPath: The index path that specifies the location of the cell in the table view.
        - item: The item that provides data for the cell.
     
     - Returns: A configured reusable cell object.
     */
    public func dequeueConfiguredReusableCell<Cell, Item>(using registration: CellRegistration<Cell, Item>, for indexPath: IndexPath, item: Item) -> Cell where Cell : UITableViewCell {
        return registration.makeCell(for: self, indexPath: indexPath, item: item)
    }
    
    /**
     A registration for the table view’s cells.
     
     Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data item type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
     
     The following example creates a cell registration for cells of type `UITableViewCell`. It creates a content configuration with a system default style, customizes the content and appearance of the configuration, and then assigns the configuration to the cell.
     
     ```swift
     let cellRegistration = UITableView.CellRegistration<UITableViewCell, Int> { cell, indexPath, item in
         
         var contentConfiguration = cell.defaultContentConfiguration()
         
         contentConfiguration.text = "\(item)"
         contentConfiguration.textProperties.color = .lightGray
         
         cell.contentConfiguration = contentConfiguration
     }
     ```
     
     After you create a cell registration, you pass it in to ``dequeueConfiguredReusableCell(using:for:item:)``, which you call from your data source’s cell provider.
     
     ```swift
     dataSource = UITableViewDiffableDataSource<Section, Int>(tableView: tableView) {
         (tableView: UITableView, indexPath: IndexPath, itemIdentifier: Int) -> UITableViewCell? in
         
         return tableView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                             for: indexPath,
                                                             item: itemIdentifier)
     }
     ```
     
     You don’t need to call `register(_:forCellWithReuseIdentifier:)` The table view registers your cell automatically when you pass the cell registration to ``dequeueConfiguredReusableCell(using:for:item:)``.
     */
    public class CellRegistration<Cell, Item> where Cell: UITableViewCell, Item: Hashable {
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = (_ cell: Cell, _ indexPath: IndexPath, _ itemIdentifier: Item) -> Void

        let nib: UINib?
        let handler: Handler
        let id = UUID().uuidString
        
        /// Creates a cell registration with the specified registration handler.
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
        }
        
        /// Creates a cell registration with the specified registration handler and nib file.
        public init(nib: UINib?, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nib
        }
        
        func makeCell(for tableView: UITableView, indexPath: IndexPath, item: Item) -> Cell {
            register(tableView)
            let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! Cell
            handler(cell, indexPath, item)
            return cell
        }
        
        func register(_ tableView: UITableView) {
            if let nib = nib, tableView.registeredCellNibs[id] == nil {
                tableView.register(nib, forCellReuseIdentifier: id)
            } else if tableView.registeredCellClasses[id] == nil {
                tableView.register(Cell.self, forCellReuseIdentifier: id)
            }
        }
        
        func unregister(_ tableView: UITableView) {
            let any: AnyClass? = nil
            tableView.register(any, forCellReuseIdentifier: id)
        }
    }
}

extension UITableViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration that configurates closure that creates and returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init<Cell: UITableViewCell>(tableView: UITableView, cellRegistration: UITableView.CellRegistration<Cell, ItemIdentifierType>) {
        self.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            tableView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
}

#endif
