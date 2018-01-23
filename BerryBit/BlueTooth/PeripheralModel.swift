//
//  PeripheralModel.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/17.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralModel: NSObject {
    
    var peripheral : CBPeripheral!
    var Data : Dictionary<String,Any>!
    var RSSI : NSNumber!
    
    override init() {
        
    }
    
}
