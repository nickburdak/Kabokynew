//
//  DriverArrivingVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 14/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import MessageUI
 protocol cancelConfirmationDelegate {
    func confirmedCancellation()
    func reportSubmitted()
    func sendMessage(_ input: String)
}

var protocolCancelConfirmation : cancelConfirmationDelegate?
class DriverArrivingVC: UIViewController, handleDrawerNavigation, cancelConfirmationDelegate, MFMessageComposeViewControllerDelegate {
  
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var imgViewDriver: SetCornerImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var lblPlateNo: UILabel!
    @IBOutlet weak var lblCall: UILabel!
    @IBOutlet weak var lblMessages: UILabel!
    @IBOutlet weak var lblCancelRide: UILabel!
    var ride = Ride()
    var driverLocTimer : Timer?
    var pickUpMarker = GMSMarker()
    var currentDriverMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    func showDetails() {
        lblDriverName.text! =  "\(ride.driverDetails.firstName)"
        lblDriverRating.text! = "\(ride.driverDetails.driverRating)"
        lblCarName.text! = ride.driverDetails.vehicleName
        lblPlateNo.text! = ride.driverDetails.vehicleNumber
        imgViewDriver.sd_setImage(with: URL(string: ride.driverDetails.imageFile), placeholderImage: #imageLiteral(resourceName: "icnProfile"))
        if ride.pickupLat != "" && ride.pickupLong != "" {
              let pickUpLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(ride.pickupLat)!, longitude: CLLocationDegrees(ride.pickupLong)!)
            pickUpMarker.position = pickUpLoc
            pickUpMarker.icon = #imageLiteral(resourceName: "ic_map_pin")
            pickUpMarker.map = mapView
            mapView.setRegion(sourceLocation: pickUpLoc)
        }
        if ride.driverDetails.driverLat != "" && ride.driverDetails.driverLong != "" {
            let currentDriverLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(ride.driverDetails.driverLat)!, longitude: CLLocationDegrees(ride.driverDetails.driverLong)!)
            currentDriverMarker.position = currentDriverLoc
            currentDriverMarker.icon = ride.driverDetails.carAnnotation
            currentDriverMarker.map = mapView
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        getJourneyDetails()
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
    //MARK:-Cancellation ConfirmedDelegate
    func confirmedCancellation() {
        protocolCancelConfirmation = self
        let justificationVC = storyboard?.instantiateViewController(withIdentifier: "JustificationVC") as! JustificationVC
        justificationVC.ride = ride
        self.present(justificationVC, animated: true, completion: nil)
    }
    
   func reportSubmitted() {
        cancelJourney()
    }
    func sendMessage(_ input: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
           messageVC.body = input
            messageVC.recipients = ["\(self.ride.driverDetails.countryCode)\(self.ride.driverDetails.contactNumber)"]
            messageVC.messageComposeDelegate = self;
            self.present(messageVC, animated: false, completion: nil)
        } else {
            proxy.sharedProxy().displayStatusCodeAlert("Message not sent")
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnActionSos(_ sender: Any) {
    KAppDelegate.pushNavigation(identifier:"EmergencyContactVC")
    }
    
    
    
    //MARK:- Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        protocolDrawerNav = self
        self.revealViewController().revealToggle(animated: true)
    }
    @IBAction func actionCall(_ sender: UIButton) {
        proxy.sharedProxy().makeCall(ride.driverDetails.countryCode+ride.driverDetails.contactNumber)
    }
    @IBAction func actionMessages(_ sender: UIButton) {
        protocolCancelConfirmation = self
        let messageVC = storyboard?.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        messageVC.ride = ride
        self.present(messageVC, animated: true, completion: nil)
    }
    @IBAction func actionCancel(_ sender: UIButton) {
        protocolCancelConfirmation = self
        let cancelConfirmationVC = storyboard?.instantiateViewController(withIdentifier: "RideCancelConfirmationVC") as! RideCancelConfirmationVC
        self.present(cancelConfirmationVC, animated: true, completion: nil)
    }
    func updateMarkerPosition(coordinates: CLLocationCoordinate2D,  duration: Double) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        currentDriverMarker.position = coordinates
        CATransaction.commit()
        let camera = GMSCameraUpdate.setTarget(coordinates)
        mapView.animate(with: camera)
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
    func getDriverLocation() {
        let contentUrl = "\(KServerUrl)\(KGetDriverLocation)?driver_id=\(ride.driverID)"
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
                            }
                        } else {
                            KAppDelegate.hideActivityIndicator()
                        }
                    }
            }
        } else {
         }
    }
    func cancelJourney() {
        let contentUrl = "\(KServerUrl)\(KUserCancelRide)?id=\(ride.rideID)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KRideDetails)")  {
            KAppDelegate.debugPrint(text: "Ride Details", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["detail"] as? NSDictionary {
                    ride.setValues(detail)
                    showDetails()
                    driverLocTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.getDriverLocation), userInfo: nil, repeats: true)
                }
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }  else   if (JSON["url"]! as AnyObject).isEqual(KGetDriverLocation)  {
            KAppDelegate.debugPrint(text: "Driver Location response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let lat = JSON["lattitude"] as? String {
                    ride.driverDetails.driverLat = lat
                }
                if let long = JSON["longitude"] as? String {
                    ride.driverDetails.driverLong = long
                }
                 let currentDriverLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(ride.driverDetails.driverLat)!, longitude: CLLocationDegrees(ride.driverDetails.driverLong)!)
                updateMarkerPosition(coordinates: currentDriverLoc, duration: 2.0)
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }  else   if (JSON["url"]! as AnyObject).isEqual(KUserCancelRide)  {
            KAppDelegate.debugPrint(text: "Ride cancel response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let success = JSON["success"] as? String {
                    proxy.sharedProxy().displayStatusCodeAlert(success)
                } else {
                    proxy.sharedProxy().displayStatusCodeAlert("Ride has been cancelled")
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
                    case .Started:
                        KAppDelegate.gotoRideStartedVC(ride)
                    case .Completed:
                        KAppDelegate.gotoRideFeedbackVC(ride)
                    default :
                        KAppDelegate.gotoHomeVC()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        driverLocTimer?.invalidate()
        driverLocTimer = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
