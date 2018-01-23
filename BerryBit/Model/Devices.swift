//
//  Devices.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/4.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

class Devices: NSObject {
    var id : String!
    var nickname : String!
    var mac : String!
    
    override init() {
        id = String()
        nickname = String()
        mac = String()
    }
    
    init(dict: [String: AnyObject]) {
        
        id = String()
        nickname = String()
        mac = String()
        
        if let a = dict["id"] {
            id = String.init(describing: a)
        }
        if let b = dict["nickname"] {
            nickname = String.init(describing: b)
        }
        if let c = dict["mac"] {
            mac = String.init(describing: c)
        }
    }
    
    func devicesToDiction(Item: Devices) -> Dictionary<String, String> {
        
        var diction : Dictionary<String, String> = Dictionary()
        if let id = Item.id {
            diction["id"] = id
        }
        if let nickname = Item.nickname {
            diction["nickname"] = nickname
        }
        if let mac = Item.mac {
            diction["mac"] = mac
        }
        
        return diction
    }
    
    func DictionaryToDevices(diction: Dictionary<String, String>) -> Devices {
        let model : Devices = Devices()

        if let a = diction["id"] {
            model.id = String.init(describing: a)
        }
        if let b = diction["nickname"] {
            model.nickname = String.init(describing: b)
        }
        if let c = diction["mac"] {
            model.mac = String.init(describing: c)
        }
        
        return model
    }
    
}
