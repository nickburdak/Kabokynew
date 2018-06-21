//
//  TripHistoryVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 25/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire

class TripHistoryVC: UIViewController, handleDrawerNavigation {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOngoing: UIButton!
    @IBOutlet weak var btnUpcoming: UIButton!
    @IBOutlet weak var btnPastBooking: UIButton!
    
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var btnToday: UIButton!
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var btnMonth: UIButton!
        
    
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var btnSummary: UIButton!

    
    @IBOutlet weak var imgViewToday: UIImageView!
    @IBOutlet weak var imgViewMonth: UIImageView!
    @IBOutlet weak var imgViewSummary: UIImageView!
    @IBOutlet weak var tblViewHistory: UITableView!
    
    @IBOutlet weak var cnstHeightLowerButtons: NSLayoutConstraint!
    @IBOutlet weak var viewLowerButtons: UIView!
    
    var historyArray = NSMutableArray()

    let tblDataSource = HistoryDataSource()
    var pastBookingSelected = Bool()
    var cancelRideSelected = Bool()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        btnOngoing.isSelected = true
        protocolDrawerNav = self
        hideLowerButtons()
        getRideHistoryFor(url : kGetOngoing)
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
            tblViewHistory.isUserInteractionEnabled = true
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil  {
            tblViewHistory.isUserInteractionEnabled = false
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //MARK:- Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    @IBAction func actionChooseRideTypeFilter(_ sender: UIButton) {
        btnOngoing.isSelected = false
        btnUpcoming.isSelected = false
        btnPastBooking.isSelected = false

        var contentUrl = String()
        switch sender {
        case btnOngoing:
            hideLowerButtons()
            view.showAnimations()
            contentUrl = kGetOngoing
            btnOngoing.isSelected = true
            pastBookingSelected = false
            cancelRideSelected = false
            
        case btnUpcoming:
            hideLowerButtons()
            view.showAnimations()
            view.showAnimations()
            contentUrl = kGetUpComing
            btnUpcoming.isSelected = true
            pastBookingSelected = false
            cancelRideSelected = true
            
        case btnPastBooking:
            viewLowerButtons.isHidden = false
            cnstHeightLowerButtons.constant = 40
            view.showAnimations()
            contentUrl = "\(kGetPast)?time_id=0"
            btnPastBooking.isSelected = true
            imgViewMonth.image = #imageLiteral(resourceName: "ic_radio_bt")
            imgViewSummary.image = #imageLiteral(resourceName: "ic_radio_bt")
            imgViewToday.image = #imageLiteral(resourceName: "ic_check_radio_bt")
            pastBookingSelected = true
            cancelRideSelected = false
        default:
            break
        }
        getRideHistoryFor(url : contentUrl)
    }
    
    func hideLowerButtons() {
        cnstHeightLowerButtons.constant = 0
        viewLowerButtons.isHidden = true
    }
    
    @IBAction func actionChoosePastBookingFilter(_ sender: UIButton) {
        imgViewToday.image = #imageLiteral(resourceName: "ic_radio_bt")
        imgViewMonth.image = #imageLiteral(resourceName: "ic_radio_bt")
        imgViewSummary.image = #imageLiteral(resourceName: "ic_radio_bt")

        var contentUrl = String()
        switch sender {
        case btnToday:
            contentUrl = "\(kGetPast)?time_id=0"
            imgViewToday.image = #imageLiteral(resourceName: "ic_check_radio_bt")
        case btnMonth:
            contentUrl = "\(kGetPast)?time_id=1"
            imgViewMonth.image = #imageLiteral(resourceName: "ic_check_radio_bt")
        case btnSummary:
            contentUrl = "\(kGetPast)?time_id=2"
            imgViewSummary.image = #imageLiteral(resourceName: "ic_check_radio_bt")
        default:
            break
        }
        getRideHistoryFor(url : contentUrl)
    }
    
    @IBAction func actionBookNow(_ sender: UIButton) {
        let ride = historyArray[sender.tag] as! Ride
        let homeVC = storyboard?.instantiateViewController(withIdentifier : "HomeVC") as! HomeVC
        homeVC.isFromHistory = true
        homeVC.rideRequest.pickupAddress = ride.pickupAddress
        homeVC.rideRequest.pickupLat = ride.pickupLat
        homeVC.rideRequest.pickupLong = ride.pickupLong
        homeVC.rideRequest.dropoffAddress = ride.dropoffAddress
        homeVC.rideRequest.dropoffLat = ride.dropoffLat
        homeVC.rideRequest.dropOffLong = ride.dropOffLong
        homeVC.rideRequest.countryCode = KAppDelegate.countryCodeId
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    @IBAction func btnCancelRide(_ sender: Any) {
        let ride = historyArray[(sender as AnyObject).tag] as! Ride
        cancelRideApi(ride.rideID)
        
    }
    
    
    func reloadTheRides() {
        tblDataSource.arrayToReload = historyArray
        tblDataSource.pastBookingSelected = pastBookingSelected
        tblDataSource.cancelRideSelected = cancelRideSelected
        self.tblViewHistory.delegate = tblDataSource
        self.tblViewHistory.dataSource = tblDataSource
        self.tblViewHistory.reloadData()
    }
    
    //MARK:-API Interaction
    func getRideHistoryFor(url: String) {
        let contentUrl = "\(KServerUrl)\(url)"
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
    
    
    func cancelRideApi(_ idRide:Int) {
        let contentUrl = "\(KServerUrl)\(KCancelRide)?id=\(idRide)"
        let reachability = Reachability()
        if (reachability?.isReachable)!    {
            KAppDelegate.showActivityIndicator()
            request(contentUrl, method: .get, parameters: nil, encoding: JSONEncoding.default,headers:["User-Agent":"\(userAgent)","auth_code":"\(proxy.sharedProxy().authNil())"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSON = response.result.value as? NSDictionary{
                                self.serviceResponseCancel(JSON .mutableCopy() as! NSMutableDictionary)
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
        if (JSON["url"]! as AnyObject).isEqual("\(kGetOngoing)") || (JSON["url"]! as AnyObject).isEqual("\(kGetUpComing)") || (JSON["url"]! as AnyObject).isEqual("\(kGetPast)") {
            historyArray.removeAllObjects()
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let list = JSON["list"] as? NSDictionary{
                   // for index in 0..<list.count {
                        let ride = Ride()
                        ride.setValues(list)
                        historyArray.add(ride)
                    
                }else{
                    if let list = JSON["list"] as? NSArray {
                        for index in 0..<list.count {
                            let ride = Ride()
                            ride.setValues(list[index] as! NSDictionary)
                            historyArray.add(ride)
                        }
                    }
                  }
                }
            
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
            reloadTheRides()
        }
    
    func serviceResponseCancel(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
            historyArray.removeAllObjects()
            if (JSON["status"]! as AnyObject).isEqual(200) {
                getRideHistoryFor(url : kGetUpComing)
        } else {
            if let errorMessage = JSON["error"] {
                proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
            }
        }
   
    }
}

   
