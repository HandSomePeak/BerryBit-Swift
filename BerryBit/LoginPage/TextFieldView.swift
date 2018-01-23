//
//  TextFieldView.swift
//  BerryBit
//
//  Created by 杨峰 on 2017/12/27.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit

@objc protocol TextFiledViewDelegate {
    
    @objc optional func SendPinButtonMethodDelegate(button: UIButton)

}

class TextFieldView: UIView {

    var delegate : TextFiledViewDelegate?
    let textfield = UITextField()
    let button = UIButton()
    var title : String {
        didSet {
            DispatchQueue.main.async {
                self.button.setTitle(self.title, for: .normal)
            }
        }
    }
    var Color : UIColor {
        didSet {
            DispatchQueue.main.async {
                self.button.backgroundColor = self.Color
            }
        }
    }
    var TagInt : NSInteger {
        didSet {
            textfield.tag = TagInt
            button.tag = TagInt
        }
    }
    var rightview : Bool {
        didSet {
            if rightview {
                textfield.rightView = BuildSendPinView()
                textfield.rightViewMode = UITextFieldViewMode.always
            }
        }
    }
    var forgetview : Bool {
        didSet {
            if forgetview {
                textfield.rightView = BuildForgetView()
                textfield.rightViewMode = UITextFieldViewMode.always
            }
        }
        
    }
    
    /// 清除按钮方法
    @objc func cleanButtonMethod(button: UIButton) -> Void {
        textfield.text = String()
    }
    
    /// 隐私按钮方法
    @objc func secureMethod(button: UIButton) -> Void {
        button.isSelected = !button.isSelected
        textfield.isSecureTextEntry = button.isSelected
    }
    
    /// 发送验证码按钮方法
    @objc func SendPinButtonMethod(button: UIButton) -> Void {
        if delegate != nil {
            delegate?.SendPinButtonMethodDelegate!(button: button)
        }
    }
    
    /// GCD倒计时
    func SecondsCountDown(time: NSInteger) {
        self.button.isEnabled = false
        // 在global线程里创建一个时间源
        let codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        var timeCount = time + 1
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        codeTimer.setEventHandler { 
            timeCount -= 1
            if timeCount < 0 {
                codeTimer.cancel()
                DispatchQueue.main.async {
                    self.button.setTitle(self.title, for: .normal)
                    self.button.backgroundColor = self.Color
                    self.button.isEnabled = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.button.setTitle(String(timeCount), for: .normal)
                    self.button.backgroundColor = PublicClass.Color(RGB: 0xCCCCCC)
                }
            }
        }
        codeTimer.resume()
    }
    
    // 发送验证码
    func BuildSendPinView() -> UIView {
        let view_w = PublicClass.WidthWith(width: 84)
        let view_h = self.frame.size.height
        let bu_h = PublicClass.HeightWith(height: 24)
        
        let rightview = UIView()
        rightview.frame = CGRect.init(x: 0, y: 0, width: view_w, height: view_h)
        rightview.backgroundColor = UIColor.clear
        
        button.frame = CGRect.init(x: 0, y: (view_h - bu_h) / 2.0, width: view_w, height: bu_h)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.adjustsImageWhenHighlighted = false
        button.titleLabel?.font = UIFont.init(name: "Helvetica", size: 12)
        button.addTarget(self, action: #selector(SendPinButtonMethod), for: .touchUpInside)
        rightview.addSubview(button)
        
        return rightview
    }
    
    //忘记密码右边视图
    func BuildForgetView() -> UIView {
        
        let view_w = PublicClass.WidthWith(width: 44)
        let view_h = self.frame.size.height
        
        let rightview = UIView()
        rightview.frame = CGRect.init(x: 0, y: 0, width: view_w, height: view_h)
        rightview.backgroundColor = UIColor.clear
        
        let bu_h = rightview.frame.size.height
        let bu_w = PublicClass.WidthWith(width: 22)
        
        let cleanBu = UIButton()
        cleanBu.frame = CGRect.init(x: 0, y: (view_h - bu_h) / 2.0, width: bu_w, height: bu_h)
        cleanBu.backgroundColor = UIColor.clear
        cleanBu.setImage(UIImage.init(named: "clean"), for: .normal)
        cleanBu.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        cleanBu.adjustsImageWhenHighlighted = false
        cleanBu.addTarget(self, action: #selector(cleanButtonMethod), for: .touchUpInside)
        
        let ri_w = PublicClass.WidthWith(width: 22)
        let rightBu = UIButton()
        rightBu.frame = CGRect.init(x: view_w - ri_w, y: (view_h - bu_h) / 2.0, width: ri_w, height: bu_h)
        rightBu.backgroundColor = UIColor.clear
        rightBu.setImage(UIImage.init(named: "openEye"), for: .normal)
        rightBu.setImage(UIImage.init(named: "closeEye"), for: .selected)
        rightBu.isSelected = true
        rightBu.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        rightBu.adjustsImageWhenHighlighted = false
        rightBu.addTarget(self, action: #selector(secureMethod), for: .touchUpInside)
        
        rightview.addSubview(rightBu)
        rightview.addSubview(cleanBu)
        
        return rightview
    }
    
    
    // 初始化
    override init(frame: CGRect) {
        self.title = ""
        self.Color = UIColor.white
        self.TagInt = 0
        self.rightview = false
        self.forgetview = false
        self.delegate = nil
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.frame = frame
        textfield.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        textfield.textColor = PublicClass.Color(RGB: 0x808080)
        textfield.font = UIFont.init(name: "Helvetica", size: 15)
        self.addSubview(textfield)
        
        BuildLineView(frame: frame, view: self)
    }
    
    
    func BuildLineView(frame: CGRect, view: UIView) {
        let line_h : CGFloat = 1.0
        let line = UIView()
        line.frame = CGRect.init(x: 0, y: frame.size.height - line_h, width: frame.size.width, height: line_h)
        line.backgroundColor = UIColor.init(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        view.addSubview(line)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }

}
