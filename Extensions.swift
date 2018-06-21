//
//  Extensions.swift
//  kaboky
//
//  Created by Himanshu Singla on 11/04/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
//MARK:- TextFieldExtension
extension UITextField {
    var isBlank : Bool {
        return (self.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
    }
    var trimmedValue : String {
        return (self.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
    }
}
extension UIView {
    func showAnimations(completion: ((Bool) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.layoutIfNeeded()
            self.layoutSubviews()
        }, completion: completion)
    }
}

extension GMSMapView {
    func setRegion(sourceLocation: CLLocationCoordinate2D)  {
        let camera = GMSCameraPosition.camera(withLatitude: sourceLocation.latitude, longitude: sourceLocation.longitude, zoom:zoomLevel)
        self.camera = camera
    }
}
extension UITableView {
    func animate( ) {
        let cells = self.visibleCells
        let tableHeight: CGFloat = self.bounds.size.height
        for i in cells {
            let cell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        for a in cells {
            let cell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
    }
}

extension String {
    var isNumeric: Bool {
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}
