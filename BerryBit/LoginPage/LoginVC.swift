//
//  LoginVC.swift
//  BerryBit
//
//  Created by 杨峰 on 17/12/4.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController , TextFiledViewDelegate {

    let Butt_1 = UIButton()
    let Butt_2 = UIButton()
    var tf_1 = TextFieldView()
    var tf_2 = TextFieldView()
    var tf_3 = TextFieldView()
    let forgot = UIButton()
    let lineview = UIView()
    let loginBu = UIButton()
    let registerBu = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BuildBaseUI()
        PublicClass.SetSVProgressHUD()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        SVProgressHUD.dismiss()
    }
    
    // MARK: 按钮方法
    
    /// 返回按钮方法
    @objc func BackButtonMethod(button: UIButton) -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 验证码登录按钮方法
    @objc func PinButtonMethod(button: UIButton) -> Void {
        SelectLoginType(type: true)
        self.view.endEditing(true)
    }
    
    /// 密码登录按钮方法
    @objc func PasswordButtonMethod(button: UIButton) -> Void {
        SelectLoginType(type: false)
        self.view.endEditing(true)
    }
    
    /// 忘记密码按钮方法
    @objc func ForgotButtonMethod(button: UIButton) -> Void {
        self.view.endEditing(true)
        
    }
    
    /// 登录按钮方法
    @objc func LoginButtonMethod(button: UIButton) -> Void {
        
        self.view.endEditing(true)
        let pub = PublicClass()
        
        var diction : Dictionary<String, String> = Dictionary()
        diction["telephone"] = tf_1.textfield.text!
        
        if Butt_1.isSelected {
            if !pub.isPhoneNumber(phone: tf_1.textfield.text!) {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("SVP_5", comment: ""))
                return
            }
            
            if tf_2.textfield.text!.count != 6 {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("SVP_6", comment: ""))
                return
            }
            //SVProgressHUD.show()
            diction["code"] = tf_2.textfield.text!
            RequestPinLogin(diction: diction)
        }
        else {
            if !pub.isPhoneNumber(phone: tf_1.textfield.text!) {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("SVP_5", comment: ""))
                return
            }
            if !pub.isPassWord(password: tf_3.textfield.text!) {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("SVP_7", comment: ""))
                return
            }
            //SVProgressHUD.show()
            diction["password"] = tf_3.textfield.text!
            RequestPasswordLogin(diction: diction)
        }
        
        
    }
    
    /// 我要注册按钮方法
    @objc func RegisterButtonMethod(button: UIButton) -> Void {
        self.view.endEditing(true)
        let vc = RegisterVC()
        vc.fromLoginVC = true
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK:  发送验证码按钮方法
    func SendPinButtonMethodDelegate(button: UIButton) {
        
        if !PublicClass().isPhoneNumber(phone: tf_1.textfield.text!) {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("SVP_5", comment: ""))
            return
        }
        // type 1为注册，2为登录或修改密码
        var params : Dictionary<String, Any> = Dictionary()
        params["telephone"] = tf_1.textfield.text
        params["type"] = "2"
        tf_2.SecondsCountDown(time: 60)
        tf_2.textfield.becomeFirstResponder()
        NetWork.shareInstance.GetPinCode(parameters: params, finished: { (item) in
            if item != 1 {
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_1", comment: ""))
            }
            
        }, failure: { (error) in
            print(error)
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_1", comment: ""))
        })
    }
    
    // MARK: 验证码登录的网络请求
    func RequestPinLogin(diction: Dictionary<String, Any>) -> Void {
        SVProgressHUD.show()
        NetWork.shareInstance.PINLogin(parameters: diction, finished: { (personalItem) in
            if let id = personalItem.id {
                let dic = ["appuserId":String(id)]
                self.RequestDeviceList(diction: dic, personalItem: personalItem)
            }
            else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_9", comment: ""))
            }
            
        }, failure: { (error) in
            print(error)
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_9", comment: ""))
        })
        
    }
    
    // MARK: 密码登录的网络请求
    func RequestPasswordLogin(diction: Dictionary<String, Any>) -> Void {
        SVProgressHUD.show()
        NetWork.shareInstance.PassWordLogin(parameters: diction, finished: { (personalItem) in
            if let id = personalItem.id {
                let dic = ["appuserId":String(id)]
                self.RequestDeviceList(diction: dic, personalItem: personalItem)
            }
            else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_9", comment: ""))
            }
            
        }, failure: { (error) in
        
            print(error)
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_9", comment: ""))
                
        })
        
    }
    
    // MARK: 获取设备列表的网络请求
    func RequestDeviceList(diction: Dictionary<String, Any>, personalItem: PersonalInfo) -> Void {
        
        NetWork.shareInstance.DeviceList(parameters: diction, finished: { (Items) in
            SVProgressHUD.dismiss()
            // 本地缓存个人信息
            let info : Dictionary<String, String> = PersonalInfo().personalInfoToDiction(Item: personalItem)
            UserDefaults.standard.set(info, forKey: "PersonalInfo")
            
            // 本地缓存设备列表
            if let item : Devices = Items.first as? Devices {
                let device = Devices().devicesToDiction(Item: item)
                UserDefaults.standard.set(device, forKey: "DevicesList")
            }
            
            let window : UIWindow = UIApplication.shared.keyWindow!
            let vc = HomeVC()
            window.rootViewController = vc
            window.makeKeyAndVisible()
            
        }, failure: { (error) in
            print(error)
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_10", comment: ""))
        })
    }
    
    // 选择 验证码登录(true)还是密码登录(false)
    func SelectLoginType(type: Bool) {
        Butt_1.isSelected = type
        Butt_2.isSelected = !type
        
        tf_2.isHidden = !type

        tf_3.isHidden = type
        forgot.isHidden = type
        lineview.isHidden = type
    }
    
    // MARK: UI
    
    /// 创建基础UI
    func BuildBaseUI() {
        
        let view_w = self.view.frame.size.width
        let right = PublicClass.WidthWith(width: 26)
        let backBu_w : CGFloat = 25
        let left = PublicClass.WidthWith(width: 36)
        let for_w = PublicClass.WidthWith(width: 84)
        let bu_h = PublicClass.HeightWith(height: 60)
        
        self.view.backgroundColor = UIColor.white
        
        // 1.返回按钮
        let backButton = UIButton()
        backButton.frame = CGRect.init(x: view_w - right - backBu_w, y: 20 + 44 - backBu_w, width: backBu_w, height: backBu_w)
        backButton.setBackgroundImage(UIImage.init(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(BackButtonMethod), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        // 2.验证码登录
        Butt_1.frame = CGRect.init(x: left, y: 64 + PublicClass.HeightWith(height: 20), width: PublicClass.WidthWith(width: 110), height: PublicClass.HeightWith(height: 44))
        Butt_1.setTitle(NSLocalizedString("LoginVC_1", comment: ""), for: .normal)
        Butt_1.setBackgroundImage(UIImage.init(), for: .normal)
        Butt_1.setBackgroundImage(UIImage.init(named: "LoginImage"), for: .selected)
        Butt_1.setTitleColor(PublicClass.Color(RGB: 0x3F3F3F), for: .selected)
        Butt_1.setTitleColor(PublicClass.Color(RGB: 0x808080), for: .normal)
        Butt_1.addTarget(self, action: #selector(PinButtonMethod), for: .touchUpInside)
        self.view.addSubview(Butt_1)
        
        // 3.密码登录
        Butt_2.frame = CGRect.init(x: Butt_1.frame.maxX, y: 64 + PublicClass.HeightWith(height: 20), width: PublicClass.WidthWith(width: 110), height: PublicClass.HeightWith(height: 44))
        Butt_2.setTitle(NSLocalizedString("LoginVC_2", comment: ""), for: .normal)
        Butt_2.setBackgroundImage(UIImage.init(), for: .normal)
        Butt_2.setBackgroundImage(UIImage.init(named: "LoginImage"), for: .selected)
        Butt_2.setTitleColor(PublicClass.Color(RGB: 0x3F3F3F), for: .selected)
        Butt_2.setTitleColor(PublicClass.Color(RGB: 0x808080), for: .normal)
        Butt_2.addTarget(self, action: #selector(PasswordButtonMethod), for: .touchUpInside)
        self.view.addSubview(Butt_2)
        
        // 4.手机号
        tf_1 = TextFieldView.init(frame: CGRect.init(x: left, y: Butt_1.frame.maxY + PublicClass.HeightWith(height: 29), width: view_w - left * 2, height: PublicClass.HeightWith(height: 60)))
        tf_1.TagInt = 1
        tf_1.textfield.keyboardType = UIKeyboardType.phonePad
        tf_1.textfield.placeholder = NSLocalizedString("LoginVC_5", comment: "")
        self.view.addSubview(tf_1)
        
        // 5.验证码登录 - 6位验证码
        tf_2 = TextFieldView.init(frame: CGRect.init(x: left, y: tf_1.frame.maxY, width: view_w - left * 2, height: PublicClass.HeightWith(height: 60)))
        tf_2.TagInt = 2
        tf_2.rightview = true
        tf_2.delegate = self
        tf_2.title = NSLocalizedString("LoginVC_9", comment: "")
        tf_2.Color = PublicClass.Color(RGB: 0x97DCFF)
        tf_2.textfield.keyboardType = UIKeyboardType.numberPad
        tf_2.textfield.placeholder = NSLocalizedString("LoginVC_8", comment: "")
        self.view.addSubview(tf_2)
        
        // 7.密码登录 - 密码
        tf_3 = TextFieldView.init(frame: CGRect.init(x: left, y: tf_1.frame.maxY, width: view_w - left * 2 - for_w, height: PublicClass.HeightWith(height: 60)))
        tf_3.TagInt = 3
        tf_3.forgetview = true
        tf_3.textfield.isSecureTextEntry = true
        tf_3.textfield.keyboardType = UIKeyboardType.emailAddress
        tf_3.textfield.placeholder = NSLocalizedString("LoginVC_6", comment: "")
        self.view.addSubview(tf_3)
        
        // 8.忘记密码
        let gap = PublicClass.WidthWith(width: 3)
        forgot.frame = CGRect.init(x: tf_3.frame.maxX + gap, y: tf_3.frame.origin.y, width: for_w - gap, height: tf_3.frame.size.height)
        forgot.setTitle(NSLocalizedString("LoginVC_7", comment: ""), for: .normal)
        forgot.setTitleColor(UIColor.init(red: 128.0 / 255, green: 128.0 / 255, blue: 128.0 / 255, alpha: 1.0), for: .normal)
        forgot.titleLabel?.font = UIFont.init(name: "Helvetica", size: 12)
        forgot.addTarget(self, action: #selector(ForgotButtonMethod), for: .touchUpInside)
        self.view.addSubview(forgot)
        
        lineview.frame = CGRect.init(x: tf_3.frame.maxX, y: tf_3.frame.maxY - 1.0, width: for_w, height: 1.0)
        lineview.backgroundColor = UIColor.init(red: 242.0 / 255, green: 242.0 / 255, blue: 242.0 / 255, alpha: 1.0)
        self.view.addSubview(lineview)
        
        SelectLoginType(type: true)
        
        // 9.登录
        loginBu.frame = CGRect.init(x: left, y: tf_2.frame.maxY + PublicClass.HeightWith(height: 38), width: view_w - left * 2, height: bu_h)
        loginBu.setTitle(NSLocalizedString("LoginVC_3", comment: ""), for: .normal)
        loginBu.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 19)
        loginBu.layer.masksToBounds = true
        loginBu.layer.cornerRadius = bu_h / 2.0
        loginBu.backgroundColor = PublicClass.Color(RGB: 0x97DCFF)
        loginBu.adjustsImageWhenHighlighted = false
        loginBu.addTarget(self, action: #selector(LoginButtonMethod), for: .touchUpInside)
        self.view.addSubview(loginBu)
        
        
        // 10.我要注册
        let re_w = PublicClass.WidthWith(width: 100)
        registerBu.frame = CGRect.init(x: (view_w - re_w) / 2.0, y: loginBu.frame.maxY + PublicClass.HeightWith(height: 40), width: re_w, height: PublicClass.HeightWith(height: 20))
        registerBu.setTitle(NSLocalizedString("LoginVC_4", comment: ""), for: .normal)
        registerBu.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 15)
        registerBu.layer.masksToBounds = true
        registerBu.layer.cornerRadius = bu_h / 2.0
        registerBu.backgroundColor = UIColor.clear
        registerBu.setTitleColor(UIColor.init(red: 151.0 / 255, green: 220.0 / 255, blue: 255.0 / 255, alpha: 1.0), for: .normal)
        registerBu.adjustsImageWhenHighlighted = false
        registerBu.addTarget(self, action: #selector(RegisterButtonMethod), for: .touchUpInside)
        self.view.addSubview(registerBu)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
