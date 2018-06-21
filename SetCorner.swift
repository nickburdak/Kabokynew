//
//  SetCorner.swift
//  kaboky
//
//  Created by Shivam Kheterpal on 23/01/17.
//  Copyright © 2017 Shivam Kheterpal. All rights reserved.
//

import UIKit

@IBDesignable
class SetCorner: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            setCorner()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            setCorner()
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            setCorner()
        }
    }
    
    func setCorner() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.masksToBounds = true
    }
    
    override public func prepareForInterfaceBuilder() {
        setCorner()
    }
}
