//
//  ArrayDataSource.swift
//  Pods
//
//  Created by mrandall on 10/17/15.
//
//

import Foundation

//MARK: - ArrayDataSource

//Array Datasource for a UITableView or a UICollectionView
public class ArrayDataSource<T, U>: DataSource, UITableViewDataSource, UICollectionViewDataSource, SectionDataSource, SectionDataSourceData {
    
    ///reusableIdentifier to dequeue the cell
    let cellReuseIdentifier: String
    
    ///closure called to configure a cell on creation
    var cellConfiguration: ((cell: U, indexPath: NSIndexPath, data: T) -> ())?
    
    ///Data to display in tableview
    public var data: [T]
    
    ///ComponentDataSource section index
    public var sectionIndex = 0
    
    //MARK: - Init
    
    public typealias CellConfiguration = (cell: U, indexPath: NSIndexPath, data: T) -> Void
    
    /// Init
    ///
    /// - Parameter data: T
    /// - Parameter cellIdentifier: String for the reusableIdentifier used to dequeue a cell
    /// - Parameter cellConfiguration: (cell: U, indexPath: NSIndexPath, data: T) closure is called for each cell created
    public init(data: [T], cellReuseIdentifier: String, cellConfiguration: CellConfiguration?) {
        self.data = data
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellConfiguration = cellConfiguration
    }
    
    //MARK: - Data
    
    /// Provide data for cell indexPath
    ///
    /// - Parameter indexPath: NSIndexPath of the cell
    /// - Returns T for a give cell
    public func dataForIndexPath(indexPath: NSIndexPath) -> T {
        return data[indexPath.row]
    }
    
    //MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = self.dataForIndexPath(indexPath)
        let cellReuseIdentifier = delegate?.dataSource(self, cellReuseIdentifierForIndexPath: indexPath, data: data as! AnyObject) ?? self.cellReuseIdentifier
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let cellConfiguration = cellConfiguration {
            cellConfiguration(cell: cell as! U, indexPath: indexPath, data: data)
        }
        
        return cell
    }
    
    //MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let data = dataForIndexPath(indexPath)
        let cellReuseIdentifier = delegate?.dataSource(self, cellReuseIdentifierForIndexPath: indexPath, data: data as! AnyObject) ?? self.cellReuseIdentifier
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        if let cellConfiguration = self.cellConfiguration {
            cellConfiguration(cell: cell as! U, indexPath: indexPath, data: data)
        }
        
        return cell
    }
}