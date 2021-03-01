//
//  UITableView+Dragable.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/7/8.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


/// TableView 可拖动Cell代理方法
public protocol UITableViewDragable: class {
    /// 震动反馈
    /// 在长按和拖动交换的时候出发震动反馈
    /// default: true
    ///
    /// - Returns: 是否支持震动反馈
    @available(iOS 10.0, *)
    func canVibrate() -> Bool
    
    /// 边缘自动滚动
    /// 在拖动cell到上下边缘时自动滚动tableView
    /// default: true
    ///
    /// - Returns: 是否支持边缘滚动
    func canEdgeScroll() -> Bool
    
    /// 边缘滚动边界距离
    /// 拖动cell距离上下边界, 触发滚动的距离, 触发的同时, 距离越近, 滚动速度越快
    /// default: 150
    ///
    /// - Returns: 边缘滚动边界距离
    func edgeScrollRange() -> CGFloat
    
    /// 自定义拖拽Cell的UI
    /// 用户可自定义长按cell后, 生成的cell截图, 并不是真正的cell
    ///
    /// - Parameter cell: cell的截图
    func configDrgableCell(_ cell: UIView)
    
    /// 长按触发时间
    /// 长按cell触发拖动的时间
    /// default: 0.5s
    ///
    /// - Returns: 长按触发时间
    func gestureMinimumPressDuration() -> TimeInterval
    
    /// 动画时间
    /// 1, 长按后生成cell并跟随手指的时间
    /// 2, 松开手指 cell 归位的时间
    /// default: 0.25
    ///
    /// - Returns: 动画时间
    func dragableCellAnimationTime() -> TimeInterval
    
    /// 处理数据
    /// 在cell进行移动界面刷新之前, 需要用户手动处理数据的变化, 移动/交换
    ///
    /// - Parameters:
    ///   - tableView: UITableView 对象
    ///   - fromIndexPath: 初始位置
    ///   - toIndexPath: 目标位置
    func tableView(_ tableView: UITableView, processDataSource fromIndexPath: IndexPath, toIndexPath: IndexPath)
    
    /// 手势锚点
    /// 长按开始时的锚点控件, 如果不设置则整个cell都响应, 默认为nil
    ///
    /// - Parameters:
    ///   - tableView: UITableView 对象
    ///   - cell: 开始时的cell
    func tableView(_ tableView: UITableView, anchorViewFor cell: UITableViewCell) -> UIView?
}

public extension UITableViewDragable {
    
    @available(iOS 10.0, *)
    func canVibrate() -> Bool {
        return true
    }
    
    func canEdgeScroll() -> Bool {
        return true
    }
    
    func edgeScrollRange() -> CGFloat {
        return 150
    }
    
    func configDrgableCell(_ cell: UIView) {
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.masksToBounds = false;
        cell.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cell.layer.shadowOpacity = 0.4
        cell.layer.shadowRadius = 5
    }
    
    func gestureMinimumPressDuration() -> TimeInterval {
        return 0.5
    }
    
    func dragableCellAnimationTime() -> TimeInterval {
        return 0.25
    }
    
    func tableView(_ tableView: UITableView, anchorViewFor cell: UITableViewCell) -> UIView? {
        return nil
    }
}

extension UITableView {
    
    /// 配置可拖动cell
    /// 与系统api不同点:
    ///   1, 系统api在可拖动状态下不执行cell的点击代理
    ///   2, 系统编辑状态下 左边会
    /// 此方法利用长按手势自定义了拖动规则.
    /// 不进行UI方面的绘制, Cell完全由用户自定义
    ///
    /// - Parameter dragableDelegate: 可拖动代理方法
    public func setDragable(_ dragableDelegate: UITableViewDragable) {
        let gestureName = "__UITableViewDragable__"
        if #available(iOS 11.0, *) {
            guard !(self.gestureRecognizers?.contains(where: { $0.name == gestureName }) ?? false) else { return }
        } else {
            guard !(self.gestureRecognizers?.contains(where: { $0 is UILongPressGestureRecognizer }) ?? false) else { return }
        }
        let longPress = UILongPressGestureRecognizer()
        if #available(iOS 11.0, *) {
            longPress.name = gestureName
        }
        longPress.minimumPressDuration = dragableDelegate.gestureMinimumPressDuration()
        self.addGestureRecognizer(longPress)
        let property = UITableView.UITableViewDragableProperty(dragableDelegate)
        longPress.delegate = property
        _ = longPress.rx.event.take(until: self.rx.deallocated).subscribe(onNext: {[weak self] (lp) in
            guard let `self` = self else { return }
            self._longPressAction(lp, property)
        })
    }
}


// MARK: - Private functions
extension UITableView {
    private class UITableViewDragableProperty: NSObject, UIGestureRecognizerDelegate {
        var lastPoint: CGPoint?
        var selectedIndexPath: IndexPath?
        var tempView: UIView?
        var toBottom = 0
        var edgeScrollTimerDispose: Disposable?
        weak var dragableDelegate: UITableViewDragable!
        init(_ dragableDelegate: UITableViewDragable) {
            super.init()
            self.dragableDelegate = dragableDelegate
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let point = gestureRecognizer.location(in: gestureRecognizer.view)
            guard let tableView = gestureRecognizer.view as? UITableView else { return false  }
            guard let selectedIndexPath = tableView.indexPathForRow(at: point), let cell = tableView.cellForRow(at: selectedIndexPath) else {
                return false
            }
            
            if let archorView = dragableDelegate.tableView(tableView, anchorViewFor: cell), let archSuper = archorView.superview {
                let archorRect = archSuper.convert(archorView.frame, to: tableView)
                guard archorRect.contains(point) else {
                    return false
                }
            }
            return true
        }
    }
    
    private func _longPressAction(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        switch _longPress.state {
        case .began:
            _LongPressBegin(_longPress, property)
        case .changed:
            guard !property.dragableDelegate.canEdgeScroll() else { return }
            _LongPresschange(_longPress, property)
        case .cancelled, .ended:
            _LongPressEndOrCancelled(_longPress, property)
        case .possible, .failed: break
        @unknown default:
            break
        }
    }
    
    private func _LongPressBegin(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        let point = _longPress.location(in: self)
        guard let selectedIndexPath = indexPathForRow(at: point), let cell = cellForRow(at: selectedIndexPath) else {
            _longPress.cancel()
            return
        }
        
//        if let archorView = property.dragableDelegate.tableView(self, anchorViewFor: cell), let archSuper = archorView.superview {
//            let archorRect = archSuper.convert(archorView.frame, to: self)
//            guard archorRect.contains(point) else {
//                _longPress.cancel()
//                return
//            }
//        }
        
        if #available(iOS 10.0, *) {
            if property.dragableDelegate.canVibrate() {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        property.lastPoint = point
        if property.dragableDelegate.canEdgeScroll() {
            _startEdgeScroll(_longPress, property)
        }
        property.selectedIndexPath = selectedIndexPath
        guard let snapShot = _snapshot(with: cell) else { return }
        property.dragableDelegate.configDrgableCell(snapShot)
        snapShot.frame = cell.frame
        addSubview(snapShot)
        property.tempView = snapShot
        cell.isHidden = true
        UIView.animate(withDuration: property.dragableDelegate.dragableCellAnimationTime()) {
            snapShot.center = CGPoint(x: snapShot.center.x, y: point.y)
        }
    }
    
    private func _LongPresschange(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        let point = _longPress.location(in: _longPress.view)
        guard property.lastPoint != nil, property.tempView != nil, property.selectedIndexPath != nil else { return }
        if point.y - property.lastPoint!.y > 0 {
            property.toBottom = 1
        } else if point.y - property.lastPoint!.y < 0 {
            property.toBottom = -1
        } else {
            property.toBottom = 0
        }
        property.lastPoint = point
        if let currentIndexPath = indexPathForRow(at: point),
            property.selectedIndexPath! != currentIndexPath,
            let cell = cellForRow(at: property.selectedIndexPath!),
            let cell1 = cellForRow(at: currentIndexPath) {
            
            let canDown = (property.toBottom == 1) && ((point.y + cell.frame.height / 2) >= cell1.frame.maxY) && (cell1.frame.maxY >= cell.frame.maxY)
            let canUp = (property.toBottom == -1) && ((point.y - cell.frame.height / 2) <= cell1.frame.minY) && (cell1.frame.minY <= cell.frame.minY)
            if canDown || canUp {
                property.dragableDelegate.tableView(self, processDataSource: property.selectedIndexPath!, toIndexPath: currentIndexPath)
                _updateCell(property.selectedIndexPath!, currentIndexPath, property)
                if #available(iOS 10.0, *) {
                    if property.dragableDelegate.canVibrate() {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                property.selectedIndexPath = currentIndexPath
            }
        }
        property.tempView!.center = CGPoint(x: property.tempView!.center.x, y: point.y)
    }
    
    private func _LongPressEndOrCancelled(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        if property.dragableDelegate.canEdgeScroll() {
            _stopEdgeScroll(property)
        }
        
        if property.selectedIndexPath != nil, let cell = cellForRow(at: property.selectedIndexPath!), property.tempView != nil {
            UIView.animate(withDuration: property.dragableDelegate.dragableCellAnimationTime(), animations: {
                property.tempView!.frame = cell.frame
            }, completion: { (_) in
                property.tempView!.removeFromSuperview()
                property.tempView = nil
                cell.isHidden = false
                self.reloadData()
            })
        } else {
            reloadData()
        }
        property.selectedIndexPath = nil
        property.lastPoint = nil
        property.toBottom = 0
    }
    
    private func _updateCell(_ fromIndexPath: IndexPath,
                             _ toIndexPath: IndexPath,
                             _ property: UITableViewDragableProperty) {
        if numberOfSections == 1 {
            moveRow(at: fromIndexPath, to: toIndexPath)
        } else {
            beginUpdates()
            moveRow(at: fromIndexPath, to: toIndexPath)
            moveRow(at: toIndexPath, to: fromIndexPath)
            endUpdates()
        }
    }
    
    
    private func _startEdgeScroll(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        property.edgeScrollTimerDispose = CADisplayLink.rx.link(to: .main, forMode: .common).subscribe(onNext: {[weak self] (_) in
            self?._processEdgeScroll(_longPress, property)
        })
    }
    
    private func _processEdgeScroll(_ _longPress: UILongPressGestureRecognizer, _ property: UITableViewDragableProperty) {
        guard property.tempView != nil else { return }
        _LongPresschange(_longPress, property)
        let edgeScrollRange = property.dragableDelegate.edgeScrollRange()
        let minOffsetY = contentOffset.y + edgeScrollRange
        let maxOffsetY = contentOffset.y + bounds.size.height - edgeScrollRange
        let touchPoint = property.tempView!.center
        if touchPoint.y < edgeScrollRange {
            if contentOffset.y <= 0 {
                return
            } else {
                if contentOffset.y - 1 < 0 {
                    return
                }
                setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y - 1), animated: false)
                property.tempView!.center = CGPoint(x: property.tempView!.center.x, y: property.tempView!.center.y - 1)
            }
        }
        if touchPoint.y > contentSize.height - edgeScrollRange {
            if contentOffset.y >= contentSize.height - bounds.height {
                return
            } else {
                if contentOffset.y + 1 > contentSize.height - bounds.height {
                    return
                }
                setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y + 1), animated: false)
                property.tempView!.center = CGPoint(x: property.tempView!.center.x, y: property.tempView!.center.y + 1)
            }
        }
        
        let maxMoveDistance: CGFloat = 20
        if touchPoint.y < minOffsetY {
            let moveDistance = (minOffsetY - touchPoint.y) / edgeScrollRange * maxMoveDistance
            setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y - moveDistance), animated: false)
            property.tempView!.center = CGPoint(x: property.tempView!.center.x, y: property.tempView!.center.y - moveDistance)
        } else if touchPoint.y > maxOffsetY {
            let moveDistance = (touchPoint.y - maxOffsetY) / edgeScrollRange * maxMoveDistance
            setContentOffset(CGPoint(x: contentOffset.x, y: contentOffset.y + moveDistance), animated: false)
            property.tempView!.center = CGPoint(x: property.tempView!.center.x, y: property.tempView!.center.y + moveDistance)
        }
    }
    
    private func _stopEdgeScroll(_ property: UITableViewDragableProperty) {
        property.edgeScrollTimerDispose?.dispose()
        property.edgeScrollTimerDispose = nil
    }
    
    private func _snapshot(with inputView: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        inputView.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        let snapShot = UIImageView.init(image: image)
        return snapShot
    }

}

extension UIGestureRecognizer {
    fileprivate func cancel() {
        DispatchQueue.main.async {
            self.isEnabled = false
            self.isEnabled = true
        }
    }
}
