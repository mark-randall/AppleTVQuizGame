//
//  DataSources.swift
//
//  Created by mrandall on 8/27/15.
//

import UIKit

//MARK: - DataSourceDelegate

public protocol DataSourceDelegate: NSObjectProtocol {
    
    // Return a unique cellReuseIdentifier
    //
    // - Parameter dataSource: DataSource
    // - Parameter cellReuseIdentifierForIndexPath: NSIndexPath
    // - Parameter data: AnyObject
    //
    // - Return String
    func dataSource(dataSource: DataSource, cellReuseIdentifierForIndexPath: NSIndexPath, data: Any) -> String?
}

extension DataSourceDelegate {
    
    func dataSource(dataSource: DataSource, cellReuseIdentifierForIndexPath: NSIndexPath, data: AnyObject) -> String? {
        return nil
    }
}

//MARK: - DataSource

///Datasource Base Class
public class DataSource: NSObject {
    
    ///Set to any object you want UITableView or UICollectionView delegate methods forwarded to if concrete implimentations do not respond to them
    public var fallBackDataSource: AnyObject?

    weak var delegate: DataSourceDelegate?
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        
        if let fallBackDataSource = self.fallBackDataSource {
            if (fallBackDataSource.respondsToSelector(aSelector)) {
                return true
            }
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        
        if let fallBackDataSource = self.fallBackDataSource {
            if (fallBackDataSource.respondsToSelector(aSelector)) {
                return fallBackDataSource
            }
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
}