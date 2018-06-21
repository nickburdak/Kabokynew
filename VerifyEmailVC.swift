//
//  VerifyEmailVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 07/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class VerifyEmailVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblVerifyEmail: UILabel!
    @IBOutlet weak var txtFieldVerOne: UITextField!
    @IBOutlet weak var txtFieldVerTwo: UITextField!
    @IBOutlet weak var txtFieldVerThree: UITextField!
    @IBOutlet weak var txtFieldVerFour: UITextField!
    @IBOutlet weak var lblCodeNotReceived: UILabel!
    @IBOutlet weak var btnResendCode: UIButton!
    @IBOutlet weak var btnDone: SetCorner!
    var userID = Int()
    var email = String()
    var fromLogin = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldVerOne.delegate = self
        txtFieldVerTwo.delegate = self
        txtFieldVerThree.delegate = self
        txtFieldVerFour.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        let firstContentAttributes =  [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName : UIFont(name: "Times New Roman", size: 14.0)!
            ] as [String : Any]
        let description = NSMutableAttributedString(string: "Please enter verification code that was sent to ", attributes: firstContentAttributes)
        let secondContentAttributes =  [
            NSForegroundColorAttributeName: UIColor.red,
            NSFontAttributeName : UIFont(name: "Times New Roman", size: 14.0)!
            ] as [String : Any]
        let email = NSMutableAttributedString(string: self.email, attributes: secondContentAttributes)
        description.append(email)
        lblVerifyEmail.attributedText = description
        if fromLogin {
        }
    }
    //MARK:- TextFieldDelegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            if textField == txtFieldVerOne && (textField.text?.characters.count)! >= 1 {
                txtFieldVerTwo.becomeFirstResponder()
            }
            if textField == txtFieldVerTwo && (textField.text?.characters.count)! >= 1 {
                txtFieldVerThree.becomeFirstResponder()
            }
            if textField == txtFieldVerThree && (textField.text?.characters.count)! >= 1 {
                txtFieldVerFour.becomeFirstResponder()
            }
            if textField == txtFieldVerFour && (textField.text?.characters.count)! >= 1 {
                txtFieldVerFour.resignFirstResponder()
            }
        }
        return true
    }
    //MARK:- Actions
    @IBAction func actionBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionResendCode(_ sender: UIButton) {
        resendCode()
    }
    @IBAction func actionDone(_ sender: UIButton) {
        if txtFieldVerOne.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || txtFieldVerTwo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || txtFieldVerThree.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || txtFieldVerFour.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter the verification code")
        } else {
            verifyEmail()
        }
    }
    //MARK:-  API Interaction
    func verifyEmail() {
        let loginUrl = "\(KServerUrl)\(KVerifyEmail)?id=\(userID)"
        let otp = txtFieldVerOne.text! + txtFieldVerTwo.text! + txtFieldVerThree.text! + txtFieldVerFour.text!
        let param = [
            "User[otp]":"\(otp)",
        ]
       
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:nil)
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }else {
                                    proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
                            }
                        } else {
                            KAppDelegate.hideActivityIndicator()
                            proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    func resendCode() {
        let loginUrl = "\(KServerUrl)\(KResendCode)?id=\(userID)"
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(loginUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:nil)
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }else {
                                    proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: nil , response: response.response, data:response.data, error: response.result.error as NSError?)
                            }
                        } else {
                            KAppDelegate.hideActivityIndicator()
                            proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KVerifyEmail)")  {
            KAppDelegate.debugPrint(text: "Verify Email", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["detail"] != nil {
                    let details = JSON["detail"] as! NSDictionary
                    
                    var userID = Int()
                    var referralCode = String()
                    if details["id"] != nil {
                        userID = details["id"] as! Int
                    }
                    if details["referral_code"] != nil {
                        referralCode = details["referral_code"] as! String
                    }
                    proxy.sharedProxy().displayStatusCodeAlert("You are verifed successfully")
                    let paymentSelectionVC = storyboard?.instantiateViewController(withIdentifier: "PaymentSelectionVC") as! PaymentSelectionVC
                    paymentSelectionVC.userID = userID
                    self.navigationController?.pushViewController(paymentSelectionVC, animated: true)
                }
            }else{
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        } else if (JSON["url"]! as AnyObject).isEqual("\(KResendCode)")  {
            KAppDelegate.debugPrint(text: "Resend Code", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                proxy.sharedProxy().displayStatusCodeAlert("Verification code has been sent")
                txtFieldVerOne.text = ""
                txtFieldVerTwo.text = ""
                txtFieldVerThree.text = ""
                txtFieldVerFour.text = ""
            }
        }else{
            if let errorMessage = JSON["error"] {
                proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
