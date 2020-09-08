//
//  ListAdapterCollectionViewUpdater.swift
//  KListAdapter
//
//  Created by kaylla on 2020/1/21.
//  Copyright © 2020 kaylla. All rights reserved.
//

import UIKit

/** Default List-adapter collection view updater
   This class handle UICollectionViewDataSource, UICollectionViewDelegateFlowLayout and UIScrollViewDelegate method
*/
final class ListAdapterCollectionViewUpdater: NSObject, ListAdapterUpdaterProtocol {
    typealias SectionControllerType = ListCollectionSCProtocol

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

// MARK: - UICollectionViewDataSource
extension ListAdapterCollectionViewUpdater: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let controller = sectionControllers[section]
        return controller.numberOfRows(in: section, with: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let controller = sectionControllers[indexPath.section]
        let cell = controller.cellForRow(at: indexPath, with: collectionView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let controller = sectionControllers[indexPath.section]
        return controller.supplementaryView(at: indexPath, of: kind, with: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let controller = sectionControllers[indexPath.section]
        return controller.canMoveItem(at: indexPath, with: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        /** Notify the source section controller that it has item will be **move to** destination section controller. */
        let sourceController = sectionControllers[sourceIndexPath.section]
        sourceController.moveItem(at: sourceIndexPath,
                                  to: destinationIndexPath,
                                  with: collectionView)
        /** Notify the destination section controller that it has item will be **move from** source section controller. */
        let destinationController = sectionControllers[destinationIndexPath.section]
        destinationController.moveItem(to: destinationIndexPath,
                                       from: sourceIndexPath,
                                       with: collectionView)
    }
}

// MARK: - UICollectionViewDelegate
extension ListAdapterCollectionViewUpdater: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getSC(in: indexPath.section)?.didSelectItem?(at: indexPath, with: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let controller = sectionControllers[indexPath.section]
        let size = controller.itemSize(at: indexPath, with: collectionView)
        return size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Cell area show
        if !areaShowRecorder.contains(indexPath) {
            areaShowRecorder.insert(indexPath)
            getSC(in: indexPath.section)?.didItemShow?(at: indexPath, with: collectionView)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let controller = sectionControllers[section]
        return controller.headerSize(in: section, for: collectionViewLayout, with: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let controller = sectionControllers[section]
        return controller.footerSize(in: section, for: collectionViewLayout, with: collectionView)
    }
}

extension ListAdapterCollectionViewUpdater {
    private func getSC(in section: Int) -> ListCollectionSCDelegateProtocol? {
        return sectionControllers[safe: section] as? ListCollectionSCDelegateProtocol
    }
}
extension ListAdapterCollectionViewUpdater: UIScrollViewDelegate {
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
