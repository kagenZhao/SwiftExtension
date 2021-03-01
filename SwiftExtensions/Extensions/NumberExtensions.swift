//
//  NumberExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 16/8/4.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit

// MARK: 数字格式化协议, 底层使用Decimal实现, 支持大数
public protocol NumberStringConverable {
    /// 四舍五入 格式化 100000.00 -> 100,000.00
    func priceFormatter(digits: Int) -> String
    
    /// 作用同`priceFormatter`
    /// 此方法会自动舍弃末尾的0, 987.8001 -> "987.8"
    /// 只有在末尾不为0时才会保留指定小数位
    func autoPriceFormatter(maxDigits: Int) -> String
    
    /// 四舍五入 格式化 100000.00 -> 10.00万
    /// digits: 大于10000时简化后小数位个数,   如 digits = 2,   100000.43123 -> 10.43万
    /// digits2: 小于10000时小数位个数, 如 digits2 = 3,   9000.43123 -> 9,000.431
    /// 默认digits2 不传 则等于 digits2 === digits
    func unitFormatter(digits: Int, digits2: Int?) -> String
    
    /// 作用同`unitFormatter`
    /// 此方法会自动舍弃末尾的0, 987.8001 -> "987.8"
    /// 只有在末尾不为0时才会保留指定小数位
    func autoUnitFormatter(maxDigits: Int, maxDigits2: Int?) -> String
    
    /// 四舍五入 格式化结果不带逗号 987.875 -> "987.88"
    func preciseDecimal(digits: Int) -> String
    
    /// 作用同`preciseDecimal`
    /// 此方法会自动舍弃末尾的0, 987.8001 -> "987.8"
    /// 只有在末尾不为0时才会保留指定小数位
    func autoPreciseDecimal(maxDigits: Int) -> String
        
    /// 根据完全自定义的`NumberFormatter`输出字符串
    func stringFormat(_ formatter: @autoclosure (() -> NumberFormatter)) -> String
        
    /// 最基础的方法, 上边所有方法都基于这个方法求出的结果
    func stringFormat(with closure: ((Decimal) -> String)) -> String
}

/// 数字转换
public protocol AbsoluteNumberFormaterConverable: NumberStringConverable {
    func toDecimal() -> Decimal
    func toInt() -> Int
    func toInt8() -> Int8
    func toInt16() -> Int16
    func toInt32() -> Int32
    func toInt64() -> Int64
    func toUInt() -> UInt
    func toUInt8() -> UInt8
    func toUInt16() -> UInt16
    func toUInt32() -> UInt32
    func toUInt64() -> UInt64
    func toFloat() -> Float
    func toDouble() -> Double
    #if canImport(UIKit)
    func toCGFloat() -> CGFloat
    #endif
    func stringValue() -> String
}

/// 针对字符串一类不确定能否转成数字的对象, 进行可选转换, 带默认值
public protocol OptionalNumberFormaterConverable: NumberStringConverable {
    var originalString: String { get }
    func toDecimal(by formatter: NumberFormatter?) -> Decimal?
    func toInt(by formatter: NumberFormatter?, default value: Int) -> Int
    func toInt8(by formatter: NumberFormatter?, default value: Int8) -> Int8
    func toInt16(by formatter: NumberFormatter?, default value: Int16) -> Int16
    func toInt32(by formatter: NumberFormatter?, default value: Int32) -> Int32
    func toInt64(by formatter: NumberFormatter?, default value: Int64) -> Int64
    func toUInt(by formatter: NumberFormatter?, default value: UInt) -> UInt
    func toUInt8(by formatter: NumberFormatter?, default value: UInt8) -> UInt8
    func toUInt16(by formatter: NumberFormatter?, default value: UInt16) -> UInt16
    func toUInt32(by formatter: NumberFormatter?, default value: UInt32) -> UInt32
    func toUInt64(by formatter: NumberFormatter?, default value: UInt64) -> UInt64
    func toFloat(by formatter: NumberFormatter?, default value: Float) -> Float
    func toDouble(by formatter: NumberFormatter?, default value: Double) -> Double
    #if canImport(UIKit)
    func toCGFloat(by formatter: NumberFormatter?, default value: CGFloat) -> CGFloat
    #endif
    func stringValue() -> String
}

// MARK: 提供数字之间的转换
/// 所有转换的结果都是截断的, `注意! 并不是` 四舍五入
/// 底层基于`NSDecimalNumber`提供的系统方法
/// 比如  1.5 toInt() ---> 1
public extension AbsoluteNumberFormaterConverable {
    func toInt() -> Int {
        return toDecimal().nsValue.intValue
    }
    
    func toInt8() -> Int8 {
        return toDecimal().nsValue.int8Value
    }
    
    func toInt16() -> Int16 {
        return toDecimal().nsValue.int16Value
    }
    
    func toInt32() -> Int32 {
        return toDecimal().nsValue.int32Value
    }
    
    func toInt64() -> Int64 {
        return toDecimal().nsValue.int64Value
    }
    
    func toUInt() -> UInt {
        return toDecimal().nsValue.uintValue
    }
    
    func toUInt8() -> UInt8 {
        return toDecimal().nsValue.uint8Value
    }
    
    func toUInt16() -> UInt16 {
        return toDecimal().nsValue.uint16Value
    }
    
    func toUInt32() -> UInt32 {
        return toDecimal().nsValue.uint32Value
    }
    
    func toUInt64() -> UInt64 {
        return toDecimal().nsValue.uint64Value
    }
    
    func toFloat() -> Float {
        return toDecimal().nsValue.floatValue
    }
    
    func toDouble() -> Double {
        return toDecimal().nsValue.doubleValue
    }
    
    #if canImport(UIKit)
    func toCGFloat() -> CGFloat {
        return CGFloat(toDouble())
    }
    #endif
    
    func stringValue() -> String {
        return toDecimal().stringValue
    }
}

public extension OptionalNumberFormaterConverable {
    func toInt(by formatter: NumberFormatter? = nil, default value: Int = 0) -> Int {
        return toDecimal(by: formatter)?.toInt() ?? value
    }
    
    func toInt8(by formatter: NumberFormatter? = nil, default value: Int8 = 0) -> Int8 {
        return toDecimal(by: formatter)?.toInt8() ?? value
    }

    func toInt16(by formatter: NumberFormatter? = nil, default value: Int16 = 0) -> Int16 {
        return toDecimal(by: formatter)?.toInt16() ?? value
    }
    
    func toInt32(by formatter: NumberFormatter? = nil, default value: Int32 = 0) -> Int32 {
        return toDecimal(by: formatter)?.toInt32() ?? value
    }

    func toInt64(by formatter: NumberFormatter? = nil, default value: Int64 = 0) -> Int64 {
        return toDecimal(by: formatter)?.toInt64() ?? value
    }
    
    func toUInt(by formatter: NumberFormatter? = nil, default value: UInt = 0) -> UInt {
        return toDecimal(by: formatter)?.toUInt() ?? value
    }

    func toUInt8(by formatter: NumberFormatter? = nil, default value: UInt8 = 0) -> UInt8 {
        return toDecimal(by: formatter)?.toUInt8() ?? value
    }
    
    func toUInt16(by formatter: NumberFormatter? = nil, default value: UInt16 = 0) -> UInt16 {
        return toDecimal(by: formatter)?.toUInt16() ?? value
    }

    func toUInt32(by formatter: NumberFormatter? = nil, default value: UInt32 = 0) -> UInt32 {
        return toDecimal(by: formatter)?.toUInt32() ?? value
    }
    
    func toUInt64(by formatter: NumberFormatter? = nil, default value: UInt64 = 0) -> UInt64 {
        return toDecimal(by: formatter)?.toUInt64() ?? value
    }

    func toFloat(by formatter: NumberFormatter? = nil, default value: Float = 0) -> Float {
        return toDecimal(by: formatter)?.toFloat() ?? value
    }
    
    func toDouble(by formatter: NumberFormatter? = nil, default value: Double = 0) -> Double {
        return toDecimal(by: formatter)?.toDouble() ?? value
    }
    
    #if canImport(UIKit)
    func toCGFloat(by formatter: NumberFormatter? = nil, default value: CGFloat = 0) -> CGFloat {
        if let double = toDecimal(by: formatter)?.toDouble() {
            return CGFloat(double)
        } else {
            return value
        }
    }
    #endif
    
    func stringValue() -> String {
        return originalString
    }
}

public extension NumberStringConverable {
    func priceFormatter(digits: Int) -> String {
        return stringFormat(minDigits: digits, maxDigits: digits, numberStyle: .decimal, roundingMode: .halfUp)
    }
    
    func autoPriceFormatter(maxDigits: Int) -> String {
        return stringFormat(minDigits: 0, maxDigits: maxDigits, numberStyle: .decimal, roundingMode: .halfUp)
    }

    func unitFormatter(digits: Int, digits2: Int? = nil) -> String {
        return unitFormatter(minDigits: digits, maxDigits: digits, minDigits2: digits2, maxDigits2: digits2)
    }
    
    func autoUnitFormatter(maxDigits: Int, maxDigits2: Int? = nil) -> String {
        return unitFormatter(minDigits: 0, maxDigits: maxDigits, minDigits2: 0, maxDigits2: maxDigits2)
    }
    
    func preciseDecimal(digits: Int) -> String {
        return stringFormat(minDigits: digits, maxDigits: digits, numberStyle: .none, roundingMode: .halfUp)
    }

    func autoPreciseDecimal(maxDigits: Int) -> String {
        return stringFormat(minDigits: 0, maxDigits: maxDigits, numberStyle: .none, roundingMode: .halfUp)
    }
    
    func stringFormat(minDigits: Int, maxDigits: Int, numberStyle: NumberFormatter.Style, roundingMode: NumberFormatter.RoundingMode = .halfUp) -> String {
        return stringFormat(NumberFormatter(minDigits: minDigits, maxDigits: maxDigits, numberStyle: numberStyle, roundingMode: roundingMode))
    }
    
    func stringFormat(_ formatter: @autoclosure (() -> NumberFormatter)) -> String {
        return stringFormat { (decimal) -> String in
            return decimal.string(by: formatter())
        }
    }
    
    private func unitFormatter(minDigits: Int, maxDigits: Int, minDigits2: Int?, maxDigits2: Int?) -> String {
        return stringFormat { (decimal) -> String in
            var format = NumberFormatter(minDigits: minDigits, maxDigits: maxDigits, numberStyle: .none, roundingMode: .halfUp)
            if decimal.magnitude >= 100000000 {
                format.positiveSuffix = "亿"
                format.negativeSuffix = "亿"
                return (decimal / 100000000).string(by: format)
            } else if decimal.magnitude >= 10000 {
                format.positiveSuffix = "万"
                format.negativeSuffix = "万"
                return (decimal / 10000).string(by: format)
            } else {
                format = NumberFormatter(minDigits: minDigits2 ?? minDigits, maxDigits: maxDigits2 ?? maxDigits, numberStyle: .decimal, roundingMode: .halfUp)
                return decimal.string(by: format)
            }
        }
    }
}

public extension AbsoluteNumberFormaterConverable {
    func stringFormat(with closure: ((Decimal) -> String)) -> String {
        return closure(toDecimal())
    }
}

public extension OptionalNumberFormaterConverable {
    func stringFormat(with closure: ((Decimal) -> String)) -> String {
        guard let decimal = toDecimal(by: nil) else { return originalString }
        return closure(decimal)
    }
}

public extension String {
    func priceUnformatter() -> Decimal? {
        return toDecimal(by: NumberFormatter(minDigits: 0, maxDigits: .max, numberStyle: .decimal, roundingMode: .halfUp))
    }
    
    func unitUnformatter() -> Decimal? {
        let formatter = NumberFormatter(minDigits: 0, maxDigits: .max, numberStyle: .none, roundingMode: .halfUp)
        
        formatter.positiveSuffix = "亿"
        formatter.negativeSuffix = "亿"
        if let yiDecimal = toDecimal(by: formatter) {
            return yiDecimal * 100000000
        }
        
        formatter.positiveSuffix = "万"
        formatter.negativeSuffix = "万"
        if let wanDecimal = toDecimal(by: formatter) {
            return wanDecimal * 10000
        }
        
        formatter.numberStyle = .decimal
        return toDecimal(by: formatter)
    }
    
    func preciseDecimalUnformatter() -> Decimal? {
        return toDecimal(by: nil)
    }
}

//MARK: 所有整型
extension Int: AbsoluteNumberFormaterConverable {}
extension Int8: AbsoluteNumberFormaterConverable {}
extension Int16: AbsoluteNumberFormaterConverable {}
extension Int32: AbsoluteNumberFormaterConverable {}
extension Int64: AbsoluteNumberFormaterConverable {}
extension UInt: AbsoluteNumberFormaterConverable {}
extension UInt8: AbsoluteNumberFormaterConverable {}
extension UInt16: AbsoluteNumberFormaterConverable {}
extension UInt32: AbsoluteNumberFormaterConverable {}
extension UInt64: AbsoluteNumberFormaterConverable {}
//MARK: 所有浮点型
extension Float: AbsoluteNumberFormaterConverable {} /// === Float32
extension Double: AbsoluteNumberFormaterConverable {} /// === Float64
#if canImport(UIKit)
extension CGFloat: AbsoluteNumberFormaterConverable {}
#endif

public extension FixedWidthInteger where Self: UnsignedInteger {
    func toDecimal() -> Decimal {
        return Decimal(UInt64(self))
    }
}

public extension FixedWidthInteger where Self: SignedInteger {
    func toDecimal() -> Decimal {
        return Decimal(Int64(self))
    }
}

public extension BinaryFloatingPoint {
    func toDecimal() -> Decimal {
        return Decimal(Double(self))
    }
}

//MARK: Decimal
extension Decimal: AbsoluteNumberFormaterConverable {
    public func toDecimal() -> Decimal {
        return self
    }
}

//MARK: String
extension String: OptionalNumberFormaterConverable {
    public var originalString: String {
        return self
    }
    public func toDecimal(by formatter: NumberFormatter? = nil) -> Decimal? {
        if let formatter = formatter {
            return formatter.number(from: self)?.decimalValue
        } else {
            if self.contains(",") {
                /// 兼容 1,990.00
                let formatter = NumberFormatter(minDigits: 0, maxDigits: .max, numberStyle: .decimal, roundingMode: .halfUp)
                return formatter.number(from: self)?.decimalValue
            } else {
                /// 这里如果直接使用Decimal(string:) 会把 1.99abc 转换成1.99, 这不是预期结果
                /// 使用formatter则会吧 1.99abc 转换成 nil, 这是符合预期的
                let formatter = NumberFormatter(minDigits: 0, maxDigits: .max, numberStyle: .none, roundingMode: .halfUp)
                return formatter.number(from: self)?.decimalValue
            }
        }
    }
}

//MARK: Private Extensions
extension NumberFormatter {
    fileprivate convenience init(minDigits: Int, maxDigits: Int, numberStyle: Style, roundingMode: RoundingMode = .halfUp) {
        self.init()
        self.minimumIntegerDigits = 1 /// 解决iOS14以下 整数为0时 显示 ".x" 的bug
        self.minimumFractionDigits = minDigits
        self.maximumFractionDigits = maxDigits
        self.numberStyle = numberStyle
        self.roundingMode = roundingMode
    }
    
    fileprivate func string(from number: AbsoluteNumberFormaterConverable) -> String {
        let decimal = number.toDecimal()
        return decimal.string(by: self)
    }
    
    fileprivate func string(from number: Decimal) -> String? {
        return string(from: number.nsValue)
    }
}

extension Decimal {
    fileprivate var stringValue: String {
        return nsValue.stringValue
    }
    
    fileprivate func string(by numberFormatter: NumberFormatter) -> String {
        return numberFormatter.string(from: self) ?? self.stringValue
    }
    
    fileprivate var nsValue: NSDecimalNumber {
        return self as NSDecimalNumber
    }
}
