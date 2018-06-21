
//
//  JustificationVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 14/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class JustificationVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var tblViewJustification: UITableView!
    var ride = Ride()
    var justificationArr = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        getJustificationList()
    }
    //MARK: - Actions
    @IBAction func actionOk(_ sender: UIButton) {
        let arrSelected = justificationArr.filter {
            ($0 as! Justification).isSelected
            }.map {
                "\(($0 as! Justification).id)"
        }
        if arrSelected.count == 0 {
            proxy.sharedProxy().displayStatusCodeAlert("Please specify a reason")
        } else {
            let selectedIDs = arrSelected.joined(separator: ",")
            KAppDelegate.showActivityIndicator()
            submitReports(selectedIDs)
        }
        
    }
    @IBAction func actionDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return justificationArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblViewJustification.dequeueReusableCell(withIdentifier: "JustificationTVC", for: indexPath) as! JustificationTVC
        let justification = justificationArr[indexPath.row] as! Justification
        if justification.isSelected {
            cell.imgViewSelection.image =  #imageLiteral(resourceName: "ic_check_radio_bt")
        } else {
            cell.imgViewSelection.image = #imageLiteral(resourceName: "ic_radio_bt")
        }
        cell.lblTitle.text = justification.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let justification = justificationArr[indexPath.row] as! Justification
        justification.isSelected = !justification.isSelected
        tblViewJustification.reloadData()
    }
    //MARK:-API Interaction
    func getJustificationList() {
        let contentUrl = "\(KServerUrl)\(KGetReportTypes)"
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
    func submitReports(_ selectedID : String) {
        let loginUrl = "\(KServerUrl)"+"\(KSubmitReport)"
        let param = [
            "Report[ride_id]":"\(ride.rideID)",
            "Report[report_type_id]":"\(selectedID)"
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            
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
   
    //MARK: - Web Service delegate
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KGetReportTypes)")  {
            justificationArr.removeAllObjects()
            KAppDelegate.debugPrint(text: "Justification", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let justificationList = JSON["list"] as? NSArray {
                    for index in 0..<justificationList.count {
                        let dict = justificationList[index] as! NSDictionary
                        let justification = Justification()
                        if dict["message"] != nil {
                            justification.title =  dict["message"] as! String
                        }
                        if dict["id"] != nil {
                            justification.id =  dict["id"] as! Int
                        }
                        justificationArr.add(justification)
                    }
                }
            } else {
                if let errorMessage = JSON["error"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage)
                }
            }
            tblViewJustification.delegate = self
            tblViewJustification.dataSource = self
            tblViewJustification.reloadData()
        } else  if (JSON["url"]! as AnyObject).isEqual("\(KSubmitReport)")  {
            KAppDelegate.debugPrint(text: "Submit Justification", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                self.dismiss(animated: true, completion: {
                   protocolCancelConfirmation?.reportSubmitted()
                })
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
