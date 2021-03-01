//
//  PageScrollingViewController.swift
//  PageScrollingKit
//
//  Created by 赵国庆 on 2018/11/2.
//  Copyright © 2018 kagen. All rights reserved.
//

import UIKit
import SnapKit


/// 允许下拉刷新控件出现的位置
public enum PageScrollingRefreshHeaderPosition {
    case all
    case rootController
    case subController
}

protocol PageScrollingSubView: PageViewControlSubController {
    var parentPageScrollingViewController: PageScrollingViewController? { get set }
    var subContentScrollView: UIScrollView? { get }
    func refresh(_ complete: ((Bool) -> ()))
    
    func parentPageScrollViewDidScroll()
    func parentPageScrollViewWillBeginDragging()
    func parentPageScrollViewWillEndDragging(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func parentPageScrollViewDidEndDragging(willDecelerate decelerate: Bool)
    func parentPageScrollViewWillBeginDecelerating()
    func parentPageScrollViewDidEndDecelerating()
    func parentPageScrollViewDidEndScrollingAnimation()
    func parentPageScrollViewShouldScrollToTop() -> Bool
    func parentPageScrollViewDidScrollToTop()
}

extension PageScrollingSubView {
    var subContentScrollView: UIScrollView? { return nil }
    func refresh(_ complete: ((Bool) -> ())) {
        complete(true)
    }
    
    func parentPageScrollViewDidScroll(){}
    func parentPageScrollViewWillBeginDragging(){}
    func parentPageScrollViewWillEndDragging(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){}
    func parentPageScrollViewDidEndDragging(willDecelerate decelerate: Bool){}
    func parentPageScrollViewWillBeginDecelerating(){}
    func parentPageScrollViewDidEndDecelerating(){}
    func parentPageScrollViewDidEndScrollingAnimation(){}
    func parentPageScrollViewShouldScrollToTop() -> Bool { return true }
    func parentPageScrollViewDidScrollToTop() {}
}

typealias PageScrollingSubController = PageScrollingSubView & UIViewController

protocol PageScrollingDelegate: class {
    func titles() -> [String]
    func subController(for title: String, idx: Int) -> PageScrollingSubController
    func topHeaderView() -> UIView?
    func hideSegmentWhenSinglePage() -> Bool // Degfault is Ture
    func rootSelectedPage() -> Int // Degfault is 0
    func refreshHeaderPosition() -> PageScrollingRefreshHeaderPosition // Default is SubController
}

// MARK: - PageScrollingDelegate Default instance
extension PageScrollingDelegate {
    public func topHeaderView() -> UIView? {
        return nil
    }
    
    public func hideSegmentWhenSinglePage() -> Bool {
        return true
    }
    
    public func rootSelectedPage() -> Int {
        return 0
    }
    
    func refreshHeaderPosition() -> PageScrollingRefreshHeaderPosition {
        return .subController
    }
}


class PageScrollingViewController: UIViewController, PageViewControlDelegate {
    
    weak var delegate: PageScrollingDelegate?
    
    private(set) lazy var pageView: PageViewControl = {
        return PageViewControl(frame: self.view.bounds)
    }()
    
    private(set) lazy var backgroundScrollView: UIScrollView = {
        return UIScrollView(frame: view.bounds)
    }()
    
    private var titles: [String] = []
    private var rootSelectedPage: Int = 0
    private var topHeaderView: UIView? = nil
    private var hideSegmentWhenSinglePage = true
    private var refreshHeaderPosition: PageScrollingRefreshHeaderPosition = .all
    private var touchPositionOnPageControl: Bool = false
    private var observer: NSKeyValueObservation?
    private var observer1: NSKeyValueObservation?
    private var observer2: NSKeyValueObservation?
    private var cacheContentOffset: [UIViewController: CGFloat] = [:]
    private var currentVC: PageScrollingSubController?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UIScrollView.setupPageScroll()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        UIScrollView.setupPageScroll()
        super.init(coder: coder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reloadDatas()
    }
    
    private func setupUI() {
        view.addSubview(backgroundScrollView)
        backgroundScrollView.delegate = self
        if #available(iOS 11.0, *) {
            backgroundScrollView.contentInsetAdjustmentBehavior = .never
        }
        backgroundScrollView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(0)
        }
        
        if topHeaderView != nil { backgroundScrollView.addSubview(topHeaderView!) }
        
        pageView.delegate = self
        backgroundScrollView.addSubview(pageView)
        backgroundScrollView.panGestureRecognizer.addTarget(self, action: #selector(backgroundScrollPanGestureAction(_:)))
        layoutSubView()
    }
    
    func reloadDatas() {
        titles = delegate?.titles() ?? []
        if titles.isEmpty {
            pageView.removeFromSuperview()
            pageView.delegate = nil
            refreshHeaderPosition = .rootController
        } else {
            pageView.delegate = self
            if pageView.superview == nil {
                backgroundScrollView.addSubview(pageView)
            }
            pageView.reload()
            rootSelectedPage = delegate?.rootSelectedPage() ?? 0
            pageView.hideSegmentWhenSinglePage = delegate?.hideSegmentWhenSinglePage() ?? true
            refreshHeaderPosition = delegate?.refreshHeaderPosition() ?? .rootController
        }
        topHeaderView = delegate?.topHeaderView()
        layoutSubView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard titles.isEmpty else { return }
        layoutSubView()
    }
    
    func subScrollViewContentOffsetDidChanged(_ animated: Bool = false) {
        _subScrollViewContentOffsetDidChanged(animated)
    }
    
    func config(_ segmentControl: PageScrollingSegment) {
        guard !titles.isEmpty else { return }
        segmentControl.config(titles: titles, selectedRow: rootSelectedPage)
    }
    
    func pageView(_ pageView: PageViewControl, controllerForItemAt pages: Int) -> (PageViewControlSubController & UIViewController) {
        if let vc = delegate?.subController(for: titles[pages], idx: pages) {
            vc.subContentScrollView?.isScrollEnabled = false
            return vc
        }
        return UIViewController()
    }
    
    func pageView(_: PageViewControl, willShowController viewController: UIViewController, onPage: Int) {
        changeController(viewController, onPage: onPage)
    }
    
    func pageView(_: PageViewControl, didShowController viewController: UIViewController, onPage: Int) {
        changeController(viewController, onPage: onPage)
    }
}


//// MARK: - PageViewControlDelegate
//extension PageScrollingViewController: PageViewControlDelegate {
//
//}


// MARK: - UIScrollViewDelegate
extension PageScrollingViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentVC?.subContentScrollView?.forceSetDragging(true)
        currentVC?.parentPageScrollViewWillBeginDragging()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        currentVC?.subContentScrollView?.forceSetDragging(false)
        currentVC?.parentPageScrollViewWillEndDragging(velocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight = topHeaderView?.frame.height ?? 0
        let pageViewHeight = self.view.bounds.height
        if scrollView.contentOffset.y >= headerHeight {
            topHeaderView?.frame = CGRect(x: 0, y: -headerHeight, width: view.bounds.width, height: headerHeight)
            if !titles.isEmpty {
                pageView.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: view.bounds.width, height: pageViewHeight)
            }
        } else {
            topHeaderView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)
            if !titles.isEmpty {
                pageView.frame = CGRect(x: 0, y: headerHeight, width: view.bounds.width, height: pageViewHeight)
            }
        }
        var y = max(0, scrollView.contentOffset.y - headerHeight)
        if ((refreshHeaderPosition == .all && touchPositionOnPageControl) || (refreshHeaderPosition == .subController)) && currentVC?.subContentScrollView != nil && scrollView.contentOffset.y <= 0 {
            topHeaderView?.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: view.bounds.width, height: headerHeight)
            if !titles.isEmpty {
                pageView.frame = CGRect(x: 0, y: scrollView.contentOffset.y + headerHeight, width: view.bounds.width, height: pageViewHeight)
            }
            y = scrollView.contentOffset.y
        }
        if !titles.isEmpty, let topInset = currentVC?.subContentScrollView?.contentInset.top {
            currentVC?.subContentScrollView?.setContentOffset(CGPoint.init(x: 0, y: y - topInset), animated: false)
        }
        currentVC?.parentPageScrollViewDidScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentVC?.parentPageScrollViewDidEndDragging(willDecelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        currentVC?.parentPageScrollViewWillBeginDecelerating()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentVC?.parentPageScrollViewDidEndDecelerating()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentVC?.parentPageScrollViewDidEndScrollingAnimation()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return currentVC?.parentPageScrollViewShouldScrollToTop() ?? true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        currentVC?.parentPageScrollViewDidScrollToTop()
    }
    
    private func _subScrollViewContentOffsetDidChanged(_ animated: Bool) {
        guard !titles.isEmpty else { return }
        let headerHeight = topHeaderView?.frame.height ?? 0
        if let currentVC = currentVC, let subContentScrollView = currentVC.subContentScrollView {
            if pageView.frame.minY > headerHeight { // 界面已经滑动到上方吸顶
                backgroundScrollView.setContentOffset(CGPoint.init(x: 0, y: subContentScrollView.contentOffset.y + subContentScrollView.contentInset.top + headerHeight), animated: animated)
            } else { // 界面还没有滑动到上方吸顶
                if subContentScrollView.contentOffset.y > 0 {
                    backgroundScrollView.setContentOffset(CGPoint.init(x: 0, y: subContentScrollView.contentOffset.y + subContentScrollView.contentInset.top + headerHeight), animated: animated)
                } else {
                    subContentScrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: animated)
                }
            }
        }
    }
}


// MARK: - Private function
extension PageScrollingViewController {
    private func layoutSubView() {
        var headerHeight: CGFloat = 0
        if let header = topHeaderView {
            header.frame.origin = CGPoint.init(x: 0, y: 0)
            headerHeight = header.frame.height
            if header.superview == nil { backgroundScrollView.addSubview(header) }
            topHeaderView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)
        }
        if self.titles.isEmpty {
            backgroundScrollView.contentSize.height = max(self.view.bounds.height, headerHeight)
            backgroundScrollView.contentOffset = CGPoint.zero
        } else {
            let pageViewHeight = self.view.bounds.height
            pageView.frame = CGRect(x: 0, y: headerHeight, width: view.bounds.width, height: pageViewHeight)
            backgroundScrollView.contentSize.height = headerHeight + pageViewHeight
            backgroundScrollView.contentOffset = CGPoint.zero
        }
    }
    
    private func resizeContent(for scrollView: UIScrollView?, idx: Int)  {
        guard !titles.isEmpty else { return }
        guard let scrollView = scrollView else {
            backgroundScrollView.contentSize.height = backgroundScrollView.frame.size.height + (topHeaderView?.frame.height ?? 0)
            return
        }
        let backSave = backgroundScrollView.contentOffset
        let height = scrollView.contentSize.height + scrollView.frame.origin.y + scrollView.contentInset.top + scrollView.contentInset.bottom
        let segmentH: CGFloat = (pageView.hideSegmentWhenSinglePage && titles.count <= 1) ? 0 : 45
        let h = max(height + segmentH, backgroundScrollView.frame.size.height) + (topHeaderView?.frame.height ?? 0)
        
        if h != backgroundScrollView.contentSize.height {
            backgroundScrollView.contentSize.height = h
        }
        backgroundScrollView.contentOffset = backSave
        scrollViewDidScroll(backgroundScrollView)
    }
    
    private func refreshSubView() {
        guard !titles.isEmpty else { return }
        if let currentScroll = currentVC?.subContentScrollView {
            let scrollView = backgroundScrollView
            let headerHeight = topHeaderView?.frame.height ?? 0
            let y = max(0, scrollView.contentOffset.y - headerHeight)
            if y != currentScroll.contentOffset.y {
                if currentScroll.contentOffset.y > 0 {
                    backgroundScrollView.contentOffset.y = currentScroll.contentOffset.y + headerHeight
                } else {
                    backgroundScrollView.contentOffset.y = headerHeight
                }
            }
        }
    }
    
    private func changeController(_ viewController: UIViewController, onPage: Int) {
        guard !titles.isEmpty else { return }
        let vc =  viewController as! PageScrollingSubController
        if currentVC != nil { cacheContentOffset[currentVC!] = backgroundScrollView.contentOffset.y }
        if currentVC?.subContentScrollView != nil && currentVC!.subContentScrollView! != vc.subContentScrollView {
            currentVC!.subContentScrollView!.forceSetDragging(false)
        }
        currentVC = vc
        currentVC?.parentPageScrollingViewController = self
        resizeContent(for: vc.subContentScrollView, idx: onPage)
        if backgroundScrollView.contentOffset.y < (topHeaderView?.frame.height ?? 0) {
            vc.subContentScrollView?.contentOffset = .zero
        } else {
            if let offset = cacheContentOffset[vc], offset >= (topHeaderView?.frame.height ?? 0) {
                backgroundScrollView.contentOffset.y = offset
            } else {
                backgroundScrollView.contentOffset.y = (topHeaderView?.frame.height ?? 0)
            }
        }
        observer = vc.subContentScrollView?.observe(\.contentSize, options: [.old, .new], changeHandler: {[weak self, unowned vc] (scroll, changed) in
            self?.resizeContent(for: vc.subContentScrollView, idx: onPage)
        })
        observer1 = vc.subContentScrollView?.observe(\.contentInset, options: [.old, .new], changeHandler: {[weak self, unowned vc] (scroll, changed) in
            self?.resizeContent(for: vc.subContentScrollView, idx: onPage)
        })
    }
    
    @objc private func backgroundScrollPanGestureAction(_ sender: UIPanGestureRecognizer) {
        guard !titles.isEmpty else { return }
        if sender.state == .began {
            let position = sender.location(in: self.backgroundScrollView)
            touchPositionOnPageControl = pageView.frame.contains(position)
        }
    }
}

extension UIScrollView {
    private static var _exchangeMethodOnceKey: Void?
    private static var _forceSetDraggingKey: Void?
    
    fileprivate static func setupPageScroll() {
        DispatchQueue.once(&_exchangeMethodOnceKey) {
            let method = class_getInstanceMethod(self, #selector(getter: isDragging))!
            let method2 = class_getInstanceMethod(self, #selector(getter: _swizzle_isDragging))!
            method_exchangeImplementations(method, method2)
        }
    }
    
    @objc dynamic var _swizzle_isDragging: Bool {
        if let forceSetDraggingValue = objc_getAssociatedObject(self, &UIScrollView._forceSetDraggingKey) as? NSNumber {
            return forceSetDraggingValue.boolValue
        } else {
            return self._swizzle_isDragging
        }
    }
    
    fileprivate func forceSetDragging(_ dragging: Bool?) {
        let value = dragging == nil ? nil : NSNumber.init(value: dragging!)
        objc_setAssociatedObject(self, &UIScrollView._forceSetDraggingKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
}
