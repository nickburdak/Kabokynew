//
//  Ride.swift
//  NVOII
//
//  Created by Himanshu Singla on 30/01/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit
var ride = Ride()
class Ride: NSObject {
    /*;public static final int RIDE_STATE_NEW = 1;
     public static final int RIDE_STATE_ACCEPTED = 2;
     public static final int RIDE_STATE_REJECTED = 3;
     public static final int RIDE_STATE_CANCELLED = 4;
     public static final int RIDE_STATE_ARRIVED = 5;
     public static final int RIDE_STATE_STARTED = 6;
     public static final int RIDE_STATE_COMPLETED = 7;
     public static final int RIDE_STATE_PAID = 8; */
    var pickupAddress = String()
    var pickupLat = String()
    var pickupLong = String()
    var dropoffAddress = String()
    var dropoffLat = String()
    var dropOffLong = String()
    var carID = Int()
    var rideType  = 1 // 1 - RideNow, 2 - Ride Later
    var rideTime = String()
    var bagsCount = Int()
    var rideETA = String()
    var estimatedPrice = String()
    var rideID = Int()
    var rideState: RideState = .New
    var amount = String()
    var paymentID = Int()
    var driverID = Int()
    var currencySymbol = String()
    var favouriteId = Int()
    var driverDetails = DriverDetails()
    var countryCode =  String()
    var  rating = Int()
    func setValues(_ rideDetail : NSDictionary) {
        if rideDetail["amount"] != nil {
            self.amount = rideDetail["amount"] as! String
        }
        if rideDetail["amount_currency_symbol"] != nil {
            self.currencySymbol = rideDetail["amount_currency_symbol"] as! String
        }
        if rideDetail["id"] != nil {
            self.rideID = rideDetail["id"] as! Int
        }
        if rideDetail["location"] != nil {
            self.pickupAddress = rideDetail["location"] as! String
        }
        if let pickupLat =  rideDetail["location_lat"] as? String {
            self.pickupLat = pickupLat
        }
        if let pickupLong = rideDetail["location_long"] as? String {
            self.pickupLong = pickupLong
        }
        if rideDetail["destination"] != nil {
            self.dropoffAddress = rideDetail["destination"] as! String
        }
        if let dropLat =  rideDetail["destination_lat"] as? String {
            self.dropoffLat = dropLat
        }
        if let dropLong =  rideDetail["destination_long"] as?String {
            self.dropOffLong = dropLong
        }
        if rideDetail["payment_mode"] != nil {
            self.paymentID = rideDetail["payment_mode"] as! Int
        }
        if rideDetail["journey_time"] != nil {
            let time = rideDetail["journey_time"] as! String
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: time)
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            self.rideTime = formatter.string(from: date!)
        }
        if rideDetail["journey_type"] != nil {
            self.rideType = rideDetail["journey_type"] as! Int
        }
        if rideDetail["state_id"] != nil {
            self.rideState = RideState(rawValue: rideDetail["state_id"] as! Int)!
        }
        if let driverID = rideDetail["driver_id"] as? String  {
            if driverID != "" {
                self.driverID = Int(rideDetail["driver_id"] as! String)!
            }
        } else if let driverID = rideDetail["driver_id"] as? Int  {
            self.driverID = driverID
        }
        if let driverDetailDict = rideDetail["driver_detail"] as? NSDictionary {
          
            if let lat = driverDetailDict["lattitude"] as? String {
                self.driverDetails.driverLat = lat
            }
            if let long = driverDetailDict["longitude"] as? String {
                self.driverDetails.driverLong = long
            }
            if driverDetailDict["first_name"] != nil {
                self.driverDetails.firstName = driverDetailDict["first_name"] as! String
            }
            if driverDetailDict["last_name"] != nil {
                self.driverDetails.lastName = driverDetailDict["last_name"] as! String
            }
            if driverDetailDict["telephone_code"] != nil {
                self.driverDetails.countryCode = driverDetailDict["telephone_code"] as! String
            }
            if driverDetailDict["contact_no"] != nil {
                self.driverDetails.contactNumber = driverDetailDict["contact_no"] as! String
            }
            if driverDetailDict["image_file"] != nil {
                self.driverDetails.imageFile = driverDetailDict["image_file"] as! String
            }
            if   driverDetailDict["rating"] != nil {
       //         self.driverDetails.driverRating = driverDetailDict["rating"] as! Double
                
            }
            if let taxiDetailDict = driverDetailDict["taxi_detail"] as? NSDictionary {
                if taxiDetailDict["title"] != nil {
                    self.driverDetails.vehicleTitle = taxiDetailDict["title"] as! String
                }
                if taxiDetailDict["brand"] != nil {
                    self.driverDetails.vehicleBrand = taxiDetailDict["brand"] as! String
                }
                if taxiDetailDict["car_type"] != nil {
                    self.driverDetails.carType = taxiDetailDict["car_type"] as! Int
                }
                self.driverDetails.vehicleName = "\(self.driverDetails.vehicleBrand) \( self.driverDetails.vehicleTitle)"
                if taxiDetailDict["plate_number"] != nil {
                    self.driverDetails.vehicleNumber = taxiDetailDict["plate_number"] as! String
                }
            }
        }
    }
}
class DriverDetails {
    var contactNumber = String()
    var countryCode = String()
    var firstName = String()
    var lastName = String()
    var imageFile = String()
    var driverRating = Double()
    var vehicleTitle = String()
    var vehicleBrand = String()
    var vehicleName = String()
    var vehicleNumber = String()
    var driverLat = String()
    var driverLong = String()
    var carAnnotation = UIImage()
    var carType = 0 {
        didSet {
            switch carType {
            case 1:
                carAnnotation = #imageLiteral(resourceName: "ic_car")
            case 2:
                carAnnotation = #imageLiteral(resourceName: "ic_suv")
            case 3:
                carAnnotation = #imageLiteral(resourceName: "ic_lux")
            default:
                carAnnotation = #imageLiteral(resourceName: "pink_car_map_pin")
            }
        }
    }
}
