
//
//  RideStartedVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 15/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
class RideStartedVC: UIViewController, handleDrawerNavigation,locationUpdateDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblDriverNameDisplay: UILabel!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblPickUpDisplay: UILabel!
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var lblDropOffDisplay: UILabel!
    @IBOutlet weak var lblDropOff: UILabel!
    @IBOutlet weak var lblDateTimeDisplay: UILabel!
    @IBOutlet weak var txtFieldDateTime: UITextField!
    var ride = Ride()
    var dropOffMarker = GMSMarker()
    var currentLocationMarker = GMSMarker()
    var driverLocation = CLLocationCoordinate2D()
    var custmoreLocation =  CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFieldDateTime.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        protocolLocationDelegate = self
        // Do any additional setup after loading the view.
        getJourneyDetails()
    }
    func showDetails() {
        if ride.driverDetails.driverLat != "" && ride.driverDetails.driverLong != "" {
            let driverLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(ride.driverDetails.driverLat)!, longitude: CLLocationDegrees(ride.driverDetails.driverLong)!)
            driverLocation = driverLoc
            currentLocationMarker.position = driverLocation
            currentLocationMarker.icon = ride.driverDetails.carAnnotation
            currentLocationMarker.map = mapView
            mapView.setRegion(sourceLocation: driverLoc)
        }
        
        if ride.dropOffLong != "" && ride.dropoffLat != ""  {
            let sourceLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(ride.dropoffLat)!, longitude: CLLocationDegrees(ride.dropOffLong)!)
            custmoreLocation = sourceLoc
            dropOffMarker.position = custmoreLocation
            dropOffMarker.icon = #imageLiteral(resourceName: "ic_map_pin_orange")
            dropOffMarker.map = self.mapView
        }

        lblDriverName.text! =  "\(ride.driverDetails.firstName) \(ride.driverDetails.lastName)"
        lblPickUp.text = ride.pickupAddress
        lblDropOff.text = ride.dropoffAddress
        txtFieldDateTime.text = ride.rideTime
        
        self.drawRoute(from:custmoreLocation, to: driverLocation)
    }
    func updateMarkerPosition(coordinates: CLLocationCoordinate2D,  duration: Double) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        currentLocationMarker.position = coordinates
        let camera = GMSCameraUpdate.setTarget(coordinates)
        mapView.animate(with: camera)
        CATransaction.commit()
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
//MARK:- LocationUpdateDelegate
    func locationUpdated() {
        if UserDefaults.standard.object(forKey: "lat") != nil &&  UserDefaults.standard.object(forKey: "long") != nil {
            let currentLat = UserDefaults.standard.value(forKey: "lat") as! String
            let currentLong = UserDefaults.standard.value(forKey: "long") as! String
            let sourceLocation = CLLocationCoordinate2D(latitude: Double(currentLat)! as CLLocationDegrees, longitude: Double(currentLong)! as CLLocationDegrees)
            currentLocationMarker.icon = ride.driverDetails.carAnnotation
            updateMarkerPosition(coordinates: sourceLocation, duration: 0.5)
        }
    }
//    func headingUpdated(_ heading: CLHeading ) {
//        
//        if UserDefaults.standard.object(forKey: "lat") != nil &&  UserDefaults.standard.object(forKey: "long") != nil {
//            let currentLat = UserDefaults.standard.value(forKey: "lat") as! String
//            let currentLong = UserDefaults.standard.value(forKey: "long") as! String
//            let sourceLocation = CLLocationCoordinate2D(latitude: Double(currentLat)! as CLLocationDegrees, longitude: Double(currentLong)! as CLLocationDegrees)
////            currentLocationMarker.position = sourceLocation
////            currentLocationMarker.icon = #imageLiteral(resourceName: "ic_car")
////            currentLocationMarker.map = mapView
//            let camera = GMSCameraPosition.camera(withLatitude: sourceLocation.latitude, longitude: sourceLocation.longitude, zoom: zoomLevel, bearing: heading.trueHeading, viewingAngle: 0)
//            
//            //You can change viewingAngle from 0 to 45
//            mapView.animate(to: camera)
//        }
  //  }
    
    
    
    
    func drawRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        KAppDelegate.drawRoute(from, to) { (polylines, error) in
            if let error = error {
                proxy.sharedProxy().displayStatusCodeAlert(error)
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
    

    
    
    
    
    
    
    //MARK: - Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        protocolDrawerNav = self
        self.revealViewController().revealToggle(animated: true)
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
    //MARK: - Web Service delegate
    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KRideDetails)")  {
            KAppDelegate.debugPrint(text: "Ride Details", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["detail"] as? NSDictionary {
                    ride.setValues(detail)
                    showDetails()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
