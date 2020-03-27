//
//  RoundButton.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 30/11/2019.
//  Copyright © 2019 BaoCode. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundButton:UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor : UIColor = .clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
}
