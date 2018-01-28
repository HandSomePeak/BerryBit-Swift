//
//  HomeVC.swift
//  BerryBit
//
//  Created by 杨峰 on 17/12/4.
//  Copyright © 2017年 BerryBit. All rights reserved.
//

import UIKit
import SVProgressHUD

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let ExpendedOffset = ScreenWidth * 0.6


class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, BlueToothDelegate{
    
    let MAINVIEW = UIView() // 主页视图
    let hideButton = UIButton() // 遮挡主页的控件
    let leftButton = UIButton() //
    let telephone = UILabel()
    let tableview = UITableView()
    
    let titleLabel = UILabel()
    let TimeLabel = UILabel()
    let messageLabel = UILabel()
    let mainButton = UIButton()
    
    var gradientLayer = CAGradientLayer()
    
    var m_array : Array = [NSLocalizedString("HomeVC_2", comment: ""),
                           NSLocalizedString("HomeVC_3", comment: ""),
                           NSLocalizedString("HomeVC_4", comment: "")]
    
    var ble : BlueTooth = BlueTooth.shareInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PublicClass.SetSVProgressHUD()
        ble.delegate = self
        
        // 制作基础的侧滑框架
        CreateBaseAnimateView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ble.delegate = self
        self.RefreshTitleLabel()
    }
    
    // MARK: BlueToothDelegate 协议方法
    func ManagerDidUpdateState(open: Bool) {
        switch open {
        case true:
            print("系统蓝牙开启")
        default:
            print("系统蓝牙关闭")
        }
    }
    
    // MARK: 手环连接状态
    func DidConnectedState(state: Bool) {
        print("主页接收到蓝牙状态改变的值 = \(state)")
        self.RefreshTitleLabel()
    }
    
    // MARK: 电池电量
    func DischangeBattery(value: Int) {
        self.RefreshTitleLabel()
    }
    
    // MARK: 侧滑框架
    func CreateBaseAnimateView() {
        self.view.backgroundColor = UIColor.white
        
        //绘制侧边栏视图
        DrawLeftView()
        
        //绘制主页视图
        DrawMainView()
    }
    
    // MARK: 从相册选择照片或拍照
    @objc func PhotoButtonMethod(button: UIButton) {
        
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell_h = PublicClass.HeightWith(height: 58)
        tableView.rowHeight = cell_h
        
        let indetifier = "cell"
        let cell = LeftViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: indetifier)
        let string : String = m_array[indexPath.row]
        cell.ValueForCell(string: string, indexPath: indexPath, cellHeight: cell_h, cellWidth: tableView.frame.size.width)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
        
        
    }
    
    // MARK: 绘制侧边栏视图
    func DrawLeftView() {
        
        let top = PublicClass.HeightWith(height: 109)
        let photo_w = PublicClass.HeightWith(height: 74)
        let left = PublicClass.WidthWith(width: 36)
        // 头像
        let photo = UIButton.init(frame: CGRect.init(x: left, y: top, width: photo_w, height: photo_w))
        photo.setImage(UIImage.init(named: "HeardImage"), for: .normal)
        photo.contentMode = UIViewContentMode.scaleAspectFit
        photo.layer.masksToBounds = true
        photo.layer.cornerRadius = photo_w / 2.0
        photo.adjustsImageWhenHighlighted = false
        photo.addTarget(self, action: #selector(PhotoButtonMethod), for: .touchUpInside)
        self.view.addSubview(photo)
        // 电话号码
        telephone.frame = CGRect.init(x: left, y: photo.frame.maxY + PublicClass.HeightWith(height: 21), width: ExpendedOffset - left, height: PublicClass.HeightWith(height: 20))
        telephone.text = "--"
        telephone.textColor = PublicClass.Color(RGB: 0x282828)
        telephone.font = UIFont.init(name: "Helvetica-Bold", size: 18)
        self.view.addSubview(telephone)
        // 用户等级
        let level = UILabel()
        level.frame = CGRect.init(x: left, y: telephone.frame.maxY + PublicClass.HeightWith(height: 12), width: ExpendedOffset - left, height: PublicClass.HeightWith(height: 13))
        level.text = NSLocalizedString("HomeVC_1", comment: "")
        level.textColor = PublicClass.Color(RGB: 0x808080)
        level.font = UIFont.init(name: "Helvetica", size: 12)
        self.view.addSubview(level)
        // tableview
        let right : CGFloat = 15
        let bottom = PublicClass.HeightWith(height: 70)
        let tab_y = level.frame.maxY + PublicClass.HeightWith(height: 37)
        let tab_h = self.view.frame.size.height - tab_y - bottom
        tableview.frame = CGRect.init(x: left, y: tab_y, width: ExpendedOffset - left - right, height: tab_h)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.clear
        tableview.separatorStyle = UITableViewCellSeparatorStyle.none
        tableview.bounces = false
        self.view.addSubview(tableview)
        // line
        let line = UIView.init(frame: CGRect.init(x: left, y: tableview.frame.maxY, width: ExpendedOffset - left - right, height: 1.0))
        line.backgroundColor = PublicClass.Color(RGB: 0xE6E6E6)
        self.view.addSubview(line)
        // 退出登录
        let quit = UIButton.init(frame: CGRect.init(x: left, y: line.frame.maxY, width: line.frame.size.width, height: bottom))
        quit.setImage(UIImage.init(named: "SignOut"), for: .normal)
        quit.setTitle(" " + NSLocalizedString("HomeVC_5", comment: ""), for: .normal)
        quit.setTitleColor(PublicClass.Color(RGB: 0x282828), for: .normal)
        quit.titleLabel?.font = UIFont.init(name: "Helvetica", size: 15)
        quit.sizeToFit()
        quit.addTarget(self, action: #selector(QuitButtonMethod), for: .touchUpInside)
        quit.frame = CGRect.init(x: left, y: line.frame.maxY, width: quit.frame.size.width + 10, height: bottom)
        self.view.addSubview(quit)
    }
    
    @objc func QuitButtonMethod(button: UIButton) {
        
    }
    
    // MARK: 绘制主页视图
    func DrawMainView() {
        let left : CGFloat = PublicClass.WidthWith(width: 36)
        let top : CGFloat = 20 + 15
        let bu_w : CGFloat = 29
        let bottom : CGFloat = PublicClass.HeightWith(height: 46)
        let bu_h : CGFloat = PublicClass.HeightWith(height: 67)
        let bu_left : CGFloat = 26
        
        // 主页视图
        MAINVIEW.frame = self.view.frame
        MAINVIEW.backgroundColor = UIColor.white
        self.view.addSubview(MAINVIEW)
        
        let view_w = MAINVIEW.frame.size.width
        let view_h = MAINVIEW.frame.size.height
        
        // 左边按钮
        leftButton.frame = CGRect.init(x: bu_left, y: top, width: bu_w, height: bu_w)
        leftButton.setImage(UIImage.init(named: "LeftNav"), for: .normal)
        leftButton.addTarget(self, action: #selector(LeftButtonMethod), for: .touchUpInside)
        leftButton.isSelected = false
        MAINVIEW.addSubview(leftButton)
        
        // 右边按钮
        let rightButton = UIButton.init(frame: CGRect.init(x:view_w - bu_left - bu_w, y: top, width: bu_w, height: bu_w))
        rightButton.setImage(UIImage.init(named: "qrCode"), for: .normal)
        rightButton.addTarget(self, action: #selector(RightButtonMethod), for: .touchUpInside)
        MAINVIEW.addSubview(rightButton)
        
        // 侧滑的遮挡按钮
        hideButton.frame = MAINVIEW.frame
        hideButton.backgroundColor = UIColor.black
        hideButton.isHidden = true
        hideButton.addTarget(self, action: #selector(HideButtonMethod), for: .touchUpInside)
        MAINVIEW.addSubview(hideButton)
        
        //
        titleLabel.frame = CGRect.init(x: view_w / 4.0, y: top, width: view_w / 2.0, height: bu_w)
        titleLabel.textColor = PublicClass.Color(RGB: 0x707070)
        titleLabel.font = UIFont.init(name: "Helvetica", size: 17)
        titleLabel.textAlignment = NSTextAlignment.center
        MAINVIEW.addSubview(titleLabel)
        
        //
        let lab_y = 64 + PublicClass.HeightWith(height: 20) + PublicClass.HeightWith(height: 248)
        let label_1 = UILabel.init(frame: CGRect.init(x: left, y: lab_y, width: view_w - left * 2, height: PublicClass.HeightWith(height: 22)))
        label_1.text = NSLocalizedString("HomeVC_7", comment: "")
        label_1.textColor = PublicClass.Color(RGB: 0x707070)
        label_1.font = UIFont.init(name: "Helvetica-Bold", size: 22)
        MAINVIEW.addSubview(label_1)
        
        //
        TimeLabel.frame = CGRect.init(x: left, y: label_1.frame.maxY + PublicClass.HeightWith(height: 26), width: view_w - left * 2, height: PublicClass.HeightWith(height: 26))
        TimeLabel.text = "--"
        TimeLabel.textColor = PublicClass.Color(RGB: 0x707070)
        TimeLabel.font = UIFont.init(name: "Helvetica-Bold", size: 15)
        MAINVIEW.addSubview(TimeLabel)
        
        //
        messageLabel.frame = CGRect.init(x: left, y: TimeLabel.frame.maxY + PublicClass.HeightWith(height: 29), width: view_w - left * 2, height: 20)
        messageLabel.textColor = PublicClass.Color(RGB: 0x999999)
        messageLabel.font = UIFont.init(name: "Helvetica", size: 13)
        messageLabel.numberOfLines = 0
        messageLabel.attributedText = PublicClass().LineSpacing(string: NSLocalizedString("HomeVC_11", comment: ""))
        messageLabel.sizeToFit()
        MAINVIEW.addSubview(messageLabel)
        
        //
        mainButton.frame = CGRect.init(x: left, y: view_h - bottom - bu_h, width: view_w - left * 2, height: bu_h)
        mainButton.titleLabel?.font = UIFont.init(name: "Helvetica-Bold", size: 20)
        mainButton.adjustsImageWhenHighlighted = false
        mainButton.layer.masksToBounds = true
        mainButton.layer.cornerRadius = bu_h / 2.0
        mainButton.tag = 0
        mainButton.addTarget(self, action: #selector(MainButtonMethod(button:)), for: .touchUpInside)
        MAINVIEW.addSubview(mainButton)
        self.SetMainButtonAttribute(index: 0, percent: 0)
        
    }
    
    // 修改按钮和提示信息
    func SetMainButtonAttribute(index: NSInteger, percent: NSInteger) {
        DispatchQueue.main.async {
            let left : CGFloat = PublicClass.WidthWith(width: 36)
            let view_w : CGFloat = self.MAINVIEW.frame.size.width
            // 0连接设备， 1同步数据， 2正在同步, 3同步完成
            let array_1 = [NSLocalizedString("HomeVC_11", comment: ""),
                         NSLocalizedString("HomeVC_12", comment: ""),
                         NSLocalizedString("HomeVC_13", comment: ""),
                         NSLocalizedString("HomeVC_13", comment: "")]
            
            let array_2 = [NSLocalizedString("HomeVC_14", comment: ""),
                         NSLocalizedString("HomeVC_15", comment: ""),
                         NSLocalizedString("HomeVC_16", comment: "") + " ~ " + String(percent) + "%",
                         NSLocalizedString("HomeVC_17", comment: "")]
            
            let array_3 = [PublicClass.Color(RGB: 0x97dcff),
                           PublicClass.Color(RGB: 0x97dcff),
                           PublicClass.Color(RGB: 0xfc5a9e),
                           PublicClass.Color(RGB: 0xfc5a9e)]
            
            // 提示信息
            self.messageLabel.attributedText = PublicClass().LineSpacing(string: array_1[index])
            self.messageLabel.frame = CGRect.init(x: self.messageLabel.frame.origin.x, y: self.messageLabel.frame.origin.y, width: view_w - left * 2, height: 20)
            self.messageLabel.sizeToFit()
            
            // 按钮
            self.mainButton.backgroundColor = array_3[index]
            self.mainButton.setTitle(array_2[index], for: .normal)
            
            switch index {
            case 0: // 连接设备
                self.titleLabel.text = ""
                self.mainButton.layer.insertSublayer(PublicClass().SetGradientLayer(button: self.mainButton, width: 0, layer: &self.gradientLayer), at: 0)
            case 1: // 同步数据
                self.mainButton.layer.insertSublayer(PublicClass().SetGradientLayer(button: self.mainButton, width: 0, layer: &self.gradientLayer), at: 0)
            case 2: // 正在同步
                let wid : CGFloat = view_w * CGFloat(percent) / 100
                print("wid = \(wid), percent = \(percent)")
                self.mainButton.layer.insertSublayer(PublicClass().SetGradientLayer(button: self.mainButton, width: wid, layer: &self.gradientLayer), at: 0)
            case 3: // 同步完成
                self.mainButton.layer.insertSublayer(PublicClass().SetGradientLayer(button: self.mainButton, width: view_w, layer: &self.gradientLayer), at: 0)
            default:
                break
            }
        }
    }
    
    // MARK: 上传按钮方法
    @objc func MainButtonMethod(button: UIButton) {
        if ble.Manger.state != .poweredOn{
            SVProgressHUD.showInfo(withStatus: "蓝牙系统已关闭")
            return
        }
        if ble.Peripheral == nil || ble.Peripheral.state != .connected {
            let vc = BlueToothVC()
            self.present(vc, animated: true, completion: nil)
        }
        else if ble.Peripheral != nil && ble.Peripheral.state == .connected {
            print("button.tag = \(button.tag)")
            switch button.tag {
            case 1:
                // 同步数据
                SendCode().SendMessageNumberCode()
            case 2:
                // 正在同步
                print("正在同步数据...")
            default:
                break
            }
        }
    }
    
    // MARK: 遮挡主页的按钮方法
    @objc func HideButtonMethod(button: UIButton) {
        LeftButtonMethod(button: leftButton)
    }
    
    // MARK: 侧滑按钮方法
    @objc func LeftButtonMethod(button: UIButton) {
        button.isSelected = !button.isSelected
        // 展开
        if button.isSelected {
            MainViewShowAnimate()
        }
        // 收起
        else {
            MainViewHideAnimate()
        }
    }
    
    func MainViewHideAnimate() {
        UIView.animate(withDuration: 0.4, animations: {
            self.MAINVIEW.frame = self.view.frame
            self.hideButton.alpha = 0.0
        }) { (finish) in
            self.hideButton.isHidden = true
        }
    }
    
    func MainViewShowAnimate() {
        self.hideButton.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.MAINVIEW.frame = CGRect.init(x: ExpendedOffset, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.hideButton.alpha = 0.5
            self.hideButton.isHidden = false
        })
    }
    
    // MARK: 扫码按钮方法
    @objc func RightButtonMethod(button: UIButton) {
        
        
    }
    
    // MARK: 更新标题
    func RefreshTitleLabel() {
        titleLabel.text = ble.ExchangeMac
        if ble.Peripheral != nil && ble.Peripheral.state != .connected {
            mainButton.tag = 0
            self.SetMainButtonAttribute(index: 0, percent: 0)
        }
        else if ble.Peripheral != nil && ble.Peripheral.state == .connected {
            if mainButton.tag == 0 {
                mainButton.tag = 1
                self.SetMainButtonAttribute(index: 1, percent: 0)
            }
        }
        
        tableview.reloadData()
    }
    
    // MARK: BlueToothDelegate协议 数据数量
    func DidReceiveMessageCount(value: Int) {
        mainButton.tag = 2
        self.SetMainButtonAttribute(index: 2, percent: 0)
        // 开始同步数据
        SendCode().SendSynchronizationDataCode()
    }
    
    // MARK: 数据接收个数
    func DidReceiveMessageData(value: Int) {
        let percent : NSInteger = NSInteger(Double(ble.receiveCount) / Double(ble.messageCount) * 100)
        print("数据接收个数 = \(percent)")
        self.SetMainButtonAttribute(index: 2, percent: percent)
    }
    
    // MARK: 同步完成
    func DidReceiveMessageOver() {
        print("同步完成")
        self.mainButton.tag = 3
        self.SetMainButtonAttribute(index: 3, percent: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.0) {
            if self.ble.Peripheral != nil && self.ble.Peripheral.state == .connected {
                self.mainButton.tag = 1
                self.SetMainButtonAttribute(index: 1, percent: 0)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


