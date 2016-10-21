//
//  UIImage+Extensions.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/10/19.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import UIKit


extension UIImage {
    // "CIPhotoEffectMono"
    func getImage(with effectName: String) -> UIImage {
        let ciimage = CIImage(image: self)
        let filter = CIFilter(name: effectName, withInputParameters: [kCIInputImageKey:ciimage!])
        filter?.setDefaults()
        let contect = CIContext(options: nil)
        let outputImage = filter?.outputImage
        let cgimage = contect.createCGImage(outputImage!, from: outputImage!.extent)
        let image = UIImage(cgImage: cgimage!)
        return image
    }
    
    class func getSnapImage() -> UIImage {
        let rect = UIApplication.shared.keyWindow!.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        UIApplication.shared.keyWindow!.drawHierarchy(in: UIApplication.shared.keyWindow!.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        // return image.getBlurImage()
    }
}


