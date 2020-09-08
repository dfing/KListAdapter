//
//  ListAdapterTableViewUpdater.swift
//  KListAdapter
//
//  Created by kaylla on 2019/10/7.
//  Copyright © 2019 kaylla. All rights reserved.
//

import UIKit

/** Default List-adapter table view updater
    This class handle UITableViewDataSource and UITableViewDelegate method
 */
final class ListAdapterTableViewUpdater: NSObject, ListAdapterUpdaterProtocol {
    typealias SectionControllerType = ListTableSCProtocol

    var dataSource: ListAdapterDataSource?
    weak var delegate: ListAdapterDelegate?
    var sectionViewModels: [CellViewModel] = []

    private var sectionControllers: [SectionControllerType]
    private var areaShowRecorder: Set<IndexPath>

    override init() {
        sectionControllers = []
        areaShowRecorder = Set()
    }

    func setSectionViewModels(_ svmArray: [CellViewModel]) {
        var _object: [CellViewModel] = []
        sectionControllers = []
        for (index, svm) in svmArray.enumerated() {
            if let dataSource = dataSource {
                let controller = dataSource.getSectionController(with: svm, atSection: index)
                if let controller = controller as? SectionControllerType {
                    _object.append(svm)
                    sectionControllers.append(controller)
                    dataSource.registerCell(for: controller)
                    dataSource.registerHeaderFooter(for: controller)
                }
            }
        }
        self.sectionViewModels = _object
    }

    func updateSectionViewModel(_ svm: CellViewModel, at index: Int) -> Bool {
        if let dataSource = dataSource {
            let controller = dataSource.getSectionController(with: svm, atSection: index)
            if let controller = controller as? SectionControllerType,
                index < sectionControllers.count {
                sectionControllers[index] = controller
                dataSource.registerCell(for: controller)
                dataSource.registerHeaderFooter(for: controller)
                return true
            }
        }
        return false
    }
}

// MARK: - UITableViewDataSource
extension ListAdapterTableViewUpdater: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionViewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let controller = sectionControllers[section]
        return controller.numberOfRows(in: section, with: tableView)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = sectionControllers[indexPath.section]
        let cell = controller.cellForRow(at: indexPath, with: tableView)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListAdapterTableViewUpdater: UITableViewDelegate {
    // MARK: Select
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return getSC(in: indexPath.section)?.willSelectRow?(at: indexPath, with: tableView) ?? indexPath
    }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return getSC(in: indexPath.section)?.willDeselectRow?(at: indexPath, with: tableView) ?? indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            getSC(in: indexPath.section)?.didSelectRowInEditState?(at: indexPath, with: tableView)
        } else {
            getSC(in: indexPath.section)?.didSelectRow?(at: indexPath, with: tableView)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            getSC(in: indexPath.section)?.didDeselectRowInEditState?(at: indexPath, with: tableView)
        } else {
            getSC(in: indexPath.section)?.didDeselectRow?(at: indexPath, with: tableView)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cell area show
        if !areaShowRecorder.contains(indexPath) {
            areaShowRecorder.insert(indexPath)
            getSC(in: indexPath.section)?.didAreaShow?(at: indexPath, with: tableView)
        }
    }
    // MARK: Edit
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return getSC(in: indexPath.section)?.editingStyle?(at: indexPath, with: tableView) ?? .none
    }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        getSC(in: indexPath.section)?.willBeginEditing?(at: indexPath, with: tableView)
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        getSC(in: indexPath.section)?.didEndEditing?(at: indexPath, with: tableView)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return getSC(in: indexPath.section)?.canEditRow?(at: indexPath, with: tableView) ?? true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        getSC(in: indexPath.section)?.commitEditRow?(at: indexPath, for: editingStyle, with: tableView)
    }
    // MARK: Header & Footer
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return getSC(in: section)?.heightForHeader?(at: section, with: tableView) ?? 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return getSC(in: section)?.heightForFooter?(at: section, with: tableView) ?? 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getSC(in: section)?.viewForHeader?(at: section, with: tableView)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return getSC(in: section)?.viewForFooter?(at: section, with: tableView)
    }
}

extension ListAdapterTableViewUpdater {
    private func getSC(in section: Int) -> ListTableSCDelegateProtocol? {
        return sectionControllers[safe: section] as? ListTableSCDelegateProtocol
    }
}

extension UITableView {
    func reloadSection(_ section: Int, with animation: UITableView.RowAnimation = .automatic) {
        UIView.performWithoutAnimation {
            let indexSet = IndexSet(integer: section)
            self.reloadSections(indexSet, with: animation)
        }
    }
}

extension ListAdapterTableViewUpdater: UIScrollViewDelegate {
    // MARK: Animation
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(with: scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(with: scrollView)
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(with: scrollView)
    }
    // MARK: Drag
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(with: scrollView)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(with: scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(with: scrollView, willDecelerate: decelerate)
    }
    // MARK: Decelerate
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(with: scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(with: scrollView)
    }
}
