//
//  proxy.swift
//  kaboky
//
//  Created by Toxsl on 24/12/15.
//  Copyright © 2015 ToXSL Technologies Pvt. Ltd. All rights reserved.

import UIKit
import CoreMotion
import CoreLocation
import Alamofire
var locationUpdates = Bool()
var locationShareInstance:locationManagerClass = locationManagerClass()
@objc protocol locationUpdateDelegate {
    func locationUpdated ()
   @objc optional func headingUpdated(_ heading: CLHeading)
}
var protocolLocationDelegate : locationUpdateDelegate?
class locationManagerClass: NSObject, CLLocationManagerDelegate , UIAlertViewDelegate
{
    // MARK: - Class Variables
    var locationManager = CLLocationManager()
    class func sharedLocationManager() -> locationManagerClass  {
        locationShareInstance = locationManagerClass()
        return locationShareInstance
    }
    
    var timer = Timer()
    func startStandardUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10
        // meters
        locationManager.pausesLocationUpdatesAutomatically = false
        if  Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
            locationManager.requestWhenInUseAuthorization()
        }
        locationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        // timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(locationManagerClass.updateLocationToServer), userInfo: nil, repeats: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If it's a relatively recent event, turn off updates to save power.
        let location: CLLocation = locations.last!
        UserDefaults.standard.set("\(location.coordinate.latitude)", forKey: "lat")
        UserDefaults.standard.set("\(location.coordinate.longitude)", forKey: "long")
        UserDefaults.standard.synchronize()
        protocolLocationDelegate?.locationUpdated()
        print(location)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        protocolLocationDelegate?.headingUpdated?(newHeading)
    }
    
    func stopStandardUpdate() {
        self.timer.invalidate()
        locationUpdates = false
        locationManager.stopUpdatingLocation()
    }
    
    //MARK:- WHEN DENIED
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            UserDefaults.standard.set("\(0.0)", forKey: "lat")
            UserDefaults.standard.set("\(0.0)", forKey: "long")
            self.generateAlertToNotifyUser()
        }
    }
    
    func generateAlertToNotifyUser() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined{
            var title: String
            title = ""
            let message: String = "Location Services are not able to determine your location"
            let alertView: UIAlertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings")
            alertView.show()
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied{
            var title: String
            title = "Location services are off"
            let message: String = "To  create or track a ride, you must turn on Location Services from Settings"
            let alertView: UIAlertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings")
            alertView.show()
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined
        {
            startStandardUpdates()
        }
    }
    
    func updateLocationToServer() {
        let authCode: String = proxy.sharedProxy().authNil()
        if !(authCode == "" ) {
            var userLoc = CLLocationCoordinate2D()
            if UserDefaults.standard.object(forKey: "lat") != nil {
                let lat =  UserDefaults.standard.object(forKey: "lat") as! String
                let long = UserDefaults.standard.object(forKey: "long") as! String
                userLoc.latitude = CDouble(lat)!
                userLoc.longitude = CDouble(long)!
            }
            let latitute =  userLoc.latitude
            let longitude = userLoc.longitude
            let LoginUrl = "\(KServerUrl)"+"user/set-location"
            let param = [
                "User[lat]":"\(latitute)",
                "User[longt]":"\(longitude)"
            ]
            let reachability = Reachability()
            if (reachability?.isReachable)!   {
                request(LoginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody,headers: ["auth_code": "\(proxy.sharedProxy().authNil())","User-Agent":"\(userAgent)"])
                    .responseJSON { response in
                        do {
                            
                            if(response.response?.statusCode == 200)  {
                            }else {
                            }
                        }
                }
            }else {
                proxy.sharedProxy().openSettingApp()
            }
        }
    }
    
    //MARK:- Serviece Response
    func serviceResponse(JSON:NSMutableDictionary) {
        if (JSON["url"]! as AnyObject).isEqual("setLocation") && (JSON["controller"]! as AnyObject).isEqual("driver") {
            if (JSON["status"]! as AnyObject).isEqual("OK") {
                
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            // Send the user to the Settings for this app
            let settingsURL: NSURL = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(settingsURL as URL)
        }
    }
}

