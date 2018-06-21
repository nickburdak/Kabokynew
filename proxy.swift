//
//  proxy.swift
//  kaboky
//
//  Created by Toxsl on 24/12/15.
//  Copyright © 2015 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

var KAppDelegate = UIApplication.shared.delegate as! AppDelegate
var shareInstance:proxy = proxy()

// MARK: - API's USER
let  KMode = "development"
let  KAppName = "Kaboky"
let  KVersion =  "1.0"
let userAgent = "\(KMode)"+"/"+"\(KAppName)"

// MARK: - API's USER
let KServerUrl =  "http://web3.toxsl.in/kaboky/"
let KCountryList = "api/user/country"
let KUserCheck = "\(KServerUrl)api/user/check?auth_code="
let KSignUp = "api/user/signup"
let KLogin = "api/user/login"
let Klogout = "api/user/logout"
let KVerifyEmail = "api/user/verify"
let KResendCode = "api/user/resend"
let KDefaultPayType = "api/user/pay"
let KImageUpdate = "api/user/update"
let KChangePassword = "api/user/change-password"
let KForgotPassword = "api/user/recover"
let KGetCarType = "api/taxi/car-type"
let KNearByDrivers = "api/taxi/get-drivers"
let KCreateRide = "api/ride/request"
let KCancelRide = "api/ride/cancel"
let KUserCancelRide = "api/ride/cancel-ride"
let KRideDetails = "api/ride/get"
let KRideStateTrack = "api/ride/track"
let KGetReportTypes = "api/report-type/get"
let KSubmitReport = "api/report-type/add"
let KAddFavouites = "api/favourite/add"
let KGetFavourites = "api/favourite/get"
let kGetOngoing = "api/ride/track"
let kGetUpComing = "api/user/upcoming-booking"
let kGetPast = "api/user/past-booking"
let kGetToday = "api/ride/track"
let KChangePaytype = "api/user/change-pay-type"
let KGetReferralDetails = "api/user/refer-detail"
let KAddCard = "api/card-detail/add"
let KCardList = "api/card-detail/get-list"
let KMarkDefaultCard = "api/card-detail/default"
let KDeleteCard = "api/card-detail/delete"
let KGetWalletBalance = "api/user-wallet/get"
let KRechargeWallet = "api/user-wallet/add-amount"
let KAddContact = "api/user/emergency-contact"
let KgetContact = "api/user/get-emergency-contacts"
let KDeleteFavouriteLocation = "api/favourite/delete"
let KRideCancel = "api/ride/cancel-ride"

let kGoogleAddress = "https://maps.googleapis.com/maps/api/"
let kGoogleApiKey = "&key=AIzaSyAtXQWUveqHurth-lJwF7CnU0iyjk_tXWw"
let KGetDriverLocation = "api/driver/location"
let KRateDriver = "api/driver/rate"
var reachable = Reachability()
class proxy: NSObject {
    // MARK: - Class Variables
    class func sharedProxy() -> proxy {
        shareInstance = proxy()
        return shareInstance
    }
    
    func checkStringIfNull(_ content: String) -> String {
        if ((content == "null")) || ((content == "(null)")) || ((content == "<null>")) || ((content == "nil")) || ((content == "")) || ((content == "<nil>")) || (content.characters.count == 0){
            return ""
        } else {
            return content
        }
    }
    
    
    func authNil () -> String
    {
        if(UserDefaults.standard.object(forKey: "auth_code") == nil) {
            return ""
        } else {
            return String(describing: UserDefaults.standard.object(forKey: "auth_code") as AnyObject)
        }
    }
    
    func makeCall(_ contactNumber: String) {
        let convert_mobile_string = contactNumber.replacingOccurrences(of: " ", with: "")
        let url:URL = URL(string: "tel://\(convert_mobile_string)")!
        if(UIApplication.shared.canOpenURL(url)) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (success) in
                })
            } else {
                if UIApplication.shared.openURL(url) {
                    
                } else {
                    proxy.sharedProxy().displayStatusCodeAlert("Call not sent")
                }
            }
        } else {
            proxy.sharedProxy().displayStatusCodeAlert("Call not sent")
        }
    }
   

    
    func expiryDateCheckMethod(_ expiryDate: String)->Bool  {
        let DateInFormat = DateFormatter()
        DateInFormat.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        DateInFormat.dateFormat = "yyyy-MM-dd"
        let expiryDate = DateInFormat.date(from: expiryDate)
        
        let f:DateFormatter = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = "yyyy-MM-dd"
        
        let now = f.string(from: NSDate() as Date)
        let currentDate = f.date(from: now)
        let offsetTime = NSTimeZone.local.secondsFromGMT()
        let finalTime = currentDate!.addingTimeInterval(TimeInterval(offsetTime))
        
        if finalTime.compare(expiryDate!) == ComparisonResult.orderedDescending  {
            return false
        }
        else if currentDate!.compare(expiryDate!) == ComparisonResult.orderedAscending  {
            return true
        }
        else{
            return true
        }
    }
    

    
    // MARK: - Error Handling
    
    func stautsHandler(_ url:String, parameter:Dictionary<String,AnyObject>? = nil, response:HTTPURLResponse?, data:Data?, error:NSError?)
    {
           KAppDelegate.hideActivityIndicator()
        if  response?.statusCode == 400  {
            displayStatusCodeAlert("bad url")
        }  else if response?.statusCode == 401  {
            displayStatusCodeAlert("unauthorized")
        }  else if response?.statusCode == 403  {
            if !(KAppDelegate.window!.currentViewController()!.isKind(of: WelcomeVC.self)) {
                KAppDelegate.gotoWelcome()
            }
            UserDefaults.standard.set("", forKey: "auth_code")
            UserDefaults.standard.synchronize()
        } else if response?.statusCode == 404  {
            displayStatusCodeAlert("file not found")
        }   else if response?.statusCode ==  500  {
            KAppDelegate.debugPrint(text: "\(url)", value: NSString(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "")
            proxy.sharedProxy().displayStatusCodeAlert("Problem connecting server: 500")
        }  else if response?.statusCode == -1005  {
             proxy.sharedProxy().displayStatusCodeAlert("Lost Network Connectivity")
        }  else if response?.statusCode == 408  {
            proxy.sharedProxy().displayStatusCodeAlert("Connection Error: Please try again later")
        } else if error?.code == -1001  {
             proxy.sharedProxy().displayStatusCodeAlert("Connection Error: Please try again later")
        } else if error?.code == -1009   {
             proxy.sharedProxy().displayStatusCodeAlert("Connection Error: Please try again later")
        }
    }
    
    func displayStatusCodeAlert(_ userMessage: String)   {
        UIView.hr_setToastThemeColor(appColor)
        KAppDelegate.window!.makeToast(message: userMessage)
    }
    
      func isValidEmail(_ testStr:String) -> Bool  {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    func isValidPassword(_ testStr:String) -> Bool  {
        let emailRegEx = "^.*(?=.{8})(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%&*_.])[a-zA-Z0-9!@#$%&*_.]+$"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidCardExpiryDate(_ testStr:String) -> Bool  {
        let emailRegEx = "(?:0[1-9]|1[0-2])/[0-9]{2}$"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func openSettingApp() {
          let settingAlert = UIAlertController(title: "Connection Problem", message: "Please check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
            settingAlert.addAction(okAction)
            let openSetting = UIAlertAction(title:"Setting", style:UIAlertActionStyle.default, handler:{ (action: UIAlertAction!) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            settingAlert.addAction(openSetting)
            KAppDelegate.window?.currentViewController()!.present(settingAlert, animated: true, completion: nil)
    }
    
}
