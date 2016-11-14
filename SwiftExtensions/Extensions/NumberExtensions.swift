//
//  NumberExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

public protocol KZIntegerProtocol {
    var ki: Int { get }
}

public protocol KZFloatProtocol {
    var kf: Float { get }
}

public protocol KZDoubleProtocol {
    var kd: Double { get }
}

public protocol KZCGFloatProtocol {
    var kcf: CGFloat { get }
}

public protocol KZABSProtocol {
    associatedtype ABSType
    var ka: ABSType { get }
}

extension Int: KZIntegerProtocol, KZFloatProtocol, KZDoubleProtocol, KZCGFloatProtocol, KZABSProtocol {

    public typealias ABSType = Int
    
    public var ki: Int { return Int(self) }
    
    public var kf: Float { return Float(self) }
    
    public var kd: Double { return Double(self) }
    
    public var kcf: CGFloat { return CGFloat(self) }
    
    public var ka: ABSType { return abs(self) }
}

extension Float: KZIntegerProtocol, KZFloatProtocol, KZDoubleProtocol, KZCGFloatProtocol, KZABSProtocol {
    
    public typealias ABSType = Float
    
    public var ki: Int { return Int(self) }
    
    public var kf: Float { return Float(self) }
    
    public var kd: Double { return Double(self) }
    
    public var kcf: CGFloat { return CGFloat(self) }
    
    public var ka: ABSType { return abs(self) }
}

extension Double: KZIntegerProtocol, KZFloatProtocol, KZDoubleProtocol, KZCGFloatProtocol, KZABSProtocol {
    
    public typealias ABSType = Double
    
    public var ki: Int { return Int(self) }
    
    public var kf: Float { return Float(self) }
    
    public var kd: Double { return Double(self) }
    
    public var kcf: CGFloat { return CGFloat(self) }
    
    public var ka: ABSType { return abs(self) }
}

extension CGFloat: KZIntegerProtocol, KZFloatProtocol, KZDoubleProtocol, KZCGFloatProtocol, KZABSProtocol {
    
    public typealias ABSType = CGFloat
    
    public var ki: Int { return Int(self) }
    
    public var kf: Float { return Float(self) }
    
    public var kd: Double { return Double(self) }
    
    public var kcf: CGFloat { return CGFloat(self) }
    
    public var ka: ABSType { return abs(self) }
}

