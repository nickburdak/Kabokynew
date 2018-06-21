//
//  ForgotPasswordVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 10/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
class ForgotPasswordVC: UIViewController, CountryCodes {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldCountryCode: UITextField!
    @IBOutlet weak var txtFieldPhoneNumber: UITextField!
    @IBOutlet weak var btnDone: SetCorner!
    var countryID = Int()
    //MARK: - CoountryCodes Delgate
    func countrySelected(_ country: Country) {
        txtFieldCountryCode.text! = country.countryCode
        countryID = country.countryID
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: - Actions
    @IBAction func actionChooseCountry(_ sender: UIButton) {
        IQKeyboardManager.sharedManager().resignFirstResponder()
        protocolCountry = self
        let countryVC = storyboard?.instantiateViewController(withIdentifier: "CountryCodeVC") as! CountryCodeVC
        self.present(countryVC, animated: true, completion: nil)
    }
    @IBAction func btnCancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnDoneAction(_ sender: AnyObject) {
        if txtFieldCountryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please select country code")
        } else if txtFieldPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter phone number")
        } else {
            forgotPassword()
        }
    }
    //MARK:-  API Interaction
    func forgotPassword() {
        let loginUrl = "\(KServerUrl)"+"\(KForgotPassword)"
        let param = [
            "User[contact_no]": txtFieldPhoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            "User[country_id]":"\(countryID)",
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
        if (JSON["url"]! as AnyObject).isEqual("\(KForgotPassword)")  {
            if (JSON["status"]! as AnyObject).isEqual(200) {
                proxy.sharedProxy().displayStatusCodeAlert("Password sent successfully")
                self.dismiss(animated: true, completion: nil)
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
