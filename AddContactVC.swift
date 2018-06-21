//
//  AddContactVC.swift
//  kaboky
//
//  Created by Jaspreet Bhatia on 24/11/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire

class AddContactVC: UIViewController,CountryCodes {
    
    @IBOutlet weak var txtFldCountryCode: UITextField!
    
   
    @IBOutlet weak var txtFldPhoneNo: UITextField!
    @IBOutlet weak var txtFldName: UITextField!
    
    //MARK: - CoountryCodes Delgate
    var countryID = Int()
    var arryContactNumber = [GetContactModel]()
    func countrySelected(_ country: Country) {
        txtFldCountryCode.text! = country.countryCode
        countryID = country.countryID
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
    }
    
       @IBAction func btnCountryCodeAction(_ sender: Any) {
        
        IQKeyboardManager.sharedManager().resignFirstResponder()
        protocolCountry = self
        let countryVC = storyboard?.instantiateViewController(withIdentifier: "CountryCodeVC") as! CountryCodeVC
        self.present(countryVC, animated: true, completion: nil)

        
    }
    @IBAction func btnCanncelAction(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnActionDone(_ sender: Any) {
      
            if txtFldName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                proxy.sharedProxy().displayStatusCodeAlert("Please enter name")
            }
            else if  txtFldCountryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please select country code")
                 
          } else if txtFldPhoneNo.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter phone number")
         } else {
                addContact()
                
         
        }
    }
    
    
    
    //Mark: - AddContact Api
    func addContact() {
        let loginUrl = "\(KServerUrl)\(KAddContact)"
       
        let param = [
          "EmergencyContact[title]":"\(String(describing: txtFldName.text!))",
           " EmergencyContact[mobile]":"\(String(describing: txtFldPhoneNo.text!))",
            "EmergencyContact[country_id]":"\(String(describing: countryID))"
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
    
    
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KAddContact)") {
            KAppDelegate.debugPrint(text: "Login", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("ReloadData"), object: nil)
                })
               
            } else{
                    if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
    }
}

