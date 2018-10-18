//
//  TableViewSectionDataSource.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/10/17.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit

fileprivate func generateReuseId(_ class: AnyClass) -> String {
    return String.init(describing: `class`)
}

open class TableViewCellContainer: TableViewReusableContainer<UITableViewCellReusableFectoryProtocol, Any>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public let `class`: AnyClass
    open var canEdit: Bool = false
    open var canMove: Bool = false
    open var clickAction: ((UITableView, IndexPath, TableViewCellContainer) -> Void)?
    fileprivate lazy var generateClosure: ((UITableView, IndexPath) -> UITableViewCell)! = {
        return {[unowned self] tableView, indexPath in
            return tableView.dequeueReusableCell(withIdentifier: generateReuseId(self.`class`), for: indexPath)
        }
    }()
    public init<T: UITableViewCellReusableFectoryProtocol>(class: T.Type,
                                                           height: CGFloat = UITableView.automaticDimension,
                                                           canEdit: Bool = false,
                                                           canMove: Bool = false,
                                                           data: T.DataType? = nil,
                                                           clickAction: ((UITableView, IndexPath, TableViewCellContainer, T.DataType?) -> Void)? = nil) {
        self.class = `class`
        super.init(height: height, data: data)
        self.canEdit = canEdit
        self.canMove = canMove
        if clickAction != nil {
            self.clickAction = { tv, ip, ct in
                clickAction?(tv, ip, ct, data)
            }
        }
        self.generateClosure = { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: generateReuseId(`class`), for: indexPath) as! T
            cell.config(data)
            return cell
        }
    }
    
    private init<T: UITableViewCellReusableFectoryProtocol>(class: T.Type,
                                                           height: CGFloat = UITableView.automaticDimension) {
        self.class = `class`
        super.init(height: height)
        self.generateClosure = { tableView, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: generateReuseId(`class`), for: indexPath) as! T
            cell.config(nil)
            return cell
        }
    }
    
    public class func space(_ height: CGFloat) -> TableViewCellContainer {
        return TableViewCellContainer.init(class: NilCellClass.self, height: height)
    }
    
    required public convenience init(floatLiteral value: Float) {
        self.init(class: NilCellClass.self, height: CGFloat(value))
    }
    
    required public convenience init(integerLiteral value: Int) {
        self.init(class: NilCellClass.self, height: CGFloat(value))
    }
}

open class TableViewHeaderFooterContainer: TableViewReusableContainer<UITableViewHeaderFooterViewReusableFectoryProtocol, Any>, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public let `class`: AnyClass
    open var clickAction: ((UITableView, IndexPath, TableViewHeaderFooterContainer) -> Void)?
    fileprivate var generateClosure: ((UITableView, Int) -> UIView?)!
    public init<T: UITableViewHeaderFooterViewReusableFectoryProtocol>(class: T.Type,
                                                                       height: CGFloat = UITableView.automaticDimension,
                                                                       data: T.DataType? = nil,
                                                                       clickAction: ((UITableView, IndexPath, TableViewHeaderFooterContainer, T.DataType?) -> Void)? = nil) {
        self.class = `class`
        super.init(height: height, data: data)
        if clickAction != nil {
            self.clickAction = { tv, ip, ct in
                clickAction?(tv, ip, ct, data)
            }
        }
        self.generateClosure = { tableView, section in
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: generateReuseId(`class`)) as! T
            header.config(data)
            return header
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

public class TableViewSectionContainer {
    public var headerContainer: TableViewHeaderFooterContainer?
    public var footerContainer: TableViewHeaderFooterContainer?
    public var cellContainers: [TableViewCellContainer] = []
    public init(_ cellContainers: [TableViewCellContainer] = [],
                headerContainer: TableViewHeaderFooterContainer? = nil,
                footerContainer: TableViewHeaderFooterContainer? = nil) {
        self.headerContainer = headerContainer
        self.footerContainer = footerContainer
        self.cellContainers = cellContainers
    }
}

public class TableViewSectionsContainer {
    public var sectionIndexTitles: [String]?
    public var sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)?
    public var moveRow: ((UITableView, IndexPath, IndexPath) -> ())?
    public var sectionsContainers: [TableViewSectionContainer] = []
    public init(_ sectionsContainers: [TableViewSectionContainer] = [],
                sectionIndexTitles: [String]? = nil,
                sectionForSectionIndexTitle: ((UITableView, String, Int) -> Int)? = nil,
                moveRow: ((UITableView, IndexPath, IndexPath) -> ())? = nil) {
        self.sectionsContainers = sectionsContainers
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
        self.moveRow = moveRow
    }
}

public class TableViewSectionDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let sectionsContainer: TableViewSectionsContainer
    private weak var tableView: UITableView!
    private weak var otherDelegate: AnyObject?
    public init(_ tableView: UITableView,
                delegate: UITableViewDelegate? = nil,
                sectionsContainer: TableViewSectionsContainer) {
        self.sectionsContainer = sectionsContainer
        super.init()
        self.tableView = tableView
        self.otherDelegate = delegate
        self.registerCells()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.otherDelegate = delegate
        
    }
    
    private func registerCells() {
        var registed = ([String: AnyClass](), [String: AnyClass]())
        sectionsContainer.sectionsContainers.forEach { (sectionContainer) in
            if let headerContainer = sectionContainer.headerContainer {
                let headerId = generateReuseId(headerContainer.class)
                if registed.0[headerId] == nil {
                    tableView.register(headerContainer.class, forHeaderFooterViewReuseIdentifier: headerId)
                    registed.0[headerId] = headerContainer.class
                }
            }
            if let footerContainer = sectionContainer.footerContainer {
                let footerId = generateReuseId(footerContainer.class)
                if registed.0[footerId] == nil {
                    tableView.register(footerContainer.class, forHeaderFooterViewReuseIdentifier: footerId)
                    registed.0[footerId] = footerContainer.class
                }
            }
            sectionContainer.cellContainers.forEach({ (cellContainer) in
                let cellId = generateReuseId(cellContainer.class)
                if registed.1[cellId] == nil {
                    tableView.register(cellContainer.class, forCellReuseIdentifier: cellId)
                    registed.1[cellId] = cellContainer.class
                }
            })
        }
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
    
    @objc private func config(_ sender: Any?) {}

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
        return sectionsContainer.sectionsContainers[section].headerContainer?.generateClosure(tableView, section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionsContainer.sectionsContainers[section].footerContainer?.generateClosure(tableView, section)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let container = sectionsContainer.sectionsContainers[indexPath.section].cellContainers[indexPath.row]
        let closure = container.generateClosure
        return closure!(tableView, indexPath)
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
