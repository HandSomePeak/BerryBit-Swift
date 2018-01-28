//
//  LeftViewCell.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/5.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit

class LeftViewCell: UITableViewCell {

    var textLab : UILabel?
    var detailLab : UILabel?
    var imv : UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    func setUpUI() {
        
        textLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        textLab?.textColor = PublicClass.Color(RGB: 0x282828)
        textLab?.font = UIFont.init(name: "Helvetica", size: 15)
        self.addSubview(textLab!)
        
        imv = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        imv?.image = UIImage.init(named: "rightArrow")
        imv?.contentMode = UIViewContentMode.scaleAspectFit
        self.addSubview(imv!)
        
        detailLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        detailLab?.textColor = PublicClass.Color(RGB: 0x808080)
        detailLab?.font = UIFont.init(name: "Helvetica", size: 12)
        detailLab?.textAlignment = NSTextAlignment.right
        self.addSubview(detailLab!)
    }
 
    func ValueForCell(string: String, indexPath: IndexPath, cellHeight: CGFloat, cellWidth: CGFloat) {
        
        let cell_w = cellWidth
        let cell_h = cellHeight
        let imv_w = 40
        
        textLab?.text = string
        
        
        imv?.frame = CGRect.init(x: 0, y: 0, width: imv_w, height: Int(cell_h))
        imv?.sizeToFit()
        let imv_x = cell_w - (imv?.frame.size.width)!
        let imv_y = (cell_h - (imv?.frame.size.height)!) / 2.0
        imv?.frame = CGRect.init(x: imv_x, y: imv_y, width: (imv?.frame.size.width)!, height: (imv?.frame.size.height)!)
        
        textLab?.frame = CGRect.init(x: 0, y: 0, width: cell_w, height: cell_h)
        
        imv?.isHidden = false
        detailLab?.isHidden = true
        let ble = BlueTooth.shareInstance
        switch indexPath.row {
        case 1:
            if ble.Peripheral != nil && ble.Peripheral.state == .connected {
                detailLab?.text = "已连接"
            }
            else {
                detailLab?.text = "未连接"
            }
            detailLab?.frame = CGRect.init(x: 0, y: 0, width: (imv?.frame.origin.x)! - 5, height: cell_h)
            detailLab?.isHidden = false
        case 2:
            if ble.Peripheral != nil && ble.Peripheral.state == .connected {
                detailLab?.text = String(ble.Battery) + "%"
                if ble.Battery == 0 {
                    detailLab?.text = ""
                }
            }
            else {
                detailLab?.text = ""
            }
            imv?.isHidden = true
            detailLab?.isHidden = false
            detailLab?.frame = CGRect.init(x: 0, y: 0, width: cell_w - (imv?.frame.size.width)! / 2.0, height: cell_h)
        default: break
            
        }
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
