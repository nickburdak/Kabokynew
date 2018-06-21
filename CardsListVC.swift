//
//  CardsListVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 28/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class CardsListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblViewCardList: UITableView!
    var arrCardList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        cardList()
    }
    //MARK:- Actions
    @IBAction func actionBack(_ sender: UIButton) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionDeleteCard(_ sender: UIButton) {
           let creditcardDetails = arrCardList[sender.tag] as! CreditCardDetails
        deleteCard(creditcardDetails.id)
    }
    @IBAction func actionSetDefaultCard(_ sender: UIButton) {
        let creditcardDetails = arrCardList[sender.tag] as! CreditCardDetails
        markDefault(creditcardDetails.id)
    }
    @IBAction func actionAddCard(_ sender: UIButton) {
        let addCardVC = storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as! AddCardVC
        self.navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    
    //MARK:- TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCardList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTVC", for: indexPath) as! CardTVC
        let creditcardDetails = arrCardList[indexPath.section] as! CreditCardDetails
        cell.lblCardExpiry.text = "\(creditcardDetails.expiryMonth) / \(creditcardDetails.expiryYear)"
        cell.btnDeleteCard.tag = indexPath.section
        cell.btnSetDefaultCard.tag = indexPath.section
        cell.lblCardNo.text = returnMaskedNumber(creditcardDetails.cardNumber)
        if creditcardDetails.isDefault == 1 {
            cell.btnSetDefaultCard.setImage(#imageLiteral(resourceName: "ic_check_radio_bt"), for: .normal)
        } else {
            cell.btnSetDefaultCard.setImage(#imageLiteral(resourceName: "ic_radio_bt"), for: .normal)
        }
        return cell
    }
    
    
    
    func returnMaskedNumber(_ input: String) -> String {
        if input.characters.count >= 4 {
            let last4 = String(input.characters.suffix(4))
            let maskedCard = "xxxx xxxx xxxx " + last4
            return maskedCard
        }
        return ""
    }
    
    //MARK:- APIs
    func cardList() {
        let contentUrl = "\(KServerUrl)\(KCardList)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
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
    func markDefault(_ id: Int) {
        let contentUrl = "\(KServerUrl)\(KMarkDefaultCard)?id=\(id)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
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
    func deleteCard(_ id: Int) {
        let contentUrl = "\(KServerUrl)\(KDeleteCard)?id=\(id)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
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
        if (JSON["url"]! as AnyObject).isEqual("\(KCardList)")  {
            arrCardList.removeAllObjects()
            KAppDelegate.debugPrint(text: "Card list response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["list"] != nil {
                    let listArr = JSON["list"] as! NSArray
                    for index in 0..<listArr.count {
                        let creditCardDetails = CreditCardDetails()
                        let cardDict = listArr[index] as! NSDictionary
                        if let customerID = cardDict["customer_id"] as? String {
                            creditCardDetails.customerID = customerID
                        }
                        if let expiryMonth = cardDict["expiry_month"] as? String {
                            creditCardDetails.expiryMonth = expiryMonth
                        }
                        if let expiryYear = cardDict["expiry_year"] as? String {
                            creditCardDetails.expiryYear = expiryYear
                        }
                        if let number = cardDict["number"] as? String {
                            creditCardDetails.cardNumber = number
                        }
                        if let full_name = cardDict["full_name"] as? String {
                            creditCardDetails.fullName = full_name
                        }
                        if let typeID = cardDict["type_id"] as? Int {
                            creditCardDetails.isDefault = typeID
                        }
                        if let id = cardDict["id"] as? Int {
                            creditCardDetails.id = id
                        }
                        arrCardList.add(creditCardDetails)
                    }
                }
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
            tblViewCardList.dataSource = self
            tblViewCardList.delegate = self
            tblViewCardList.reloadData()
        } else  if (JSON["url"]! as AnyObject).isEqual("\(KMarkDefaultCard)")  {
            KAppDelegate.debugPrint(text: "Card list response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let success = JSON["success"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(success)
                }
                cardList()
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }  else  if (JSON["url"]! as AnyObject).isEqual("\(KDeleteCard)")  {
            KAppDelegate.debugPrint(text: "Card list response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let success = JSON["success"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(success)
                }
                cardList()
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
