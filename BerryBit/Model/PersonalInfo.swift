//
//  PersonalInfo.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/3.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

class PersonalInfo: NSObject {

    var id : String!
    var nickname : String!
    var password : String!
    var telephone : String!
    var recentSyncTime : String!
    var statusCode: String!
    
    override init() {
        
    }
    
    init(dict: [String: AnyObject]) {
        
        print("dict = \(dict)")
        
        let a = dict["id"]
        let b = dict["nickname"]
        let c = dict["password"]
        let d = dict["telephone"]
        let e = dict["recentSyncTime"]
        
        id = String()
        nickname = String()
        password = String()
        password = String()
        recentSyncTime = String()
        statusCode = "0"

        if a != nil {
            id = String.init(describing: a)
        }
        if b != nil {
            nickname = String(describing: b)
        }
        if c != nil {
            password = String(describing: c)
        }
        if d != nil {
            telephone = String(describing: d)
        }
        if e != nil {
            recentSyncTime = String(describing: e)
        }
    }
    
    func personalInfoToDiction(Item: PersonalInfo) -> Dictionary<String, String> {
        
        var diction : Dictionary<String, String> = Dictionary()
        if let id = Item.id {
            diction["id"] = id as String
        }
        if let nickname = Item.nickname {
            diction["nickname"] = nickname as String
        }
        if let password = Item.password {
            diction["password"] = password as String
        }
        if let telephone = Item.telephone {
            diction["telephone"] = telephone as String
        }
        if let recentSyncTime = Item.recentSyncTime {
            diction["recentSyncTime"] = recentSyncTime as String
        }
        if let statusCode = Item.statusCode {
            diction["statusCode"] = statusCode as String
        }
        
        return diction
    }
    
}
