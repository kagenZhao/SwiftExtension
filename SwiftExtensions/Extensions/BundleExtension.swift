//
//  BundleExtension.swift
//  SwiftExtensions
//
//  Created by 赵国庆 on 2018/8/31.
//  Copyright © 2018年 kagenZhao. All rights reserved.
//

import UIKit
internal class SwiftExtensionBundleClass{}

extension Bundle {
    internal class func currentBundle() -> Bundle {
        return Bundle.init(for: SwiftExtensionBundleClass.self)
    }
}

extension UIImage {
    internal class func currentBundleImage(with named: String) -> UIImage? {
        return UIImage.init(named: named, in: .currentBundle(), compatibleWith: UITraitCollection())
    }
}
