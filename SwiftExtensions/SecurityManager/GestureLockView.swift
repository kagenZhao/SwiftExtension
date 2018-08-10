//
//  GestureLockView.swift
//  SecurityManager
//
//  Created by 赵国庆 on 2018/7/30.
//  Copyright © 2018年 zhaoguoqing. All rights reserved.
//

import UIKit
import SnapKit

class GestureLockView: UIView {
    private var points: [UIButton] = []
    private var selectedPoints: [UIButton] = []
    private let lineLayer = CAShapeLayer()
    
    var drawRectFinished:((String) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    
    private func constructor() {
        backgroundColor = .white
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction(_:))))
        
        lineLayer.lineWidth = 6
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor(red: 0.0706, green: 0.588, blue: 0.859, alpha: 1).cgColor
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(lineLayer)
        
        for i in 0...8 {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = .white
            btn.isUserInteractionEnabled = false
            btn.setImage(UIImage(named: "gesture_normal"), for: .normal)
            btn.setImage(UIImage(named: "gesture_selected"), for: .selected)
            btn.tag = 1000 + i
            btn.imageView?.contentMode = .scaleAspectFit
            btn.contentHorizontalAlignment = .fill
            btn.contentVerticalAlignment = .fill
            addSubview(btn)
            points.append(btn)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        let cols = 3
        let minW = min(frame.size.height, frame.size.width)
        let w = (minW / CGFloat(cols + cols - 1)) * 1.2
        let dt = (minW - CGFloat(cols) * w) / CGFloat(cols - 1)
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        if frame.size.height > frame.size.width {
            dy = (frame.size.height - frame.size.width) / 2
        } else {
            dx = (frame.size.width - frame.size.height) / 2
        }
        for (i, btn) in points.enumerated() {
            let col = CGFloat(i % cols) // 横排
            let row = CGFloat(i / cols) // 竖排
            let x = dx + col * (w + dt)
            let y = dy + row * (w + dt)
            let width = w
            let height = w
            btn.layer.cornerRadius = w / 2
            btn.snp.remakeConstraints { (maker) in
                maker.left.equalTo(x)
                maker.top.equalTo(y)
                maker.width.equalTo(width)
                maker.height.equalTo(height)
            }
        }
    }
    
    private var currentPoint = CGPoint.zero
    @objc private func panAction(_ pan: UIPanGestureRecognizer) {
        currentPoint = pan.location(in: self)
        
        setNeedsDisplay()
        
        points.forEach { (btn) in
            if btn.frame.contains(currentPoint), btn.isSelected == false {
                btn.isSelected = true
                selectedPoints.append(btn)
            }
        }
        
        layoutIfNeeded()
        
        if pan.state == .ended {
            var pwd = ""
            selectedPoints.forEach { (btn) in
                pwd += "\(btn.tag - 1000)"
                btn.isSelected = false
                btn.viewWithTag(8080)?.isHidden = true
            }
            selectedPoints.removeAll()
            
            drawRectFinished?(pwd)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard selectedPoints.count > 0 else {
            lineLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        for (i, btn) in selectedPoints.enumerated() {
            if i == 0 {
                path.move(to: btn.center)
            } else {
                path.addLine(to: btn.center)
                setButtonArrow(btn, lastBtn: selectedPoints[i - 1])
            }
        }
        path.addLine(to: currentPoint)
        lineLayer.path = path.cgPath
    }
    
    private func setButtonArrow(_ btn: UIButton, lastBtn: UIButton) {
        let x1 = lastBtn.center.x, y1 = lastBtn.center.y
        let x2 = btn.center.x, y2 = btn.center.y
        var r = atan((y2 - y1) / (x2 - x1))
        if abs(y2 - y1) <= .ulpOfOne {
            r = x2 - x1 > .ulpOfOne ? 0 : -.pi
        } else if abs(x2 - x1) <= .ulpOfOne {
            r = y2 - y1 > .ulpOfOne ? (.pi / 2) : (.pi / -2)
        } else if x2 - x1 < -.ulpOfOne {
            r = y2 - y1 > .ulpOfOne ? (r + .pi) : (r - .pi)
        }
        let imageView = (lastBtn.viewWithTag(8080) as? UIImageView) ?? UIImageView(image: createArrowImage(with: lastBtn))
        imageView.tag = 8080
        imageView.transform = .init(rotationAngle: r + .pi / 2)
        imageView.isHidden = false
        lastBtn.addSubview(imageView)
    }
    
    private func createArrowImage(with btn: UIButton) -> UIImage? {
        let image = UIImage(named: "gesture_direction")!
        let btnSize = btn.frame.size
        let centerSize = CGSize(width: btnSize.width / 2.7, height: btnSize.height / 2.7)
        UIGraphicsBeginImageContextWithOptions(btn.frame.size, false, UIScreen.main.scale)
        image.draw(at: CGPoint(x: (btnSize.width - centerSize.width) / 2 + (centerSize.width - image.size.width) / 2, y: ((btnSize.height - centerSize.height) / 2 - image.size.width) / 2))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
