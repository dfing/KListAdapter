//
//  RefreshHeader.swift
//  KListAdapter
//
//  Created by kaylla on 2019/9/11.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit
import MJRefresh

class RefreshHeader: MJRefreshHeader {

    weak var indicator: UIActivityIndicatorView?

    // 配置 ui
    override func prepare() {
        super.prepare()

        let _indicator = UIActivityIndicatorView(style: .medium)
        self.addSubview(_indicator)

        self.indicator = _indicator
    }
    // 設置 ui 的位置
    override func placeSubviews() {
        super.placeSubviews()

        self.indicator?.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.indicator?.center = CGPoint(x: self.mj_w / 2, y: self.mj_h / 2)
    }
    // 监听scrollView的contentOffset改变
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
    // 监听scrollView的contentSize改变
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewContentSizeDidChange(change)
    }
    // 监听scrollView的拖拽状态改变
    override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewPanStateDidChange(change)
    }
    // 监听控件的刷新状态
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.indicator?.stopAnimating()
            case .pulling:
                self.indicator?.startAnimating()
            case .refreshing:
                self.indicator?.startAnimating()
            default:
                break
            }
        }
    }
    // 监听拖拽比例（控件被拖出来的比例）
    override var pullingPercent: CGFloat {
        didSet {
        }
    }
}
