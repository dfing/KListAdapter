//
//  ListAdapterFactory.swift
//  KListAdapter
//
//  Created by kaylla on 2020/4/7.
//  Copyright © 2020 kaylla. All rights reserved.
//

import UIKit

class ListAdapterFactory {
    static func generateTableView(withEstimatedRowHeight rowHeight: CGFloat = 44) -> UITableView {
        let tableview = UITableView()
        tableview.separatorStyle = .none
        tableview.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            tableview.insetsContentViewsToSafeArea = false
            tableview.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = rowHeight
        return tableview
    }
}
