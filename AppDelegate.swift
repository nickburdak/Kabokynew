//
//  AppDelegate.swift
//  kaboky
//
//  Created by Himanshu Singla on 03/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Alamofire
import SwiftSpinner
import SWRevealViewController
import GooglePlaces
import GoogleMaps
import Fabric
import Crashlytics
var appColor = UIColor(red: 178/255, green: 33/255, blue: 219/255, alpha: 1)
var profile = Profile()
var storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//NavigationControllers
var mainNavController = UINavigationController()
var homeNavController = UINavigationController()
var rideNavController = UINavigationController()
var paymentNavController = UINavigationController()
var walletNavController = UINavigationController()
var favouritesNavController = UINavigationController()
var fareNavController = UINavigationController()
var inviteNavController = UINavigationController()
var settingsNavController = UINavigationController()
var aboutNavController = UINavigationController()
var historyNavController = UINavigationController()
var sideNavController = UINavigationController()

enum RideState : Int {
    case New = 1, Accepted, Rejected, Cancelled, Arrived, Started, Completed, Paid
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SWRevealViewControllerDelegate {
    
    var window: UIWindow?
    var didStartFromNotification = Bool()
    let imgViewSplash = UIImageView()
    var viewController: SWRevealViewController!
    var countryCodeId = String()
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAtXQWUveqHurth-lJwF7CnU0iyjk_tXWw")
        GMSPlacesClient.provideAPIKey("AIzaSyAtXQWUveqHurth-lJwF7CnU0iyjk_tXWw")
        locationManagerClass.sharedLocationManager().startStandardUpdates()
        //DummyController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let dummyController:UIViewController = UIViewController()
        dummyController.view.backgroundColor = UIColor.white
        imgViewSplash.frame = CGRect(x: 0, y: 0, width: (self.window?.frame.width)!, height: (self.window?.frame.height)!)
        imgViewSplash.image = #imageLiteral(resourceName: "splash")
        dummyController.view .addSubview(imgViewSplash)
         self.window!.rootViewController = dummyController
        self.window!.makeKeyAndVisible()

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        registerForPushNotifications(application: application)
        //Notifications
        application.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            application.cancelAllLocalNotifications()
        }
        
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                didStartFromNotification = true
                checkApiMethod(userInfo: notification)
            }  else {
                didStartFromNotification = false
                checkApiMethodWithoutNotification()
            }
        } else {
            didStartFromNotification = false
            checkApiMethodWithoutNotification()
        }
        return true
    }
    
    
    
    // MARK: - Push Method
    func pushNavigation(identifier:String)  {
        let initalVc = storyboard.instantiateViewController(withIdentifier: identifier)
        mainNavController.pushViewController(initalVc, animated: true)
    }
    
    func checkApiMethodWithoutNotification() {
        let authCode = proxy.sharedProxy().authNil()
        let reachability = Reachability()
        if  (reachability?.isReachable)!   {
            request("\(KUserCheck)\(authCode)", method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil)
                .responseJSON { response in
                    
                    do {
                        if response.data != nil && response.result.error == nil {
                            
                            let jason = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                            self.debugPrint(text: "Check Response", value: jason!)
                            if let JSON = response.result.value as? NSDictionary {
                                if let date = JSON["datecheck"] as? String {
                                    if proxy.sharedProxy().expiryDateCheckMethod(date) {
                                        if response.response?.statusCode == 200 {
                                            if (JSON["status"]! as AnyObject).isEqual(200) {
                                                self.handleCheckResponse(JSON)
                                            } else {
                                                self.gotoWelcome()
                                            }
                                        } else {
                                            self.gotoWelcome()
                                        }
                                    } else {
                                        self.displayDateCheckAlert()
                                    }
                                } else {
                                    if response.response?.statusCode == 200 {
                                        if (JSON["status"]! as AnyObject).isEqual(200) {
                                            self.handleCheckResponse(JSON)
                                        } else {
                                            self.gotoWelcome()
                                        }
                                    } else {
                                        self.gotoWelcome()
                                    }
                                }
                            } else {
                                self.checkApiMethodWithoutNotification()
                                proxy.sharedProxy().displayStatusCodeAlert("Connectivity problem, please wait..")
                            }
                        } else {
                            proxy.sharedProxy().displayStatusCodeAlert("Connectivity problem, please wait..")
                            self.checkApiMethodWithoutNotification()
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    func checkApiMethod(userInfo: NSDictionary) {
        let authCode = proxy.sharedProxy().authNil()
        let reachability = Reachability()
        if  (reachability?.isReachable)!   {
            request("\(KUserCheck)\(authCode)", method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil)
                .responseJSON { response in
                    
                    do {
                        if response.data != nil && response.result.error == nil {
                            
                            let jason = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                            self.debugPrint(text: "Check Response", value: jason!)
                            if let JSON = response.result.value as? NSDictionary {
                                if let date = JSON["datecheck"] as? String {
                                    if proxy.sharedProxy().expiryDateCheckMethod(date) {
                                        if response.response?.statusCode == 200 {
                                            if (JSON["status"]! as AnyObject).isEqual(200) {
                                                self.handleCheckResponse(JSON)
                                                self.handleNotifications(userInfo: userInfo)
                                            } else {
                                                self.gotoWelcome()
                                            }
                                        } else {
                                            self.gotoWelcome()
                                        }
                                    } else {
                                        self.displayDateCheckAlert()
                                    }
                                } else {
                                    if response.response?.statusCode == 200 {
                                        if (JSON["status"]! as AnyObject).isEqual(200) {
                                            self.handleCheckResponse(JSON)
                                        } else {
                                            self.gotoWelcome()
                                        }
                                    } else {
                                        self.gotoWelcome()
                                    }
                                }
                            } else {
                                self.checkApiMethodWithoutNotification()
                                proxy.sharedProxy().displayStatusCodeAlert("Connectivity problem, please wait..")
                            }
                        } else {
                            proxy.sharedProxy().displayStatusCodeAlert("Connectivity problem, please wait..")
                            self.checkApiMethodWithoutNotification()
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    func handleCheckResponse(_ JSON : NSDictionary) {
        self.imgViewSplash.removeFromSuperview()
        if JSON["detail"] != nil  {
            let detail = JSON["detail"] as! NSDictionary
            if detail["id"] != nil {
                profile.id = detail["id"] as! Int
            }
            if detail["contact_no"] != nil {
                profile.contactNumber = detail["contact_no"] as! String
            }
            if detail["email"] != nil {
                profile.email = detail["email"] as! String
            }
            if detail["image_file"] != nil {
                profile.imageFile = detail["image_file"] as! String
            }
            if detail["first_name"] != nil {
                profile.firstName = detail["first_name"] as! String
            }
            if detail["last_name"] != nil {
                profile.lastName = detail["last_name"] as! String
            }
            if detail["referral_code"] != nil {
                profile.referralCode = detail["referral_code"] as! String
            }
            if detail["pay_type"] != nil {
                profile.payType = detail["pay_type"] as! Int
            }
            if detail["is_verify"] != nil {
                profile.isVerified = detail["is_verify"] as! Int
            }
            if detail["telephone_code"] != nil {
                profile.countryCode = detail["telephone_code"] as! String
            }
            if let countryID = detail["country"] as? String {
                profile.countryID = Int(countryID)!
            } else if let countryID =  detail["country"] as? Int {
                profile.countryID = countryID
            }
            if let rideDetails = detail["ride_detail"] as? NSDictionary {
                let ride = Ride()
                ride.setValues(rideDetails)
                switch ride.rideState {
                case .New :
                    KAppDelegate.gotoRideConfirmationVC(ride)
                case .Accepted, .Arrived, .Paid :
                    KAppDelegate.gotoDriverArrivingVC(ride)
                case .Started:
                    KAppDelegate.gotoRideStartedVC(ride)
                default :
                    KAppDelegate.gotoHomeVC()
                }
            } else {
                KAppDelegate.gotoHomeVC()
            }
        } else {
            KAppDelegate.gotoHomeVC()
        }
    }
    //MARK:- LATEST Journey 
    func getLatestJourneyState() {
        let contentUrl = "\(KServerUrl)\(KCountryList)"
        let reachability = Reachability()
        if  (reachability?.isReachable)!    {
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
        if (JSON["url"]! as AnyObject).isEqual("\(KCountryList)")  {
            if (JSON["status"]! as AnyObject).isEqual(200) {

            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        }
    }
    //MARK:- Route Draw API
    func drawRoute(_ sourceLoc : CLLocationCoordinate2D, _ destinationLoc : CLLocationCoordinate2D, completion: @escaping (_ polylines : String? , _ error : String? ) -> Void) {
        let routeUrl = "\(kGoogleAddress)directions/json?origin=\(sourceLoc.latitude),\(sourceLoc.longitude)&destination=\(destinationLoc.latitude),\(destinationLoc.longitude)\(kGoogleApiKey)"
        
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(routeUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                
                .responseJSON { response in
                    
                        if(response.response?.statusCode == 200) {
                            var getResults = NSArray()
                            var JSONDIC = NSMutableDictionary()
                            JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as! NSMutableDictionary
                             getResults = (JSONDIC["routes"]! as? NSArray)!
                            var getRouteDict = NSDictionary()
                            if getResults.count > 0  {
                            getRouteDict = getResults.lastObject as! NSDictionary
                                let polylines = (getRouteDict.value(forKey: "overview_polyline") as! NSDictionary).value(forKey: "points") as! String
                            completion(polylines, nil)
                            } else {
                                completion(nil, "Some problem occurred" )
                            }
                            
                        } else {
                            proxy.sharedProxy().stautsHandler(routeUrl, parameter: nil, response: response.response, data:response.data, error: response.result.error as NSError?)
                        }
            }
            
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }

    //MARK:-DATECHECK alert
    func displayDateCheckAlert() {
        imgViewSplash.removeFromSuperview()
        let alert=UIAlertController(title: "Demo Expired", message: "Please contact the development team", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.window!.currentViewController()?.present(alert, animated: true, completion: nil)
    }
    
    //MARK:-DebugPrint
    func debugPrint(text:String, value: Any){
        print("\(text) : ",value)
    }
   
    //MARK:- Activity Indicator Method
    func showActivityIndicator() {
        SwiftSpinner.show("Loading", animated: true)
    }
    
    func hideActivityIndicator() {
        SwiftSpinner.hide()
    }
    
    
    
    //MARK:- Navigation Methods
    func gotoWelcome() {
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        mainNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: mainNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoHomeVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        homeNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: homeNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoHistoryVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "TripHistoryVC") as! TripHistoryVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        historyNavController  = UINavigationController(rootViewController: frontViewController)
        historyNavController.isNavigationBarHidden = true
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: historyNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }

    func gotoSettingsVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        favouritesNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: favouritesNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoFavouritesVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "FavouritesVC") as! FavouritesVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        favouritesNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: favouritesNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoWalletVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        walletNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: walletNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoInviteVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "InviteFriendsVC") as! InviteFriendsVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        walletNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: walletNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }

    func gotoPaymentOptionsVC(){
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "PaymentOptionsVC") as! PaymentOptionsVC
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        paymentNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: paymentNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoRideConfirmationVC(_ ride: Ride) {
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "RideConfirmationVC") as! RideConfirmationVC
        frontViewController.rideRequest = ride
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        rideNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: rideNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoDriverArrivingVC(_ ride: Ride) {
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "DriverArrivingVC") as! DriverArrivingVC
        frontViewController.ride = ride
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        rideNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: rideNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoRideStartedVC(_ ride: Ride) {
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "RideStartedVC") as! RideStartedVC
        frontViewController.ride = ride
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        rideNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: rideNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }
    func gotoRideFeedbackVC(_ ride: Ride) {
        let frontViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        frontViewController.ride = ride
        let rearViewController = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        rideNavController  = UINavigationController(rootViewController: frontViewController)
        sideNavController = UINavigationController(rootViewController: rearViewController)
        let mainRevealController = SWRevealViewController(rearViewController: sideNavController, frontViewController: rideNavController)
        mainRevealController?.delegate = self
        self.viewController = mainRevealController
        self.window!.rootViewController = self.viewController
        self.window!.makeKeyAndVisible()
    }

    //MARK:- LogoutVC
    func logOut() {
        let logoutURL = "\(KServerUrl)"+"\(Klogout)"
        let reachability = Reachability()
        if  (reachability?.isReachable)!   {
            showActivityIndicator()
            request(logoutURL, method: .post, parameters: nil, encoding: URLEncoding.httpBody,headers: ["auth_code": "\(proxy.sharedProxy().authNil())","User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do  {
                        self.hideActivityIndicator()
                        if let JSON = response.result.value as? NSDictionary {
                            if (JSON["status"]! as AnyObject).isEqual(200) {
                                profile = Profile()
                                UserDefaults.standard.set("", forKey: "auth_code")
                                UserDefaults.standard.synchronize()
                                KAppDelegate.gotoWelcome()
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(logoutURL, parameter: nil as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
                            }
                        }
                    }
            }
        } else {
        }
    }
    
    //MARK: - NOTIFICATION METHODS
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted) {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                else{
                }
            })
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(tokenString, forKey: "device_token")
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UserDefaults.standard.set("000000000000000000000000000000000000000000000000000000000000055", forKey: "device_token")
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        if didStartFromNotification != true {
            handleNotifications(userInfo: userInfo as NSDictionary)
        }
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (_ options: UNNotificationPresentationOptions) -> Void) {
        
        var userInfo = NSDictionary()
        userInfo = notification.request.content.userInfo as NSDictionary
        print(userInfo)
         if (userInfo["action"]! as AnyObject).isEqual("get-fare") && (userInfo["controller"]! as AnyObject).isEqual("ride") {
            completionHandler([.sound,.alert])
         } else {
            completionHandler([.sound])
             handleNotifications(userInfo: userInfo)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        var userInfo = NSDictionary()
        userInfo = response.notification.request.content.userInfo as NSDictionary
        
        if didStartFromNotification != true {
            handleNotifications(userInfo: userInfo)
        }
    }
    func  handleNotifications(userInfo: NSDictionary) {
        self.debugPrint(text: "Notifications Response", value : userInfo)
        didStartFromNotification = false
        let currentNavCont: UINavigationController = self.viewController.frontViewController as! UINavigationController
        let currentViewCont = currentNavCont.visibleViewController
        
        
        let pay = userInfo as NSDictionary
        let ride = Ride()
        if let rideID =   pay["ride_id"] as? String {
            ride.rideID =  Int(rideID)!
        }
        if let message = pay["message"] as? String {
            proxy.sharedProxy().displayStatusCodeAlert(message)
        }
        if (pay["action"]! as AnyObject).isEqual("accept") && (pay["controller"]! as AnyObject).isEqual("ride")  ||  (pay["action"]! as AnyObject).isEqual("arrive") && (pay["controller"]! as AnyObject).isEqual("ride") ||  (pay["action"]! as AnyObject).isEqual("later") && (pay["controller"]! as AnyObject).isEqual("ride"){
            if currentViewCont!.isKind(of: DriverArrivingVC.self) {
            } else if currentViewCont!.isKind(of: SWRevealViewController.self) {
                var currentNavCont: UINavigationController?
                var currentViewContOnTop : UIViewController?
                currentNavCont = self.viewController.frontViewController as? UINavigationController
                currentViewContOnTop = currentNavCont?.visibleViewController
                if (currentViewContOnTop!.isKind(of: DriverArrivingVC.self)) {
                }
                else {
                    let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "DriverArrivingVC") as! DriverArrivingVC
                        driverArrivingVC.ride = ride
                    currentNavCont?.pushViewController(driverArrivingVC, animated: true)
                }
            } else {
                let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "DriverArrivingVC") as! DriverArrivingVC
                driverArrivingVC.ride = ride
                currentViewCont?.navigationController?.pushViewController(driverArrivingVC, animated: true)
            }
        } else if (pay["action"]! as AnyObject).isEqual("start") && (pay["controller"]! as AnyObject).isEqual("ride") {
            if currentViewCont!.isKind(of: RideStartedVC.self) {
            } else if currentViewCont!.isKind(of: SWRevealViewController.self) {
                var currentNavCont: UINavigationController?
                var currentViewContOnTop : UIViewController?
                currentNavCont = self.viewController.frontViewController as? UINavigationController
                currentViewContOnTop = currentNavCont?.visibleViewController
                if (currentViewContOnTop!.isKind(of: RideStartedVC.self)) {
                }
                else {
                    let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "RideStartedVC") as! RideStartedVC
                    driverArrivingVC.ride = ride
                    currentNavCont?.pushViewController(driverArrivingVC, animated: true)
                }
            } else {
                let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "RideStartedVC") as! RideStartedVC
                driverArrivingVC.ride = ride
                currentViewCont?.navigationController?.pushViewController(driverArrivingVC, animated: true)
            }
            
        }
        else if (pay["action"]! as AnyObject).isEqual("end") && (pay["controller"]! as AnyObject).isEqual("ride") {
            if currentViewCont!.isKind(of: FeedbackVC.self) {
            } else if currentViewCont!.isKind(of: SWRevealViewController.self) {
                var currentNavCont: UINavigationController?
                var currentViewContOnTop : UIViewController?
                currentNavCont = self.viewController.frontViewController as? UINavigationController
                currentViewContOnTop = currentNavCont?.visibleViewController
                if (currentViewContOnTop!.isKind(of: FeedbackVC.self)) {
                }
                else {
                    let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
                    driverArrivingVC.ride = ride
                    currentNavCont?.pushViewController(driverArrivingVC, animated: true)
                }
            } else {
                let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
                 driverArrivingVC.ride = ride
                currentViewCont?.navigationController?.pushViewController(driverArrivingVC, animated: true)
            }
        } else if (pay["action"]! as AnyObject).isEqual("paid") && (pay["controller"]! as AnyObject).isEqual("ride") {
            if currentViewCont!.isKind(of: HomeVC.self) {
            } else if currentViewCont!.isKind(of: SWRevealViewController.self) {
                var currentNavCont: UINavigationController?
                var currentViewContOnTop : UIViewController?
                currentNavCont = self.viewController.frontViewController as? UINavigationController
                currentViewContOnTop = currentNavCont?.visibleViewController
                if (currentViewContOnTop!.isKind(of: HomeVC.self)) {
                }
                else {
                    let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    currentNavCont?.pushViewController(driverArrivingVC, animated: true)
                }
            } else {
                let driverArrivingVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                currentViewCont?.navigationController?.pushViewController(driverArrivingVC, animated: true)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            application.cancelAllLocalNotifications()
        }
        checkApiMethodWithoutNotification()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

