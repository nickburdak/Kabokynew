

//
//  InviteFriendsVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 29/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class InviteFriendsVC: UIViewController, handleDrawerNavigation {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblReferCode: UILabel!
    @IBOutlet weak var lblReferCodeValue: UILabel!
    @IBOutlet weak var lblYouEarn: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    var referralAmount = String()
    var referralCode = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        protocolDrawerNav = self
        getReferralDetails()
    }
    
    //MARK: - Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    @IBAction func actionShare(_ sender: UIButton) {
        let appLink = "https://www.google.com  "
        let shareText = "Download & register with Kaboky using the code \(referralCode). You'll get \(referralAmount) discount on your first ride"
        if UIDevice.current.userInterfaceIdiom == .pad {
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityVC.excludedActivityTypes = []
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = self.view.frame
            self.present(activityVC, animated: true, completion: nil)
        } else {
            let shareVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            self.present(shareVC, animated: true, completion: nil)
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
        if (self.revealViewController()) != nil   {
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil {
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    //MARK:- APIs
    func getReferralDetails() {
        let contentUrl = "\(KServerUrl)\(KGetReferralDetails)"
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
    //MARK: - Web Service delegate
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KGetReferralDetails)")  {
            KAppDelegate.debugPrint(text: "Referral response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["detail"] as? NSDictionary {
                    if let discount = detail["discount"] as? String {
                        lblDiscount.text = "\(discount)%"
                        referralAmount = "\(discount)%"
                    }
                    if let referCode = detail["refer_code"] as? String {
                        lblReferCodeValue.text = referCode
                        referralCode = referCode
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
        // Dispose of any resources that can be recreated.
    }
}
