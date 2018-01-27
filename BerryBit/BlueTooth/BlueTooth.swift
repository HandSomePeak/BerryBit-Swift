//
//  BlueTooth.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/17.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BlueToothDelegate {
    
    // 系统蓝牙状态改变
    @objc optional func ManagerDidUpdateState(open: Bool)
    // 发现绑定的设备
    @objc optional func DiscoverBundingDevice(device: PeripheralModel)
    // 发现外设
    @objc optional func DiscoverPeripheral(device: PeripheralModel)
    // 电量改变
    @objc optional func DischangeBattery(value: Int)
    // 固件更新校验是否成功
    @objc optional func DidReceiveFirmwareUpdateState(state: Bool)
    // 手环信息（硬件版本号、软件版本号）
    @objc optional func DidReceiveMatchMessage(heardVersion: String, SoftWareVersion: String)
    // 数据数量
    @objc optional func DidReceiveMessageCount(value: Int)
    // 数据接收
    @objc optional func DidReceiveMessageData(value: Int)
    // 指令接收成功
    @objc optional func DidReceiveCodeSuccess(value: UInt8)
    // 指令接收失败
    @objc optional func DidReceiveCodeFail(value: UInt8)
    // 数据接收完毕
    @objc optional func DidReceiveMessageOver()
    // 开始封装数据并上传
    @objc optional func DidStartUploadData()
    // 手环绑定状态
    @objc optional func DidConnectedState(state: Bool)
    
    
}

class BlueTooth: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var Manger : CBCentralManager!
    var Service : CBService!
    var Peripheral : CBPeripheral!
    
    var peripheralArray : Array<PeripheralModel>!
    var char_battery : CBCharacteristic!
    
    var delegate : BlueToothDelegate?
    
    var ExchangeMac = String()  // 扫码的MAC
    var macdata = String()      // 暂存连接设备的mac地址
    //var MacData = String()      // 连接设备的mac地址
    var Battery : Int = 0       // 电池电量
    var HardVersion = String()  // 硬件版本号
    var softwareVersion = String()  // 软件版本号
    
    var receiveCount = 0        // 已接收数据的个数
    var messageCount = 0        // 数据总个数
    
    // 单例
    static let shareInstance = BlueTooth()
    override init() {
        super.init()
        print("BlueTooth.init")
        self.initBlueTooth()
    }
    
    func initBlueTooth() {
        self.Manger = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    // MARK: 扫描外围设备方法
    func scanDevicesFunc() {
        print("扫描外围设备方法")
        if Manger == nil || Manger.state != .poweredOn {
            print("系统蓝牙已关闭，不能扫描外围设备")
            self.initBlueTooth()
        }
        else {
            if Peripheral == nil || Peripheral.state != .connected {
                print("开始扫描外围设备")
                peripheralArray = Array.init()
                Manger.scanForPeripherals(withServices: nil, options: nil)
            }
            else {
                print("已连接，不扫描外围设备")
            }
        }
    }
    
    // MARK: 系统蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            delegate?.ManagerDidUpdateState?(open: true)
        default:
            delegate?.ManagerDidUpdateState?(open: false)
        }
    }
    
    // MARK: 发现外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.name != nil && (peripheral.name == "ELB" || peripheral.name == "ELA") {
            let perName : String = peripheral.name!
            let macStr = PublicClass().AdcDataToMacStr(AdvData: advertisementData)
            if macStr.count == 0 {
                return
            }
            
            print("name = \(perName), adv = \(String(describing: advertisementData["kCBAdvDataManufacturerData"])), macStr = \(macStr)")
            
            // 扫码连接
            if self.ExchangeMac.count > 0 {
                print("扫码连接")
            }
            else {
                let arrayList = UserDefaults.standard.object(forKey: "DevicesList")
                // print("arrayList = \(String(describing: arrayList))")
                if arrayList != nil {
                    let dict : Dictionary<String, AnyObject> = arrayList as! Dictionary<String, AnyObject>
                    if dict.count == 0 {
                        print("dict_1")
                        self.addPeripheralToDevicesList(peripheral: peripheral, data: advertisementData, RSSI: RSSI)
                    }
                    else {
                        print("dict = \(dict)")
                        let mode = Devices()
                        let item : Devices = mode.DictionaryToDevices(diction: dict as! Dictionary<String, String>)
                        print("item.mac = \(item.mac), macStr = \(macStr)")
                        if item.mac.count == 0 {
                            print("mac == 空")
                            self.addPeripheralToDevicesList(peripheral: peripheral, data: advertisementData, RSSI: RSSI)
                        }
                        // 如果搜索到的设备是设备列表中的设备，则连接该设备
                        else if item.mac == macStr {
                            print("mac != 空")
                            let model = self.CreatePeripheralModel(peripheral: peripheral, data: advertisementData, RSSI: RSSI)
                            self.peripheralArray = []
                            self.peripheralArray.append(model)
                            // 连接设备
                            self.connectedPeripheral(peripheral: peripheral, data: advertisementData)
                            // 协议
                            delegate?.DiscoverBundingDevice?(device: model)
                        }
                    }
                }
                else {
                    print("dict_2")
                    self.addPeripheralToDevicesList(peripheral: peripheral, data: advertisementData, RSSI: RSSI)
                }
            }
        }
    }
    
    // MARK: 已连接外设
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已连接外设")
        self.Manger.stopScan()
        self.Peripheral.delegate = self
        self.Peripheral.discoverServices(nil)
        
        self.ExchangeMac = String()
    }
    
    // MARK: 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //print("发现服务 = \(String(describing: peripheral.services))")
        for service in peripheral.services! {
            print("service = \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    
    // MARK: 发现特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("发现特征值")
        if service.characteristics != nil {
            for characteristic in service.characteristics! {
                let uuid : String = String.init(describing: characteristic.uuid)
                self.Peripheral.setNotifyValue(true, for: characteristic)
                print("uuid = \(uuid)")
                if uuid == "Battery Level" {
                    self.ExchangeMac = self.macdata
                    self.char_battery = characteristic
                    // 获取电池电量
                    SendCode().SendBatteryCode()
                    // 手环连接状态
                    delegate?.DidConnectedState?(state: true)
//                    // 对手环进行时间同步
//                    SendCode().SendSynchronizationTimeCode()
//                    // 获取手环设备的信息（硬件版本号、软件版本号）
//                    SendCode().SendMatchMessageCode()
                }
            }
        }
    }
    
    // MARK: 特征值改变
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let value = [UInt8](characteristic.value!)
        if value.count == 1 {
            // 如果特征值只有一位，则说明该特征值为电池电量
            self.Battery = Int(value.first!)
            delegate?.DischangeBattery?(value: Int(value.first!))
        }
        else if value.count >= 5 {
            var k : Int = 0
            if value[2] == 0x0A {
                k = 4   // 多指令模式， cmd 在第五位
            }
            else if value[2] == 0x05 {
                k = 3   // 单指令模式， cmd 在第四位
            }
            switch value[k] {
            case 0x02:  // 校验成功与否指令
                self.FirmwareUpdateCheckResults(value: Int(value[5]))
            case 0x03:  // 手环信息
                self.MatchMessage(value: value)
            case 0x14:  // 数据数量
                self.DataCount(value: value)
            case 0x15:  // 数据接收
                self.ReceiveData(value: value)
            case 0x2D:  // 指令接收成功
                delegate?.DidReceiveCodeSuccess?(value: value[5])
            case 0x2E:  // 指令接收失败
                delegate?.DidReceiveCodeFail?(value: value[5])
            case 0x58:  // 数据接收完毕
                self.ReceiveDataOver()
            default:
                break
            }
        }
    }

    // MARK: 发送指令反馈
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            print("指令发送失败 = \(String(describing: error))")
        }
        else {
            print("指令发送成功 = \(String(describing: error))")
        }
    }
    
    // MARK: 外设连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("外设连接失败")
        self.ConnectedState(state: false)
    }
    
    // MARK: 外设连接成功后，再失去连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("外设连接成功后，再失去连接")
        self.ConnectedState(state: false)
    }
    
    // MARK: 发送指令（有响应）
    func sendCode(data: Data, characteristic: CBCharacteristic) {
        self.Peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // MARK: 发送指令（无响应）
    func sendWithOutCode(data: Data, characteristic: CBCharacteristic) {
        self.Peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    // MARK: 封装 外设、广播包、信号强度
    func CreatePeripheralModel(peripheral: CBPeripheral, data: Dictionary<String, Any>, RSSI: NSNumber) -> PeripheralModel {
        let model = PeripheralModel()
        model.peripheral = peripheral
        model.Data = data
        model.RSSI = RSSI
        return model
    }
    
    // MARK: 连接指定外设
    func connectedPeripheral(peripheral: CBPeripheral, data: Dictionary<String, Any>) {
        self.Peripheral = peripheral
        self.Manger.connect(peripheral, options: nil)
        self.macdata = PublicClass().AdcDataToMacStr(AdvData: data)
    }
    
    // MARK: 添加外围设备到设备列表中
    func addPeripheralToDevicesList(peripheral: CBPeripheral, data: Dictionary<String, Any>, RSSI: NSNumber) {
        let model = self.CreatePeripheralModel(peripheral: peripheral, data: data, RSSI: RSSI)
        
        if self.peripheralArray.count <= 0 {
            self.peripheralArray.append(model)
        }
        else {
            let macStr = PublicClass().AdcDataToMacStr(AdvData: model.Data!)
            for k in self.peripheralArray.indices {
                let item = self.peripheralArray[k]
                let mac = PublicClass().AdcDataToMacStr(AdvData: item.Data!)
                if mac == macStr {
                    self.peripheralArray[k] = model
                    break
                }
                if k == self.peripheralArray.count - 1 {
                    self.peripheralArray.append(model)
                    break
                }
            }
        }
        delegate?.DiscoverPeripheral?(device: model)
    }
    
    // MARK: 特征值改变 ---- 固件更新校验是否成功
    func FirmwareUpdateCheckResults(value: Int) {
        print("特征值改变 ---- 固件更新校验是否成功 = \(value)")
        if value == 1 {
            delegate?.DidReceiveFirmwareUpdateState?(state: true)
            return
        }
        delegate?.DidReceiveFirmwareUpdateState?(state: false)
    }
    
    // MARK: 特征值改变 ---- 手环信息
    func MatchMessage(value: [UInt8]) {
        print("特征值改变 ---- 手环信息 = \(value)")
        let version = SendCode().ParseingMatchMessage(value: value)
        self.HardVersion = version.heard
        self.softwareVersion = version.software
        delegate?.DidReceiveMatchMessage?(heardVersion: version.heard, SoftWareVersion: version.software)   // 接收到手环信息的协议
    }
    
    // MARK: 特征值改变 ---- 数据数量
    func DataCount(value: [UInt8]) {
        self.receiveCount = 0
        self.messageCount = SendCode().ParseingMessageCount(value: value)
        print("特征值改变 ---- 数据数量 = \(self.messageCount)")
        delegate?.DidReceiveMessageCount?(value: self.messageCount)
    }
    
    // MARK: 特征值改变 ---- 数据接收
    func ReceiveData(value: [UInt8]) {
        let count = SendCode().ParseingData(value: value)
        self.receiveCount += count
        print("特征值改变 ---- 已数据接收 = \(self.receiveCount)")
        delegate?.DidReceiveMessageData?(value: self.receiveCount)
    }
    
    // MARK: 特征值改变 ---- 数据接收完毕
    func ReceiveDataOver() {
        print("特征值改变 ---- 数据接收完毕")
        delegate?.DidReceiveMessageOver?()
        // 保存数据到数据库
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.cdh().backgroundSaveContext()
            print("开始， 保存数据到数据库")
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + 1), execute: {
                print("结束, 开始上传数据")
                self.delegate?.DidStartUploadData?()
            })
        }
    }
    
    
    
    // MARK: 手环连接状态
    func ConnectedState(state: Bool) {
        if state {
            self.ExchangeMac = String()
        }
        delegate?.DidConnectedState?(state: state)
    }
    
    
    
    
    
    
    
    
    
}
