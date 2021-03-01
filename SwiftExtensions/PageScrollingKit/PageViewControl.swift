//
//  PageViewControl.swift
//  PageScrollingKit
//
//  Created by 赵国庆 on 2018/9/6.
//  Copyright © 2018年 赵国庆. All rights reserved.
//

import SnapKit
import UIKit

@objc protocol PageViewControlSubController: class {
    @objc func pageSubControllerWillShow()
    @objc func pageSubControllerDidShow()
}

extension UIViewController: PageViewControlSubController {
    func pageSubControllerWillShow() {}
    func pageSubControllerDidShow() {}
}

protocol PageViewControlDelegate: class {
    func config(_ segmentControl: PageScrollingSegment)
    func pageView(_ pageView: PageViewControl, controllerForItemAt pages: Int) -> (PageViewControlSubController & UIViewController)
    func pageView(_: PageViewControl, willShowController viewController: UIViewController, onPage: Int)
    func pageView(_: PageViewControl, didShowController viewController: UIViewController, onPage: Int)
}

extension PageViewControlDelegate {
    func pageView(_: PageViewControl, willShowController viewController: UIViewController, onPage: Int){}
    func pageView(_: PageViewControl, didShowController viewController: UIViewController, onPage: Int){}
}

class PageViewControl: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    weak var delegate: (PageViewControlDelegate & UIViewController)? {
        didSet {
            reload()
        }
    }

    var hideSegmentWhenSinglePage: Bool = false {
        didSet {
            reload()
        }
    }
    
    /// 是否允许手势横划
    var allowScrollContent = true {
        didSet {
            collectionView.isScrollEnabled = allowScrollContent
        }
    }
    
    internal lazy var segmentControl: PageScrollingSegment = {
        let s = PageScrollingSegment(frame: CGRect.zero)
        s.selectedRowAction = {[weak self] idx in
            self?.showPage(idx, animate: false)
        }
        return s
    }()

    private var isFirstShow = true
    private var collectionLayout = MyCollectionFlowLayout()
    private lazy var collectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    }()

    private func setupUI() {
        buildSegmentControl()
        buildCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkIndexAndScrollTo()
    }
    
    func showPage(_ index: Int, animate: Bool) {
        guard index < segmentControl.titles.count else { return }
        segmentControl.selectedRowAnimated(index, animated: animate)
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animate)
        if !isFirstShow {
            delegate?.pageView(self, controllerForItemAt: index).pageSubControllerWillShow()
            delegate?.pageView(self, controllerForItemAt: index).pageSubControllerDidShow()
        }
    }

    private func buildCollectionView() {
        addSubview(collectionView)
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.sectionInset = UIEdgeInsets.zero
        collectionLayout.estimatedItemSize = .zero
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.snp.makeConstraints { maker in
            maker.top.equalTo(segmentControl.snp.bottom)
            maker.left.equalTo(0)
            maker.width.equalTo(self)
            maker.height.equalTo(self).offset(-45)
        }
    }

    private func buildSegmentControl() {
        addSubview(segmentControl)
        segmentControl.snp.makeConstraints { maker in
            maker.left.equalTo(0)
            maker.top.equalTo(0)
            maker.right.equalTo(0)
            maker.height.equalTo(45)
        }
    }
    
    func reload() {
        delegate?.config(segmentControl)
        if hideSegmentWhenSinglePage && segmentControl.titles.count <= 1 {
            segmentControl.isHidden = true
            collectionView.snp.updateConstraints { maker in
                maker.top.equalTo(segmentControl.snp.bottom).offset(-45)
                maker.height.equalTo(self)
            }
        } else {
            segmentControl.isHidden = false
            collectionView.snp.updateConstraints { maker in
                maker.top.equalTo(segmentControl.snp.bottom)
                maker.height.equalTo(self).offset(-45)
            }
        }
        collectionView.reloadData()
        DispatchQueue.main.async { [self] in
            /// 异步 放到下一次runloop中执行 避免当前CollectionView 没有加载
            checkIndexAndScrollTo()
        }
    }
    
    private func checkIndexAndScrollTo() {
        if !segmentControl.titles.isEmpty,
           segmentControl.selectedRow >= 0,
           segmentControl.selectedRow < segmentControl.titles.count,
           let indexPath = collectionView.indexPathsForVisibleItems.first, indexPath.item != segmentControl.selectedRow {
            collectionView.scrollToItem(at: IndexPath(item: segmentControl.selectedRow, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        }
    }
}

extension PageViewControl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return segmentControl.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.contentView.clipsToBounds = true
        let vc: (PageViewControlSubController & UIViewController) = delegate?.pageView(self, controllerForItemAt: indexPath.item) ?? (UIViewController() as (PageViewControlSubController & UIViewController))
        if !cell.contentView.subviews.contains(vc.view) {
            cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
            vc.willMove(toParent: delegate)
            delegate?.addChild(vc)
            cell.contentView.addSubview(vc.view)
            vc.didMove(toParent: delegate)
            if isFirstShow && indexPath.item == segmentControl.selectedRow {
                delegate?.pageView(self, controllerForItemAt: segmentControl.selectedRow).pageSubControllerWillShow()
                delegate?.pageView(self, controllerForItemAt: segmentControl.selectedRow).pageSubControllerDidShow()
                isFirstShow = false
            }
        }
        vc.view.snp.remakeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getsize()
    }
    
    func getsize() -> CGSize {
        return CGSize(width: bounds.size.width, height: bounds.size.height - (segmentControl.isHidden ? 0 : 45))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isFirstShow {
            let vc: (PageViewControlSubController & UIViewController) = delegate?.pageView(self, controllerForItemAt: indexPath.item) ?? (UIViewController() as (PageViewControlSubController & UIViewController))
            delegate?.pageView(self, willShowController: vc, onPage: indexPath.item)
            vc.pageSubControllerWillShow()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = floor(scrollView.contentOffset.x / scrollView.frame.width)
        segmentControl.selectedRowAnimated(max(min(Int(currentPage), segmentControl.titles.count - 1), 0))
        if !isFirstShow {
            let vc: (PageViewControlSubController & UIViewController) = delegate?.pageView(self, controllerForItemAt: segmentControl.selectedRow) ?? (UIViewController() as (PageViewControlSubController & UIViewController))
            delegate?.pageView(self, didShowController: vc, onPage: segmentControl.selectedRow)
            vc.pageSubControllerDidShow()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = scrollView.contentOffset.x / scrollView.frame.width
        segmentControl.scrollling(currentPage)
    }
}


private class MyCollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var temp = super.layoutAttributesForElements(in: rect) ?? []
        guard let collection = self.collectionView else { return temp }
        temp = temp.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        for i in temp {
            i.frame.origin.y = 0
            i.frame.size = collection.frame.size
        }
        return temp
    }
}
