//
//  ListAdapterUpdaterProtocol.swift
//  KListAdapter
//
//  Created by kaylla on 2020/5/19.
//  Copyright © 2020 kaylla. All rights reserved.
//

import UIKit

/// if you wanna to use *custom* updater, your *updater* need to implement this protocol
protocol ListAdapterUpdaterProtocol {
    var dataSource: ListAdapterDataSource? { get set }
    var delegate: ListAdapterDelegate? { get set }
    var sectionViewModels: [CellViewModel] { get set }
    /**
    Set section view model for *list*
    - Parameter svmArray: all section view model data array
    */
    func setSectionViewModels(_ svmArray: [CellViewModel])
    /**
    Update view model for *target section*
    - Parameter svm: section view model data
    - Parameter index: section index
    - Returns: *bool* value. it's mean update result or not
    */
    func updateSectionViewModel(_ svm: CellViewModel, at index: Int) -> Bool
}
