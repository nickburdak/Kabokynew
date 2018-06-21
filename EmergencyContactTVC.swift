//
//  EmergencyContactTVC.swift
//  kaboky
//
//  Created by Jaspreet Bhatia on 24/11/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class EmergencyContactTVC: UITableViewCell {

    @IBOutlet weak var lblContactNumber: UILabel!
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var btnCallContact: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
