//
//  RefreshNLoadMore.swift
//  KListAdapter
//
//  Created by kaylla on 2019/9/11.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit

protocol RefreshDelegate: AnyObject {
    func shouldRefresh()
    func shouldLoadMore()
}

class RefreshNLoadMore: NSObject {

    weak var refreshDelegate: RefreshDelegate?

    @objc var shouldShowPullRefresh: Bool = true
    var shouldShowLoadMore: Bool = true
    var shouldShowScrollToTop: Bool = false
    var shouldShowBouncesImage: Bool = false // 還沒實現

    private var isRefreshing: Bool = false
    private var isLoadMoreFetching: Bool = false

    var scrollToTopAction: (() -> Void)?

    override init() {
        super.init()
    }

    func setup(to targetView: UIScrollView) {
        // Pull Refresh
        if shouldShowPullRefresh {
            targetView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
                self?.isRefreshing = true
                self?.refreshDelegate?.shouldRefresh()
            })
        }

        // Load more
        if shouldShowLoadMore {
            let footer = LoadMoreFooter(refreshingBlock: { [weak self] in
                self?.isLoadMoreFetching = true
                self?.refreshDelegate?.shouldLoadMore()
            })
            footer.shouldShowScrollToTop = self.shouldShowScrollToTop
            footer.scrollToTopAction = self.scrollToTopAction
            targetView.mj_footer = footer
        }
    }

    func beginRefreshing(to targetView: UIScrollView) {
        isRefreshing = true
        targetView.mj_header?.beginRefreshing()
    }

    func beginLoadMore(to targetView: UIScrollView) {
        isLoadMoreFetching = true
        targetView.mj_footer?.beginRefreshing()
    }

    func endRefreshing(to target: UIScrollView) {
        isRefreshing = false
        isLoadMoreFetching = false
        target.mj_header?.endRefreshing()
        target.mj_footer?.endRefreshing()
    }

    func endLoadMoreData(to target: UIScrollView) {
        isLoadMoreFetching = false
        target.mj_footer?.endRefreshingWithNoMoreData()
    }
}
