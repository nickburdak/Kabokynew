//
//  EmergencyContactVC.swift
//  kaboky
//
//  Created by Jaspreet Bhatia on 24/11/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire

class EmergencyContactVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tblVwEmergencyContact: UITableView!
    
    var arryContactNumber = [GetContactModel]()
 

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handelNotification(_:)), name: NSNotification.Name("ReloadData"), object: nil)


        // Do any additional setup after loading the view.
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
          getAddContact()
        
    }
    func handelNotification(_ notification: Notification)
    {
        getAddContact()
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
  

    @IBAction func BtnActionAddContact(_ sender: Any) {
        let addContactVC = storyboard?.instantiateViewController(withIdentifier: "AddContactVC") as! AddContactVC
        self.navigationController?.present(addContactVC, animated: true, completion: nil)

    }
    
        @IBAction func btnActionCall(_ sender: UIButton) {
            proxy.sharedProxy().makeCall(arryContactNumber[sender.tag].UserContactNumber)
    }
    
    //MARK:- TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arryContactNumber.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmergencyContactTVC") as! EmergencyContactTVC
        cell.lblContactName.text = arryContactNumber[indexPath.row].userContactName
        cell.lblContactNumber.text = arryContactNumber[indexPath.row].UserContactNumber
        cell.btnCallContact.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
   
    // Mark: - GetAddContact Api
    func getAddContact() {
    
        arryContactNumber = []
        let contentUrl = "\(KServerUrl)\(KgetContact)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
            KAppDelegate.showActivityIndicator()
            request(contentUrl, method: .get, parameters: nil, encoding: JSONEncoding.default,headers:["User-Agent":"\(userAgent)"])
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
        if (JSON["url"]! as AnyObject).isEqual("\(KgetContact)")  {
            if (JSON["status"]! as AnyObject).isEqual(200) {
                let countryArr = JSON["list"] as! NSArray
                for i in 0..<countryArr.count {
                    let contactNumber = GetContactModel()
                    let dict = countryArr[i] as! NSDictionary
                    contactNumber.userContactName = dict["title"] as! String
                    contactNumber.UserContactNumber = dict["mobile"] as! String
                    arryContactNumber.append(contactNumber)
                }
                KAppDelegate.hideActivityIndicator()
                tblVwEmergencyContact.delegate = self
                tblVwEmergencyContact.dataSource = self
                tblVwEmergencyContact.reloadData()
               
            } else {
                KAppDelegate.hideActivityIndicator()
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
        }
     }
  }
}
