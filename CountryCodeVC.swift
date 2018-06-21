//
//  CountryCodeVC.swift
//  NVOII
//
//  Created by Gaurav Tiwari on 21/09/16.
//  Copyright © 2016 Toxsl Technologies. All rights reserved.
//

import UIKit
import Alamofire

protocol CountryCodes {
    func countrySelected(_ country: Country)
}

var protocolCountry : CountryCodes?
class CountryCodeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblSelect: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewCentral: UIView!
    @IBOutlet weak var tblViewCountryCode: UITableView!
    
    var counrtyCodesArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCountryCode()
    }
    
    @IBAction func actionCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
 
    //MARK:- tableView delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counrtyCodesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 20
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCountry")!
        let country = counrtyCodesArray[(indexPath as NSIndexPath).row] as! Country
        cell.textLabel?.text = country.countryName
        cell.detailTextLabel?.text = country.countryCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = counrtyCodesArray[(indexPath as NSIndexPath).row] as! Country
        protocolCountry?.countrySelected(country)
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCountryCode() {
        let contentUrl = "\(KServerUrl)\(KCountryList)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KCountryList)")  {
             if (JSON["status"]! as AnyObject).isEqual(200) {
                let countryArr = JSON["list"] as! NSArray
                for i in 0..<countryArr.count {
                    let country = Country()
                    let dict = countryArr[i] as! NSDictionary
                    country.countryName = dict["title"] as! String
                    country.countryCode = dict["telephone_code"] as! String
                    country.countryID = (dict["id"]! as AnyObject).intValue
                    counrtyCodesArray.add(country)
                }
                KAppDelegate.hideActivityIndicator()
            } else {
                KAppDelegate.hideActivityIndicator()
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
            tblViewCountryCode.delegate = self
            tblViewCountryCode.dataSource = self
            tblViewCountryCode.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
