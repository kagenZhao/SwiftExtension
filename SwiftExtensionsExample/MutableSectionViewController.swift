//
//  MutableSectionViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2018/10/17.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions

class MutableCell1: UITableViewCell, TableViewReusableFectoryProtocol {
    @objc func config(_ data: String?) {
        self.textLabel?.text = "MutableCell1---\(data ?? "")"
    }
}

class MutableCell2: UITableViewCell, TableViewReusableFectoryProtocol {
    @objc func config(_ data: [String]?) {
        self.textLabel?.text = "MutableCell2---\(data?[0] ?? "")"
    }
}


class MutableSectionViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var sectionsDataSource: TableViewMutableSectionsContainer!
    var tableViewDataSource: TableViewMutableSectionDataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        let section1 = TableViewMutableSectionContainer([
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            .space(10),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section0 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section0 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            })], headerContainer: 10, footerContainer: 30)
        
        let section2 = TableViewMutableSectionContainer([
            TableViewMutableCellContainer(class: MutableCell1.self, data: "section1 row0", clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            }),
            TableViewMutableCellContainer(class: MutableCell2.self, data: ["section1 row1"], clickAction: { (tv, indexPath, container, data) in
                print("section: \(indexPath.section), row: \(indexPath.row), data: \(data!)")
            })], headerContainer: 50, footerContainer: 15.0)
        sectionsDataSource = .init([section1, section2])
        tableViewDataSource = TableViewMutableSectionDataSource(tableView, delegate: self, sectionsContainer: sectionsDataSource)
    }
}
