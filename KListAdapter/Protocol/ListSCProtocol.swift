//
//  ListSCProtocol.swift
//  KListAdapter
//
//  Created by kaylla on 2020/5/19.
//  Copyright © 2020 kaylla. All rights reserved.
//

import UIKit

protocol ListSectionControllerProtocol {
    var pingbackParameters: [String: String] { get set }
    var sectionViewModel: CellViewModel { get }
    init(sectionViewModel: CellViewModel)
    func getRegisterCellArrayData() -> [RegisterCellInfo]
    func getRegisterHeaderArrayData() -> [RegisterCellInfo]
    func getRegisterFooterArrayData() -> [RegisterCellInfo]
    func getRegisterSupplementaryViewArrayData() -> [RegisterKindCellInfo]
}
extension ListSectionControllerProtocol {
    func getRegisterHeaderArrayData() -> [RegisterCellInfo] { return [] }
    func getRegisterFooterArrayData() -> [RegisterCellInfo] { return [] }
    func getRegisterSupplementaryViewArrayData() -> [RegisterKindCellInfo] { return [] }
}
/// ----------------------------
// MARK: - Table View
/// ----------------------------
/// If your vc has a **TableView** section controller, then implement it
protocol ListTableSCProtocol: ListSectionControllerProtocol {
    func cellForRow(at indexPath: IndexPath, with component: UITableView) -> UITableViewCell
    func numberOfRows(in section: Int, with component: UITableView) -> Int
}
@objc protocol ListTableSCDelegateProtocol {
    @objc optional func didAreaShow(at indexPath: IndexPath, with tableView: UITableView)
    // MARK: Select
    @objc optional func willSelectRow(at indexPath: IndexPath, with tableView: UITableView) -> IndexPath?
    @objc optional func willDeselectRow(at indexPath: IndexPath, with tableView: UITableView) -> IndexPath?
    @objc optional func didSelectRow(at indexPath: IndexPath, with tableView: UITableView)
    @objc optional func didDeselectRow(at indexPath: IndexPath, with tableView: UITableView)
    @objc optional func didSelectRowInEditState(at indexPath: IndexPath, with tableView: UITableView)
    @objc optional func didDeselectRowInEditState(at indexPath: IndexPath, with tableView: UITableView)
    // MARK: Edit
    @objc optional func editingStyle(at indexPath: IndexPath, with tableView: UITableView) -> UITableViewCell.EditingStyle
    @objc optional func willBeginEditing(at indexPath: IndexPath, with tableView: UITableView)
    @objc optional func didEndEditing(at indexPath: IndexPath?, with tableView: UITableView)
    @objc optional func canEditRow(at indexPath: IndexPath, with tableView: UITableView) -> Bool
    @objc optional func commitEditRow(at indexPath: IndexPath,
                                      for editingStyle: UITableViewCell.EditingStyle,
                                      with tableView: UITableView)
    // MARK: Header & Footer
    @objc optional func heightForHeader(at section: Int, with tableView: UITableView) -> CGFloat
    @objc optional func heightForFooter(at section: Int, with tableView: UITableView) -> CGFloat
    @objc optional func viewForHeader(at section: Int, with tableView: UITableView) -> UIView?
    @objc optional func viewForFooter(at section: Int, with tableView: UITableView) -> UIView?
}
/// ----------------------------
// MARK: - Collection View
/// ----------------------------
/// If your vc has a **CollectionView** section controller, then implement it
protocol ListCollectionSCProtocol: ListSectionControllerProtocol {
    var layout: UICollectionViewLayout? { get }
    init(sectionViewModel: CellViewModel, layout: UICollectionViewLayout)
    func cellForRow(at indexPath: IndexPath, with component: UICollectionView) -> UICollectionViewCell
    func numberOfRows(in section: Int, with component: UICollectionView) -> Int
    func itemSize(at indexPath: IndexPath, with component: UICollectionView) -> CGSize
    // Header/Footer
    func supplementaryView(at indexPath: IndexPath,
                           of kind: String,
                           with component: UICollectionView) -> UICollectionReusableView
    func headerSize(in section: Int,
                    for layout: UICollectionViewLayout,
                    with component: UICollectionView) -> CGSize
    func footerSize(in section: Int,
                    for layout: UICollectionViewLayout,
                    with component: UICollectionView) -> CGSize
    // Move
    func canMoveItem(at indexPath: IndexPath, with component: UICollectionView) -> Bool
    func moveItem(at sourceIndexPath: IndexPath,
                  to destinationIndexPath: IndexPath,
                  with component: UICollectionView)
    func moveItem(to destinationIndexPath: IndexPath,
                  from sourceIndexPath: IndexPath,
                  with component: UICollectionView)
}
extension ListCollectionSCProtocol {
    // Header/Footer
    func supplementaryView(at indexPath: IndexPath,
                           of kind: String,
                           with component: UICollectionView) -> UICollectionReusableView {
        let view = UICollectionReusableView()
        return view
    }
    func headerSize(in section: Int,
                    for layout: UICollectionViewLayout,
                    with component: UICollectionView) -> CGSize {
        return CGSize()
    }
    func footerSize(in section: Int,
                    for layout: UICollectionViewLayout,
                    with component: UICollectionView) -> CGSize {
        return CGSize()
    }
    // Move
    func canMoveItem(at indexPath: IndexPath, with component: UICollectionView) -> Bool {
        return false
    }
    func moveItem(at sourceIndexPath: IndexPath,
                  to destinationIndexPath: IndexPath,
                  with component: UICollectionView) {}
    func moveItem(to destinationIndexPath: IndexPath,
                  from sourceIndexPath: IndexPath,
                  with component: UICollectionView) {}
}
@objc protocol ListCollectionSCDelegateProtocol {
    @objc optional
    func didSelectItem(at indexPath: IndexPath, with collectionView: UICollectionView)
    @objc optional
    func didItemShow(at indexPath: IndexPath, with collectionView: UICollectionView)
}
