//
//  HistoryDataSource.swift
//  KabokyDriver
//
//  Created by Gaurav Tiwari on 18/04/17.
//  Copyright © 2017 Toxsl technologies. All rights reserved.
//

import UIKit

class HistoryDataSource : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var arrayToReload = NSMutableArray()
    var pastBookingSelected = Bool()
    var cancelRideSelected = Bool()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayToReload.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryTVC") as! RideHistoryTVC
        let ride = arrayToReload[indexPath.section] as! Ride
        cell.btnBookAgain.tag = indexPath.section
        cell.btnCancel.tag = indexPath.section
        cell.lblDriverNameValue.text = "\(ride.driverDetails.firstName) \(ride.driverDetails.lastName)"
        cell.lblPickupLocValue.text = ride.pickupAddress
        cell.lblDropOffLocValue.text = ride.dropoffAddress
        cell.txtFldDateTimeValue.text = ride.rideTime
        if !pastBookingSelected  {
            cell.btnBookAgain.isHidden = true
              cell.btnCancel.isHidden = false
        }
        else{
             cell.btnBookAgain.isHidden = false
             cell.btnCancel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200
        return UITableViewAutomaticDimension
    }
}
