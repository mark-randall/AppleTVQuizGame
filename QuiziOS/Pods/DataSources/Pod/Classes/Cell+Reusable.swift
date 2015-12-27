//
//  Cell+Reusable.swift
//  Pods
//
//  Created by mrandall on 12/10/15.
//
//

import Foundation

/// Protocol to keep custom cell API consistent
/// Only use if cell will ever use 1 xib
public protocol CustomCell {
    static var nibName: String { get }
    static var reuseIdentifier: String { get }
}

public extension UITableView {
    
    func registerCellUsingNib(cell: CustomCell.Type) {
        self.registerNib(UINib(nibName: cell.nibName, bundle: nil), forCellReuseIdentifier: cell.reuseIdentifier)
    }
}


public extension UICollectionView {

    func registerCellUsingNib(cell: CustomCell.Type) {
        self.registerNib(UINib(nibName: cell.nibName, bundle: nil), forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
 
}