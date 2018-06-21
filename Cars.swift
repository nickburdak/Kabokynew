//
//  Cars.swift
//  NVOII
//
//  Created by Himanshu Singla on 20/03/17.
//  Copyright © 2017 ToXSL Technologies Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit
class Cars {
    var carName = String()
    var carImage  = UIImage()
    var carAnnotation = UIImage()
    var carType = 1 {
        didSet {
            switch carType {
            case 1:
                carAnnotation = #imageLiteral(resourceName: "ic_car")
                carImage = #imageLiteral(resourceName: "car")
            case 2:
                carAnnotation = #imageLiteral(resourceName: "ic_suv")
                carImage = #imageLiteral(resourceName: "suv")
            case 3:
                carAnnotation = #imageLiteral(resourceName: "ic_lux")
                carImage = #imageLiteral(resourceName: "lux")
            default:
                carAnnotation = #imageLiteral(resourceName: "pink_car_map_pin")
                carImage = #imageLiteral(resourceName: "pink_default")
            }
        }
    }
    var carID = Int()
}
