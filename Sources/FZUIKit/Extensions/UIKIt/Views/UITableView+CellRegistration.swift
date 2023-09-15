//
//  UITableView+CellRegistration.swift
//
//
//  Created by Florian Zand on 15.09.23.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension UITableView {
    /**
     Dequeues a configured reusable cell object.
     
     - Parameters:
        - registration: The cell registration for configuring the cell object. See `UITableView.CellRegistration.
        - indexPath: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - item: The item that provides data for the cell.
     
     - returns:A configured reusable cell object.
     */
    func dequeueReusableCell<Cell, Item>(using registration: CellRegistration<Cell, Item>, for indexPath: IndexPath, item: Item) -> Cell where Cell: UITableViewCell {
        return registration.makeCell(self, indexPath, item)
    }
    
    /**
     A registration for the table view’s cells.
     
     Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
     
     The following example creates a cell registration for cells of type `UITableViewCell`. Each cells textfield displays its element.
     
     ```swift
     let cellRegistration = UITableView.CellRegistration<UITableViewCell, String> { cell, indexPath, string in
     cell.textField.stringValue = string
     }
     ```
     
     After you create a cell registration, you pass it in to ``UIKit/UITableView/makeCell(using:for:item:)``, which you call from your data source’s cell provider.
     ```swift
     dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) {
     tableView, indexPath, item in
    return tableView.makeCell(using: cellRegistration, for: indexPath, item: item)
     }
     ```
     
     `UITableViewDiffableDataSource` provides a convenient initalizer:
     ```swift
     dataSource = UITableViewDiffableDataSource<Section, String>(collectionView: collectionView, cellRegistration: cellRegistration)
     ```
     
     You don’t need to call  `register(_:forCellReuseIdentifier:). The table view registers your cell automatically when you pass the cell registration to ``UIKit/UITableView/makeCell(using:for:item:)``.
          
     - Important: Do not create your cell registration inside a `UITableViewDiffableDataSource.CellProvider` closure; doing so prevents cell reuse.
     */
    struct CellRegistration<Cell, Item> where Cell: UITableViewCell  {
        
        internal let reuseIdentifier: String
        private let nib: UINib?
        private let handler: Handler
        
        // MARK: Creating a cell registration
        
        /**
         Creates a cell registration with the specified registration handler.
         
         - Parameters:
         - handler: The handler to configurate the cell.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.reuseIdentifier = String(describing: Cell.self)
        }
        
        /**
         Creates a cell registration with the specified registration handler and nib file.
         
         - Parameters:
         - nib: The nib of the cell.
         - handler: The handler to configurate the cell.
         */
        public init(nib: UINib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.reuseIdentifier = String(describing: Cell.self) + String(describing: nib.self)
        }
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = ((_ cell: Cell, _ indexPath: IndexPath, _ item: Item)->(Void))
        
        internal func makeCell(_ tableView: UITableView, _ indexPath: IndexPath, _ element: Item) -> Cell {
            self.registerIfNeeded(for: tableView)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
            self.handler(cell, indexPath, element)
            return cell
        }
        
        internal func registerIfNeeded(for tableView: UITableView) {
            if tableView.registeredCellIdentifiers.contains(reuseIdentifier) == false {
                if let nib = self.nib {
                    tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
                } else {
                    tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
                }
                tableView.registeredCellIdentifiers.append(reuseIdentifier)
            }
        }
        
        internal func unregister(for tableView: UITableView) {
            if let index = tableView.registeredCellIdentifiers.firstIndex(of: reuseIdentifier) {
                if self.nib != nil {
                    let any: UINib? = nil
                    tableView.register(any, forCellReuseIdentifier: reuseIdentifier)
                } else {
                    let any: AnyClass? = nil
                    tableView.register(any, forCellReuseIdentifier: reuseIdentifier)
                }
                tableView.registeredCellIdentifiers.remove(at: index)
            }
        }
    }
}

internal extension UITableView {
    var registeredCellIdentifiers: [String]   {
        get { getAssociatedValue(key: "registeredCellIdentifiers", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "registeredCellIdentifiers", object: self) }
    }
}
#endif
