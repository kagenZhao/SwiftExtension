//
//  QRDecode.swift
//  QRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

public extension QRManager where Type: QRDecodeProtocol {
    
    public func decodeQR() -> String? {
        
        guard let data = base.decodeImage.pngData() else { return nil }
        
        guard let ciImage = CIImage(data: data) else { return nil }
        
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]) else { return nil }
        
        let feature = detector.features(in: ciImage)
        
        guard let result = feature.first as? CIQRCodeFeature else { return nil }
        
        return result.messageString
    }
}
