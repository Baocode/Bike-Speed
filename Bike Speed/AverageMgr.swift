//
//  AverageMgr.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 27/01/2020.
//  Copyright © 2020 BaoCode. All rights reserved.
//

import Foundation
import CoreLocation

class AverageMgr {
    var speedSum: CLLocationSpeed = CLLocationSpeed();
    var speedIndex: Int = 0
    var averageSpeed: CLLocationSpeed = CLLocationSpeed()
    
    func calculateAverage(currentSpeed:CLLocationSpeed) -> CLLocationSpeed {
    
        speedSum = speedSum + currentSpeed;
        speedIndex += 1
        averageSpeed = (speedSum / Double(speedIndex)) * 3600/1000
        return averageSpeed
        
    }
}
