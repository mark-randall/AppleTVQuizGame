//
//  CompositeDataSources.swift
//
//  Created by mrandall on 8/27/15.
//

import UIKit

public protocol SectionDataSource {
    
    ///section individual data source is used populate
    ///Required for NSFetchedResultsController driven ComponentDataSource data sources
    var sectionIndex: Int { get set }
}

public protocol SectionDataSourceData {
    
    typealias T
    
    func dataForIndexPath(indexPath: NSIndexPath) -> T
}

///Allows multiple SectionDataSource to be composed using one per section
public class CompositeDataSource: DataSource, UITableViewDataSource, UICollectionViewDataSource {
    
    ///Data sources used per section
    public var dataSourcesPerSection: [SectionDataSource] = [] {
        didSet {
            var i = 0
            for var ds in self.dataSourcesPerSection {
                ds.sectionIndex = ++i
            }
            //self.dataSourcesPerSection.forEach { $0.sectionIndex = ++i }
        }
    }
    
    //MARK: - Init
    
    public init(dataSourcesPerSection: [SectionDataSource]) {
        self.dataSourcesPerSection = dataSourcesPerSection
    }
        
    //MARK - UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int { return self.dataSourcesPerSection.count }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSourcePerSection = self.dataSourcesPerSection[section] as! UITableViewDataSource
        return dataSourcePerSection.tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataSourcePerSection = self.dataSourcesPerSection[indexPath.section] as! UITableViewDataSource
        return dataSourcePerSection.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    //MARK - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return self.dataSourcesPerSection.count }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSourcePerSection = self.dataSourcesPerSection[section] as! UICollectionViewDataSource
        return dataSourcePerSection.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dataSourcePerSection = self.dataSourcesPerSection[indexPath.section] as! UICollectionViewDataSource
        return dataSourcePerSection.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
}