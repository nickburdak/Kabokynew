
//
//  HomeVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 08/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

@objc protocol rideConfigHome {
    func pickUpSelected(selectedLocation : NSDictionary)
    func dropOffSelected(selectedLocation : NSDictionary)
    func moveToRideConfirmationScreen(_ rideRequest : Ride)
}
var protocolRideConfigHome : rideConfigHome?
var zoomLevel : Float = 14.9
class HomeVC: UIViewController, handleDrawerNavigation, GMSMapViewDelegate, rideConfigHome,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var countryID = String()
    

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var mapViewHome: GMSMapView!
    @IBOutlet weak var lblPickUpDisplay: UILabel!
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var lblDropOffDisplay: UILabel!
    @IBOutlet weak var lblDropOff: UILabel!
    @IBOutlet weak var viewDateTime: SetCorner!
    @IBOutlet weak var cnstLeadingDateTime: NSLayoutConstraint!
    @IBOutlet weak var lblDateTimeDisplay: UILabel!
    @IBOutlet weak var txtFieldDateTime: UITextField!
    @IBOutlet weak var clctnViewCars: UICollectionView!
    @IBOutlet weak var txtFieldPromoCode: UITextField!
    @IBOutlet weak var btnBookNow: SetCorner!
    @IBOutlet weak var btnBookLater: SetCorner!
    var currentCarIndex = Int()
    var isFromFavourites = Bool()
    var isFromHistory = Bool()
    var carArray = NSMutableArray()
    var favouriteLocationId  = Int()
    let btnNormalColor = UIColor(colorLiteralRed: 227/255, green: 107/255, blue: 0, alpha: 1.0)
    let btnSelectedColor = UIColor(colorLiteralRed: 178/255, green: 33/255, blue: 219/255, alpha: 1.0)
        var rideRequest = Ride()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationController?.isNavigationBarHidden = true
        mapViewHome.delegate = self
        protocolDrawerNav = self
        if isFromFavourites {
            btnFavourite.setImage(#imageLiteral(resourceName: "ic_star_rating"), for: .normal)
            lblPickUp.text = rideRequest.pickupAddress
            lblDropOff.text = rideRequest.dropoffAddress
            favouriteLocationId = rideRequest.favouriteId
            initialConfigurations(rideRequest.pickupLat, rideRequest.pickupLong)
        } else if isFromHistory {
            lblPickUp.text = rideRequest.pickupAddress
            lblDropOff.text = rideRequest.dropoffAddress
            initialConfigurations(rideRequest.pickupLat, rideRequest.pickupLong)
        } else {
             setDefaultLocation()
        }
    }
   
    //MARK:- Map Methods
    func setDefaultLocation() {
        if UserDefaults.standard.object(forKey: "lat") != nil &&  UserDefaults.standard.object(forKey: "long") != nil {
            let currentLat = UserDefaults.standard.value(forKey: "lat") as! String
            let currentLong = UserDefaults.standard.value(forKey: "long") as! String
            let sourceLocation = CLLocationCoordinate2D(latitude: Double(currentLat)! as CLLocationDegrees, longitude: Double(currentLong)! as CLLocationDegrees)
            reverseGeocodeCoordinate(coordinate: sourceLocation)
            getReverseGeocodeCoordinate(coordinate: sourceLocation)
            self.rideRequest.pickupLat = "\(sourceLocation.latitude)"
            self.rideRequest.pickupLong = "\(sourceLocation.longitude)"
            initialConfigurations(currentLat, currentLong)
        }
    }
    func initialConfigurations(_ currentLat: String, _ currentLong: String ) {
        if currentLat != "" && currentLong != "" {
            let sourceLocation = CLLocationCoordinate2D(latitude: Double(currentLat)! as CLLocationDegrees, longitude: Double(currentLong)! as CLLocationDegrees)
            let pickupMarker = GMSMarker(position: sourceLocation)
            pickupMarker.icon = #imageLiteral(resourceName: "ic_map_pin")
            pickupMarker.map = mapViewHome
            setRegion(sourceLocation: sourceLocation)
            getCarTypes()
            nearByDrivers()
        }
    }
    func setRegion(sourceLocation: CLLocationCoordinate2D)  {
        let camera = GMSCameraPosition.camera(withLatitude: sourceLocation.latitude, longitude: sourceLocation.longitude, zoom:zoomLevel)
        mapViewHome.camera = camera
    }
    
    func getReverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder ()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
       geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
                        
            // Country Code
            if let CountryCode = placeMark.isoCountryCode as NSString?{
                self.rideRequest.countryCode =  CountryCode as String
                 KAppDelegate.countryCodeId = CountryCode as String
            }
          
          })
    }

   
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
       let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                if address.thoroughfare != nil &&  address.locality != nil  {
                    self.lblPickUp.text  = address.thoroughfare! + ", " + address.locality!
                } else if address.lines != nil  {
                    self.lblPickUp.text  = address.lines?.joined(separator: " ")
                }
                self.rideRequest.pickupAddress = self.lblPickUp.text!
                self.rideRequest.pickupLat = "\(coordinate.latitude)"
                self.rideRequest.pickupLong = "\(coordinate.longitude)"
            }
        }
    }
    //MARK: - CollectionViewDelegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellCar = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCarCVC", for: indexPath) as! HomeCarCVC
        let car = carArray[indexPath.item] as! Cars
        cellCar.lblCarType.text! = car.carName
        cellCar.imgViewCar.image = car.carImage
        return cellCar
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return clctnViewCars.bounds.size
    }
    //MARK: - Ride Config Delegates
    
    func pickUpSelected(selectedLocation: NSDictionary) {
        var address = String()
        var name = String()
        if selectedLocation["sub_Address"] != nil {
            address = selectedLocation["sub_Address"] as! String
        }
        if selectedLocation["name"] != nil {
            name = selectedLocation["name"] as! String
        }
        if selectedLocation["title"] != nil {
            address = selectedLocation["title"] as! String
        }
        rideRequest.pickupLat = "\(selectedLocation["lat"] as! NSNumber)"
        rideRequest.pickupLong = "\(selectedLocation["long"] as! NSNumber)"
        if name != "" {
            rideRequest.pickupAddress = name + ", " + address
        } else {
            rideRequest.pickupAddress = address
        }
        btnFavourite.setImage(#imageLiteral(resourceName: "ic_favourite"), for: .normal)
        lblPickUp.text! = rideRequest.pickupAddress
        getCarTypes()
        let sourceLocation = CLLocationCoordinate2D(
            latitude: Double(rideRequest.pickupLat)! as CLLocationDegrees, longitude: Double(rideRequest.pickupLong)! as CLLocationDegrees)
        setRegion(sourceLocation: sourceLocation)
        nearByDrivers()
    }
    func dropOffSelected(selectedLocation: NSDictionary) {
        var address = String()
        var name = String()
        if selectedLocation["sub_Address"] != nil {
            address = selectedLocation["sub_Address"] as! String
        }
        if selectedLocation["name"] != nil {
            name = selectedLocation["name"] as! String
        }
        if selectedLocation["title"] != nil {
            address = selectedLocation["title"] as! String
        }
        btnFavourite.setImage(#imageLiteral(resourceName: "ic_favourite"), for: .normal)

        rideRequest.dropoffLat = "\(selectedLocation["lat"] as! NSNumber)"
        rideRequest.dropOffLong = "\(selectedLocation["long"] as! NSNumber)"
        if name != "" {
            rideRequest.dropoffAddress = name + ", " + address
        } else {
            rideRequest.dropoffAddress = address
        }
        lblDropOff.text = rideRequest.dropoffAddress
       
    }
    func moveToRideConfirmationScreen(_ rideRequest : Ride) {
        let rideConfirmationVC = storyboard?.instantiateViewController(withIdentifier: "RideConfirmationVC") as! RideConfirmationVC
        rideConfirmationVC.rideRequest = rideRequest
        self.navigationController?.pushViewController(rideConfirmationVC, animated: true)
    }
    //MARK: - Drawer Delegates
    func navigateToScreen(string: String) {
        if string == "Profile" {
            let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    func dismissDrawer() {
        if (self.revealViewController()) != nil
        {
            mapViewHome.isUserInteractionEnabled = true
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil
        {
            mapViewHome.isUserInteractionEnabled = false
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //MARK:- Actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    @IBAction func actionChoosePickUp(_ sender: UIButton) {
        protocolRideConfigHome = self
        let pickupVC = storyboard?.instantiateViewController(withIdentifier: "PickUpVC") as! PickUpVC
        self.navigationController?.pushViewController(pickupVC, animated: true)
    }
    @IBAction func actionChooseDropOff(_ sender: UIButton) {
        protocolRideConfigHome = self
        let dropoffVC = storyboard?.instantiateViewController(withIdentifier: "DropOffVC") as! DropOffVC
        self.navigationController?.pushViewController(dropoffVC, animated: true)
    }
    @IBAction func actionAddToFavourites(_ sender: UIButton) {
        
        if lblPickUp.text != "" && lblDropOff.text != "" && btnFavourite.currentImage! != #imageLiteral(resourceName: "ic_star_rating"){
            addToFavourites()
        }
        else{
             btnFavourite.setImage(#imageLiteral(resourceName: "ic_favourite"), for: .normal)
            deleteFavouritesLocation()
            
        }
    }
    @IBAction func actionChooseRideType(_ sender: UIButton) {
        if sender == btnBookNow {
            if lblPickUp.text == "" {
                proxy.sharedProxy().displayStatusCodeAlert("Please select pick up address")
            } else if lblDropOff.text ==  "" {
                proxy.sharedProxy().displayStatusCodeAlert("Please select drop off address")
            } else {
                rideRequest.rideType = 1
                createRide()
            }
        } else if sender == btnBookLater {
            if lblPickUp.text == "" {
                proxy.sharedProxy().displayStatusCodeAlert("Please select pick up address")
            } else if lblDropOff.text ==  "" {
                proxy.sharedProxy().displayStatusCodeAlert("Please select drop off address")
            } else {
                rideRequest.rideType = 2
                let scheduleRideVC = storyboard?.instantiateViewController(withIdentifier: "ScheduleRideVC") as! ScheduleRideVC
                scheduleRideVC.rideRequest = rideRequest
                self.present(scheduleRideVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionSelectNextCar(_ sender: UIButton) {
        if carArray.count > 0 {
            if currentCarIndex < carArray.count - 1 {
                clctnViewCars.layoutIfNeeded()
                currentCarIndex = currentCarIndex + 1
                clctnViewCars.scrollToItem(at: NSIndexPath(item: currentCarIndex, section: 0) as IndexPath , at: .centeredHorizontally, animated: true)
                let car = carArray[currentCarIndex] as! Cars
                rideRequest.carID = car.carID
                nearByDrivers()
            }
        }
    }
    @IBAction func actionSelectPreviousCar(_ sender: UIButton) {
        if carArray.count > 0 {
            if currentCarIndex > 0 {
                clctnViewCars.layoutIfNeeded()
                currentCarIndex = currentCarIndex - 1
                clctnViewCars.scrollToItem(at: NSIndexPath(item: currentCarIndex, section: 0) as IndexPath , at: .centeredHorizontally, animated: true)
                let car = carArray[currentCarIndex] as! Cars
                rideRequest.carID = car.carID
                nearByDrivers()
            }
        }
    }
    
    //MARK:- API Interaction
    func getCarTypes() {
        let loginUrl = "\(KServerUrl)\(KGetCarType)"
        let param = [
            "lat":"\(rideRequest.pickupLat)",
            "long":"\(rideRequest.pickupLong)",
            "country_code":"\(KAppDelegate.countryCodeId)"        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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
    func addToFavourites() {
        let loginUrl = "\(KServerUrl)\(KAddFavouites)"
        let param = [
            "Favourite[latitude]":"\(rideRequest.pickupLat)",
            "Favourite[longitude]":"\(rideRequest.pickupLong)",
            "Favourite[address]":"\(rideRequest.pickupAddress)",
            "Favourite[destination_address]":"\(rideRequest.dropoffAddress)",
            "Favourite[destination_latitude]":"\(rideRequest.dropoffLat)",
            "Favourite[destination_longitude]":"\(rideRequest.dropOffLong)"
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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
    func deleteFavouritesLocation() {
       // id = favouriteLocationId
        let loginUrl = "\(KServerUrl)\(KDeleteFavouriteLocation)?id=\(favouriteLocationId)"
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(loginUrl, method: .post, parameters: nil, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000  {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: nil as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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
    
    
    func nearByDrivers() {
        //Fetchhing Users Current Location
        let loginUrl = "\(KServerUrl)\(KNearByDrivers)?id=\(rideRequest.carID)"
        let param = [
            "lat":"\(rideRequest.pickupLat)",
            "long":"\(rideRequest.pickupLong)",
        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)"])
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000 {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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
    func createRide() {
        rideRequest.rideTime = txtFieldDateTime.trimmedValue
        let loginUrl = "\(KServerUrl)\(KCreateRide)"
        let param = [
            "Ride[location]":"\(rideRequest.pickupAddress)",
            "Ride[location_lat]":"\(rideRequest.pickupLat)",
            "Ride[location_long]":"\(rideRequest.pickupLong)",
            "Ride[destination]":"\(rideRequest.dropoffAddress)",
            "Ride[destination_lat]":"\(rideRequest.dropoffLat)",
            "Ride[destination_long]":"\(rideRequest.dropOffLong)",
            "Ride[journey_type]":"\(rideRequest.rideType)",
            "Ride[car_type_id]":"\(rideRequest.carID)",
            "Ride[country_code]":"\(KAppDelegate.countryCodeId)"

        ]
        let reachable = Reachability()
        if reachable?.isReachable == true {
            KAppDelegate.showActivityIndicator()
            request(loginUrl, method: .post, parameters: param, encoding: URLEncoding.httpBody, headers:["auth_code" : proxy.sharedProxy().authNil(), "User-Agent":"\(userAgent)", "time_diff":TimeZone.current.abbreviation()!,"timezone":"\(TimeZone.current.identifier)"])
                
                .responseJSON { response in
                    do {
                        if response.data != nil && response.result.error == nil {
                            if response.response?.statusCode == 200 || response.response?.statusCode == 1000 {
                                if let JSONDIC = (response.result.value as? NSDictionary)?.mutableCopy() as? NSMutableDictionary{
                                    self.serviceResponse(JSONDIC)
                                }else {
                                    proxy.sharedProxy().displayStatusCodeAlert("Connectivity Problem")
                                }
                            } else {
                                KAppDelegate.hideActivityIndicator()
                                proxy.sharedProxy().stautsHandler(loginUrl, parameter: param as Dictionary<String, AnyObject>?, response: response.response, data:response.data, error: response.result.error as NSError?)
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

    func serviceResponse(_ JSON:NSMutableDictionary) {
        KAppDelegate.hideActivityIndicator()
        if (JSON["url"]! as AnyObject).isEqual("\(KGetCarType)")  {
            KAppDelegate.debugPrint(text: "Car types", value: JSON)
            let previousCount = carArray.count
            carArray.removeAllObjects()
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["list"] != nil {
                    let listArr = JSON["list"] as! NSArray
                    for index in 0..<listArr.count {
                        let carDict = listArr[index] as! NSDictionary
                        let car = Cars()
                        car.carID = carDict["id"] as! Int
                        car.carType = carDict["type_id"] as! Int
                        car.carName = carDict["title"] as! String
                        carArray.add(car)
                    }
                }
            } else{
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
                   clctnViewCars.dataSource = self
            clctnViewCars.delegate = self
            clctnViewCars.reloadData()
            if carArray.count != previousCount && carArray.count > 0{
                currentCarIndex = 0
                let car  = carArray.firstObject as! Cars
                rideRequest.carID = car.carID
                clctnViewCars.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                nearByDrivers()
            }
        } else  if (JSON["url"]! as AnyObject).isEqual("\(KNearByDrivers)")  {
             KAppDelegate.debugPrint(text: "Drivers", value: JSON)
            mapViewHome.clear()
            if rideRequest.pickupLat != "" && rideRequest.pickupLong != "" {
            let currentLocation = CLLocationCoordinate2D(latitude: Double(rideRequest.pickupLat)! as CLLocationDegrees, longitude: Double(rideRequest.pickupLong)! as CLLocationDegrees)
                let pickupMarker = GMSMarker(position: currentLocation)
                pickupMarker.icon = #imageLiteral(resourceName: "ic_map_pin")
                pickupMarker.map = mapViewHome
            }

            if (JSON["status"]! as AnyObject).isEqual(200) {
                if JSON["list"] != nil {
                    let driversArr = JSON["list"] as! NSArray
                    if driversArr.count > 0 {
                        for index in 0..<driversArr.count {
                            let driverDict = driversArr[index] as! NSDictionary
                            if driverDict["lattitude"] != nil && driverDict["longitude"] != nil {
                                if driverDict["lattitude"] as? NSNull == nil && driverDict["longitude"] as? NSNull == nil {
                                    if driverDict["lattitude"] as! String != "" && driverDict["longitude"] as! String != "" {
                                        let driverLocation = CLLocationCoordinate2D(
                                            latitude: Double(driverDict["lattitude"] as! String)! as CLLocationDegrees, longitude: Double(driverDict["longitude"] as! String)! as CLLocationDegrees)
                                        let marker = GMSMarker(position: driverLocation)
                                        var carType = Int()
                                        if driverDict["taxi_detail"] != nil {
                                            let vehicleDetail = driverDict["taxi_detail"] as! NSDictionary
                                            carType = vehicleDetail["car_type"] as! Int
                                        }
                                        switch carType {
                                        case 1 :  marker.icon = #imageLiteral(resourceName: "ic_car")
                                        case 2 :  marker.icon = #imageLiteral(resourceName: "ic_suv")
                                        case 3:    marker.icon = #imageLiteral(resourceName: "ic_lux")
                                        default:  marker.icon = #imageLiteral(resourceName: "pink_car_map_pin")
                                        }
                                        marker.map = mapViewHome
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                if let _ = JSON["error"] {
                    //  proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }
            }
        } else if (JSON["url"]! as AnyObject).isEqual("\(KCreateRide)") {
             KAppDelegate.debugPrint(text: "Ride now", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                proxy.sharedProxy().displayStatusCodeAlert("Ride successfully created")
                if let detail = JSON["detail"] as? NSDictionary  {
                    rideRequest.rideID = detail["id"] as! Int
                }
                moveToRideConfirmationScreen(rideRequest)
            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }else{
                    proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                }
            }
        } else if (JSON["url"]! as AnyObject).isEqual("\(KAddFavouites)") {
            KAppDelegate.debugPrint(text: "Add Favourites Response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                btnFavourite.setImage(#imageLiteral(resourceName: "ic_star_rating"), for: .normal)
                if let detail = JSON["detail"] as? NSDictionary  {
                    favouriteLocationId  = detail["id"] as! Int
                }

            } else {
                if let errorMessage = JSON["error"] {
                    proxy.sharedProxy().displayStatusCodeAlert(errorMessage as! String)
                }else{
                    proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                }
            }
        }
        else if (JSON["url"]! as AnyObject).isEqual("\(KDeleteFavouriteLocation)") {
            KAppDelegate.debugPrint(text: " Delete Response", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                btnFavourite.setImage(#imageLiteral(resourceName: "ic_favourite"), for: .normal)
                proxy.sharedProxy().displayStatusCodeAlert("Unfavourite successfully.")
                
            } else {
                if JSON["error"] != nil {
                    proxy.sharedProxy().displayStatusCodeAlert("select dropoff location")
                }else{
                    proxy.sharedProxy().displayStatusCodeAlert("Something went wrong")
                }
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
