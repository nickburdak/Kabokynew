//
//  PaymentOptionsVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 27/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class PaymentOptionsVC: UIViewController,handleDrawerNavigation {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCreditCard: UIButton!
    @IBOutlet weak var lblCreditCard: UILabel!
    @IBOutlet weak var btnCash: UIButton!
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var lblWallet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        protocolDrawerNav = self
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
           setPayTypeSelections()
    }
    
    func setPayTypeSelections() {
        btnCreditCard.isSelected = false
        btnCash.isSelected = false
        btnWallet.isSelected = false
        switch profile.payType {
        case 0:
            btnCreditCard.isSelected = true
        case 1:
            btnCash.isSelected = true
        case 2:
            btnWallet.isSelected = true
        default:
            break
        }
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
        if (self.revealViewController()) != nil {
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //MARK:- Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    @IBAction func actionCardDetails(_ sender: UIButton) {
        let cardDetailsVC = storyboard?.instantiateViewController(withIdentifier: "CardsListVC") as! CardsListVC
        _ = self.navigationController?.pushViewController(cardDetailsVC, animated: true)
    }
    @IBAction func actionChoosePayType(_ sender: UIButton) {
        switch sender {
        case btnCreditCard:
            changePayType(0)
        case btnCash:
            changePayType(1)
        case btnWallet:
            changePayType(2)
        default :
            break
        }
    }
    
    //MARK:-API Interaction
    func changePayType(_ payType: Int) {
        let contentUrl = "\(KServerUrl)\(KChangePaytype)?pay_type=\(payType)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
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
    //MARK: - Web Service delegate
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KChangePaytype)")  {
            KAppDelegate.debugPrint(text: "Change PayType response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let payTypeSelection = JSON["pay_type"] as? String {
                    profile.payType = Int(payTypeSelection)!
                    setPayTypeSelections()
                } else if let payTypeSelection = JSON["pay_type"] as? Int {
                    profile.payType = payTypeSelection
                    setPayTypeSelections()
                }
                proxy.sharedProxy().displayStatusCodeAlert("Payment method set successfully")
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
