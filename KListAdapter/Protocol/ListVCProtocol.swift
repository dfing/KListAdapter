//
//  ListVCProtocol.swift
//  phone
//
//  Created by kaylla on 2019/10/5.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit

protocol ListProtocol {
    var adapter: ListAdapter { get set }
    func listScrollToTop()
}
/// Allow list page refreshable
protocol Refreshable {
    var refreshAdapter: RefreshNLoadMore { get set }
    func listRefreshSetup()
    func listEndFetchingData()
    func listShouldRefresh()
}
extension Refreshable where Self: RefreshDelegate {
    var refreshAdapter: RefreshNLoadMore {
        get {
            return associated(to: self, key: &AssociatedKeys.refreshAdapter) { () -> RefreshNLoadMore in
                let obj = RefreshNLoadMore()
                obj.shouldShowLoadMore = false
                obj.refreshDelegate = self
                return obj
            }
        }
        set {
            associate(to: self, key: &AssociatedKeys.refreshAdapter, value: newValue)
        }
    }
    func shouldRefresh() { listShouldRefresh() }
    func shouldLoadMore() { listEndFetchingData() }
}

/// Allow list page refreshable and pageable
protocol ListPageable {
    var refreshAdapter: RefreshNLoadMore { get set }
    func pageListSetup()
    func pageListNoMoreData()
    func pageListEndFetchingData()
    func pageListShouldRefresh()
    func pageListShouldLoadMore()
}
extension ListPageable where Self: RefreshDelegate {
    var refreshAdapter: RefreshNLoadMore {
        get {
            return associated(to: self, key: &AssociatedKeys.refreshAdapter) { () -> RefreshNLoadMore in
                let obj = RefreshNLoadMore()
                obj.refreshDelegate = self
                return obj
            }
        }
        set {
            associate(to: self, key: &AssociatedKeys.refreshAdapter, value: newValue)
        }
    }
    func shouldRefresh() { pageListShouldRefresh() }
    func shouldLoadMore() { pageListShouldLoadMore() }
}

/// ----------------------------
// MARK: - Table View Protocol
/// ----------------------------
protocol ListTableViewProtocol: ListProtocol {
    var tableView: UITableView { get }
    func clearSelection(_ animated: Bool)
}
extension ListTableViewProtocol {
    func listScrollToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    func clearSelection(_ animated: Bool = true) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
}
/**
UITableView can be implement *pull down to refresh*

This protocol has some parameter and method you can to use.
- **var adapter** ListAdapter class that to handle section object, delegate and dataSourece of UITableView.
- **var refreshAdapter** RefreshNLoadMore class that to handle pull down and pull up loading method.
- **func pageListEndFetchingData()** Method that tell *refreshAdapter* to mark this list fetching has completed.
- **func pageListShouldRefresh()** Method that be called when list should be to refresh by *pull down list view*.
*/
protocol RefreshableTableViewProtocol: ListTableViewProtocol, Refreshable, RefreshDelegate {}
extension RefreshableTableViewProtocol {
    func listRefreshSetup() {
        refreshAdapter.setup(to: tableView)
    }
    func listEndFetchingData() { refreshAdapter.endRefreshing(to: tableView) }
}
/**
 UITableView can be implement *pull down to refresh* and *pull up loading*.
 
 This protocol has some parameter and method you can to use.
 - **var adapter** ListAdapter class that to handle section object, delegate and dataSourece of UITableView.
 - **var refreshAdapter** RefreshNLoadMore class that to handle pull down and pull up loading method.
 - **func pageListNoMoreData()** Method that tell *refreshAdapter* to mark this list no more data from fetching.
 - **func pageListEndFetchingData()** Method that tell *refreshAdapter* to mark this list fetching has completed.
 - **func pageListShouldRefresh()** Method that be called when list should be to refresh by *pull down list view*.
 - **func pageListShouldLoadMore()** Method that be called when list should be to loading by *pull up list view* if need.
 */
protocol PageableTableViewProtocol: ListTableViewProtocol, ListPageable, RefreshDelegate {}
extension PageableTableViewProtocol where Self: ListTableViewProtocol {
    func pageListSetup() {
        refreshAdapter.shouldShowScrollToTop = true
        refreshAdapter.scrollToTopAction = ({ [weak self] in
            self?.listScrollToTop()
        })
        refreshAdapter.setup(to: tableView)
    }
    func pageListNoMoreData() { refreshAdapter.endLoadMoreData(to: tableView) }
    func pageListEndFetchingData() { refreshAdapter.endRefreshing(to: tableView) }
}

/// ---------------------------------
// MARK: - Collection View Protocol
/// ---------------------------------
protocol ListCollectionViewProtocol: ListProtocol {
    var collectionView: UICollectionView { get set }
    var collectionLayout: UICollectionViewLayout { get set }
}
extension ListCollectionViewProtocol {
    func listScrollToTop() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}

private struct AssociatedKeys {
    static var refreshAdapter: Void?
    static var editAdapter: Void?
}
/**
 UICollectionView can be implement pull down to refresh and pull up loading.

 This protocol has some parameter and method you can to use.
 - **var adapter** ListAdapter class that to handle section object, delegate and dataSourece of UICollectionView.
 - **var refreshAdapter** RefreshNLoadMore class that to handle pull down and pull up loading method.
 - **func pageListNoMoreData()** Method that tell *refreshAdapter* to mark this list no more data from fetching.
 - **func pageListEndFetchingData()** Method that tell *refreshAdapter* to mark this list fetching has completed.
 - **func pageListShouldRefresh()** Method that be called when list should be to refresh by *pull down list view*.
 - **func pageListShouldLoadMore()** Method that be called when list should be load by *pull up list view* if need.
 */
protocol PageableCollectionViewProtocol: ListCollectionViewProtocol, ListPageable, RefreshDelegate {}
extension PageableCollectionViewProtocol where Self: ListCollectionViewProtocol {
    func pageListSetup() {
        refreshAdapter.shouldShowScrollToTop = true
        refreshAdapter.scrollToTopAction = ({ [weak self] in
            self?.listScrollToTop()
        })
        refreshAdapter.setup(to: collectionView)
    }
    func pageListNoMoreData() { refreshAdapter.endLoadMoreData(to: collectionView) }
    func pageListEndFetchingData() { refreshAdapter.endRefreshing(to: collectionView) }
}
