//
//  DropOffVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 30/01/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import GoogleMaps

class DropOffVC: UIViewController, UISearchBarDelegate ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblViewNearBy: UITableView!
    @IBOutlet weak var tblViewSearchLocation: UITableView!
    @IBOutlet weak var searchBarAddress: UISearchBar!
    @IBOutlet weak var btnEditHomeAddress: UIButton!
    @IBOutlet weak var btnEditWorkAddress: UIButton!
    @IBOutlet weak var btnSelectWorkAddress: UIButton!
    @IBOutlet weak var btnSelectHomeAddress: UIButton!
    @IBOutlet weak var lblWorkAddress: UILabel!
    @IBOutlet weak var lblAddWork: UILabel!
    @IBOutlet weak var lblAddHome: UILabel!
    @IBOutlet weak var lblHomeAddress: UILabel!
    var searchActive : Bool = false
    var locationArray = NSMutableArray()
    var nearByArr = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarAddress.delegate = self
        if UserDefaults.standard.object(forKey: "lat") != nil &&  UserDefaults.standard.object(forKey: "long") != nil {
            let currentLat = UserDefaults.standard.value(forKey: "lat") as! String
            let currentLong = UserDefaults.standard.value(forKey: "long") as! String
            let sourceLocation = CLLocationCoordinate2D(
                latitude: Double(currentLat)! as CLLocationDegrees, longitude: Double(currentLong)! as CLLocationDegrees)
            nearbyLocations(sourceLocation: sourceLocation)
        }
    }
    
    //MARK : - Actions
    @IBAction func actionBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Search Bar delegates
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBarAddress.text = ""
        searchBarAddress.resignFirstResponder()
        tblViewSearchLocation.isHidden = true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        locationArray.removeAllObjects()
        tblViewSearchLocation.isHidden = false
        tblViewSearchLocation.dataSource = self
        tblViewSearchLocation.delegate = self
        tblViewSearchLocation.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        search_API(searchBarAddress.text!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search_API( searchBarAddress.text!)
    }
    //MAK:-API Interaction
    func search_API(_ searchText:String){
        let trimmedText = searchText.replacingOccurrences(of: " ", with: "")
        let apiAddress = "\(kGoogleAddress)place/textsearch/json?query="
        
        let searchAddress = apiAddress + trimmedText
        let urlwithPercentEscapes = searchAddress.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let newURl = urlwithPercentEscapes! + kGoogleApiKey
        let reachability = Reachability()
        if reachability?.isReachable == true {
            request(newURl, method: .get, parameters: nil, encoding: JSONEncoding.default , headers: nil)
                .responseJSON { response in
                    if response.data != nil && response.result.error == nil {
                        if(response.response?.statusCode == 200) {
                            var JSONDIC = NSDictionary()
                            JSONDIC = response.result.value as! NSDictionary
                            self.serviseResponseLocation((JSONDIC.mutableCopy() as? NSMutableDictionary)!)
                        }
                    }
            }
        } else {
            proxy.sharedProxy().openSettingApp()
        }
    }
    
    func serviseResponseLocation(_ JSON:NSMutableDictionary) {
        if (JSON["status"]! as AnyObject).isEqual("OK") {
            
            let resultsArray = JSON["results"] as! NSArray
            self.locationArray = []
            for i in 0 ..< resultsArray.count {
                var dict = NSDictionary()
                dict = resultsArray[i] as! NSDictionary
                var name = String()
                let locationDict = NSMutableDictionary()
                locationDict.setValue("\(dict["formatted_address"]!)", forKey: "sub_Address" )
                if dict["name"] != nil {
                    name = dict["name"]! as! String
                    locationDict.setValue("\(name)", forKey: "name" )
                }
                else {
                    locationDict.setValue("", forKey: "name" )
                }
                if dict["icon"] != nil {
                    let icon = dict["icon"]! as! String
                    locationDict.setValue("\(icon)", forKey: "icon" )
                }
                let location = (dict["geometry"] as! NSDictionary).value(forKey: "location") as! NSDictionary
                locationDict.setValue(location["lat"], forKey: "lat")
                locationDict.setValue(location["lng"], forKey: "long")
                self.locationArray.add(locationDict)
            }
            
        } else {
            self.locationArray.removeAllObjects()
            _ = JSON["status"] as! String
            //   proxy.sharedProxy().displayStatusCodeAlert(errorMessage)
        }
        tblViewSearchLocation.delegate = self
        tblViewSearchLocation.dataSource = self
        tblViewSearchLocation.reloadData()
    }
    //MARK:- APi Interactions
    func nearbyLocations(sourceLocation:CLLocationCoordinate2D) {
        let routeUrl = "\(kGoogleAddress)place/nearbysearch/json?location=\(sourceLocation.latitude),\(sourceLocation.longitude)&radius=1000\(kGoogleApiKey)"
        
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(routeUrl, method: .get, parameters: nil, encoding: JSONEncoding.default)
                
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            KAppDelegate.hideActivityIndicator()
                            
                            if(response.response?.statusCode == 200) {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponseNearByPlace(JSONDIC)
                                }else {
                                }
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
    
    func serviceResponseNearByPlace(_ JSON: NSMutableDictionary) {
        nearByArr.removeAllObjects()
        if JSON["results"] != nil {
            let resultArr = JSON["results"] as! NSArray
            if resultArr.count >  0 {
                for i in 0 ..< resultArr.count {
                    var dict = NSMutableDictionary()
                    dict = (resultArr[i] as! NSDictionary) .mutableCopy() as! NSMutableDictionary
                    let locationDict = NSMutableDictionary()
                    var name = String()
                    if dict["name"] != nil {
                        name = dict["name"]! as! String
                        locationDict.setValue("\(name)", forKey: "name" )
                    } else {
                        locationDict.setValue("", forKey: "name" )
                    }
                    if dict["icon"] != nil {
                        let icon = dict["icon"]! as! String
                        locationDict.setValue("\(icon)", forKey: "icon" )
                    }
                    let vicinity = dict["vicinity"]! as! String
                    locationDict.setValue("\(vicinity)", forKey: "sub_Address" )
                    let lat = ((dict.object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary).object(forKey: "lat") as! NSNumber
                    let long = ((dict.object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary).object(forKey: "lng") as! NSNumber
                    locationDict.setValue(lat, forKey: "lat")
                    locationDict.setValue(long, forKey: "long")
                    
                    self.nearByArr.add(locationDict)
                }
            }
            tblViewNearBy.dataSource = self
            tblViewNearBy.delegate = self
            tblViewNearBy.reloadData()
        }
    }
    
    //MARK:- Tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 45
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblViewSearchLocation {
            return locationArray.count
        } else {
            return nearByArr.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPickUp") as! PlaceTVC
        if tableView == tblViewSearchLocation {
            let name = (locationArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "name") as? String
            let address = (locationArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "sub_Address") as? String
            if name != "" {
                cell.lblName.text = name
                cell.lblAddress.text = address
            } else {
                cell.lblName.text = address
            }
            if  (locationArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "icon") != nil {
                let icon = ((locationArray.object(at: indexPath.row) as! NSDictionary).object(forKey: "icon") as? String)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if icon != "" {
                    cell.imgViewIcon.sd_setImage(with: URL(string: icon!), placeholderImage: #imageLiteral(resourceName: "search_pin"))
                } else {
                    cell.imgViewIcon.image = #imageLiteral(resourceName: "search_pin")
                }
            }

        } else {
            let name = (nearByArr.object(at: indexPath.row) as! NSDictionary).object(forKey: "name") as? String
            let address = (nearByArr.object(at: indexPath.row) as! NSDictionary).object(forKey: "sub_Address") as? String
            if name != "" {
                cell.lblName.text = name
                cell.lblAddress.text = address
            } else {
                cell.lblName.text = address
            }
            
            if  (nearByArr.object(at: indexPath.row) as! NSDictionary).object(forKey: "icon") != nil {
                let icon = ((nearByArr.object(at: indexPath.row) as! NSDictionary).object(forKey: "icon") as? String)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if icon != "" {
                    cell.imgViewIcon.sd_setImage(with: URL(string: icon!), placeholderImage: #imageLiteral(resourceName: "search_pin"))
                } else {
                    cell.imgViewIcon.image = #imageLiteral(resourceName: "search_pin")
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblViewSearchLocation {
            let selectedLocation = locationArray[(indexPath as NSIndexPath).row] as! NSMutableDictionary
            protocolRideConfigHome?.dropOffSelected(selectedLocation: selectedLocation)
            tblViewSearchLocation.isHidden = true
        } else {
            let selectedLocation = nearByArr[(indexPath as NSIndexPath).row] as! NSMutableDictionary
            protocolRideConfigHome?.dropOffSelected(selectedLocation: selectedLocation)
        }
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
