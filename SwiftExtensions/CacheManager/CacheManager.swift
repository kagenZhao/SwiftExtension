//
//  CacheManager.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/17.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

// 这个类具用于计算项目文件缓存， 这是一个根类， 只提供了基本的计算和删除， 若要使用 需要自行实现代理。

import Foundation

public protocol CacheSourceProtocol {
    
    /// KB
    func cacheSize() throws -> UInt
    
    func clearCache() throws
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
    
    
    public static func clearCache(complete: @escaping () -> ()) {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        _otherSources.forEach { (source) in
            group.enter()
            queue.async(group: group) {
                do {
                    try source.clearCache()
                    group.leave()
                }
                catch {
                    debugPrint("source: \(source) cannot clear cache")
                    group.leave()
                }
            }
        }
        group.enter()
        queue.async(group: group) {
            do {
                try FileManager.default.removeItem(atPath: NSTemporaryDirectory())
                group.leave()
            }
            catch {
                debugPrint("chear \"NSTemporaryDirectory\" failed")
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: {
            complete()
        })
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
