//
//  TableViewCellFectory.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/10/15.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit
public typealias UITableViewCellReusableFectoryProtocol = (UITableViewCell & TableViewReusableFectoryProtocol)
public typealias UITableViewHeaderFooterViewReusableFectoryProtocol = (UITableViewHeaderFooterView & TableViewReusableFectoryProtocol)

public protocol TableViewReusableFectoryProtocol {
    associatedtype DataType
    func config(_ data: DataType?)
}

open class TableViewReusableContainer<ReusableClass, DataType>: NSObject {
    open var height: CGFloat = UITableView.automaticDimension
    open var data: DataType?
    public init(height: CGFloat = UITableView.automaticDimension, data: DataType? = nil) {
        super.init()
        self.height = height
        self.data = data
    }
}

public final class NilCellClass: UITableViewCellReusableFectoryProtocol {
    @objc public func config(_: Any?) { selectionStyle = .none }
}

public final class NilHeaderFooterClass: UITableViewHeaderFooterViewReusableFectoryProtocol {
    @objc public func config(_: Any?) {}
}
