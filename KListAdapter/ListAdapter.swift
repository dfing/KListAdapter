//
//  ListAdapter.swift
//  KListAdapter
//
//  Created by kaylla on 2019/10/7.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit

typealias RegisterCellInfo = (class: AnyClass?, reuseIdentifier: String)
typealias RegisterKindCellInfo = (class: AnyClass?, reuseIdentifier: String, kind: String)
// ============================================================
// MARK: - DataSource
// ============================================================
protocol ListAdapterDataSource {
    /// Register cell class
    func registerCell(for controller: ListSectionControllerProtocol)
    /// Return **section controller** of each section
    func getSectionController(with sectionViewModel: CellViewModel, atSection: Int) -> ListSectionControllerProtocol
    /// Register footer or header class
    func registerHeaderFooter(for controller: ListSectionControllerProtocol)
}

extension ListAdapterDataSource where Self: ListTableViewProtocol {
    func registerCell(for controller: ListSectionControllerProtocol) {
        let cellsInformation = controller.getRegisterCellArrayData()
        for cell in cellsInformation {
            self.tableView.register(cell.class, forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }
    func registerHeaderFooter(for controller: ListSectionControllerProtocol) {
        controller.getRegisterHeaderArrayData().forEach { (viewInfo) in
            self.tableView.register(viewInfo.class, forHeaderFooterViewReuseIdentifier: viewInfo.reuseIdentifier)
        }
        controller.getRegisterFooterArrayData().forEach { (viewInfo) in
            self.tableView.register(viewInfo.class, forHeaderFooterViewReuseIdentifier: viewInfo.reuseIdentifier)
        }
    }
}

extension ListAdapterDataSource where Self: ListCollectionViewProtocol {
    func registerCell(for controller: ListSectionControllerProtocol) {
        let cellsInformation = controller.getRegisterCellArrayData()
        for cell in cellsInformation {
            self.collectionView.register(cell.class, forCellWithReuseIdentifier: cell.reuseIdentifier)
        }
    }
    func registerHeaderFooter(for controller: ListSectionControllerProtocol) {
        controller.getRegisterSupplementaryViewArrayData().forEach { (viewInfo) in
            self.collectionView.register(viewInfo.class,
                                         forSupplementaryViewOfKind: viewInfo.kind,
                                         withReuseIdentifier: viewInfo.reuseIdentifier)
        }
    }
}
// ============================================================
// MARK: - Delegate
// ============================================================
@objc public protocol ListAdapterDelegate {
    // MARK: - ScrollViewDelegate
    // MARK: Animation
    @objc optional
    func scrollViewDidScroll(with scrollView: UIScrollView)
    @objc optional
    func scrollViewDidEndScrollingAnimation(with scrollView: UIScrollView)
    @objc optional
    func scrollViewDidScrollToTop(with scrollView: UIScrollView)
    @objc optional
    func scrollViewWillBeginDragging(with scrollView: UIScrollView)
    @objc optional
    func scrollViewWillEndDragging(with scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
    @objc optional
    func scrollViewDidEndDragging(with scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool)
    @objc optional
    func scrollViewWillBeginDecelerating(with scrollView: UIScrollView)
    @objc optional
    func scrollViewDidEndDecelerating(with scrollView: UIScrollView)
}

// ============================================================
// MARK: - ListAdapter
// ============================================================
/// Allow to set up to class type
typealias ListComponent = UIScrollView
//@available(iOS 11.0, *)
//typealias ListComponent = UIScrollView & UIDataSourceTranslating

/**
 ListAdapter is a module to help you to use **UITableView** or **UICollectionView** relate method quickly.
 
 That has initialization method that set up to your component (TableView or CollectionView) and your custom updater if need.
 - init(setupTo component: ListComponent, with updater: ListAdapterUpdaterProtocol? = nil)
*/
final class ListAdapter: NSObject {

    /// This is a delegate for some action. You can reference > ListAdapterDelegate
    var delegate: ListAdapterDelegate? {
        set {
            updater?.delegate = newValue
        }
        get {
            return updater?.delegate
        }
    }

    /// This is a delegate for data source of list. Including number of section ... etc. You can reference > ListAdapterDataSource
    var dataSource: ListAdapterDataSource? {
        set {
            updater?.dataSource = newValue
        }
        get {
            return updater?.dataSource
        }
    }

    /// This is array that object data for **each** section.
    var sectionViewModel: [CellViewModel] {
        return updater?.sectionViewModels ?? []
    }
    /// ListComponent editing status
    var isEditing: Bool {
        set {
            if let tableView = component as? UITableView {
                tableView.setEditing(newValue, animated: true)
            } else if let collectionView = component as? UICollectionView {
                // collection not support editable yet. kayllatodo
                collectionView.allowsMultipleSelection = newValue
            }
        }
        get {
            if let tableView = component as? UITableView {
                return tableView.isEditing
            } else if let collectionView = component as? UICollectionView {
                // collection not support editable yet. kayllatodo
                return collectionView.allowsMultipleSelection
            } else {
                return false
            }
        }
    }
    private var component: ListComponent

    private var updater: ListAdapterUpdaterProtocol?

    /**
     - Parameter component: only accept UITableView or UICollectionView class
     - Parameter updater: update ui and data class, if you NOT use custom updater you just pass nil.
     */
    init(setupTo component: ListComponent, with updater: ListAdapterUpdaterProtocol? = nil) {
        if let tableView = component as? UITableView {
            self.updater = updater ?? ListAdapterTableViewUpdater()
            if let _updater = self.updater as? UITableViewDataSource {
                tableView.dataSource = _updater
            }
            if let _updater = self.updater as? UITableViewDelegate {
                tableView.delegate = _updater
            }
        } else if let collectionView = component as? UICollectionView {
            self.updater = updater ?? ListAdapterCollectionViewUpdater()
            if let _updater = self.updater as? UICollectionViewDataSource {
                collectionView.dataSource = _updater
            }
            if let _updater = self.updater as? UICollectionViewDelegate {
                collectionView.delegate = _updater
            }
        } else {
            assert(true, "Can't setup (\(component.self)) class to list adapter")
        }
        self.component = component
        super.init()
    }

    // MARK: - Update Section View Model
    /**
     ListAdapter to update all section view model for *list*
     - Parameter svmArray: all section view model data array
     */
    func updateSectionViewModels(_ svmArray: [CellViewModel]) {
        updater?.setSectionViewModels(svmArray)
    }

    /**
    ListAdapter to update section view model for *target section*
    - Parameter svm: section view model data
    - Parameter section: section index
    - Returns: *bool* value. it's mean update result or not
    */
    @discardableResult
    func updateSectionViewModel(_ svm: CellViewModel, atSection section: Int) -> Bool {
        return updater?.updateSectionViewModel(svm, at: section) ?? false
    }
}
