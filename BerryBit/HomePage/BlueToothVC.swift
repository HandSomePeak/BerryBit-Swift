//
//  BlueToothVC.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/18.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit
import SVProgressHUD

class BlueToothVC: UIViewController, UITableViewDelegate, UITableViewDataSource, BlueToothDelegate, DevicesCellDelegate {

    let ble = BlueTooth.shareInstance
    var table = UITableView()
    var m_array : Array<PeripheralModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("蓝牙扫描界面")
        self.CreateTableView()
        
        ble.scanDevicesFunc()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ble.delegate = self
    }
    
    // MARK: BlueToothDelegate
    // 发现外围设备
    func DiscoverPeripheral(device: PeripheralModel) {
        if !m_array.contains(device) {
            m_array.append(device)
            table.reloadData()
        }
    }
    
    // 手环连接状态
    func DidConnectedState(state: Bool) {
        if state {
            print("手环已连接")
            // 对手环进行时间同步
            SendCode().SendSynchronizationTimeCode()
            // 获取手环设备的信息（硬件版本号、软件版本号）
            SendCode().SendMatchMessageCode()
            SVProgressHUD.showSuccess(withStatus: "连接手环成功")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        else {
            print("手环未连接")
        }
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
        let cell = DevicesCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: indetifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        let model = m_array[indexPath.row]
        cell.setFrameAndModel(model: model, tableview: tableView, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func DidSelectedBunding(button: UIButton) {
        let model = m_array[button.tag]
        
        ble.connectedPeripheral(peripheral: model.peripheral, data: model.Data)
        
        PublicClass.SetSVProgressHUD()
        SVProgressHUD.show()
    }
    
    func CreateTableView() {
        
        let view_w = self.view.frame.size.width
        let view_h = self.view.frame.size.height
        let bottom = PublicClass.HeightWith(height: 43)
        let bu_w : CGFloat = PublicClass.WidthWith(width: 100)
        let bu_h : CGFloat = PublicClass.WidthWith(width: 40)
        let tab_h : CGFloat = view_h - 64 - bottom - bu_h
        
        self.view.backgroundColor = UIColor.white
        
        self.table.frame = CGRect.init(x: 0, y: 64, width: view_w, height: tab_h)
        self.table.delegate = self
        self.table.dataSource = self
        self.table.separatorStyle = .none
        self.table.bounces = false
        self.view.addSubview(self.table)
        
        
        let button = UIButton.init(frame: CGRect.init(x: (view_w - bu_w) / 2.0, y: self.table.frame.maxY, width: bu_w, height: bu_h))
        button.setTitle("取消", for: .normal)
        button.setTitleColor(PublicClass.Color(RGB: 0x808080), for: .normal)
        button.titleLabel?.font = UIFont.init(name: "Helvetica", size: 15)
        button.addTarget(self, action: #selector(CancelButtonMethod(button:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func CancelButtonMethod(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
