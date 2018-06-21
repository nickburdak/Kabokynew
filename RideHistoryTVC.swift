//
//  RideHistoryTVC.swift
//  KabokyDriver
//
//  Created by Gaurav Tiwari on 18/04/17.
//  Copyright © 2017 Toxsl technologies. All rights reserved.
//

import UIKit

class RideHistoryTVC: UITableViewCell {
    
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverNameValue: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblPickupLoc: UILabel!
    @IBOutlet weak var lblPickupLocValue: UILabel!
    
    @IBOutlet weak var lblDropOffLoc: UILabel!
    @IBOutlet weak var lblDropOffLocValue: UILabel!
    
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var txtFldDateTimeValue: UITextField!
    @IBOutlet weak var btnBookAgain: SetCorner!
    @IBOutlet weak var viewBookAgain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
