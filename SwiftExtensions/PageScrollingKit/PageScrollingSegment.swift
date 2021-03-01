//
//  PaveScrollingSegment.swift
//  PageScrollingKit
//
//  Created by 赵国庆 on 2018/11/2.
//  Copyright © 2018 kagen. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift

struct PageScrollingSegmentTitleConfig {
    var font: UIFont
    var textColor: UIColor
    var backgroundColor: UIColor
}

class PageScrollingSegment: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var indicatorBg: UIView!
    private var indicator: UIView!
    private var flowLayout = UICollectionViewFlowLayout()
    private var cacheWidths: [CGFloat] = []
    private var cacheIndicatorLeft: [CGFloat] = []
    private var cacheIndicatorWidth: [CGFloat] = []

    private var verticleSeparators: [UIView] = []
    private var horizontalSeparators: [UIView] = []

    var addVerticleSeparator = false
    var horizontalSeparatorColor = UIColor.init(hex: 0xdcdcdc)! {
        didSet {
            setupHorizontalSeparator()
        }
    }
    var horizontalSeparatorHeight: CGFloat = 1 / UIScreen.main.scale {
        didSet {
            setupHorizontalSeparator()
        }
    }
    var verticleSeparatorColor = UIColor.init(hex: 0xdcdcdc)! {
        didSet {
            setupVerticleSeparator()
        }
    }
    var verticleSeparatorWidth: CGFloat = 1 / UIScreen.main.scale  {
        didSet {
            setupVerticleSeparator()
        }
    }
    var titleTextLeftInset: CGFloat = 10
    var titleTextRightInset: CGFloat = 10
    var normalTitleConfig: PageScrollingSegmentTitleConfig = PageScrollingSegmentTitleConfig.init(font: UIFont.systemFont(ofSize: 15), textColor: UIColor.init(hex: 0xaaaaaa)!, backgroundColor: .clear)
    var selectedTitleConfig: PageScrollingSegmentTitleConfig = PageScrollingSegmentTitleConfig.init(font: UIFont.systemFont(ofSize: 15), textColor: UIColor.init(hex: 0x333333)!, backgroundColor: .clear)
    
    var indicatorColor = UIColor.red {
        didSet {
            indicator?.backgroundColor = indicatorColor
        }
    }
    
    var indicatorHeight: CGFloat = 3
    
    var indicatorWidthEqualText = false
    var indicatorWidthPercent: CGFloat = 0.7 {
        didSet {
            indicatorWidthPercent = max(min(1, indicatorWidthPercent), 0)
        }
    }
    var indicatorBottomSpace: CGFloat = 3
    
    var selectedRowAction: ((Int) -> ())?
    internal var titles: [String] = [] {
        didSet {
            collectionView.reloadData()
            reload()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            collectionView?.backgroundColor = backgroundColor
        }
    }
    
    internal private(set) var selectedRow: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func config(titles: [String], selectedRow: Int = 0) {
        self.titles = titles
        self.selectedRow = selectedRow
        reload()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadWidths()
        setupVerticleSeparator()
        setupHorizontalSeparator()
    }
    
    private func reload(_ animated: Bool = false) {
        guard titles.count > 0 else { return }
        cacheWidths = [CGFloat].init(repeating: 0, count: titles.count)
        cacheIndicatorLeft = [CGFloat].init(repeating: 0, count: titles.count)
        cacheIndicatorWidth = [CGFloat].init(repeating: 0, count: titles.count)
        reloadWidths()
        setupVerticleSeparator()
        setupHorizontalSeparator()
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.indicator.layoutIfNeeded()
                self.indicatorBg.layoutIfNeeded()
            }
        } else {
            collectionView.layoutIfNeeded()
        }
    }
    
    private func reloadWidths() {
        guard self.bounds != .zero else { return }
        for (idx, title) in titles.enumerated() {
            let size = title.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: UIFont.systemFont(ofSize: 15)], context: nil)
            cacheWidths[idx] = titleTextLeftInset + size.width + titleTextRightInset
            if indicatorWidthEqualText {
                cacheIndicatorWidth[idx] = size.width
            } else {
                cacheIndicatorWidth[idx] = cacheWidths[idx] * indicatorWidthPercent
            }
            let leftP = (1 - indicatorWidthPercent) / 2
            if idx == 0 {
                if indicatorWidthEqualText {
                    cacheIndicatorLeft[idx] = titleTextLeftInset
                } else {
                    cacheIndicatorLeft[idx] = cacheWidths[idx] * leftP
                }
            } else {
                if indicatorWidthEqualText {
                    cacheIndicatorLeft[idx] = cacheWidths[0...(idx - 1)].reduce(0, +) + titleTextLeftInset
                } else {
                    cacheIndicatorLeft[idx] = cacheWidths[0...idx].reduce(0, +) - cacheWidths[idx] * (1 - leftP)
                }
            }
        }
        let totalW = cacheWidths.reduce(0, +)
        if totalW < bounds.width {
            let d = (bounds.width - totalW) / CGFloat(titles.count)
            var sum: CGFloat = 0
            cacheWidths = cacheWidths.enumerated().map({ (arg) in
                let rw = arg.element + d
                sum += rw
                if indicatorWidthEqualText {
//                    cacheIndicatorWidth[arg.offset] = size.width
                } else {
                    cacheIndicatorWidth[arg.offset] = rw * indicatorWidthPercent
                }
                let leftP = (1 - indicatorWidthPercent) / 2
                if arg.offset == 0 {
                    if indicatorWidthEqualText {
                        cacheIndicatorLeft[arg.offset] = titleTextLeftInset + d / 2
                    } else {
                        cacheIndicatorLeft[arg.offset] = rw * leftP
                    }
                } else {
                    if indicatorWidthEqualText {
                        cacheIndicatorLeft[arg.offset] = sum - rw + titleTextLeftInset + d / 2
                    } else {
                        cacheIndicatorLeft[arg.offset] = sum - rw * (1 - leftP)
                    }
                }
                return rw
            })
        }
        if selectedRow < titles.count {
            indicator.snp.updateConstraints { (make) in
                make.left.equalTo(cacheIndicatorLeft[selectedRow])
                make.height.equalTo(indicatorHeight)
                make.right.equalTo(indicatorBg.snp.left).offset(cacheIndicatorLeft[selectedRow] + cacheIndicatorWidth[selectedRow])
                make.bottom.equalTo(self).offset(-(indicatorBottomSpace))
            }
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath.init(item: selectedRow, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    private func setupUI() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout)
        addSubview(collectionView)
        collectionView?.backgroundColor = backgroundColor ?? .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SegmentCell.self, forCellWithReuseIdentifier: "SegmentCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        
        indicatorBg = UIView()
        indicatorBg.backgroundColor = .clear
        indicatorBg.clipsToBounds = false
        collectionView.addSubview(indicatorBg)
        indicatorBg.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(3)
        }
        
        indicator = UIView()
        indicator.backgroundColor = indicatorColor
        indicator.layer.cornerRadius = 1.5
        indicatorBg.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-(indicatorBottomSpace))
            make.height.equalTo(indicatorHeight)
            make.left.equalTo(0)
            make.right.equalTo(indicatorBg.snp.left).offset(40)
        }
        
        setupHorizontalSeparator()
    }
    
    func setupHorizontalSeparator() {
        if horizontalSeparators.count > 0 {
            let topLine = horizontalSeparators[0]
            topLine.backgroundColor = horizontalSeparatorColor
            topLine.snp.updateConstraints { (make) in
                make.height.equalTo(horizontalSeparatorHeight)
            }
        } else {
            let topLine =  UIView()
            addSubview(topLine)
            topLine.backgroundColor = horizontalSeparatorColor
            horizontalSeparators.append(topLine)
            topLine.snp.makeConstraints { (make) in
                make.left.right.top.equalTo(0)
                make.height.equalTo(horizontalSeparatorHeight)
            }
        }
        
        if self.horizontalSeparators.count > 1 {
            let bottomLine = horizontalSeparators[1]
            bottomLine.backgroundColor = horizontalSeparatorColor
            bottomLine.snp.updateConstraints { (make) in
                make.height.equalTo(horizontalSeparatorHeight)
            }
        } else {
            let bottomLine = UIView()
            addSubview(bottomLine)
            bottomLine.backgroundColor = horizontalSeparatorColor
            horizontalSeparators.append(bottomLine)
            bottomLine.snp.makeConstraints { (make) in
                make.left.right.bottom.equalTo(0)
                make.height.equalTo(horizontalSeparatorHeight)
            }
        }
    }
    
    
    func setupVerticleSeparator() {
        verticleSeparators.forEach({ $0.removeFromSuperview() })
        if addVerticleSeparator {
            var left: CGFloat = 0
            cacheWidths.forEach { (w) in
                left += w
                let v = UIView.init(frame: CGRect.init(x: left - verticleSeparatorWidth / 2, y: 0, width: verticleSeparatorWidth, height: self.bounds.height))
                collectionView.addSubview(v)
                v.backgroundColor = verticleSeparatorColor
                verticleSeparators.append(v)
            }
            collectionView.bringSubviewToFront(indicator)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
        cell.titleLabel.text = titles[indexPath.item]
        cell.isSelected = indexPath.item == selectedRow
        cell.configColors(normalTitleConfig, selected: selectedTitleConfig)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRowAnimated(indexPath.item, animated: true)
        selectedRowAction?(selectedRow)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cacheWidths[indexPath.item], height: self.bounds.height)
    }
    
    func scrollling(_ percent: CGFloat) {
        guard titles.count > 1 else { return }
        let beginRow = max(0, min(Int(floor(percent)), titles.count - 1))
        let endRow = max(0, min(Int(ceil(percent)), titles.count - 1))
        guard beginRow != endRow else { return }
        let beginL = cacheIndicatorLeft[beginRow]
        let endL = cacheIndicatorLeft[endRow]
        let beginR = cacheIndicatorWidth[beginRow] + cacheIndicatorLeft[beginRow]
        let endR = cacheIndicatorLeft[endRow] + cacheIndicatorWidth[endRow]
        let leftPercent = (percent - CGFloat(beginRow)) <= CGFloat(endRow - beginRow) / 2 ? ((percent - CGFloat(beginRow)) / (CGFloat(endRow - beginRow) / 2)) : 1
        let rightPercent = (percent - CGFloat(beginRow)) <= CGFloat(endRow - beginRow) / 2 ? 1 : ((percent - CGFloat(beginRow)) / (CGFloat(endRow - beginRow) / 2) - 1)
        var currentL = beginL
        var currentR = endR
        if leftPercent < 1 {
            currentR = beginR + (endR - beginR) * leftPercent
        } else {
            currentL = beginL + (endL - beginL) * rightPercent
        }
        indicator.snp.updateConstraints { (make) in
            make.left.equalTo(currentL)
            make.right.equalTo(indicatorBg.snp.left).offset(currentR)
        }
        collectionView.layoutIfNeeded()
    }
    
    func selectedRowAnimated(_ row: Int, animated: Bool = false) {
        self.selectedRow = row
        self.reload(animated)
    }
}

fileprivate class SegmentCell: UICollectionViewCell {
    fileprivate var titleLabel: UILabel!
    var normalTitleConfig: PageScrollingSegmentTitleConfig = PageScrollingSegmentTitleConfig.init(font: UIFont.systemFont(ofSize: 15), textColor: UIColor.init(hex: 0xaaaaaa)!, backgroundColor: .clear)
    var selectedTitleConfig: PageScrollingSegmentTitleConfig = PageScrollingSegmentTitleConfig.init(font: UIFont.systemFont(ofSize: 15), textColor: UIColor.init(hex: 0x333333)!, backgroundColor: .clear)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = normalTitleConfig.backgroundColor
        titleLabel = UILabel()
        titleLabel.textColor = normalTitleConfig.textColor
        titleLabel.font = normalTitleConfig.font
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.frame = contentView.bounds
//        titleLabel.backgroundColor = UIColor.random
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(contentView)
            make.height.equalTo(contentView)
            make.width.equalTo(contentView)
        }
    }
    
    fileprivate func configColors(_ normal: PageScrollingSegmentTitleConfig, selected: PageScrollingSegmentTitleConfig) {
        normalTitleConfig = normal
        selectedTitleConfig = selected
        if isSelected {
            titleLabel.textColor = selectedTitleConfig.textColor
            titleLabel.font = selectedTitleConfig.font
            contentView.backgroundColor = selectedTitleConfig.backgroundColor
        } else {
            titleLabel.textColor = normalTitleConfig.textColor
            titleLabel.font = normalTitleConfig.font
            contentView.backgroundColor = normalTitleConfig.backgroundColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTitleConfig.textColor
                titleLabel.font = selectedTitleConfig.font
                contentView.backgroundColor = selectedTitleConfig.backgroundColor
            } else {
                titleLabel.textColor = normalTitleConfig.textColor
                titleLabel.font = normalTitleConfig.font
                contentView.backgroundColor = normalTitleConfig.backgroundColor
            }
        }
    }
}



