//
//  MQTTResponse.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/9/4.
//  Copyright © 2019 kagen. All rights reserved.
//


import UIKit
import HandyJSON

public enum MQTTClientConnectState {
    case initial
    case connecting
    case connected
    case disconnected
}


public enum MQTTMessageModule: Equatable {
    case application
    case system
    case others(String)
    
    public init(rawValue: String) {
        switch rawValue {
        case "application":
            self = .application
        case "system":
            self = .system
        default:
            self = .others(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .application: return "application"
        case .system: return "system"
        case .others(let s): return s
        }
    }
    
    public static func ==(lhs: MQTTMessageModule, rhs: MQTTMessageModule) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension MQTTMessageModule: _ExtendCustomBasicType {
    
    public static func _transform(from object: Any) -> MQTTMessageModule? {
        if let str = object as? String {
            return MQTTMessageModule.init(rawValue: str)
        } else {
            return nil
        }
    }
    public func _plainValue() -> Any? {
        return self.rawValue
    }
}

public enum MQTTMessageType: Equatable {
    case echo
    case others(String)
    
    public init(rawValue: String) {
        switch rawValue {
        case "mqtt_echo":
            self = .echo
        default:
            self = .others(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .echo: return "mqtt_echo"
        case .others(let s): return s
        }
    }
    
    public static func ==(lhs: MQTTMessageType, rhs: MQTTMessageType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}


public enum MQTTQosLevel: Int, CustomStringConvertible {
    case mostOnce = 0
    case leastOnce = 1
    case exactlyOnce = 2
    
    public var description: String {
        switch self {
            case .mostOnce: return "mostOnce(qos0)"
            case .leastOnce: return "leastOnce(qos1)"
            case .exactlyOnce: return "exactlyOnce(qos2)"
        }
    }
}

extension MQTTQosLevel: _ExtendCustomBasicType {
    public static func _transform(from object: Any) -> MQTTQosLevel? {
        if let str = object as? String, let intValue = Int(str) {
            return MQTTQosLevel.init(rawValue: intValue)
        } else if let num = object as? NSNumber {
            return MQTTQosLevel.init(rawValue: num.intValue)
        } else {
            return nil
        }
    }
    
    public func _plainValue() -> Any? {
        return self.rawValue
    }
}

extension MQTTMessageType: _ExtendCustomBasicType {
    public static func _transform(from object: Any) -> MQTTMessageType? {
        if let str = object as? String {
            return MQTTMessageType.init(rawValue: str)
        } else {
            return nil
        }
    }
    public func _plainValue() -> Any? {
        return self.rawValue
    }
}

public struct MQTTResponseHead: HandyJSON {
    public var msgId = UUID().uuidString // 消息唯一标识，UUID version 4
    public var emqClientId = UUID().uuidString // 未登录用户随机生成不重复ID，登录后重新改用用户注册账号订阅
    public var sendTime: TimeInterval = 0 // 消息发送时的UNIX毫秒时间戳
    public var qos: MQTTQosLevel = .mostOnce // 消息发送时填写的服务等级
    public var ttl: Int = 0 // 消息有效期，以毫秒为单位，无需求填0即可
    public var module: MQTTMessageModule = .others("") // 推送消息分类，目前仅有两类"application"业务推送、"system"系统推送
    public var type: MQTTMessageType = .others("") // 指定分类下消息类别
    public init() {}
}

public struct MQTTResponse<T> {
    public var head: MQTTResponseHead
    public var body: T
    public init(_ head: MQTTResponseHead, body: T) {
        self.head = head
        self.body = body
    }
}


extension MQTTResponse: HandyJSON, _ExtendCustomModelType, _Transformable, _Measurable where T: HandyJSON {
    public init() {
        self.init(MQTTResponseHead(), body: T())
    }
}

extension MQTTResponse where T == [String: Any] {
    public func transformBody<BodyType: HandyJSON>() -> MQTTResponse<BodyType>? {
        guard let body = BodyType.deserialize(from: self.body) else { return nil }
        return MQTTResponse<BodyType>.init(head, body: body)
    }
    
    internal static func deserialize(from dict: [String: Any]) -> Self? {
        guard let head = MQTTResponseHead.deserialize(from: dict["head"] as? [String: Any]),
            let body = dict["body"] as? [String: Any] else { return nil }
        return MQTTResponse<[String: Any]>.init(head, body: body)
    }
}


public struct MQTTTopic: HandyJSON {
    public var topic: String = ""
    public var qos: MQTTQosLevel = .mostOnce // 消息发送时填写的服务等级
    public init() {}
}

public struct MQTTSubscribeService: HandyJSON {
    public var emqClientId: String = ""
    public var cleanSession: Bool = true
    public var subscriptions: [MQTTTopic] = []
    public var publication = MQTTTopic()
    public var mqttEnabled: Bool = false
    public var tlsEnabled: Bool = false
    public var emqHost: String = ""
    public var emqPort: UInt16 = 0
    public var userName: String = ""
    public var password: String = ""
    
    public func isValid() -> Bool {
        return (!emqClientId.isEmpty) && (!emqHost.isEmpty) && (emqPort > 0) && (!userName.isEmpty) && (!password.isEmpty)
    }
    
    public init() {}
}
