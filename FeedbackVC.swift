//
//  RideCompletionVC.swift
//  KabokyDriver
//
//  Created by Gaurav Tiwari on 15/04/17.
//  Copyright © 2017 Toxsl technologies. All rights reserved.
//

import UIKit
import Alamofire
class FeedbackVC: UIViewController {
    
    @IBOutlet weak var lblNavHeader: UILabel!
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var lblFare: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var viewRating: FloatRatingView!
    @IBOutlet weak var lblShareIt: UILabel!
    
    @IBOutlet weak var btnBookTaxi: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    var ride = Ride()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // getJourneyDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        getJourneyDetails()
    }
    //MARK:- Button actions
    @IBAction func actionBack(_ sender: UIButton) {
        KAppDelegate.gotoHomeVC()
    }
    
    @IBAction func actionSocial(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //fb
            break
        case 1:
            //twitter
            break
        case 2:
            //message
            break
        default:
            //email
            break
        }
    }

    @IBAction func actionBook(_ sender: UIButton) {
         KAppDelegate.gotoHomeVC()
    }

    @IBAction func actionDone(_ sender: UIButton) {
        if viewRating.rating == 0 {
            proxy.sharedProxy().displayStatusCodeAlert("Rate your driver")
        } else {
            rateDriver()
        }
        
    }
    
    //MARK:-API Interaction
    func getJourneyDetails() {
        let contentUrl = "\(KServerUrl)\(KRideDetails)?id=\(ride.rideID)"
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

    func rateDriver() {
        let loginUrl = "\(KServerUrl)"+"\(KRateDriver)"
        let param = [
            "Rating[rating]":"\(viewRating.rating)",
            "Rating[driver_id]":"\(ride.driverID)",
            "Rating[ride_id]":"\(ride.rideID)"
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
    //MARK:- service response
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KRideDetails)")  {
            KAppDelegate.debugPrint(text: "Ride Details", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["detail"] as? NSDictionary {
                    ride.setValues(detail)
                    lblFare.text = " \(ride.currencySymbol) \(ride.amount)"
                }
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        } else if (JSON["url"]! as AnyObject).isEqual("\(KRateDriver)") {
            KAppDelegate.debugPrint(text: "Feedback response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                KAppDelegate.gotoHomeVC()
                proxy.sharedProxy().displayStatusCodeAlert("Rating has been successfully submitted")
                } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }else{
                    proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
