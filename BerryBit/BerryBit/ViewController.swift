//
//  ViewController.swift
//  BerryBit
//
//  Created by 杨峰 on 17/12/4.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BuildBaseUI()
    }
    
    // MARK: 按钮方法
    
    /// 登录按钮方法
    @objc func LoginButtonMethod(button: UIButton) -> Void {
        let vc : LoginVC = LoginVC()
        self.present(vc, animated: true, completion: nil)
    }
    
    /// 注册按钮方法
    @objc func RegisterButtonMethod(button: UIButton) -> Void {
        let vc : RegisterVC = RegisterVC()
        vc.fromLoginVC = false
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: UI
    
    /// 创建界面
    func BuildBaseUI() {
        
        let view_w = self.view.frame.size.width
        let left = PublicClass.WidthWith(width: 36)
        let imv_w = PublicClass.HeightWith(height: 120)
        let imv_top = PublicClass.HeightWith(height: 90)
        let bu_h = PublicClass.HeightWith(height: 60)
        let bu_top = PublicClass.HeightWith(height: 56)
        
        self.view.backgroundColor = UIColor.white
        
        // Logo ImageView
        let imv = UIImageView.init(image: UIImage.init(named: "LogoImage"))
        imv.frame = CGRect.init(x: (view_w - imv_w) / 2.0, y: imv_top, width: imv_w, height: imv_w)
        imv.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(imv)
        
        // 标题
        let lab_1_y = imv.frame.maxY + PublicClass.HeightWith(height: 42);
        let lab_1 = UILabel.init(frame: CGRect.init(x: left, y: lab_1_y , width: (view_w - left * 2), height: PublicClass.HeightWith(height: 23)))
        lab_1.text = NSLocalizedString("VC_1", comment: "")
        lab_1.textColor = PublicClass.Color(RGB: 0x3F3F3F)
        lab_1.font = UIFont.init(name: "Helvetica-Bold", size: 24)
        self.view.addSubview(lab_1)
        
        // 说明
        let lab_2_y = lab_1.frame.maxY + PublicClass.HeightWith(height: 28);
        let lab_2 = UILabel.init(frame: CGRect.init(x: left, y: lab_2_y , width: (view_w - left * 2), height: PublicClass.HeightWith(height: 50)))
        lab_2.text = NSLocalizedString("VC_2", comment: "")
        lab_2.textColor = PublicClass.Color(RGB: 0x808080)
        lab_2.numberOfLines = 0;
        lab_2.font = UIFont.init(name: "Helvetica-Light", size: 15)
        lab_2.sizeToFit()
        self.view.addSubview(lab_2)
        
        // 登录按钮
        let login_y = lab_2.frame.maxY + bu_top
        let loginButton = UIButton.init(frame: CGRect.init(x: left, y: login_y, width: (view_w - left * 2), height: bu_h))
        loginButton.setTitle(NSLocalizedString("VC_3", comment: ""), for: UIControlState.normal)
        loginButton.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 19)
        loginButton.adjustsImageWhenHighlighted = false
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = bu_h / 2.0
        loginButton.backgroundColor = PublicClass.Color(RGB: 0x97DCFF)
        loginButton.addTarget(self, action: #selector(LoginButtonMethod), for: .touchUpInside)
        self.view.addSubview(loginButton)
        
        // 注册按钮
        let register_y = loginButton.frame.maxY + PublicClass.HeightWith(height: 20)
        let registerButton = UIButton.init(frame: CGRect.init(x: left, y: register_y, width: (view_w - left * 2), height: bu_h))
        registerButton.setTitle(NSLocalizedString("VC_4", comment: ""), for: UIControlState.normal)
        registerButton.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 19)
        registerButton.adjustsImageWhenHighlighted = false
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = bu_h / 2.0
        registerButton.backgroundColor = PublicClass.Color(RGB: 0x3CE4BB)
        registerButton.addTarget(self, action: #selector(RegisterButtonMethod), for: .touchUpInside)
        self.view.addSubview(registerButton)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

