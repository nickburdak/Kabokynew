//
//  CardTVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 28/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class CardTVC: UITableViewCell {

    @IBOutlet weak var btnSetDefaultCard: UIButton!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblCardExpiry: UILabel!
    @IBOutlet weak var btnDeleteCard: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
