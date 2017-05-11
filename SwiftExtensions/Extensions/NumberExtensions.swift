//
//  NumberExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

/// 转换成Int
public protocol KZIntegerConversion {
    var toInt: Int { get }
}

/// 转换成Float
public protocol KZFloatConversion {
    var toFloat: Float { get }
}

/// 转换成Double
public protocol KZDoubleConversion {
    var toDouble: Double { get }
}

/// 转换成CGFloat
public protocol KZCGFloatConversion {
    var toCGFloat: CGFloat { get }
}

/// 转换成绝对值
public protocol KZABSConversion {
    associatedtype ABSType
    var toABS: ABSType { get }
}

/// 添加转换方法, 便于书写
extension Int: KZIntegerConversion, KZFloatConversion, KZDoubleConversion, KZCGFloatConversion, KZABSConversion {

    public typealias ABSType = Int
    
    public var toInt: Int { return Int(self) }
    
    public var toFloat: Float { return Float(self) }
    
    public var toDouble: Double { return Double(self) }
    
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    public var toABS: ABSType { return abs(self) }
}

/// 添加转换方法, 便于书写
extension Float: KZIntegerConversion, KZFloatConversion, KZDoubleConversion, KZCGFloatConversion, KZABSConversion {
    
    public typealias ABSType = Float
    
    public var toInt: Int { return Int(self) }
    
    public var toFloat: Float { return Float(self) }
    
    public var toDouble: Double { return Double(self) }
    
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    public var toABS: ABSType { return abs(self) }
}

/// 添加转换方法, 便于书写
extension Double: KZIntegerConversion, KZFloatConversion, KZDoubleConversion, KZCGFloatConversion, KZABSConversion {
    
    public typealias ABSType = Double
    
    public var toInt: Int { return Int(self) }
    
    public var toFloat: Float { return Float(self) }
    
    public var toDouble: Double { return Double(self) }
    
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    public var toABS: ABSType { return abs(self) }
}

/// 添加转换方法, 便于书写
extension CGFloat: KZIntegerConversion, KZFloatConversion, KZDoubleConversion, KZCGFloatConversion, KZABSConversion {
    
    public typealias ABSType = CGFloat
    
    public var toInt: Int { return Int(self) }
    
    public var toFloat: Float { return Float(self) }
    
    public var toDouble: Double { return Double(self) }
    
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    public var toABS: ABSType { return abs(self) }
}

