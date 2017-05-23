//
//  QRManager.swift
//  QRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

public final class QRManager<Type> {
    
    let base: Type
    
    init(_ base: Type) {
        
        self.base = base
    }
}

public protocol QRManagerCompatible {
    
    associatedtype CompatibleType
    
    var qr: CompatibleType { get }
}

public extension QRManagerCompatible {
    
    public var qr: QRManager<Self> {
        
        get { return QRManager(self) }
    }
    
}

/// you can set another Class to conform this protocol
public protocol QRDecodeUIProtocol: QRManagerCompatible, NSObjectProtocol {
    
    var decodeUISuperLayer: CALayer { get }
}

/// you can set another Class to conform this protocol
public protocol QRDecodeProtocol: QRManagerCompatible {
    
    var decodeImage: UIImage { get }
}

/// you can set another Class to conform this protocol
public protocol QREncodeProtocol: QRManagerCompatible {
    
    var encodeMessage:String { get }
}


extension UIImage: QRDecodeProtocol {
    
    public var decodeImage: UIImage { return self }
}

extension String: QREncodeProtocol {
    
    public var encodeMessage: String { return self }
}

extension NSString: QREncodeProtocol {
    
    public var encodeMessage: String { return self as String }
}

extension URL: QREncodeProtocol {
    
    public var encodeMessage: String { return self.absoluteString }
}

extension NSURL: QREncodeProtocol {
    
    public var encodeMessage: String { return self.absoluteString ?? "" }
}

extension CALayer: QRDecodeUIProtocol {
    
    public var decodeUISuperLayer: CALayer { return self }
}

extension UIView: QRDecodeUIProtocol {
    
    public var decodeUISuperLayer: CALayer { return self.layer }
}

extension UIViewController: QRDecodeUIProtocol {
    
    public var decodeUISuperLayer: CALayer { return self.view.layer }
}


