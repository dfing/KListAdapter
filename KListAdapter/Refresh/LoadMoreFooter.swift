//
//  LoadMoreFooter.swift
//  KListAdapter
//
//  Created by kaylla on 2019/9/11.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit
import MJRefresh

class LoadMoreFooter: MJRefreshAutoFooter {

    weak var loadmoreView: UIView? {
        didSet {
            if let view = loadmoreView {
                addSubview(view)
                placeSubviews()
            }
        }
    }
    weak var scrollToTopView: UIView?
    weak var bottomBGView: UIView?

    var shouldShowScrollToTop: Bool = false
    var scrollToTopAction: (() -> Void)?

    // 配置 ui
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        self.triggerAutomaticallyRefreshPercent = 0.5
    }
    // 設置 ui 的位置
    override func placeSubviews() {
        super.placeSubviews()

        self.loadmoreView?.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 50)
        self.loadmoreView?.center = CGPoint(x: self.mj_w / 2, y: self.mj_h / 2)
    }
    // 监听scrollView的contentOffset改变
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewContentOffsetDidChange(change)

        let pullUp = checkPullUp()
        if pullUp.more {
            if let bottomBGView = self.bottomBGView, !bottomBGView.isHidden {

                var frame = bottomBGView.frame
                frame.origin = CGPoint(x: self.mj_x, y: self.mj_h)
                frame.size = CGSize(width: self.mj_w, height: pullUp.offset)
                bottomBGView.frame = frame

            } else {
                self.bottomBGView?.frame = .zero
            }
        }

    }
    // 监听scrollView的contentSize改变
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewContentSizeDidChange(change)
        guard let scrollView = self.scrollView else { return }

        // 將 load more 推到底部
        // 内容的高度
        let contentHeight = scrollView.mj_contentH + self.ignoredScrollViewContentInsetBottom
        // 表格的高度
        let scrollHeight = scrollView.mj_h - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom
        // 设置位置和尺寸
        self.mj_y = max(contentHeight, scrollHeight)
    }
    // 监听scrollView的拖拽状态改变
    override func scrollViewPanStateDidChange(_ change: [AnyHashable: Any]!) {
        super.scrollViewPanStateDidChange(change)
    }

    // 监听控件的刷新状态
    override var state: MJRefreshState {
        didSet {
            self.hiddenScrollToTopView()
            switch state {
            case .idle:
                // ...
                break

            case .pulling:
                // 正在載入 ...
                break

            case .refreshing:
                if selfHidden {
                    selfHidden = false // 調整底部 inset
                }
                // 正在載入 ...
                break

            case .noMoreData:
                // 沒有更多 ...
                if self.shouldShowScrollToTop {
                    self.showScrollToTopView()
                } else {
                    selfHidden = true // 調整底部 inset
                }
                break
                
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

    func showScrollToTopView() {
        if self.isInsideScreen() {
            return
        }

        guard let view = scrollToTopView else { return }
        
        if view.superview == nil {
            view.frame = CGRect(origin: .zero, size: self.bounds.size)
//            view.setScrollToTopView({ [weak self] in
//                self?.scrollToTopAction?()
//            })
            self.addSubview(view)

            let bg = UIView()
            self.addSubview(bg)
            self.bottomBGView = bg
        }

        if let bottomBGView = bottomBGView {
            self.sendSubviewToBack(bottomBGView)
            bottomBGView.isHidden = false
        }
        if let scrollToTopView = scrollToTopView {
            self.bringSubviewToFront(scrollToTopView)
            scrollToTopView.isHidden = false
        }
    }

    func hiddenScrollToTopView() {
        self.scrollToTopView?.isHidden = true
        self.bottomBGView?.isHidden = true
    }

    private func isInsideScreen() -> Bool {
        guard let scrollView = self.scrollView else { return false }

        // 内容不超过一个屏幕
        return scrollView.mj_insetT + scrollView.mj_contentH < scrollView.mj_h
    }

    private func checkPullUp() -> (more: Bool, offset: CGFloat) {
        guard let scrollView = self.scrollView else { return (more: false, offset: 0) }

        // 是否是底部上拉,且上拉多少
        let bottom_offset = scrollView.mj_offsetY - (scrollView.mj_contentH + scrollView.mj_insetB - scrollView.mj_h)
        return (more: bottom_offset > 0, offset: bottom_offset)
    }

    private var lastHidden: Bool = false
    private var selfHidden: Bool = false {
        willSet {
            self.lastHidden = selfHidden
        }
        didSet {
            guard let scrollView = self.scrollView else { return }

            if !lastHidden && selfHidden {
                scrollView.mj_insetB -= self.mj_h
            } else if lastHidden && !selfHidden {
                scrollView.mj_insetB += self.mj_h
                self.mj_y = scrollView.mj_contentH
            }
        }
    }
}
