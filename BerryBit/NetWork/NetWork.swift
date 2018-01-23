//
//  NetWork.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/2.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NetWork: NSObject {
    static let shareInstance = NetWork()
    let URL = "http://weixin3.berrybit.cn/berrybit-wechat/"
    
    // 获取验证码
    func GetPinCode(parameters: Dictionary<String, Any>, finished:@escaping (_ item: Int) -> (), failure:@escaping ((_ error: NSError) -> ())) {
        
        let baseUrl : String = URL + "user/sendSMS.do"
        Alamofire
            .request(baseUrl, parameters: parameters)
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    
                    failure(response.error! as NSError)
                    return
                }
                /*
                 
                 */
                print("获取验证码 = \(response)")
                if let value = response.result.value {
                    let dict = JSON(value)
                    let statusCode = dict["statusCode"].intValue
                    finished(statusCode)
                }
        }
        
    }
    
    // PIN登录
    func PINLogin(parameters: Dictionary<String, Any>, finished:@escaping (_ personalItem: PersonalInfo) -> (), failure:@escaping ((_ error: NSError) -> ())) {
        
        let baseUrl : String = URL + "user/loginBySMS.do"
        Alamofire
            .request(baseUrl, parameters: parameters)
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    
                    failure(response.error! as NSError)
                    return
                }
                /*
                 
                 */
                print("PIN登录 = \(response)")
                if let value = response.result.value {
                    
                    let dict = JSON(value)
                    let statusCode = dict["statusCode"].intValue
                    
                    if let data = dict["data"].dictionaryObject {
                        let personalItem = PersonalInfo.init(dict: data as [String : AnyObject])
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                    else {
                        let personalItem = PersonalInfo.init(dict: Dictionary())
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                }
        }

    }
    
    // 密码登录
    func PassWordLogin(parameters: Dictionary<String, Any>, finished:@escaping (_ personalItem: PersonalInfo) -> (), failure:@escaping ((_ error: NSError) -> ())) {
        
        let baseUrl : String = URL + "user/appLogin.do"
        
        Alamofire
            .request(baseUrl, parameters: parameters)
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    
                    failure(response.error! as NSError)
                    return
                }
                /*
                SUCCESS: {
                    data =     {
                        id = 19;
                        nickname = "<null>";
                        password = "<null>";
                        recentSyncTime = 1512956724;
                        telephone = 18318206223;
                    };
                    statusCode = 1;
                }
                */
                print("密码登录 = \(response)")
                if let value = response.result.value {
                    
                    let dict = JSON(value)
                    let statusCode = dict["statusCode"].intValue
                    
                    if let data = dict["data"].dictionaryObject {
                        let personalItem = PersonalInfo.init(dict: data as [String : AnyObject])
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                    else {
                        let personalItem = PersonalInfo.init(dict: Dictionary())
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                }
        }
    }
    
    // 获取设备列表
    func DeviceList(parameters: Dictionary<String, Any>, finished:@escaping (_ Items: Array<Any>) -> (), failure:@escaping ((_ error: NSError) -> ())) {
        
        let baseUrl : String = URL + "personal/findBabyList.do"
        
        Alamofire
            .request(baseUrl, parameters: parameters)
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    
                    failure(response.error! as NSError)
                    return
                }
                
                print("设备列表 = \(response)")
                if let value = response.result.value {
                    
                    let dict = JSON(value)
                    let statusCode = dict["statusCode"].intValue
                    
                    if let data = dict["data"].arrayObject {
                        var items = [Devices]()
                        if statusCode == 1 {
                            for item in data {
                                let it = Devices.init(dict: item as! [String : AnyObject])
                                items.append(it)
                            }
                        }
                        finished(items)
                    }
                    else {
                        let items = [Devices]()
                        finished(items)
                    }
                }
        }
    }
    
    // 注册
    func Register(parameters: Dictionary<String, Any>, finished:@escaping (_ personalItem: PersonalInfo) -> (), failure:@escaping ((_ error: NSError) -> ())) {
        
        let baseUrl : String = URL + "user/registerAndBund.do"
        Alamofire
            .request(baseUrl, parameters: parameters)
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    
                    failure(response.error! as NSError)
                    return
                }
                print("注册 = \(response)")
                if let value = response.result.value {
                    
                    let dict = JSON(value)
                    let statusCode = dict["statusCode"].intValue
                    
                    if let data = dict["data"].dictionaryObject {
                        let personalItem = PersonalInfo.init(dict: data as [String : AnyObject])
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                    else {
                        let personalItem = PersonalInfo.init(dict: Dictionary())
                        personalItem.statusCode = String(statusCode)
                        finished(personalItem)
                    }
                }
        }
    }
    
    
    
}












