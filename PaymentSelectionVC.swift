//
//  PaymentSelectionVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 07/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class PaymentSelectionVC: UIViewController {
    
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var lblPayCash: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReferralCode: UILabel!
    @IBOutlet weak var btnCreditCard: UIButton!
    @IBOutlet weak var btnCash: UIButton!
    @IBOutlet weak var btnWallet: UIButton!
    var userID = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    //MARK:- Actions
    @IBAction func actionCreditCard(_ sender: Any) {
        defaultPayType(0)
    }
    @IBAction func actionCash(_ sender: Any) {
        defaultPayType(1)
    }
    @IBAction func actionWallet(_ sender: UIButton) {
            defaultPayType(2)
      
    }
    @IBAction func actionBack(_ sender: UIButton) {
        let sigInVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.navigationController?.pushViewController(sigInVC, animated: false)    }
    
    //MARK:-  API Interaction
    func defaultPayType(_ payType: Int) {
        var deviceToken = String()
        if UserDefaults.standard.object(forKey: "device_token") == nil {
            deviceToken = "156116515615646411"
        } else {
            deviceToken = UserDefaults.standard.object(forKey: "device_token")! as! String
        }
        let loginUrl = "\(KServerUrl)\(KDefaultPayType)?id=\(userID)"
        let param = [
            "User[pay_type]":"\(payType)",
            "User[device_type]":"2",
            "User[device_token]":"\(deviceToken)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KDefaultPayType)") {
            KAppDelegate.debugPrint(text: "PayType", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["auth_code"] != nil {
                    let authcode = JSON["auth_code"] as! String
                    UserDefaults.standard.set(authcode, forKey: "auth_code")
                    UserDefaults.standard.synchronize()
                }
                if JSON["detail"] != nil  {
                    let detail = JSON["detail"] as! NSDictionary
                    if detail["id"] != nil {
                        profile.id = detail["id"] as! Int
                    }
                    if detail["contact_no"] != nil {
                        profile.contactNumber = detail["contact_no"] as! String
                    }
                    if detail["email"] != nil {
                        profile.email = detail["email"] as! String
                    }
                    if detail["first_name"] != nil {
                        profile.firstName = detail["first_name"] as! String
                    }
                    if detail["last_name"] != nil {
                        profile.lastName = detail["last_name"] as! String
                    }
                    if detail["image_file"] != nil {
                        profile.imageFile = detail["image_file"] as! String
                    }
                    if detail["image_file"] != nil {
                        profile.imageFile = detail["image_file"] as! String
                    }
                    if detail["referral_code"] != nil {
                        profile.referralCode = detail["referral_code"] as! String
                    }
                    if detail["pay_type"] != nil {
                        profile.payType = detail["pay_type"] as! Int
                    }
                    if detail["is_verify"] != nil {
                        profile.isVerified = detail["is_verify"] as! Int
                    }
                    if detail["telephone_code"] != nil {
                        profile.countryCode = detail["telephone_code"] as! String
                    }
                    if let countryID = detail["country"] as? String {
                        profile.countryID = Int(detail["country"] as! String)!
                    } else if let countryID =  detail["country"] as? Int {
                        profile.countryID = countryID
                    }

                    KAppDelegate.gotoHomeVC()
                }
            } else{
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
