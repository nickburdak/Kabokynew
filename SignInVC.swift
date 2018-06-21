//
//  SignInVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 06/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
class SignInVC: UIViewController, CountryCodes {

    @IBOutlet weak var txtFieldCountryCode: UITextField!
    @IBOutlet weak var txtFieldPhoneNumber: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var lblFacebookLogin: UILabel!
    @IBOutlet weak var btnSignIn: SetCorner!
    @IBOutlet weak var lblLoginVia: UILabel!
     var countryID = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    //MARK: - CoountryCodes Delgate
    func countrySelected(_ country: Country) {
        txtFieldCountryCode.text! = country.countryCode
        countryID = country.countryID
    }

    //MARK:- Actions
    @IBAction func actionFacebookLogin(_ sender: UIButton) {
    }
    @IBAction func actionBack(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: WelcomeVC.self ) {
                self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                return
            }
        }
        let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
        self.navigationController?.pushViewController(welcomeVC, animated: false)
    }
    @IBAction func actionChooseCountry(_ sender: UIButton) {
        IQKeyboardManager.sharedManager().resignFirstResponder()
        protocolCountry = self
        let countryVC = storyboard?.instantiateViewController(withIdentifier: "CountryCodeVC") as! CountryCodeVC
        self.present(countryVC, animated: true, completion: nil)

    }
    @IBAction func actionSignIn(_ sender: UIButton) {
        if txtFieldCountryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please select country code")
        } else if txtFieldPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter phone number")
        } else if txtFieldPassword.text! == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter password")
        } else {
            loginMethod()
        }
    }
    @IBAction func actionForgotPassword(_ sender: UIButton) {
        let forgotPasswordVC = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
         self.present(forgotPasswordVC, animated: true, completion: nil)
    }
    
    //MARK:-  API Interaction
    func loginMethod() {
        var deviceToken = String()
        if UserDefaults.standard.object(forKey: "device_token") == nil {
            deviceToken = "156116515615456646411"
        } else {
            deviceToken = UserDefaults.standard.object(forKey: "device_token")! as! String
        }
        let loginUrl = "\(KServerUrl)\(KLogin)"
        let param = [
            "LoginForm[username]":"\(txtFieldPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines))",
            "LoginForm[password]":"\(txtFieldPassword.text!)",
            "LoginForm[device_type]":"2",
            "LoginForm[device_token]":"\(deviceToken)",
            "LoginForm[country_id]":"\(countryID)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KLogin)") {
            KAppDelegate.debugPrint(text: "Login", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["auth_code"] != nil {
                    let authcode = JSON["auth_code"] as! String
                    UserDefaults.standard.set(authcode, forKey: "auth_code")
                    UserDefaults.standard.synchronize()
                }
                if JSON["detail"] != nil  {
                    let detail = JSON["detail"] as! NSDictionary
                    KAppDelegate.handleCheckResponse(JSON)
                }
            } else{
                if JSON["detail"] != nil  {
                    var userID = Int()
                    var email = String()
                    var referralCode = String()
                    var payType = Int()
                    var isVerified = Int()
                    let detail = JSON["detail"] as! NSDictionary
                    if detail["id"] != nil {
                        userID = detail["id"] as! Int
                    }
                    if detail["email"] != nil {
                       email = detail["email"] as! String
                    }
                    if detail["referral_code"] != nil {
                        referralCode = detail["referral_code"] as! String
                    }
                    if detail["pay_type"] != nil {
                        payType = detail["pay_type"] as! Int
                    }
                    if detail["is_verify"] != nil {
                        isVerified = detail["is_verify"] as! Int
                    }
                    if isVerified == 0 {
                        let verifyEmailVC = storyboard?.instantiateViewController(withIdentifier: "VerifyEmailVC") as! VerifyEmailVC
                        verifyEmailVC.email = email
                        verifyEmailVC.userID = userID
                        verifyEmailVC.fromLogin = true
                        self.navigationController?.pushViewController(verifyEmailVC, animated: true)
                    } else if payType == 10 {
                        let paymentSelectionVC = storyboard?.instantiateViewController(withIdentifier: "PaymentSelectionVC") as! PaymentSelectionVC
                        paymentSelectionVC.userID = userID
                        self.navigationController?.pushViewController(paymentSelectionVC, animated: true)
                    }

                }
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
