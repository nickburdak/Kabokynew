//
//  SettingsVC.swift
//  KabokyDriver
//
//  Created by Gaurav Tiwari on 15/04/17.
//  Copyright © 2017 Toxsl technologies. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, handleDrawerNavigation {
    
    @IBOutlet weak var lblNavHeader: UILabel!
    @IBOutlet weak var lblLanguageSelection: UILabel!
    @IBOutlet weak var tblViewLanguage: UITableView!
    
    let languageArray = ["English", "French", "العربية","Crotian", "Deutsche"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        protocolDrawerNav = self
        tblViewLanguage.reloadData()
        tblViewLanguage.animate()
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
            tblViewLanguage.isUserInteractionEnabled = true
            KAppDelegate.window?.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    func openDrawer() {
        if (self.revealViewController()) != nil
        {
            tblViewLanguage.isUserInteractionEnabled = false
            KAppDelegate.window?.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    
    @IBAction func btnActionEmergencyContacts(_ sender: Any) {
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "EmergencyContactVC") as! EmergencyContactVC
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        
    }
    
    

    //MARK:- Button actions
    @IBAction func actionDrawer(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    //MARK:- TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVC") as! SettingsTVC
        cell.lblLanguage.text = languageArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
