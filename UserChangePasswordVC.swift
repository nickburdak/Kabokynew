//
//  UserChangePasswordVC.swift
//  Khit Thit
//
//  Created by Shivam Kheterpal on 28/12/16.
//  Copyright © 2016 Shivam Kheterpal. All rights reserved.
//

import UIKit
import Alamofire


class UserChangePasswordVC: UIViewController{
    @IBOutlet weak var txtfldCurrentPassword: UITextField!
    @IBOutlet weak var txtfldnewPasswoprd: UITextField!
    @IBOutlet weak var txtfldRetypePassword: UITextField!
    @IBOutlet weak var btnDone: SetCorner!
    @IBOutlet weak var lblChangePassword: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK:- Action
    
    @IBAction func btnCancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneAction(_ sender: AnyObject) {
        
        if txtfldCurrentPassword.text?.isEmpty == true {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter current password")
        }else if txtfldnewPasswoprd.text?.isEmpty == true {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter new password")
        }else if proxy.sharedProxy().isValidPassword(txtfldnewPasswoprd.text!) == false {
            proxy.sharedProxy().displayStatusCodeAlert("Password should have minimum 8 alphanumeric characters with at least one special character(Ex:- !@#$%&*_.)")
        }else if txtfldRetypePassword.text?.isEmpty == true {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter confirm password")
        }else if txtfldnewPasswoprd.text != txtfldRetypePassword.text {
            proxy.sharedProxy().displayStatusCodeAlert("Password doesn't match")
        }else{
            changePassword()
        }
    }
    
    //MARK:-  Api
    
    func changePassword() {
        let ForgetUrl = "\(KServerUrl)"+"\(KChangePassword)"
        let param = [
            "User[newPassword]":"\(txtfldnewPasswoprd.text!)",
            "User[confirm_password]":"\(txtfldRetypePassword.text!)",
            "User[oldPassword]":"\(txtfldCurrentPassword.text!)"
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            
            request(ForgetUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers: ["auth_code": "\(proxy.sharedProxy().authNil())","User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do
                    {
                        KAppDelegate.hideActivityIndicator()
                        if response.data != nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                var JSONDIC = NSMutableDictionary()
                                JSONDIC = (response.result.value as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                self.serviceResponse(JSONDIC)
                            } else {
                                proxy.sharedProxy().stautsHandler(ForgetUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
                            }
                        }else {
                            proxy.sharedProxy().displayStatusCodeAlert("Error")
                    }
                }
            }
        }
        else
        {
            KAppDelegate.hideActivityIndicator()
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    //MARK:- service response
    func serviceResponse(_ JSON:NSMutableDictionary) {
        print(JSON)
        if (JSON["url"]! as AnyObject).isEqual("\(KChangePassword)") {
            if (JSON["status"]! as AnyObject).isEqual(200) {
                proxy.sharedProxy().displayStatusCodeAlert("Password changed successfully")
                self.dismiss(animated: true, completion: nil)
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }else{
                    proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
