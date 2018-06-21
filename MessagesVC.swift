//
//  MessagesVC.swift
//  kaboky
//
//  Created by Himanshu Singla on 05/05/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import UIKit
import MessageUI
class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblViewMessages: UITableView!
    var arrMessages = ["OK", "Call me", "I am waiting.", "I'm on my way.", "Wait for 5 min","Other"]
    var ride = Ride()
    override func viewDidLoad() {
        super.viewDidLoad()
        tblViewMessages.dataSource = self
        tblViewMessages.delegate = self
        tblViewMessages.beginUpdates()
        tblViewMessages.reloadSections([0], with: .fade)
        tblViewMessages.endUpdates()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrMessages[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 40
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            if indexPath.row == self.arrMessages.count - 1 {
                protocolCancelConfirmation?.sendMessage("")
            } else {
                protocolCancelConfirmation?.sendMessage(self.arrMessages[indexPath.row])
            }
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
