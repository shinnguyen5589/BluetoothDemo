//
//  ItemTableViewCell.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 8/30/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import UIKit

class ItemTableViewCell: BaseTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
}
