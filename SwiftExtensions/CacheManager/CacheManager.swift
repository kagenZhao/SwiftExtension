//
//  CacheManager.swift
//  SwiftExtensions
//
//  Created by Kagen Zhao on 2016/11/17.
//  Copyright © 2016年 kagenZhao. All rights reserved.
//

// 这个类具用于计算项目文件缓存， 这是一个根类， 只提供了基本的计算和删除， 若要使用 需要自行实现代理。

import Foundation

//        case applicationDirectory 1  /Applications !/Applications !/Network/Applications
//        case demoApplicationDirectory 2 /Applications/Demos  !/Applications/Demos !/Network/Applications/Demos
//        case developerApplicationDirectory 3 /Developer/Applications !/Developer/Applications  !/Network/Developer/Applications
//        case adminApplicationDirectory 4 /Applications/Utilities !/Applications/Utilities !/Network/Applications/Utilities
//        case libraryDirectory 5 /Library !/Library !/Network/Library !/System/Library
//        case developerDirectory 6 /Developer  !/Developer  !/Network/Developer
//        case userDirectory 7  !/Users, !/Network/Users!
//        case documentationDirectory 8 /Library/Documentation !/Library/Documentation !/Network/Library/Documentation !/System/Library/Documentation
//        case documentDirectory 9 /Documents
//        case coreServiceDirectory 10 !/System/Library/CoreServices
//        case autosavedInformationDirectory 11 /Library/Autosave Information
//        case desktopDirectory 12 /Desktop
//        case cachesDirectory 13  /Library/Caches !/Library/Caches !/System/Library/Caches
//        case applicationSupportDirectory 14 /Library/Application Support !/Library/Application Support !/Network/Library/Application Support
//        case downloadsDirectory 15 /Downloads
//        case inputMethodsDirectory 16 /Library/Input Methods !/Library/Input Methods !/Network/Library/Input Methods !/System/Library/Input Methods
//        case moviesDirectory 17 /Movies
//        case musicDirectory 18 /Music
//        case picturesDirectory 19 /Pictures
//        case printerDescriptionDirectory 20 !/System/Library/Printers/PPDs
//        case sharedPublicDirectory 21 /Public
//        case preferencePanesDirectory 22 /Library/PreferencePanes !/Library/PreferencePanes !/System/Library/PreferencePanes
//        case itemReplacementDirectory 23
//        case allApplicationsDirectory 24
//        case allLibrariesDirectory 25
//        case trashDirectory 26

public struct Finder {
    
    public struct Component {
        public let string: String
        public init(_ string: String) {
            self.string = string.components(separatedBy: "/").last ?? ""
        }
    }
    
    fileprivate var paths: [Component] = []
    
    public var pathString: String {
        guard paths.count >= 0 else { return "/" }
        return paths.reduce("", { (result, comp) in
            return result + "/" + comp.string
        })
    }
    
    public init(component: String = "") {
        component.components(separatedBy: "/").forEach { (comp) in
            if comp.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                paths.append(Component(comp))
            }
        }
    }
    
    public mutating func append(_ comp: Component) {
        if comp.string.count > 0 {
            paths.append(comp)
        }
    }
    
    public mutating func append(_ comp: String) {
        if comp.count > 0 {
            append(Component.init(comp))
        }
    }
    
    public static var root: Finder {
        return .init()
    }
    
    public static var home: Finder {
        return .init(component: NSHomeDirectory())
    }
    
    public static var application: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Applications"))
    }
    
    public static var demoApplication: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.demoApplicationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Applications/Demos"))
    }
    
    public static var developerApplication: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.developerApplicationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Developer/Applications"))
    }
    
    public static var adminApplication: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.adminApplicationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Applications/Utilities"))
    }
    
    public static var library: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library"))
    }
    
    public static var developer: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.developerDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Developer"))
    }
    
    public static var documentation: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/Documentation"))
    }
    
    public static var document: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Documents"))
    }
    
    public static var autosavedInformation: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.autosavedInformationDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/Autosave"))
    }
    
    public static var caches: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/Caches"))
    }
    
    public static var applicationSupport: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/Application Support"))
    }
    
    public static var downloads: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Downloads"))
    }
    
    public static var inputMethods: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.inputMethodsDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/Input Methods"))
    }
    
    public static var movies: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.moviesDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Movies"))
    }
    
    public static var music: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.musicDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Music"))
    }
    
    public static var pictures: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Pictures"))
    }
    
    public static var sharedPublic: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.sharedPublicDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Public"))
    }
    
    public static var preferencePanes: Finder {
        return .init(component: NSSearchPathForDirectoriesInDomains(.preferencePanesDirectory, .userDomainMask, true).last ?? (NSHomeDirectory() + "/Library/PreferencePanes"))
    }
    
    public static var temporary: Finder {
        return .init(component: NSTemporaryDirectory())
    }
}

extension Finder: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return pathString
    }
    public var debugDescription: String {
        return pathString
    }
}

extension Finder.Component: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

public func / (lhs: Finder, rhs: Finder.Component) -> Finder {
    var result = lhs
    result.append(rhs)
    return result
}

public func / (lhs: Finder, rhs: String) -> Finder {
    var result = lhs
    result.append(rhs)
    return result
}

public struct CacheManager {
    
    
    /// 缓存所在目录, 默认为 Finder.temporary, Finder.caches
    public var cacheFolder: [Finder] = [
        Finder.temporary,
        Finder.caches
    ]
    
    public static let shared = CacheManager()
    
    public func clearCache(complete: @escaping ([Finder]) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.cacheFolder.forEach({ (finder) in
                do {
                    try FileManager.default.removeItem(atPath: finder.pathString);
                } catch {
                    debugPrint("chear \"\(finder)\" failed")
                } 
            })
            complete(self.cacheFolder)
        }
    }
    
    /// KB
    public func cacheSize() -> UInt64 {
        var result: UInt64 = 0
        self.cacheFolder.forEach({ (finder) in
            result += sizeFor(file: finder)
        })
        return result
    }
    
    public func cacheSizeString() -> String {
        
        let size = cacheSize()
        
        var cacheSizeStr = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        
        if size == 0 { cacheSizeStr = "0 KB" }
        
        return cacheSizeStr
    }
    
    public func sizeFor(folder: Finder) -> UInt64 {
        return sizeFor(folder: folder.pathString)
    }
    
    public func sizeFor(file: Finder) -> UInt64 {
        return sizeFor(file: file.pathString)
    }
    
    public func sizeFor(folder: String) -> UInt64 {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: folder, isDirectory: &isDirectory) else {
            return 0
        }
        if isDirectory.boolValue {
            let content = (try? manager.contentsOfDirectory(atPath: folder)) ?? []
            return content.reduce(UInt64(0)) { (result, subPath) in
                return result + sizeFor(file: folder.appending("/\(subPath)"))
            }
        } else {
            return sizeFor(file: folder)
        }
    }
    
    public func sizeFor(file: String) -> UInt64 {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: file, isDirectory: &isDirectory) else {
            return 0
        }
        if isDirectory.boolValue {
            return sizeFor(folder: file)
        } else {
            let attr = try? manager.attributesOfItem(atPath: file)
            return (attr?[.size] as? UInt64) ?? 0
        }
    }
    
}

