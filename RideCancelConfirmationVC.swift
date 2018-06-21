//
//  RideCancelConfirmationVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 14/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class RideCancelConfirmationVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: - Actions
    @IBAction func actionOk(_ sender: UIButton) {
        self.dismiss(animated: true) { 
            protocolCancelConfirmation?.confirmedCancellation()
        }
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
