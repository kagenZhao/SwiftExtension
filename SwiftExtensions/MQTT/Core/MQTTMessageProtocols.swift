//
//  MQTTMessageProceser.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/9/9.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import HandyJSON

public protocol MQTTMessageProceser {
    func processMessage(_ message: MQTTResponse<[String: Any]>)
}

public protocol MQTTMessagePublisher {
    var host: String { get }
    var port: UInt16 { get }
    var clientID: String { get }
    var username: String? { get}
    var password: String? { get}
    var cleanSession: Bool { get}
    var keepAlive: UInt16 { get }
    var state: MQTTClientConnectState { get }
    var publishTopic: MQTTTopic? { get }
    
    func reStart()
    func connect()
    func disconnect()
    
    func publish<M: HandyJSON>(_ message: M)
    func register<Proceser: MQTTMessageProceser>(for module: MQTTMessageModule, type: MQTTMessageType, proceser: Proceser)
}
