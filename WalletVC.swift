//
//  WalletVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 27/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class WalletVC: UIViewController,handleDrawerNavigation {

    @IBOutlet weak var lblWallet: UILabel!
    @IBOutlet weak var lblCurrentBalance: UILabel!
    @IBOutlet weak var imgViewLogo: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblRechargeMoney: UILabel!
    @IBOutlet weak var btnAdd50: SetCorner!
    @IBOutlet weak var btnAdd200: SetCorner!
    @IBOutlet weak var btnAdd500: SetCorner!
    @IBOutlet weak var txtFieldAmount: UITextField!
    @IBOutlet weak var txtFieldPromoCode: UITextField!
    @IBOutlet weak var viewEnterPromoCode: UIView!
    @IBOutlet weak var viewHavePromoCode: UIView!
    @IBOutlet weak var btnAddMoney: UIView!
    @IBOutlet weak var btnHavePromoCode: UIButton!
    var walletID = Int()
    var walletBalance = String()
    var currencySymbol = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        protocolDrawerNav = self
    }
    override func viewWillAppear(_ animated: Bool) {
        getWalletDetails()
    }
    //MARK: - Drawer Delegates
    func navigateToScreen(string: String) {
        if string == "Profile" {
            let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    func dismissDrawer() {
        if (self.revealViewController()) != nil  {
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil  {
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func showDetails() {
        lblCurrentBalance.text = walletBalance
        btnAdd50.setTitle("\(currencySymbol)50", for: .normal)
        btnAdd200.setTitle("\(currencySymbol)200", for: .normal)
        btnAdd500.setTitle("\(currencySymbol)500", for: .normal)
    }
    //MARK:-Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    @IBAction func actionPresetMoneyValue(_ sender: UIButton) {
        txtFieldAmount.text = ""
        switch sender {
        case btnAdd50:
            txtFieldAmount.text = "50"
        case btnAdd200:
            txtFieldAmount.text = "200"
        case btnAdd500:
            txtFieldAmount.text = "500"
        default:
            break
        }
    }
    
    @IBAction func actionAddMoney(_ sender: UIButton) {
        if txtFieldAmount.isBlank {
            proxy.sharedProxy().displayStatusCodeAlert("Please enter amount")
        } else {
            rechargeWallet()
        }
    }
    
    @IBAction func actionHavePromoCode(_ sender: UIButton) {
        viewEnterPromoCode.isHidden = false
        btnHavePromoCode.isHidden  = true
        self.view.showAnimations()
    }
    //MARK:-API Interaction
    func getWalletDetails() {
        let contentUrl = "\(KServerUrl)\(KGetWalletBalance)"
        let reachability = Reachability()
        if  (reachability?.isReachable)!    {
            KAppDelegate.showActivityIndicator()
            request(contentUrl, method: .get, parameters: nil, encoding: JSONEncoding.default,headers:["User-Agent":"\(userAgent)","auth_code":"\(proxy.sharedProxy().authNil())"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSON = response.result.value as? NSDictionary{
                                    self.serviceResponse(JSON .mutableCopy() as! NSMutableDictionary)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(contentUrl, parameter: nil, response: response.response, data: response.data as Data?, error: response.result.error as NSError?)
                                
                            }
                        } else {
                            KAppDelegate.hideActivityIndicator()
                            proxy.sharedProxy().openSettingApp()
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    func rechargeWallet() {
        let loginUrl = "\(KServerUrl)\(KRechargeWallet)?amount=\(txtFieldAmount.trimmedValue)"
            let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(loginUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)", "time_diff":TimeZone.current.abbreviation()!,"timezone":"\(TimeZone.current.identifier)"])
                
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
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: nil, response: response.response, data:response.data, error: response.result.error as NSError?)
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

    //MARK: - Web Service delegate
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KGetWalletBalance)")  {
            KAppDelegate.debugPrint(text: "Wallet Details", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["detail"] as? NSDictionary {
                    if let symbol = detail["currency_symbol"] as? String {
                        currencySymbol = symbol
                    }
                    if let amount = detail["amount"] as? String {
                        walletBalance = "\(currencySymbol)\(amount)"
                    }
                    if let id = detail["id"] as? Int {
                        walletID = id
                    }
                    showDetails()
                }
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
        if (JSON["url"]! as AnyObject).isEqual(KRechargeWallet)  {
            KAppDelegate.debugPrint(text: "Wallet Add", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                txtFieldAmount.text = ""
                txtFieldPromoCode.text = ""
                viewEnterPromoCode.isHidden = true
                btnHavePromoCode.isHidden  = false
                if let detail = JSON["detail"] as? NSDictionary {
                    if let symbol = detail["currency_symbol"] as? String {
                        currencySymbol = symbol
                    }
                    if let amount = detail["amount"] as? String {
                        lblCurrentBalance.text = "\(currencySymbol)\(amount)"
                    } else if let amount = detail["amount"] as? Int {
                        lblCurrentBalance.text = "\(currencySymbol)\(amount)"
                    }
                }
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
