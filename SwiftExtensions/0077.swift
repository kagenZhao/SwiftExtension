//
//  0077.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/10/14.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation


/// 运算符重载
/// 语法

/// AssignmentPrecedence < TernaryPrecedence < DefaultPrecedence

// TernaryPrecedence < LogicalDisjunctionPrecedence < LogicalConjunctionPrecedence < ComparisonPrecedence < NilCoalescingPrecedence < CastingPrecedence < RangeFormationPrecedence < AdditionPrecedence < MultiplicationPrecedence < BitwiseShiftPrecedence

/*
 postfix operator ++
 postfix operator --
 // postfix operator !
 
 prefix operator ++
 prefix operator --
 prefix operator !
 prefix operator ~
 prefix operator +
 prefix operator -
 
 // infix operator = : AssignmentPrecedence
 infix operator *=  : AssignmentPrecedence
 infix operator /=  : AssignmentPrecedence
 infix operator %=  : AssignmentPrecedence
 infix operator +=  : AssignmentPrecedence
 infix operator -=  : AssignmentPrecedence
 infix operator <<= : AssignmentPrecedence
 infix operator >>= : AssignmentPrecedence
 infix operator &=  : AssignmentPrecedence
 infix operator ^=  : AssignmentPrecedence
 infix operator |=  : AssignmentPrecedence
 
 // infix operator ?: : TernaryPrecedence
 
 infix operator ||  : LogicalDisjunctionPrecedence
 
 infix operator &&  : LogicalConjunctionPrecedence
 
 infix operator <   : ComparisonPrecedence
 infix operator <=  : ComparisonPrecedence
 infix operator >   : ComparisonPrecedence
 infix operator >=  : ComparisonPrecedence
 infix operator ==  : ComparisonPrecedence
 infix operator !=  : ComparisonPrecedence
 infix operator === : ComparisonPrecedence
 infix operator !== : ComparisonPrecedence
 infix operator ~=  : ComparisonPrecedence
 
 infix operator ??  : NilCoalescingPrecedence
 
 // infix operator as : CastingPrecedence
 // infix operator as? : CastingPrecedence
 // infix operator as! : CastingPrecedence
 // infix operator is : CastingPrecedence
 
 infix operator ..< : RangeFormationPrecedence
 infix operator ... : RangeFormationPrecedence
 
 infix operator +   : AdditionPrecedence
 infix operator -   : AdditionPrecedence
 infix operator &+  : AdditionPrecedence
 infix operator &-  : AdditionPrecedence
 infix operator |   : AdditionPrecedence
 infix operator ^   : AdditionPrecedence
 
 infix operator *   : MultiplicationPrecedence
 infix operator /   : MultiplicationPrecedence
 infix operator %   : MultiplicationPrecedence
 infix operator &*  : MultiplicationPrecedence
 infix operator &   : MultiplicationPrecedence
 
 infix operator <<  : BitwiseShiftPrecedence
 infix operator >>  : BitwiseShiftPrecedence
 */

// 例如
precedencegroup NAME {
    /// 不知道试干什么用的 等待查询
    assignment: false // false
    
    /// 计算顺序 从做到右还是从右到左
    associativity: left // right
    
    // 优先级 
    higherThan: AdditionPrecedence
//    lowerThan: RangeFormationPrecedence
}

infix operator -->: NAME

//func -->(lhs: Int, rhs: Int) -> Int {
//    return rhs + 1000 * rhs
//    
//}
func -->(lhs: inout Int, rhs: Int) -> Int {
    lhs = lhs + 1000 * rhs
    return lhs
}

extension Int {
    var someInt: Int {
        get {
            return 999
        }
    }
    
    static var someInt2: Int {
    return 999
    }
}








