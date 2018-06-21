//
//  ScheduleRideVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 14/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
class ScheduleRideVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnDone: SetCorner!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldDateTime: UITextField!
    var rideRequest = Ride()
    var datePicker  = UIDatePicker()
    var  selectedDate_Time  = Date()
    var currentDateAndTime  = Date()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        datePicker.minuteInterval = 5
        txtFieldDateTime.inputView = datePicker
        txtFieldDateTime.delegate = self
    }
    
    //MARK:- Actions
    @IBAction func btnCancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneAction(_ sender: AnyObject) {
        
        let dateVal = Date()
        let newDateAfter1Hr = NSCalendar.current.date(byAdding: .minute, value: 60, to: dateVal)
        
        if txtFieldDateTime.text == "" {
            proxy.sharedProxy().displayStatusCodeAlert("Please select date & time")
        } else if selectedDate_Time > newDateAfter1Hr! {
            proxy.sharedProxy().displayStatusCodeAlert("Valid Time ")
                createRide()
        }else {
             proxy.sharedProxy().displayStatusCodeAlert("Invalid Time")
        }
    }


    //MARK:- TextFieldDelegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if txtFieldDateTime.trimmedValue == "" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateAndTime = formatter.string(from: datePicker.date)
            selectedDate_Time  = datePicker.date
            txtFieldDateTime.text = dateAndTime
            datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
           
        }
    }
    func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateAndTime = formatter.string(from: datePicker.date)
        selectedDate_Time = datePicker.date
        txtFieldDateTime.text = dateAndTime
        
    }
    
        //MARK:-  Api
    func createRide() {
        rideRequest.rideTime = txtFieldDateTime.trimmedValue
        let createRideUrl = "\(KServerUrl)\(KCreateRide)"
        let param = [
            "Ride[location]":"\(rideRequest.pickupAddress)",
            "Ride[location_lat]":"\(rideRequest.pickupLat)",
            "Ride[location_long]":"\(rideRequest.pickupLong)",
            "Ride[destination]":"\(rideRequest.dropoffAddress)",
            "Ride[destination_lat]":"\(rideRequest.dropoffLat)",
            "Ride[destination_long]":"\(rideRequest.dropOffLong)",
            "Ride[journey_type]":"\(rideRequest.rideType)",
            "Ride[journey_time]":"\(rideRequest.rideTime):00",
            "Ride[car_type_id]":"\(rideRequest.carID)",
            "Ride[country_code]":"\(rideRequest.countryCode)"
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(createRideUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)", "time_diff":TimeZone.current.abbreviation()!,"timezone":"\(TimeZone.current.identifier)"])
                
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000   {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }else {
                                    proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(createRideUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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
        if (JSON["url"]! as AnyObject).isEqual("\(KCreateRide)") {
            KAppDelegate.debugPrint(text: "Ride later response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                proxy.sharedProxy().displayStatusCodeAlert("Ride successfully created")
                if let detail = JSON["detail"] as? NSDictionary  {
                    rideRequest.rideID = detail["id"] as! Int
                }
                self.dismiss(animated: true, completion: {
                   // protocolRideConfigHome?.moveToRideConfirmationScreen(self.rideRequest)
                })
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
