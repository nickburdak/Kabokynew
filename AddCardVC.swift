//
//  ViewController.swift
//  kaboky
//
//  Created by Himanshu Singla on 28/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import FormTextField
import Formatter
import InputValidator
import Validation
import Alamofire
class AddCardVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnOnOff: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldCardNo: UITextField!
    @IBOutlet weak var txtFieldExpiry: FormTextField!
    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var btnSave: SetCorner!
    
    var btnSelected = 0
    var selectValue = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldCardNo.delegate = self
        txtFieldExpiry.inputType = .Integer
        txtFieldExpiry.formatter = CardExpirationDateFormatter()
        var validation = Validation()
        validation.required = true
        let inputValidator = CardExpirationDateInputValidator(validation: validation)
        txtFieldExpiry.inputValidator = inputValidator
        btnOnOff.setImage(#imageLiteral(resourceName: "ic_default_on"), for: .normal)
    }
    
    //MARK:- Actions
    @IBAction func actionBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnActionOnOff(_ sender: Any) {
        if btnSelected == 0 {
        if  btnOnOff.currentImage == UIImage(named:"ic_default_on") {
            //btnOnOff.setImage(#imageLiteral(resourceName: "ic_default_on"), for: .normal)
            btnOnOff.setImage(#imageLiteral(resourceName: "ic_default_off"), for: .normal)
            btnSelected = btnSelected + 1
            selectValue = 0
         }
        }else if btnSelected == 1 {
           // btnOnOff.setImage(#imageLiteral(resourceName: "ic_default_off"), for: .normal)
            btnOnOff.setImage(#imageLiteral(resourceName: "ic_default_on"), for: .normal)
            btnSelected = 0
            selectValue = 1
       }
    }
    
    
    
    @IBAction func actionSaveCard(_ sender: Any) {
        if txtFieldName.isBlank {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter name")
        } else if txtFieldCardNo.isBlank {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter card number")
        } else if txtFieldCardNo.trimmedValue.characters.count != 16 {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter valid card number")
        } else if txtFieldExpiry.isBlank {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter expiry date")
        } else if !proxy.sharedProxy().isValidCardExpiryDate(txtFieldExpiry.trimmedValue) {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter valid expiry date")
        } else {
            saveCard()
        }
    }
    //MARK:-TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if (txtFieldCardNo.text?.characters.count)! >= 16 {
            return false
        }
        return true
    }
    func saveCard() {
        let cardExpiryDetails = txtFieldExpiry.trimmedValue.components(separatedBy: "/")
        let loginUrl = "\(KServerUrl)\(KAddCard)"
        let param = [
            "CardDetail[full_name]":"\(txtFieldName.trimmedValue)",
            "CardDetail[number]":"\(txtFieldCardNo.trimmedValue)",
            "CardDetail[expiry_month]": "\(cardExpiryDetails.first!)",
            "CardDetail[expiry_year]": "\(cardExpiryDetails.last!)",
            "CardDetail[type_id]": "\(selectValue)"
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)", "time_diff":TimeZone.current.abbreviation()!,"timezone":"\(TimeZone.current.identifier)"])
                
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000 {
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
        if (JSON["url"]! as AnyObject).isEqual("\(KAddCard)")  {
            KAppDelegate.debugPrint(text: "Add Card", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
               proxy.sharedProxy().displayStatusCodeAlert("Card has been saved")
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                if let errorMessage = JSON["error"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage)
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  }
