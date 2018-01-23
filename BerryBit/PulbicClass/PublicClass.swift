//
//  PublicClass.swift
//  BerryBit
//
//  Created by 杨峰 on 17/12/11.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit
import SVProgressHUD

class PublicClass: NSObject {

    //MARK: 屏幕适配
    
    /// 适配屏幕宽度
    ///
    /// - parameter width: 原宽度
    ///
    /// - returns: 适配后的宽度
    class func WidthWith(width: CGFloat) -> CGFloat {
        let screen = UIScreen.main.bounds.size.width
        let w = width * screen / 375
        return w
    }
    
    /// 适配屏幕高度
    ///
    /// - parameter height: 原高度
    ///
    /// - returns: 适配后的高度
    class func HeightWith(height: CGFloat) -> CGFloat {
        let screen = UIScreen.main.bounds.size.height
        let h = height * screen / 667
        return h
    }
    
    
    //MARK: 手机号码和密码校验
    func isPhoneNumber(phone: String) -> Bool {
        let mobile = "^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$"
        let regextestmoblie = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regextestmoblie.evaluate(with: phone) {
            return true
        }
        return false
    }
    
    func isPassWord(password: String) -> Bool {
        if password.count >= 6 && password.count <= 20 {
            return true
        }
        return false
    }
    
    
    //MARK: 颜色设置
    class func Color(RGB: Int) -> UIColor {
        let red = (CGFloat)((RGB & 0xFF0000) >> 16) / 255.0
        let green = (CGFloat)((RGB & 0xFF00) >> 8) / 255.0
        let blue = (CGFloat)(RGB & 0xFF) / 255.0
        let color = UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
    

    // MARK: SVProgressHUD 设置
    class func SetSVProgressHUD() -> Void {
        SVProgressHUD.setBackgroundColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
    }
    
    // MARK: 设置行间距
    func LineSpacing(string : String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let attStr = NSMutableAttributedString.init(string: string)
        attStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSMakeRange(0, string.count))
        return attStr
    }
 
    // MARK: 渐变色
    func SetGradientLayer(button: UIButton, width: CGFloat, layer: inout CAGradientLayer) -> CAGradientLayer {
        
        let height = button.frame.size.height
        
        // 创建图层对象
        //let layer = CAGradientLayer()
        
        // 设置图层尺寸和位置
        layer.bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
        layer.position = CGPoint.init(x: width / 2.0, y: height / 2.0)
        // 设置要进行色彩渐变的颜色
        layer.colors = [UIColor.init(red: 252 / 255.0, green: 100 / 255.0, blue: 164 / 255.0, alpha: 1).cgColor,
                        UIColor.init(red: 253 / 255.0, green: 152 / 255.0, blue: 195 / 255.0, alpha: 1).cgColor]
        
        // 设置要进行渐变的临界位置
        layer.locations = [NSNumber.init(value: 0),
                           NSNumber.init(value: 1)]
        // 设置渐变的起始点与结束点
        layer.startPoint = CGPoint.init(x: 0, y: 0.5)
        layer.endPoint = CGPoint.init(x: 1, y: 0.5)
        return layer
    }
    
    // MARK: data转String
    func dataToString(data: Data) -> String {
        let str = [UInt8](data)
        var m_str = String()
        for index in str.indices {
            let a = str[index] & 0xff
            var  str = String().appendingFormat("%x",a)
            if str.count != 2 {
                str = "0" + str
            }
            m_str.append(str)
        }
        m_str.removeSubrange(m_str.startIndex...m_str.index(m_str.startIndex, offsetBy: 3))
        return m_str
    }
    
    // MARK: 广播包获取MAC地址
    func AdcDataToMacStr(AdvData: Dictionary<String, Any>) -> String {
        var string = String()
        let da = AdvData["kCBAdvDataManufacturerData"]
        if da != nil {
            let data = da as! Data
            string = PublicClass().dataToString(data: data)
        }
        return string
    }
    
    
    
    
    
    
}
