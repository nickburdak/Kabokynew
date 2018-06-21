//
//  FavouritesTVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 25/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class FavouritesTVC: UITableViewCell {
    @IBOutlet weak var lblPickUpDisplay: UILabel!
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var lblDropOffDisplay: UILabel!
    @IBOutlet weak var lblDropOff: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
