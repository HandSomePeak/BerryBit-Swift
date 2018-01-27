//
//  SendCode.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/23.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

class SendCode: NSObject {
    // MARK:
    // MARK: ======== 指令发送方法
    // MARK:
    
    // MARK: 发送获取电池电量指令的指令
    func SendBatteryCode() {
        print("发送获取电池电量指令的指令")
        let ble = BlueTooth.shareInstance
        ble.Peripheral.readValue(for: ble.char_battery)
    }
    
    // MARK: 发送获取手环信息（硬件版本号、软件版本号）的指令
    func SendMatchMessageCode() {
        print("发送获取手环信息（硬件版本号、软件版本号）的指令")
        var ack : [UInt8] = [UInt8].init(repeating: 0x00, count: 5)
        ack[0] = 0xAA; ack[1] = 0x55; ack[2] = 0x05; ack[3] = 0x55;
        ack[4] = ack[2] &+ ack[3]
        self.SendCode(ack: ack)
    }
    
    // MARK: 发送同步时间的指令
    func SendSynchronizationTimeCode() {
        print("发送同步时间的指令")
        var ack : [UInt8] = [UInt8].init(repeating: 0x00, count: 10)
        ack[0] = 0xAA; ack[1] = 0x55; ack[2] = 0x0A; ack[3] = 0x05; ack[4] = 0x05;
        let time : Double = Date().timeIntervalSince1970
        let newTime = Int(time) + TimeZone.current.secondsFromGMT(for: Date())
        for i in 0...3 {
            ack[5 + i] = UInt8((newTime >> (8 * i)) & 0xff)
        }
        for i in 2...8 {
            ack[9] = ack[9] &+ ack[i]
        }

        self.SendCode(ack: ack)
    }
    
    // MARK: 发送获取数据数量的指令
    func SendMessageNumberCode() {
        print("发送获取数据数量的指令")
        var ack : [UInt8] = [UInt8].init(repeating: 0x00, count: 5)
        ack[0] = 0xAA; ack[1] = 0x55; ack[2] = 0x05; ack[3] = 0x56;
        ack[4] = ack[2] &+ ack[3]
        self.SendCode(ack: ack)
    }
    
    // MARK: 发送开始数据同步的指令
    func SendSynchronizationDataCode() {
        print("发送开始数据同步的指令")
        var ack : [UInt8] = [UInt8].init(repeating: 0x00, count: 5)
        ack[0] = 0xAA; ack[1] = 0x55; ack[2] = 0x05; ack[3] = 0x57;
        ack[4] = ack[2] &+ ack[3]
        self.SendCode(ack: ack)
    }
    
    
    
    // MARK:
    // MARK: ======== 解析指令方法
    // MARK:
    
    
    // MARK: 解析 ---- 手环信息(硬件版本号、软件版本号)
    func ParseingMatchMessage(value: [UInt8]) -> (heard: String, software: String) {
        var version : (heard: String, software: String) = ("-","-")
        if value.count > 13 {
            // 硬件版本号
            var heard_version = String()
            for i in 5...8 {
                let str : String = String.init(format: "%.2x", UInt8(value[i]) & 0xff)
                heard_version = str + heard_version
            }
            version.heard = String(self.hexStr(hex: heard_version))
            
            // 软件版本号
            var soft_version = String()
            for i in 9...12 {
                let str : String = String.init(format: "%.2x", UInt8(value[i]) & 0xff)
                soft_version = str + soft_version
            }
            version.software = String(self.hexStr(hex: soft_version))
        }
        return version
    }
    
    // MARK: 解析 ---- 数据数量
    func ParseingMessageCount(value: [UInt8]) -> Int {
        if value.count > 9 {
            var string = String()
            for i in 5...8 {
                let str = String.init(format: "%.2x", UInt8(value[i]) & 0xff)
                string = str + string
            }
            if string.count > 0 {
                let a = self.hexStr(hex: string)
                return a
            }
        }
        return 0
    }
    
    // MARK: 解析 ---- 数据
    func ParseingData(value: [UInt8]) -> Int {
        if value.count > 7 {
            switch Int(value[5]) {
            case 0:
                return self.ParseingStepData(value: value)
            case 1:
                return self.ParseingSleepData(value: value)
            case 3:
                return self.ParseingLightData(value: value)
            default:
                break
            }
        }
        return 0
    }
    
    // MARK: 解析 ---- 睡眠数据
    func ParseingSleepData(value: [UInt8]) -> Int {
        let type = Int(value[5])
        let n = Int(value[3])
        
        var count = 0
        var i = 0
        let step = 8
        for _ in 0..<((n - 1) / step) {
            // 时间戳
            var time = String()
            for j in 0...3 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 6]) & 0xff)
                time = time + str
            }
            let Time = String(self.hexStr(hex: time))
            
            // 数据 1
            var data_1 = String()
            for j in 0...1 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 10]) & 0xff)
                data_1 = data_1 + str
            }
            let Data_1 = String(self.hexStr(hex: data_1))
            
            // 保存数据
            if Int(Data_1)! < 10 {
                self.SaveDataToDB(time: Time, data: Data_1, type: String(type))
            }
            
            count += 1
            i += step
        }
        return count
    }
    
    // MARK: 解析 ---- 计步数据
    func ParseingStepData(value: [UInt8]) -> Int {
        let type = Int(value[5])
        let n = Int(value[3])
        
        var count = 0
        var i = 0
        let step = 8
        for _ in 0..<((n - 1) / step) {
            // 时间戳
            var time = String()
            for j in 0...3 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 6]) & 0xff)
                time = time + str
            }
            let Time = String(self.hexStr(hex: time))
            
            // 数据 1
            var data_1 = String()
            for j in 0...1 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 10]) & 0xff)
                data_1 = data_1 + str
            }
            let Data_1 = String(self.hexStr(hex: data_1))
            
            // 保存数据
            if Int(Data_1)! < 50000 {
                self.SaveDataToDB(time: Time, data: Data_1, type: String(type))
            }
            
            count += 1
            i += step
        }
        return count
    }
    
    // MARK: 解析 ---- 光感数据
    func ParseingLightData(value: [UInt8]) -> Int {
        let type = Int(value[5])
        let n = Int(value[3])
        
        var count = 0
        var i = 0
        let step = 8
        for _ in 0..<((n - 1) / step) {
            // 时间戳
            var time = String()
            for j in 0...3 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 6]) & 0xff)
                time = time + str
            }
            let Time = String(self.hexStr(hex: time))
            
            // 数据 1
            var data_1 = String()
            for j in 0...1 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 10]) & 0xff)
                data_1 = data_1 + str
            }
            let Data_1 = String(self.hexStr(hex: data_1))
            
            // 数据 2
            var data_2 = String()
            for j in 0...1 {
                let str : String = String.init(format: "%.2x", UInt8(value[i + j + 12]) & 0xff)
                data_2 = data_2 + str
            }
            let Data_2 = String(self.hexStr(hex: data_2))
            
            // 保存数据
            if Int(Data_1)! < 20000 && Int(Data_2)! < 20000 {
                self.SaveDataToDB(time: Time, data: Data_1 + "-" + Data_2, type: String(type))
            }
            
            count += 1
            i += step
        }
        return count
    }

    // MARK: 保存数据到数据库
    func SaveDataToDB(time: String, data: String, type: String) {
        print("保存数据到数据库 = \(time), \(data), \(type)")
    }
    
    // MARK: 十六进制字符串转十进制整数
    func hexStr(hex: String) -> Int {
        let str = hex.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    // MARK: 发送指令
    func SendCode(ack: [UInt8]) {
        let data : Data = Data.init(bytes: ack)
        BlueTooth.shareInstance.sendCode(data: data, characteristic: BlueTooth.shareInstance.char_battery)
    }
}
