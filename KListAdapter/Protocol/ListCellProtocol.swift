//
//  ListCellProtocol.swift
//  KListAdapter
//
//  Created by kaylla on 2019/9/9.
//  Copyright © 2019 kaylla. All rights reserved.
//

import Foundation

/// Conform this protocol to declare 'the ViewModel' can be use in config cell in ListAdapter
protocol CellViewModel {}

/// Every cell class of ListAdapter implement this protocol in order to handle config cell and get cell's identifier
protocol CellProtocol {
    associatedtype viewModel: CellViewModel
    static var identifier: String { get }
    func configCell(with viewModel: viewModel)
}

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
