//
//  TableViewMutableSectionDataSource.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/10/17.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit

open class TableViewMutableCellContainer: TableViewReusableContainer<UITableViewCellReusableFectoryProtocol, Any>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public let `class`: AnyClass
    open var canEdit: Bool = false
    open var canMove: Bool = false
    open var clickAction: ((UITableView, IndexPath, TableViewMutableCellContainer) -> Void)?
    public init<T: UITableViewCellReusableFectoryProtocol>(class: T.Type,
                                                           height: CGFloat = UITableView.automaticDimension,
                                                           canEdit: Bool = false,
                                                           canMove: Bool = false,
                                                           data: T.DataType? = nil,
                                                           clickAction: ((UITableView, IndexPath, TableViewMutableCellContainer, T.DataType?) -> Void)? = nil) {
        self.class = `class`
        super.init(height: height, data: data)
        self.canEdit = canEdit
        self.canMove = canMove
        self.clickAction = { tv, ip, ct in
            clickAction?(tv, ip, ct, data)
        }
    }
    
    public class func space(_ height: CGFloat) -> TableViewMutableCellContainer {
        return TableViewMutableCellContainer.init(class: NilCellClass.self, height: height)
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init(class: NilCellClass.self, height: CGFloat(value))
    }
    
    required public convenience init(integerLiteral value: Int) {
        self.init(class: NilCellClass.self, height: CGFloat(value))
    }
}

open class TableViewMutableHeaderFooterContainer: TableViewReusableContainer<UITableViewHeaderFooterViewReusableFectoryProtocol, Any>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public let `class`: AnyClass
    open var clickAction: ((UITableView, IndexPath, TableViewMutableHeaderFooterContainer) -> Void)?
    public init<T: UITableViewHeaderFooterViewReusableFectoryProtocol>(class: T.Type,
                                                                       height: CGFloat = UITableView.automaticDimension,
                                                                       data: T.DataType? = nil,
                                                                       clickAction: ((UITableView, IndexPath, TableViewMutableHeaderFooterContainer, T.DataType?) -> Void)? = nil) {
        self.class = `class`
        super.init(height: height, data: data)
        self.clickAction = { tv, ip, ct in
            clickAction?(tv, ip, ct, data)
        }
    }
    
    public convenience init(height: CGFloat) {
        self.init(class: NilHeaderFooterClass.self, height: height, data: nil, clickAction: nil)
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init(height: CGFloat(value))
    }
    required public convenience init(integerLiteral value: Int) {
        self.init(height: CGFloat(value))
    }
}

public class TableViewMutableSectionContainer {
    public var headerContainer: TableViewMutableHeaderFooterContainer?
    public var footerContainer: TableViewMutableHeaderFooterContainer?
    public var cellContainers: [TableViewMutableCellContainer] = []
    public init(_ cellContainers: [TableViewMutableCellContainer] = [],
                headerContainer: TableViewMutableHeaderFooterContainer? = nil,
                footerContainer: TableViewMutableHeaderFooterContainer? = nil) {
        self.headerContainer = headerContainer
        self.footerContainer = footerContainer
        self.cellContainers = cellContainers
    }
}

public class TableViewMutableSectionsContainer {
    public var sectionIndexTitles: [String]?
    public var sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)?
    public var moveRow: ((UITableView, IndexPath, IndexPath) -> ())?
    public var sectionsContainers: [TableViewMutableSectionContainer] = []
    public init(_ sectionsContainers: [TableViewMutableSectionContainer] = [],
                sectionIndexTitles: [String]? = nil,
                sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)? = nil,
                moveRow: ((UITableView, IndexPath, IndexPath) -> ())? = nil) {
        self.sectionsContainers = sectionsContainers
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
        self.moveRow = moveRow
    }
}

public class TableViewMutableSectionDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let sectionsContainer: TableViewMutableSectionsContainer
    private weak var tableView: UITableView!
    private weak var otherDelegate: AnyObject?
    public init(_ tableView: UITableView,
                delegate: UITableViewDelegate? = nil,
                sectionsContainer: TableViewMutableSectionsContainer) {
        self.sectionsContainer = sectionsContainer
        super.init()
        self.tableView = tableView
        self.otherDelegate = delegate
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.otherDelegate = delegate
        registerCells()
    }
    
    private func registerCells() {
        sectionsContainer.sectionsContainers.forEach { (sectionContainer) in
            if let headerContainer = sectionContainer.headerContainer {
                tableView.register(headerContainer.class, forHeaderFooterViewReuseIdentifier: generateReuseId(headerContainer.class))
            }
            if let footerContainer = sectionContainer.footerContainer {
                tableView.register(footerContainer.class, forHeaderFooterViewReuseIdentifier: generateReuseId(footerContainer.class))
            }
            sectionContainer.cellContainers.forEach({ (cellContainer) in
                tableView.register(cellContainer.class, forCellReuseIdentifier: generateReuseId(cellContainer.class))
            })
        }
    }
    
    private func generateReuseId(_ class: AnyClass) -> String {
        return String.init(describing: `class`)
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
    
    @objc public func config(_ sender: Any?) {}

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
        guard let height = sectionsContainer.sectionsContainers[section].headerContainer?.height else {
            return .leastNormalMagnitude
        }
        return height == 0.0 ? .leastNormalMagnitude : height
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let height = sectionsContainer.sectionsContainers[section].footerContainer?.height else {
            return .leastNormalMagnitude
        }
        return height == 0.0 ? .leastNormalMagnitude : height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerContainer = sectionsContainer.sectionsContainers[section].headerContainer else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: generateReuseId(headerContainer.class))
        header?.perform(#selector(config(_:)), with: headerContainer.data)
        return header
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerContainer = sectionsContainer.sectionsContainers[section].headerContainer else { return nil }
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: generateReuseId(footerContainer.class))
        footer?.perform(#selector(config(_:)), with: footerContainer.data)
        return footer
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContainer = sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: generateReuseId(cellContainer.class), for: indexPath)
        cell.perform(#selector(config(_:)), with: cellContainer.data)
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
