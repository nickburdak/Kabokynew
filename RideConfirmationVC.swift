//
//  RideConfirmationVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 14/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
class RideConfirmationVC: UIViewController, handleDrawerNavigation {
    
    @IBOutlet weak var btnCancelRide: SetCorner!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var rideRequest = Ride()
    var pickUpMarker = GMSMarker()
    var dropOffMarker = GMSMarker()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        mapView.clear()
        if rideRequest.pickupLat != "" && rideRequest.pickupLong != ""  {
            let sourceLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(rideRequest.pickupLat)!, longitude: CLLocationDegrees(rideRequest.pickupLong)!)
            pickUpMarker.position = sourceLoc
            pickUpMarker.icon = #imageLiteral(resourceName: "ic_map_pin")
            pickUpMarker.map = mapView
            mapView.setRegion(sourceLocation: sourceLoc)
            if rideRequest.dropoffLat != "" && rideRequest.dropOffLong != ""  {
                let destinationLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(rideRequest.dropoffLat)!, longitude: CLLocationDegrees(rideRequest.dropOffLong)!)
                dropOffMarker.position = destinationLoc
                dropOffMarker.icon = #imageLiteral(resourceName: "ic_map_pin_orange")
                dropOffMarker.map = mapView
                KAppDelegate.drawRoute(sourceLoc, destinationLoc) { (polylines, error) in
                    if let error = error {
                        return
                    }
                    if let polylines = polylines {
                        let path: GMSPath = GMSPath(fromEncodedPath: polylines as String)!
                        let routePolyline = GMSPolyline(path: path)
                        routePolyline.strokeWidth = 3.0
                        routePolyline.strokeColor = UIColor(colorLiteralRed: 227/255, green: 108/255, blue: 0, alpha: 1)
                        routePolyline.map = self.mapView
                        return
                    }
                }
            }
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
        if (self.revealViewController()) != nil {
            mapView.isUserInteractionEnabled = true
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil  {
            mapView.isUserInteractionEnabled = false
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    //MARK:- Actions
    @IBAction func actionCancelRide(_ sender: Any) {
        cancelJourney()
    }
    @IBAction func actionDrawer(_ sender: UIButton) {
        protocolDrawerNav = self
        self.revealViewController().revealToggle(animated: true)
    }
    //MARK:- APIs
    func cancelJourney() {
        let contentUrl = "\(KServerUrl)\(KCancelRide)?id=\(rideRequest.rideID)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KCancelRide)")  {
            KAppDelegate.debugPrint(text: "Ride cancel response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let success = JSON["success"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(success)
                }
                KAppDelegate.gotoHomeVC()
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
                if let state_id = JSON["state_id"] as? Int {
                    var rideState = RideState.New
                    rideState = RideState(rawValue: state_id)!
                    switch rideState  {
                    case .New :
                        break
                    case .Accepted, .Arrived, .Paid:
                        KAppDelegate.gotoDriverArrivingVC(rideRequest)
                    case .Started:
                        KAppDelegate.gotoRideStartedVC(rideRequest)
                    default :
                        KAppDelegate.gotoHomeVC()
                    }
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
