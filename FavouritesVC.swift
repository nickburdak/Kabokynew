//
//  FavouritesVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 25/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import GooglePlaces
class FavouritesVC: UIViewController, handleDrawerNavigation, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblViewFavourites: UITableView!
    var arrFavourites = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        protocolDrawerNav = self
        self.navigationController?.isNavigationBarHidden = true
        getFavourites()
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
            tblViewFavourites.isUserInteractionEnabled = true
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil   {
            tblViewFavourites.isUserInteractionEnabled = false
        KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //MARK:- Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    //MARK:- TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavourites.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tblViewFavourites.estimatedRowHeight = 100
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavouritesTVC
        let favourite = arrFavourites[indexPath.row] as! FavouritePlace
        cell.lblPickUp.text = favourite.pickupAddress
        cell.lblDropOff.text = favourite.dropoffAddress
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favourite = arrFavourites[indexPath.row] as! FavouritePlace
        let homeVC = storyboard?.instantiateViewController(withIdentifier : "HomeVC") as! HomeVC
        homeVC.isFromFavourites = true
        homeVC.rideRequest.pickupAddress = favourite.pickupAddress
        homeVC.rideRequest.pickupLat = favourite.pickupLat
        homeVC.rideRequest.pickupLong = favourite.pickupLong
        homeVC.rideRequest.dropoffAddress = favourite.dropoffAddress
        homeVC.rideRequest.dropoffLat = favourite.dropoffLat
        homeVC.rideRequest.dropOffLong = favourite.dropOffLong
        homeVC.rideRequest.favouriteId = favourite.id
        let sourceLocation = CLLocationCoordinate2D(latitude: Double(favourite.pickupLat)! as CLLocationDegrees, longitude: Double(favourite.pickupLong)! as CLLocationDegrees)
        homeVC.getReverseGeocodeCoordinate(coordinate: sourceLocation)
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    //MARK:- API Interaction
    func getFavourites() {
        let loginUrl = "\(KServerUrl)\(KGetFavourites)"
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(loginUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: nil, response: response.response, data:response.data, error: response.result.error as NSError?)
                            }
                        } else {
                            KAppDelegate.hideActivityIndicator()
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KGetFavourites)")  {
            arrFavourites.removeAllObjects()
            KAppDelegate.debugPrint(text: "Favourites Response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let list = JSON["list"] as? NSArray {
                    for index in 0..<list.count {
                        let favourite = FavouritePlace()
                        if let dict = list[index] as? NSDictionary {
                            if let address = dict["address"]  as? String {
                                favourite.pickupAddress = address
                            }
                            if let lat = dict["latitude"]  as? String {
                                favourite.pickupLat = lat
                            }
                            if let long = dict["longitude"]  as? String {
                                favourite.pickupLong = long
                            }
                            if let destAddress = dict["destination_address"]  as? String {
                                favourite.dropoffAddress = destAddress
                            }
                            if let destLat = dict["destination_latitude"]  as? String {
                                favourite.dropoffLat = destLat
                            }
                            if let destLong = dict["destination_longitude"]  as? String {
                                favourite.dropOffLong = destLong
                            }
                            if let id = dict["id"]  as? Int {
                                favourite.id = id
                            }
                        }
                        arrFavourites.add(favourite)
                    }
                }
            }else{
                if let errorMessage = JSON["error"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage)
                }
            }
            tblViewFavourites.dataSource = self
            tblViewFavourites.delegate = self
            tblViewFavourites.reloadData()
            tblViewFavourites.animate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
