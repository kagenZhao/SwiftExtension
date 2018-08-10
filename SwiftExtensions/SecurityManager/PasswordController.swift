//
//  PasswordController.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/8/1.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit

class PasswordController: UIViewController {

     var error: UIButton!
     var success: UIButton!
    
    
    var errorAction:((NSError) -> ())?
    var successAction:(() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.green
        
        error = UIButton(type: .system)
        error.setTitle("error", for: .normal)
        error.frame = CGRect(x: 10, y: 100, width: 100, height: 100)
        error.addTarget(self, action: #selector(errora(_:)), for: .touchUpInside)
        view.addSubview(error)
        
        success = UIButton(type: .system)
        success.setTitle("success", for: .normal)
        success.frame = CGRect(x: 10, y: 150, width: 100, height: 100)
        success.addTarget(self, action: #selector(successa(_:)), for: .touchUpInside)
        view.addSubview(success)
        
    }

    @objc func errora(_ sender: Any) {
        self.back()
        errorAction?(NSError(domain: "sssss", code: 1, userInfo: nil))
    }
    @objc func successa(_ sender: Any) {
        self.back()
        successAction?()
    }
    private func back() {
        if self.navigationController != nil, self.navigationController?.viewControllers[0] != self {
            self.navigationController?.popViewController(animated: true)
        } else if self.navigationController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
