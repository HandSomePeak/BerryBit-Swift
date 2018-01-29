//
//  DataBaseVC.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/29.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

class DataBaseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var table = UITableView()
    var m_array = Array<Measure>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidAppear")
        
        self.CreateTableView()
        
        self.SetMutableArray()
    }
    
    func SetMutableArray() {
        DispatchQueue.global().async {
            self.m_array = CoreDataHelper.shareInstance.selectDataFromCoreData()
            DispatchQueue.main.async {
                self.table.reloadData()
            }
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
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        let model = m_array[indexPath.row]
        let date : Date = Date.init(timeIntervalSince1970: Double(model.time!)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: date)
        let string = "\(dateStr), type = \(model.type!), data = \(model.data!)"
        cell.textLabel?.text = string
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func DidSelectedBunding(button: UIButton) {
        
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
