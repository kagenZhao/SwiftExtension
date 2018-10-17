//
//  TableViewSameSectionDataSource.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/10/15.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit

open class TableViewSameCellContainer<ReusableClass>: TableViewReusableContainer<ReusableClass, ReusableClass.DataType>
where ReusableClass: UITableViewCellReusableFectoryProtocol {
    open var canEdit: Bool = false
    open var canMove: Bool = false
    open var clickAction: ((UITableView, IndexPath, TableViewSameCellContainer<ReusableClass>) -> Void)?
    public init(height: CGFloat = UITableView.automaticDimension,
                canEdit: Bool = false,
                canMove: Bool = false,
                data: ReusableClass.DataType? = nil,
                clickAction: ((UITableView, IndexPath, TableViewSameCellContainer<ReusableClass>) -> Void)? = nil) {
        super.init(height: height, data: data)
        self.canEdit = canEdit
        self.canMove = canMove
        self.clickAction = clickAction
    }
}

open class TableViewSameHeaderFooterContainer<ReusableClass>: TableViewReusableContainer<ReusableClass, ReusableClass.DataType>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral
where ReusableClass: UITableViewHeaderFooterViewReusableFectoryProtocol {
    open var clickAction: ((UITableView, IndexPath, TableViewSameHeaderFooterContainer<ReusableClass>) -> Void)?
    public init(height: CGFloat = UITableView.automaticDimension,
                         data: ReusableClass.DataType? = nil,
                         clickAction: ((UITableView, IndexPath, TableViewSameHeaderFooterContainer<ReusableClass>) -> Void)? = nil) {
        super.init(height: height, data: data)
        self.clickAction = clickAction
    }
    
    public convenience init(height: CGFloat) {
        self.init(height: height, data: nil, clickAction: nil)
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init(height: CGFloat(value))
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(height: CGFloat(value))
    }
}

public class TableViewSameSectionContainer<CellClass, HeaderClass, FooterClass>
where HeaderClass:UITableViewHeaderFooterViewReusableFectoryProtocol, FooterClass: UITableViewHeaderFooterViewReusableFectoryProtocol, CellClass: UITableViewCellReusableFectoryProtocol {
    public var headerContainer: TableViewSameHeaderFooterContainer<HeaderClass>?
    public var footerContainer: TableViewSameHeaderFooterContainer<FooterClass>?
    public var cellContainers: [TableViewSameCellContainer<CellClass>] = []
    public init(_ cellContainers: [TableViewSameCellContainer<CellClass>] = [], headerContainer: TableViewSameHeaderFooterContainer<HeaderClass>? = nil, footerContainer: TableViewSameHeaderFooterContainer<FooterClass>? = nil) {
        self.headerContainer = headerContainer
        self.footerContainer = footerContainer
        self.cellContainers = cellContainers
    }
}

public class TableViewSameSectionsContainer<CellClass, HeaderClass, FooterClass>
where HeaderClass:UITableViewHeaderFooterViewReusableFectoryProtocol, FooterClass: UITableViewHeaderFooterViewReusableFectoryProtocol, CellClass: UITableViewCellReusableFectoryProtocol {
    public var sectionIndexTitles: [String]?
    public var sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)?
    public var moveRow: ((UITableView, IndexPath, IndexPath) -> ())?
    public var sectionsContainers: [TableViewSameSectionContainer<CellClass, HeaderClass, FooterClass>] = []
    public init(_ sectionsContainers: [TableViewSameSectionContainer<CellClass, HeaderClass, FooterClass>] = [],
                sectionIndexTitles: [String]? = nil,
                sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)? = nil,
                moveRow: ((UITableView, IndexPath, IndexPath) -> ())? = nil) {
        self.sectionsContainers = sectionsContainers
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
        self.moveRow = moveRow
    }
}


public class TableViewSameSectionDataSource<CellClass, HeaderClass, FooterClass>: NSObject, UITableViewDelegate, UITableViewDataSource where HeaderClass:UITableViewHeaderFooterViewReusableFectoryProtocol, FooterClass: UITableViewHeaderFooterViewReusableFectoryProtocol, CellClass: UITableViewCellReusableFectoryProtocol {
    
    private let sectionsContainer: TableViewSameSectionsContainer<CellClass, HeaderClass, FooterClass>
    private weak var tableView: UITableView!
    private weak var otherDelegate: AnyObject?
    private let cellReuseId = String.init(describing: CellClass.self)
    private let headerReuseId = String.init(describing: HeaderClass.self)
    private let footerReuseId = String.init(describing: FooterClass.self)
    public init(_ tableView: UITableView, delegate: UITableViewDelegate? = nil, sectionsContainer: TableViewSameSectionsContainer<CellClass, HeaderClass, FooterClass>) {
        self.sectionsContainer = sectionsContainer
        super.init()
        self.tableView = tableView
        self.otherDelegate = delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.otherDelegate = delegate
        registerCells()
    }
    
    public convenience init(_ tableView: UITableView, delegate: UITableViewDelegate? = nil, cells: [TableViewSameCellContainer<CellClass>]) {
        self.init(tableView, delegate: delegate, sectionsContainer: .init([.init(cells)]))
    }
    
    private func registerCells() {
        tableView.register(CellClass.self, forCellReuseIdentifier: cellReuseId)
        tableView.register(HeaderClass.self, forHeaderFooterViewReuseIdentifier: headerReuseId)
        tableView.register(FooterClass.self, forHeaderFooterViewReuseIdentifier: footerReuseId)
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        guard super.responds(to: aSelector) == false else { return true }
        guard let delegate = otherDelegate else { return false }
        let delegateResult = delegate.responds(to: aSelector)
        return delegateResult
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return super.forwardingTarget(for: aSelector) ?? otherDelegate
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsContainer.sectionsContainers.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsContainer.sectionsContainers[section].cellContainers.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row].height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionsContainer.sectionsContainers[section].headerContainer?.height ?? CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionsContainer.sectionsContainers[section].headerContainer?.height ?? CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerContainer = sectionsContainer.sectionsContainers[section].headerContainer else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseId)
        header?.perform(Selector.init(("config:")), with: headerContainer.data)
        return header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerContainer = sectionsContainer.sectionsContainers[section].headerContainer else { return nil }
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerReuseId)
        footer?.perform(Selector.init(("config:")), with: footerContainer.data)
        return footer
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        cell.perform(Selector.init(("config:")), with: sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row].data)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row].clickAction?(tableView, indexPath, sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row].canEdit
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row].canMove
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionsContainer.sectionIndexTitles
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionsContainer.sectionForSectionIndexTitle?(tableView, title, index) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sectionsContainer.moveRow?(tableView, sourceIndexPath, destinationIndexPath)
    }
    
}

