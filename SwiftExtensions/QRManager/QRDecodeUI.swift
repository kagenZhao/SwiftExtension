//
//  QRDecodeUI.swift
//  QRManager
//
//  Created by Kagen Zhao on 2016/11/9.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import AVFoundation

private var _sessionKey: Void?
private var _previewLayerKey: Void?
private var _outputDelegateKey: Void?
private var _decodeNotifierKey: Void?
private var _sessionIsStartKey: Void?
private var _sessionAutoStopKey: Void?


private class _OutputDelegate: NSObject {
    
    fileprivate var value: ((String) -> Void)?
    
    fileprivate init(_ obj: ((String) -> Void)?) {
        
        super.init()
        
        self.value = obj
    }
}

extension QRManager where Type: QRDecodeUIProtocol {
   
    private var _session: AVCaptureSession? {
        set {
            objc_setAssociatedObject(base, &_sessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
             return objc_getAssociatedObject(base, &_sessionKey) as? AVCaptureSession
        }
    }
    
    private var _previewLayer: AVCaptureVideoPreviewLayer? {
        set {
            objc_setAssociatedObject(base, &_previewLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &_previewLayerKey) as? AVCaptureVideoPreviewLayer
        }
    }
    
    private var _outputDelegate: _OutputDelegate? {
        set {
            objc_setAssociatedObject(base, &_outputDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &_outputDelegateKey) as? _OutputDelegate
        }
    }
    
    private var _sessionAutoStop: Bool {
        set {
            objc_setAssociatedObject(base, &_sessionAutoStopKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let value = objc_getAssociatedObject(base, &_sessionAutoStopKey) as? Bool {
                return value
            }
            return false
        }
    }
    
    private func setupInput() -> AVCaptureDeviceInput {
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let input: AVCaptureDeviceInput!
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        }
        catch {
            fatalError("can't create input")
        }
        
        return input
    }
    
    private func setupOutput() -> AVCaptureMetadataOutput {
        
        let output = AVCaptureMetadataOutput()
        
        return output
    }
    
    private func checkAVAuthorizationStatus() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        return status == .authorized
    }
    
    
    private func setupSession() {
        
        let input = setupInput()
        
        let output = setupOutput()
        
        let session = AVCaptureSession()
        
        guard session.canAddInput(input) else {
            
            fatalError("can't add input")
        }
        
        guard session.canAddOutput(output) else {
            
            fatalError("can't add output")
        }
        
        session.addInput(input)
        
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        _session = session
    }
    
    private func setupLayer(in superLayer: CALayer) {
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: _session) else {
            
            fatalError("can't create previewLayer")
        }
        
        previewLayer.frame = superLayer.bounds
        
        _previewLayer = previewLayer
        
        superLayer.insertSublayer(_previewLayer!, at: 0)
    }
    
    @discardableResult
    public func setupQRUIInSelf() -> Self? {
        
        return setupQRUI(in: base.decodeUISuperLayer)
    }
    
    @discardableResult
    public func setupQRUI(in superLayer: CALayer) -> Self? {
        
        if !checkAVAuthorizationStatus() {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {_ in}
        }
        
        setupSession()
        
        setupLayer(in: superLayer)
        
        return self
    }
    
    /// Default is superLayer.bouns
    @discardableResult
    public func setPreview(layerFrame: CGRect) -> Self {
        
        assert(_session != nil, "not call function setupQRUI")
        
        _previewLayer?.frame = layerFrame
        
        return self
    }
    
    
    /// Default is (0,0,1,1)
    @discardableResult
    public func setOutput(interest: CGRect) -> Self {
        
        assert(_session != nil, "not call function setupQRUI")
        
        _session!.outputs.forEach { (output) in
            
            guard let output = output as? AVCaptureMetadataOutput else { return }
            
            output.rectOfInterest = interest
        }
        
        return self
    }
    
    @discardableResult
    
    public func startRunning(decodeNotifier: @escaping (String) -> Void) -> Self {
        
        assert(_session != nil, "not call function setupQRUI")
        
        stopRunning()
        
        self._outputDelegate = _OutputDelegate({[weak base] (str) in
            
            decodeNotifier(str)
            
            guard let base_strong = base else { return }
            
            let manager = QRManager.init(base_strong)
           
            if manager._sessionAutoStop {
                
                manager.stopRunning()
            }
        })
        
        _session!.outputs.forEach {[weak base] (output) in
            
            guard let base_strong = base else { return }
            
            let manager = QRManager.init(base_strong)
            
            guard let output = output as? AVCaptureMetadataOutput else { return }
            
            output.setMetadataObjectsDelegate(manager._outputDelegate, queue: .main)
        }
        
        _session?.startRunning()
        
        return self
    }
    
    @discardableResult
    public func stopRunning() -> Self {
        
        assert(_session != nil, "not call function setupQRUI")
        
        guard _session?.isRunning == true else { return self }
        
        _session?.stopRunning()
        
        return self
    }
    
    /// Default is false
    /// Session will be stop, previewlayer will not be destroy while get first qr code
    /// The results will not be "nil"
    @discardableResult
    public func set(stopWhenGetFirstQrcode: Bool) -> Self {
        
        assert(_session != nil, "not call function setupQRUI")
        
        _sessionAutoStop = stopWhenGetFirstQrcode
        
        return self
    }
    
    /// PreviewLayer will be destroy 
    /// All attribute will be reset
    public func destroyQRUI() {
        stopRunning()
        _previewLayer?.removeFromSuperlayer()
        _session = nil
        _previewLayer = nil
        _outputDelegate = nil
        _sessionAutoStop = false
    }
}

extension _OutputDelegate: AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        guard let obj = metadataObjects.last as? AVMetadataMachineReadableCodeObject else { return }
        
        guard !obj.stringValue.isEmpty else { return }
        
        value?(obj.stringValue)
    }
}



