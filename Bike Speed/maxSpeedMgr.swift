//
//  maxSpeedMgr.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 27/01/2020.
//  Copyright © 2020 BaoCode. All rights reserved.
//

import Foundation
import CoreLocation

class MaxSpeedMgr {
    var maxSpeed : CLLocationSpeed = CLLocationSpeed()
    
    func checkMaxSpeed(actualSpeed: CLLocationSpeed) -> CLLocationSpeed {
        if actualSpeed > maxSpeed{
            maxSpeed = actualSpeed
            return (maxSpeed * 3600/1000)
        }else {
            return (maxSpeed * 3600/1000)
        }
    }
}
