//
//  WelcomeVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 06/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var btnSignIn: SetCorner!
    @IBOutlet weak var btnRegister: SetCorner!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK:- Actions
    @IBAction func actionSignIn(_ sender: UIButton) {
        let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(signInVC, animated: true)
    }
    @IBAction func actionRegister(_ sender: UIButton) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
