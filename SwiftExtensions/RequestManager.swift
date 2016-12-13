
//
//  AlamfireExtensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/12/12.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

///


import UIKit
import Alamofire

public enum ObjectConvertError: Error {
    case objectNil
    case jsonSerializationFailed(Error)
}

public protocol ObjectConvertible {
    associatedtype ObjectClass
    static func instance(data: Any) throws -> ObjectClass
    static func instance(datas: Any) throws -> [ObjectClass]

}

extension DataRequest {

    @discardableResult
    public func responseObject<T: ObjectConvertible>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<[T]>) -> Void)
        -> Self
    {
        return responseJSON(queue: queue, completionHandler: { (response) in

        })
    }
}


