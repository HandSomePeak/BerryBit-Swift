//
//  DevicesCell.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/18.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

@objc protocol DevicesCellDelegate {
    
    @objc optional func DidSelectedBunding(button: UIButton)
    
}

class DevicesCell: UITableViewCell {

    var delegate: DevicesCellDelegate!
    
    var photo : UIImageView!
    var label_1 : UILabel!
    var label_2 : UILabel!
    var button : UIButton!
    var line : UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    func setUpUI() {
        photo = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        photo.image = UIImage.init(named: "device")
        photo.contentMode = .scaleAspectFit
        self.addSubview(photo)
        
        label_1 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        label_1.textColor = PublicClass.Color(RGB: 0x000000)
        label_1.font = UIFont.init(name: "Helvetica", size: 15)
        self.addSubview(label_1)
        
        label_2 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        label_2.textColor = PublicClass.Color(RGB: 0x808080)
        label_2.font = UIFont.init(name: "Helvetica", size: 12)
        self.addSubview(label_2)
        
        button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        button.setTitle("连接并绑定", for: .normal)
        button.setTitleColor(PublicClass.Color(RGB: 0x42A7CE), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.layer.borderWidth = 0.6
        button.layer.borderColor = PublicClass.Color(RGB: 0x42A7CE).cgColor
        button.titleLabel?.font = UIFont.init(name: "Helvetica", size: 13)
        button.addTarget(self, action: #selector(ButtonMethod(button:)), for: .touchUpInside)
        self.addSubview(button)
        
    }
    
    func setFrameAndModel(model: PeripheralModel, tableview: UITableView, indexPath: IndexPath) {
        
        let view_w = tableview.frame.size.width;
        let cell_h = PublicClass.HeightWith(height: 60)
        let left = PublicClass.WidthWith(width: 26)
        let right = PublicClass.WidthWith(width: 26)
        let gap = PublicClass.WidthWith(width: 13)
        let imv_w = PublicClass.HeightWith(height: 35)
        let lab_top = PublicClass.HeightWith(height: 14)
        let lab_h = PublicClass.HeightWith(height: 17)
        let lab_h_2 = PublicClass.HeightWith(height: 14)
        let bu_w = PublicClass.WidthWith(width: 89)
        let bu_h = PublicClass.HeightWith(height: 28)
        
        tableview.rowHeight = cell_h
        
        photo.frame = CGRect.init(x: left, y: (cell_h - imv_w) / 2.0, width: imv_w, height: imv_w)
        
        button.frame = CGRect.init(x: view_w - bu_w - right, y: (cell_h - bu_h) / 2.0, width: bu_w, height: bu_h)
        
        let name_x = photo.frame.maxX + gap
        let nameRect = CGRect.init(x: name_x, y: lab_top, width: button.frame.origin.x - name_x, height: lab_h)
        
        label_1.frame = nameRect
        label_2.frame = CGRect.init(x: name_x, y: label_1.frame.maxY + PublicClass.HeightWith(height: 5), width: button.frame.origin.x - name_x, height: lab_h_2)
        
        label_1.text = "睛灵果果"
        button.tag = indexPath.row
        label_2.text = "MAC:  " + PublicClass().AdcDataToMacStr(AdvData: model.Data)
        
    }
    
    @objc func ButtonMethod(button: UIButton) {
        print("选择设备")
        delegate?.DidSelectedBunding!(button: button)
    }
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
