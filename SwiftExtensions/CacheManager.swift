//
//  CacheManager.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/17.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

import Foundation

public protocol CacheSourceProtocol {
    
    /// KB
    func cacheSize() throws -> UInt
    
    func clearCache()
}

private var _otherSources: [CacheSourceProtocol] = []

public struct CacheManager {
    
    @discardableResult
    public static func add<T: CacheSourceProtocol>(_ otherSource: T) -> CacheManager.Type where T: Equatable  {
        
        _otherSources.append(otherSource)
        
        return self
    }
    
    @discardableResult
    public static func remove<T: CacheSourceProtocol>(_ otherSource: T) -> CacheManager.Type where T: Equatable {
        
        _otherSources = _otherSources.filter { $0 is T && ($0 as! T) == otherSource }
        
        return self
    }
    
    
    public static func clearCache() {
        
        _otherSources.forEach { (source) in
            
            DispatchQueue.global().async {
                
                source.clearCache()
            }
        }
        
        DispatchQueue.global().async {
            
            do { try FileManager.default.removeItem(atPath: NSTemporaryDirectory()) }
            catch {}
        }
    }
    
    /// KB
    public static func cacheSize() throws -> UInt {
        
        let sizeOfDir = try size(for: NSTemporaryDirectory())
        
        let sizeOfOther = try otherSourceSize()
        
        return sizeOfDir + sizeOfOther
    }
    
    public static func cacheSizeString() throws -> String {
        
        let size = try cacheSize()
        
        var cacheSizeStr = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        
        if size == 0 { cacheSizeStr = "0KB" }
        
        return cacheSizeStr
    }
    
    public static func size(for folder: String) throws -> UInt {
        
        let contents = try FileManager.default.contentsOfDirectory(atPath: folder)
        
        var folderSize: UInt = 0
        
        try contents.forEach { file in
            
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: "\(folder)/\(file)")
            
            folderSize += fileAttributes[FileAttributeKey.size] as! UInt
        }
        
        return folderSize
    }
    
    private static func otherSourceSize() throws -> UInt {
        
        var folderSize: UInt = 0
        
        try _otherSources.forEach({ (source) in
            
            folderSize += try source.cacheSize()
        })
        
        return folderSize
    }
}

