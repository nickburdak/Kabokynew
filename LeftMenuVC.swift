//
//  LeftMenuVC.swift
//  NVOII
//
//  Created by Himanshu Singla on 21/01/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
protocol handleDrawerNavigation {
    func navigateToScreen(string: String)
    func dismissDrawer()
    func openDrawer()
}
var protocolDrawerNav : handleDrawerNavigation?
class LeftMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tbvwTitle: UITableView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgvwProfile: SetCornerImageView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnViewProfile: UIButton!
    @IBOutlet weak var btnBookTaxi: UIButton!
    

    var arrTitle = ["Track My Car","My Booking","Payment Options","Wallet","Favourites" , "Invite Friends", "Settings", "About"]
    var arrImg = [#imageLiteral(resourceName: "ic_drawer_track_my_car"), #imageLiteral(resourceName: "ic_drawer_my_booking"), #imageLiteral(resourceName: "ic_drawer_payment"), #imageLiteral(resourceName: "ic_wallet"), #imageLiteral(resourceName: "ic_drawer_favourite"), #imageLiteral(resourceName: "ic_drawer_invite_friend"), #imageLiteral(resourceName: "ic_drawer_settings"),#imageLiteral(resourceName: "ic_drawer_about")]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        lblTitle.text = profile.firstName + " " + profile.lastName
        if  profile.imageFile != "" {
        imgvwProfile.sd_setImage(with: URL(string: profile.imageFile), placeholderImage: #imageLiteral(resourceName: "icnProfile"))
        } else {
             imgvwProfile.image = #imageLiteral(resourceName: "icnProfile")
        }
        tbvwTitle.dataSource = self
        tbvwTitle.delegate = self
        tbvwTitle.reloadData()

    }
    override func viewDidAppear(_ animated: Bool) {
        protocolDrawerNav?.openDrawer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        protocolDrawerNav?.dismissDrawer()
    }
    //MARK:- action

    @IBAction func actionProfile(_ sender: AnyObject) {
         self.revealViewController().revealToggle(animated: true)
        protocolDrawerNav?.navigateToScreen(string: "Profile")
    }
    @IBAction func actionBookTaxi(_ sender: UIButton) {
        KAppDelegate.gotoHomeVC()
    }
    @IBAction func actionLogout(_ sender: UIButton) {
        KAppDelegate.logOut()
    }
    
    //MARK:- tableviewDelegte
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LeftMenuTVC
        cell.lblTitle.text = arrTitle[indexPath.row] 
        cell.lblImgvw.image = arrImg[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch  indexPath.row {
        case 0:
            getJourneyDetails()
        case 1:
                KAppDelegate.gotoHistoryVC()
        case 2:
            KAppDelegate.gotoPaymentOptionsVC()
        case 3:
             KAppDelegate.gotoWalletVC()
        case 4:
            KAppDelegate.gotoFavouritesVC()
        case 5 :
            KAppDelegate.gotoInviteVC()
        case 6:
            KAppDelegate.gotoSettingsVC()
        default:
            break
        }
    }
    //MARK:-API Interaction
    func getJourneyDetails() {
        let contentUrl = "\(KServerUrl)\(KRideStateTrack)"
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
        if (JSON["url"]! as AnyObject).isEqual("\(KRideStateTrack)")  {
            KAppDelegate.debugPrint(text: "Ride Details", value: JSON)
            if (JSON["status"]! as AnyObject).isEqual(200) {
                if let detail = JSON["list"] as? NSDictionary {
                    let ride = Ride()
                    ride.setValues(detail)
                    switch ride.rideState  {
                        case .New :
                        KAppDelegate.gotoRideConfirmationVC(ride)
                        case .Accepted, .Arrived, .Paid:
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
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
