//
//  GestureLockIndicator.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/30.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit

class GestureLockIndicator: UIView {
    private var points: [UIButton] = []
    private var selectedPoints: [UIButton] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    private func constructor() {
        backgroundColor = .clear
        for i in 0...8 {
            let btn = UIButton(type: .custom)
            btn.isUserInteractionEnabled = false
            btn.setImage(UIImage(named: "gesture_indicator_normal"), for: .normal)
            btn.setImage(UIImage(named: "gesture_indicator_selected"), for: .selected)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.contentHorizontalAlignment = .fill
            btn.contentVerticalAlignment = .fill
            addSubview(btn)
            points.append(btn)
            
            let cols = 3
            let col = CGFloat(i % cols) // 横排
            let row = CGFloat(i / cols) // 竖排
            btn.snp.makeConstraints { (maker) in
                if col == 0 {
                    maker.left.equalTo(self)
                } else if col == 1 {
                    maker.centerX.equalTo(self)
                } else if col == 2 {
                    maker.right.equalTo(self)
                }
                
                if row == 0 {
                    maker.top.equalTo(self)
                } else if row == 1 {
                    maker.centerY.equalTo(self)
                } else if row == 2 {
                    maker.bottom.equalTo(self)
                }
                
                maker.width.equalTo(self).dividedBy(3).offset(-3)
                maker.height.equalTo(btn.snp.width)
            }
        }
    }
    
    public func setPwd(_ pwd: String) {
        guard pwd.count > 0 else {
            points.forEach{ $0.isSelected = false }
            return
        }
        
        for c in pwd {
            guard let i = Int(String(c)) else {
                continue
            }
            points[i].isSelected = true
        }
    }
    
}
