//
//  RegisterVC.swift
//  BerryBit
//
//  Created by 杨峰 on 2017/12/27.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterVC: UIViewController , TextFiledViewDelegate {

    var fromLoginVC : Bool = true
    var tf_1 = TextFieldView()
    var tf_2 = TextFieldView()
    var tf_3 = TextFieldView()
    var tf_4 = TextFieldView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BuildBaseUI()
        PublicClass.SetSVProgressHUD()
    }
    
    /// MARK: 按钮方法
    
    /// 返回按钮方法
    @objc func BackButtonMethod(button: UIButton) -> Void {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    ///
    @objc func RegisterButtonMethod(button: UIButton) -> Void {
        if !PublicClass().isPhoneNumber(phone: tf_1.textfield.text!) {
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_5", comment: ""))
            return
        }
        if tf_2.textfield.text?.count != 6 {
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_6", comment: ""))
            return
        }
        if !PublicClass().isPassWord(password: tf_3.textfield.text!) ||
            !PublicClass().isPassWord(password: tf_4.textfield.text!) {
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_7", comment: ""))
            return
        }
        if tf_3.textfield.text != tf_4.textfield.text &&
            tf_3.textfield.text!.count > 0 {
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_8", comment: ""))
            return
        }
        self.view.endEditing(true)
        SVProgressHUD.show()
        let dic = ["telephone":tf_1.textfield.text!,
                   "code":tf_2.textfield.text!,
                   "password":tf_3.textfield.text!]
        
        NetWork.shareInstance.Register(parameters: dic, finished: { (personalItem) in
            SVProgressHUD.dismiss()
            if personalItem.id != nil {
                // 本地缓存个人信息
                let info : Dictionary<String, String> = PersonalInfo().personalInfoToDiction(Item: personalItem)
                UserDefaults.standard.set(info, forKey: "PersonalInfo")
                
                let window : UIWindow = UIApplication.shared.keyWindow!
                let vc = HomeVC()
                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
            else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_2", comment: ""))
            }
            
        }, failure: { (error) in
            print(error)
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_2", comment: ""))
        })
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
        params["type"] = "1"
        tf_2.SecondsCountDown(time: 60)
        tf_2.textfield.becomeFirstResponder()
        NetWork.shareInstance.GetPinCode(parameters: params, finished: { (item) in
            
            print("item = \(item)")
            if item != 1 {
                SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_1", comment: ""))
            }
            
        }, failure: { (error) in
            
            print(error)
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: NSLocalizedString("SVP_1", comment: ""))
        })
    }
    
    /// MARK: UI
    
    /// 创建基础UI
    func BuildBaseUI() {
        
        let view_w = self.view.frame.size.width
        let right = PublicClass.WidthWith(width: 26)
        let left = PublicClass.WidthWith(width: 36)
        let backBu_w : CGFloat = 25
        let bu_h = PublicClass.WidthWith(width: 60)
        
        self.view.backgroundColor = UIColor.white
        
        // 1.创建返回按钮
        let backButton = UIButton()
        backButton.frame = CGRect.init(x: view_w - right - backBu_w, y: 20 + 44 - backBu_w, width: backBu_w, height: backBu_w)
        backButton.setBackgroundImage(UIImage.init(named: "close"), for: .normal)
        backButton.addTarget(self, action: #selector(BackButtonMethod), for: .touchUpInside)
        self.view.addSubview(backButton)
        if fromLoginVC {
            backButton.frame = CGRect.init(x: right, y: 20 + 44 - backBu_w, width: backBu_w, height: backBu_w)
            backButton.setBackgroundImage(UIImage.init(named: "RegisterVC_1"), for: .normal)
            backButton.sizeToFit()
            backButton.frame = CGRect.init(x: right, y: 20 + 44 - backBu_w, width: backButton.frame.size.width, height: backBu_w)
        }
        
        // 2.欢迎注册精灵果果
        let lab_1 = UILabel.init()
        lab_1.frame = CGRect.init(x: left, y: PublicClass.HeightWith(height: 84), width: view_w - left * 2, height: PublicClass.HeightWith(height: 23))
        lab_1.text = NSLocalizedString("RegisterVC_1", comment: "")
        lab_1.textColor = UIColor.init(red: 63.0 / 255.0, green: 63.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
        lab_1.font = UIFont.init(name: "Helvetica-Bold", size: 24)
        self.view.addSubview(lab_1)
        
        // 3.手机号
        let frame_1 = CGRect.init(x: left, y: lab_1.frame.maxY + PublicClass.HeightWith(height: 22), width: view_w - left * 2, height: PublicClass.HeightWith(height: 60))
        tf_1 = TextFieldView.init(frame: frame_1)
        tf_1.rightview = false
        tf_1.tag = 1
        tf_1.textfield.keyboardType = UIKeyboardType.phonePad
        tf_1.textfield.placeholder = NSLocalizedString("RegisterVC_2", comment: "")
        self.view.addSubview(tf_1)
        
        // 4.验证码
        let frame_2 = CGRect.init(x: left, y: tf_1.frame.maxY, width: view_w - left * 2, height: PublicClass.HeightWith(height: 60))
        tf_2 = TextFieldView.init(frame: frame_2)
        tf_2.rightview = true
        tf_2.delegate = self
        tf_2.tag = 2
        tf_2.textfield.keyboardType = UIKeyboardType.numberPad
        tf_2.title = NSLocalizedString("RegisterVC_4", comment: "")
        tf_2.Color = UIColor.init(red: 60.0 / 255, green: 228.0 / 255, blue: 187 / 255.0, alpha: 1.0)
        tf_2.textfield.placeholder = NSLocalizedString("RegisterVC_3", comment: "")
        self.view.addSubview(tf_2)
        
        // 5.密码
        let frame_3 = CGRect.init(x: left, y: tf_2.frame.maxY, width: view_w - left * 2, height: PublicClass.HeightWith(height: 60))
        tf_3 = TextFieldView.init(frame: frame_3)
        tf_3.rightview = false
        tf_3.tag = 3
        tf_3.textfield.isSecureTextEntry = true
        tf_3.textfield.placeholder = NSLocalizedString("RegisterVC_5", comment: "")
        self.view.addSubview(tf_3)
        
        // 6.确认密码
        let frame_4 = CGRect.init(x: left, y: tf_3.frame.maxY, width: view_w - left * 2, height: PublicClass.HeightWith(height: 60))
        tf_4 = TextFieldView.init(frame: frame_4)
        tf_4.rightview = false
        tf_4.tag = 4
        tf_4.textfield.isSecureTextEntry = true
        tf_4.textfield.placeholder = NSLocalizedString("RegisterVC_6", comment: "")
        self.view.addSubview(tf_4)
        
        // 7.
        let registerBu = UIButton()
        registerBu.frame = CGRect.init(x: left, y: tf_4.frame.maxY + PublicClass.HeightWith(height: 38), width: view_w - left * 2, height: bu_h)
        registerBu.setTitle(NSLocalizedString("RegisterVC_7", comment: ""), for: .normal)
        registerBu.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 19)
        registerBu.layer.masksToBounds = true
        registerBu.layer.cornerRadius = bu_h / 2.0
        registerBu.backgroundColor = PublicClass.Color(RGB: 0x3CE4BB)
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
