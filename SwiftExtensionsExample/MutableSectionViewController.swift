//
//  SectionViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2018/10/17.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions

class Cell1: UITableViewCellReusableFectoryProtocol {
    func config(_ data: Int?) {
        self.selectionStyle = .none
        self.textLabel?.text = "Cell1---\(data!)"
    }
}

class Cell2: UITableViewCellReusableFectoryProtocol {
    func config(_ data: [String]?) {
        self.selectionStyle = .none
        self.textLabel?.text = "Cell2---\(data?[0] ?? "")"
    }
}

class Header1: UITableViewHeaderFooterViewReusableFectoryProtocol {
    
    var label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    func config(_ data: Int?) {
        label.text = "header1   \(data!)"
    }
}

class Header2: UITableViewHeaderFooterViewReusableFectoryProtocol {
    var label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    func config(_ data: [String]?) {
        label.text = "header2   \(data!)"
    }
}

class Footer1: UITableViewHeaderFooterViewReusableFectoryProtocol {
    
    var label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    func config(_ data: Int?) {
        label.text = "Footer1   \(data!)"
    }
}

class Footer2: UITableViewHeaderFooterViewReusableFectoryProtocol {
    
    var label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 300, height: 45))
        self.contentView.addSubview(label)
    }
    
    func config(_ data: Int?) {
        label.text = "Footer2   \(data!)"
    }
}

class MutableSectionViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var sectionsDataSource: TableViewSectionsContainer!
    var tableViewDataSource: TableViewSectionDataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        let section1 = TableViewSectionContainer(
            [
            TableViewCellContainer(class: Cell1.self, data: 123, clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            .space(10)
            ],
            headerContainer: TableViewHeaderFooterContainer.init(class: Header1.self, height: 45, data: 2222),
            footerContainer: TableViewHeaderFooterContainer.init(class: Footer1.self, height: 45, data: 1111))
        
        let section2 = TableViewSectionContainer(
            [
            TableViewCellContainer(class: Cell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            })
            ],
            headerContainer: TableViewHeaderFooterContainer.init(class: Header2.self, height: 45, data: ["abc, abc"]),
            footerContainer: 15.0)
        
        let section3 = TableViewSectionContainer(
            [
                TableViewCellContainer(class: Cell1.self, data: 456, clickAction: { (tv, indexPath, container, data) in
                    print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
                })
            ])
        sectionsDataSource = .init([section1, section2, section3])
        tableViewDataSource = TableViewSectionDataSource(tableView, delegate: self, sectionsContainer: sectionsDataSource)
    }
}
