//
//  PlaceTVC.swift
//  NVOII
//
//  Created by Himanshu Singla on 09/02/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class PlaceTVC: UITableViewCell {

    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
