//
//  DistanceMgr.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 22/11/2019.
//  Copyright © 2019 BaoCode. All rights reserved.
//

import Foundation
import CoreLocation
class DistanceMgr {
    var distanceTotale: CLLocationDistance = CLLocationDistance()
    var prevDist: CLLocationDistance = CLLocationDistance()
    var previousPosition: CLLocation? = nil
 
    func calculDistanceTotale( actualPosition: CLLocation) -> CLLocationDistance {
        if let prevPosition = previousPosition{
            let dist = actualPosition.distance(from: prevPosition)/1000
            if dist != prevDist
            {
                distanceTotale = distanceTotale + dist
                previousPosition = actualPosition
            }   
            prevDist = dist
            return distanceTotale
        }else{
            previousPosition = actualPosition
            distanceTotale = distanceTotale + actualPosition.distance(from: actualPosition)/1000
            return distanceTotale
        }
    }
}
