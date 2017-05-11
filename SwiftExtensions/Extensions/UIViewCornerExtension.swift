//
//  UIViewCornerExtension.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation
import UIKit

private func roundbyunit(_ num: Double, _ unit: inout Double) -> Double {
    let remain = modf(num, &unit)
    if (remain > unit / 2.0) {
        return ceilbyunit(num, &unit)
    } else {
        return floorbyunit(num, &unit)
    }
}
private func ceilbyunit(_ num: Double, _ unit: inout Double) -> Double {
    return num - modf(num, &unit) + unit
}


private func floorbyunit(_ num: Double, _ unit: inout Double) -> Double {
    return num - modf(num, &unit)
}


private func pixel(_ num: Double) -> Double {
    var unit: Double
    switch Int(UIScreen.main.scale) {
    case 1: unit = 1.0 / 1.0
    case 2: unit = 1.0 / 2.0
    case 3: unit = 1.0 / 3.0
    default: unit = 0.0
    }
    return roundbyunit(num, &unit)
}

public extension UIView {
    func addCorner(radius: CGFloat) {
        self.addCorner(radius: radius, borderWidth: 1, backgroundColor: UIColor.clear, borderColor: UIColor.black)
    }
    
    func addCorner(radius: CGFloat,
                              borderWidth: CGFloat,
                              backgroundColor: UIColor,
                              borderColor: UIColor) {
        
        let imageView = UIImageView(image: drawRectWithRoundedCorner(radius: radius,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            borderColor: borderColor))
        self.insertSubview(imageView, at: 0)
    }
    
    private func drawRectWithRoundedCorner(radius: CGFloat,
                                              borderWidth: CGFloat,
                                              backgroundColor: UIColor,
                                              borderColor: UIColor) -> UIImage {
        
        let sizeToFit = CGSize(width: pixel(Double(self.bounds.size.width)), height: Double(self.bounds.size.height))
        let halfBorderWidth = CGFloat(borderWidth / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(borderWidth)
        context?.setStrokeColor(borderColor.cgColor)
        context?.setFillColor(backgroundColor.cgColor)
        
        let width = sizeToFit.width, height = sizeToFit.height
        context?.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))  // 开始坐标右边开始
        context?.addArc(tangent1End: CGPoint.init(x: width - halfBorderWidth, y: height - halfBorderWidth),
                        tangent2End: CGPoint.init(x: width - radius - halfBorderWidth, y: height - halfBorderWidth),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint.init(x: halfBorderWidth, y: height - halfBorderWidth),
                        tangent2End: CGPoint.init(x: halfBorderWidth, y: height - radius - halfBorderWidth),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint.init(x: halfBorderWidth, y: halfBorderWidth),
                        tangent2End: CGPoint.init(x: width - halfBorderWidth, y: halfBorderWidth),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint.init(x: width - halfBorderWidth, y: halfBorderWidth),
                        tangent2End: CGPoint.init(x: width - halfBorderWidth, y: radius + halfBorderWidth),
                        radius: radius)
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output!
    }
}

public extension UIImageView {
    override func addCorner(radius: CGFloat) {
        self.image = self.image?.drawRectWithRoundedCorner(radius: radius, self.bounds.size)
    }
}

private extension UIImage {
    func drawRectWithRoundedCorner(radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        UIGraphicsGetCurrentContext()?.clip()
        
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return output!
    }
}

