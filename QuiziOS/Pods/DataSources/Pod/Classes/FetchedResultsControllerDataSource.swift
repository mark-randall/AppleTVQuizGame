//
//  FetchedResultsControllerDataSource.swift
//  Pods
//
//  Created by mrandall on 10/17/15.
//
//

import Foundation
import CoreData

//MARK: - NSFetchedResultsControllerDataSource

public class FetchedResultsControllerDataSource<T, U>: DataSource, SectionDataSource, SectionDataSourceData {
    
    ///ComponentDataSource section index
    public var sectionIndex = 0
    
    ///reusableIdentifier to dequeue the cell
    let cellReuseIdentifier: String
    
    ///closure called to configure a cell on creation
    var cellConfiguration: ((cell: U, indexPath: NSIndexPath, data: T) -> ())?

    ///FetchedResultsController for section
    var fetchedResultsController: NSFetchedResultsController
    
    //MARK: - Init
    
    public typealias CellConfiguration = (cell: U, indexPath: NSIndexPath, data: T) -> Void
    
    /// Init
    ///
    /// - Parameter data: T
    /// - Parameter cellIdentifier: String for the reusableIdentifier used to dequeue a cell
    /// - Parameter cellConfiguration: (cell: U, indexPath: NSIndexPath, data: T) closure is called for each cell created
    public init(fetchedResultsController: NSFetchedResultsController, cellReuseIdentifier: String, cellConfiguration: ((cell: U, indexPath: NSIndexPath, data: T) -> ())?) {
        self.fetchedResultsController = fetchedResultsController
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellConfiguration = cellConfiguration
    }
    
    //MARK: - Data
    
    /// Provide data for cell indexPath
    ///
    /// - Parameter indexPath: NSIndexPath of the cell
    /// - Returns T for a give cell
    public func dataForIndexPath(indexPath: NSIndexPath) -> T {
        return self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! T
    }
}

public class TableViewFetchedResultsControllerDataSource<T, U>: FetchedResultsControllerDataSource<T, U>, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    //UITableView reference used by NSFetchedResultsControllerDelegate
    public weak var tableView: UITableView?
    
    
    /// Init
    ///
    /// - Parameter tableView: UITableView
    /// - Parameter data: T
    /// - Parameter cellIdentifier: String for the reusableIdentifier used to dequeue a cell
    /// - Parameter cellConfiguration: (cell: U, indexPath: NSIndexPath, data: T) closure is called for each cell created
    public init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController, cellReuseIdentifier: String, cellConfiguration: CellConfiguration?) {
        
        self.tableView = tableView
        super.init(fetchedResultsController: fetchedResultsController, cellReuseIdentifier: cellReuseIdentifier, cellConfiguration: cellConfiguration)
        self.fetchedResultsController.delegate = self
    }
    
    //Mark: - UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let data = self.dataForIndexPath(indexPath)
        let cellReuseIdentifier = delegate?.dataSource(self, cellReuseIdentifierForIndexPath: indexPath, data: data as! AnyObject) ?? self.cellReuseIdentifier
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let cellConfiguration = self.cellConfiguration {
            cellConfiguration(cell: cell as! U, indexPath: indexPath, data: data)
        }
        
        return cell
    }
    
    //Mark: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.beginUpdates()
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard let tableView = self.tableView else {
            return
        }
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!), let cellConfiguration = self.cellConfiguration {
                cellConfiguration(cell: cell as! U, indexPath: indexPath!, data: anObject as! T)
            }
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.endUpdates()
    }
}

public class CollectionViewFetchedResultsControllerDataSource<T, U>: FetchedResultsControllerDataSource<T, U>, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //UITableView reference used by NSFetchedResultsControllerDelegate
    public weak var collectionView: UICollectionView?
    
    /// Init
    ///
    /// - Parameter collectionView: UICollectionView
    /// - Parameter data: T
    /// - Parameter cellIdentifier: String for the reusableIdentifier used to dequeue a cell
    /// - Parameter cellConfiguration: (cell: U, indexPath: NSIndexPath, data: T) closure is called for each cell created
    public init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, cellReuseIdentifier: String, cellConfiguration: CellConfiguration?) {
        
        self.collectionView = collectionView
        super.init(fetchedResultsController: fetchedResultsController, cellReuseIdentifier: cellReuseIdentifier, cellConfiguration: cellConfiguration)
        self.fetchedResultsController.delegate = self
    }
    
    //Mark: - UITableViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let data = self.dataForIndexPath(indexPath)
        let cellReuseIdentifier = delegate?.dataSource(self, cellReuseIdentifierForIndexPath: indexPath, data: data as! AnyObject) ?? self.cellReuseIdentifier
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let cellConfiguration = self.cellConfiguration {
            cellConfiguration(cell: cell as! U, indexPath: indexPath, data: data)
        }
        
        return cell
    }
    
    //Mark: - NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView?.reloadData()
    }
}
