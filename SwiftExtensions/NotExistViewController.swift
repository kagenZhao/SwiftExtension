//
//  NotExistViewController.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2017/4/27.
//  Copyright © 2017年 Kagen Zhao. All rights reserved.
//

import UIKit

class NotExistViewController: UIViewController {

    var pageName: String?
    
    convenience init(pageName: String) {
        self.init(nibName: nil, bundle: nil)
        self.pageName = pageName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel(frame: view.bounds)
        label.text = "page \(pageName != nil ? "\"\(pageName!)\"" : "") not found\n"
        label.textColor = .gray
        label.textAlignment = .center
        view.addSubview(label)
    }
}
