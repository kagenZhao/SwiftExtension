//
//  SameSectionViewController.swift
//  SwiftExtensionsExample
//
//  Created by 赵国庆 on 2018/10/16.
//  Copyright © 2018 kagenZhao. All rights reserved.
//

import UIKit
import SwiftExtensions

class SameCell: UITableViewCell, TableViewReusableFectoryProtocol {
    @objc func config(_ data: [String]?) {
        self.textLabel?.text = data?[0]
    }
}

class SameSectionViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    private var sectionsDataSource: TableViewSameSectionsContainer<SameCell, NilHeaderFooterClass, NilHeaderFooterClass>!
    private var tableViewDataSource: TableViewSameSectionDataSource<SameCell, NilHeaderFooterClass, NilHeaderFooterClass>!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        tableViewDataSource = TableViewSameSectionDataSource(tableView, delegate: self, sectionsContainer: sectionsDataSource)
    }

    private func setupData() {
        let section0Cells = (0...10).map { (idx)  in
            TableViewSameCellContainer<SameCell>.init(data: ["section: 0, row: \(idx)"], clickAction: { (tableView, indexPath, container) in
                print("section: 0, 点击了\(idx)")
            })
        }
        
        let section1Cells = (0...10).map { (idx)  in
            TableViewSameCellContainer<SameCell>.init(data: ["section: 1, row: \(idx)"], clickAction: { (tableView, indexPath, container) in
                print("section: 1, 点击了\(idx)")
            })
        }
        sectionsDataSource = TableViewSameSectionsContainer.init([TableViewSameSectionContainer(section0Cells), TableViewSameSectionContainer(section1Cells)])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay indexpath: \(indexPath.section), \(indexPath.row)")
    }
}
