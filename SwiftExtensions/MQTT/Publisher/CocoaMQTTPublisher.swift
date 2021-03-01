//
//  MQTTPublisher.swift
//  wmIOS
//
//  Created by 赵国庆 on 2019/9/5.
//  Copyright © 2019 kagen. All rights reserved.
//

import UIKit
import CocoaMQTT
import HandyJSON

internal class CocoaMQTTPublisher {
    private let debugLog = false
    private let client: CocoaMQTT
    private var subscribeService: MQTTSubscribeService?
    private lazy var procesers: [String: MQTTMessageProceser] = [:]
    private var _isRestart: Bool = false
    
    internal init() {
        client = CocoaMQTT(clientID: "")
        client.delegate = self
        client.enableSSL = false
        client.autoReconnect = true
    }
}

extension CocoaMQTTPublisher {
    private func requestTopic() {
        _isRestart = true
        /// 自定义
        self.subscribeService = MQTTSubscribeService()
        self._isRestart = false
        self.connect()
    }
}

extension CocoaMQTTPublisher: MQTTMessagePublisher {
    
    internal var host: String { return client.host }
    
    internal var port: UInt16 { return client.port }
    
    internal var clientID: String { return client.clientID }
    
    internal var username: String? { return client.username }
     
    internal var password: String? { return client.password }
    
    internal var cleanSession: Bool { return client.cleanSession }
    
    internal var keepAlive: UInt16 { return client.keepAlive }
    
    internal var publishTopic: MQTTTopic? { return subscribeService?.publication }
    
    internal var state: MQTTClientConnectState {
        switch client.connState {
        case .initial: return .initial
        case .connected: return .connected
        case .connecting: return .connecting
        case .disconnected: return .disconnected
        }
    }
    
    internal func register<Proceser: MQTTMessageProceser>(for module: MQTTMessageModule, type: MQTTMessageType, proceser: Proceser) {
        procesers[module.rawValue + type.rawValue] = proceser
    }

    internal func reStart() {
        disconnect()
        guard !_isRestart else { return }
        requestTopic()
    }
    
    internal func connect() {
        guard !_isRestart else { return }
        guard let service = subscribeService else { return }
        guard service.isValid() else { return }
        guard service.mqttEnabled else {
            if debugLog { print("MQTT-\(client.clientID), 后台目前不允许连接MQTT") }
            return
        }
        
        switch client.connState {
        case .connected, .connecting:
            disconnect()
        case .initial, .disconnected:
            break
        }
        client.username = service.userName
        client.password = service.password
        client.clientID = service.emqClientId
        client.cleanSession = service.cleanSession
        client.host = service.emqHost
        client.port = service.emqPort
        client.enableSSL = service.tlsEnabled
        client.allowUntrustCACertificate = false
        _ = client.connect()
    }
    
    internal func disconnect() {
        client.disconnect()
    }
    
    internal func publish<M: HandyJSON>(_ message: M) {
        guard let jsonStr = message.toJSONString() else {
            if debugLog { print("MQTTPublisher 无法将Model转换成JSONString: \(M.self)") }
            return
        }
        
        guard let publishTopic = self.subscribeService?.publication else {
            if debugLog { print("MQTTPublisher 没有指定 发送主题: publishTopic") }
            return
        }
        
        let topic: String = publishTopic.topic
        guard let qos: CocoaMQTTQOS = CocoaMQTTQOS.init(rawValue: UInt8(publishTopic.qos.rawValue)) else {
            if debugLog { print("未定义的QOS: \(publishTopic.qos.rawValue)") }
            return
        }
        client.publish(topic, withString: jsonStr, qos: qos, retained: false, dup: false)
    }
}

extension CocoaMQTTPublisher: CocoaMQTTDelegate {
    internal func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if debugLog { print("MQTT-\(mqtt.clientID), 接收到Socket-Ack:\(ack.description)") }
        if ack == .accept, let service = subscribeService, mqtt.clientID == service.emqClientId {
            /**
             逐条订阅, 防止订阅错误时断开连接
             */
            service.subscriptions.forEach { (topic) in
                client.subscribe(topic.topic, qos: topic.qos.toQos())
            }
            if debugLog { print("MQTT-\(mqtt.clientID), 开始订阅:\(service.subscriptions.map({ ($0.topic, $0.qos) }))") }
        }
    }
    
    internal func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        if debugLog { print("MQTT-\(mqtt.clientID), 发布信息:\(message.string ?? "空信息")") }
    }
    
    internal func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        if debugLog { print("MQTT-\(mqtt.clientID), 发送Socket-Ack(id: \(id))") }
    }
    
    internal func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if debugLog { print("MQTT-\(mqtt.clientID), 收到信息(id: \(id)):\(message.string ?? "空信息")") }
        guard let jsonData = message.string?.data(using: .utf8) else {
            if debugLog { print("MQTT-\(mqtt.clientID), 无法将信息(id:\(id))转换成Data: \(message.string ?? "")") }
            return
        }
        guard let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])) as? [String: Any] else {
            if debugLog { print("MQTT-\(mqtt.clientID), 信息(id: \(id))不是JSON字符串: \(message.string ?? "")") }
            return
        }
        guard let response = MQTTResponse<[String: Any]>.deserialize(from: jsonObject) else {
            if debugLog { print("MQTT-\(mqtt.clientID), 信息(id: \(id))不是规定的信息格式: \(message.string ?? "")") }
            return
        }
        
        let proceser = procesers[response.head.module.rawValue + response.head.type.rawValue]
        proceser?.processMessage(response)
    }
    
    internal func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        if debugLog { print("MQTT-\(mqtt.clientID), 订阅成功:\(topics)") }
    }
    
    internal func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        if debugLog { print("MQTT-\(mqtt.clientID), 取消订阅:\(topic)") }
    }
    
    internal func mqttDidPing(_ mqtt: CocoaMQTT) {
        if debugLog { print("MQTT-\(mqtt.clientID), 发送心跳...") }
    }
    
    internal func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        if debugLog { print("MQTT-\(mqtt.clientID), 收到心跳...") }
    }
    
    internal func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if debugLog { print("MQTT-\(mqtt.clientID), 断开连接 错误:\(err?.localizedDescription ?? "未知错误")") }
    }
    
    /**
    单项验证, 只验证后台证书是否正确
    测试的时候用, 正式环境用不到
    */
//    @objc internal func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
//
//        guard let certFileUrl = Bundle.main.url(forResource: "mqtt_server", withExtension: "der") else {
//            if debugLog { printLog("MQTT-\(mqtt.clientID), 没有找到证书文件: mqtt_server.der") }
//            completionHandler(false)
//            return
//        }
//        guard let certData = try? Data.init(contentsOf: certFileUrl) else {
//            if debugLog { printLog("MQTT-\(mqtt.clientID), 无法将证书转换成Data: mqtt_server.der") }
//            completionHandler(false)
//            return
//        }
//        guard let cert = SecCertificateCreateWithData(nil, certData as CFData) else {
//            if debugLog { printLog("MQTT-\(mqtt.clientID), 无法将证书Data转换成SecCertificate") }
//            completionHandler(false)
//            return
//        }
//        SecTrustSetAnchorCertificates(trust, [cert] as CFArray)
//        var result = SecTrustResultType.deny
//        let status = SecTrustEvaluate(trust, &result)
//        guard status == errSecSuccess, (result == .proceed || result == .unspecified) else {
//            if debugLog { printLog("MQTT-\(mqtt.clientID), SSL连接发生异常: \(SecTrustCopyProperties(trust) as Array?)") }
//            completionHandler(false)
//            return
//        }
//        completionHandler(true)
//        if debugLog { printLog("MQTT-\(mqtt.clientID), SSL连接成功") }
//    }
    
    @objc internal func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16) {
        if debugLog { print("MQTT-\(mqtt.clientID), 发送信息成功(id:\(id))") }
    }
    
    @objc internal func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        if debugLog { print("MQTT-\(mqtt.clientID), 连接状态改变了:\(state.description)") }
    }
}

extension MQTTQosLevel {
    fileprivate func toQos() -> CocoaMQTTQOS {
        switch self {
        case .mostOnce: return .qos0
        case .leastOnce: return .qos1
        case .exactlyOnce: return .qos2
        }
    }
}
