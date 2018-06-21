//
//  SignUpVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 07/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
class SignUpVC: UIViewController, CountryCodes {

    @IBOutlet weak var txtFieldFName: UITextField!
    @IBOutlet weak var txtFieldLName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldCountryCode: UITextField!
    @IBOutlet weak var txtFieldPhoneNo: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var txtFieldReferralCode: UITextField!
    @IBOutlet weak var btnRegister: SetCorner!
    var countryID = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK: - CoountryCodes Delgate
    func countrySelected(_ country: Country) {
        txtFieldCountryCode.text! = country.countryCode
        countryID = country.countryID
    }

    //MARK:- Actions
    @IBAction func actionBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionRegister(_ sender: UIButton) {
        if txtFieldFName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter first name")
        } else if txtFieldLName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""  {
             proxy.sharedProxy().displayStatusCodeAlert("Please enter last name")
        } else if txtFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""  {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter email")
        } else  if !proxy.sharedProxy().isValidEmail(txtFieldEmail.trimmedValue) {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter valid email")
        } else  if txtFieldCountryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please select country code")
        } else if txtFieldPhoneNo.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter phone number")
        } else if txtFieldPassword.text! == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter password")
        }  else  if proxy.sharedProxy().isValidPassword(txtFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)) == false {
            proxy.sharedProxy().displayStatusCodeAlert("Password should have minimum 8 alphanumeric characters with at least one special character(Ex:- !@#$%&*_.)")
        } else if txtFieldConfirmPassword.text! == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter confirm password")
        } else if txtFieldPassword.text != txtFieldConfirmPassword.text {
            proxy.sharedProxy().displayStatusCodeAlert("Password do not match")
        } else {
            signUpMethod()
        }
    }
    @IBAction func actionChooseCountry(_ sender: UIButton) {
        IQKeyboardManager.sharedManager().resignFirstResponder()
        protocolCountry = self
        let countryVC = storyboard?.instantiateViewController(withIdentifier: "CountryCodeVC") as! CountryCodeVC
        self.present(countryVC, animated: true, completion: nil)
    }
    
    //MARK:-  API Interaction
    func signUpMethod() {
        let loginUrl = "\(KServerUrl)"+"\(KSignUp)"
            let param = [
            "User[first_name]":"\(txtFieldFName.text!.trimmingCharacters(in: .whitespacesAndNewlines))",
            "User[last_name]":"\(txtFieldLName.text!.trimmingCharacters(in: .whitespacesAndNewlines))",
            "User[email]":"\(txtFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines))",
            "User[password]": "\(txtFieldPassword.text!)",
            "User[confirm_password]":"\(txtFieldConfirmPassword.text!)",
            "User[contact_no]": txtFieldPhoneNo.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            "User[country_id]":"\(countryID)",
            "User[refer_code]":"\(txtFieldReferralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines))"
                
        ]
        let reachable = Reachability()
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
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KSignUp)") {
            
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["detail"] != nil {
                    let details = JSON["detail"] as! NSDictionary
                    var email = String()
                    var userID = Int()
                    if details["id"] != nil {
                        userID = details["id"] as! Int
                    }
                    if details["email"] != nil {
                        email = details["email"] as! String
                    }
                    proxy.sharedProxy().displayStatusCodeAlert("You have successfully registered")
                    let verifyEmailVC = storyboard?.instantiateViewController(withIdentifier: "VerifyEmailVC") as! VerifyEmailVC
                    verifyEmailVC.email = email
                    verifyEmailVC.userID = userID
                    self.navigationController?.pushViewController(verifyEmailVC, animated: true)
                }
            }else{
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
    }
    
 override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
