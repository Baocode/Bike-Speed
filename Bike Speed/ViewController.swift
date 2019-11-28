//
//  ViewController.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 30/08/2019.
//  Copyright © 2019 BaoCode. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {


    let locationManager = CLLocationManager()
    var speed: CLLocationSpeed = CLLocationSpeed()
    var altitude: CLLocationDistance = CLLocationDistance()
    var actualDistance: CLLocationDistance = CLLocationDistance()
    var distanceMgr: DistanceMgr = DistanceMgr()
    var previousLocation: CLLocation = CLLocation()
    
    
    
    @IBOutlet weak var speedLabelUI: UILabel!
    @IBOutlet weak var altitudeLabelUI: UILabel!
    @IBOutlet weak var distanceLabelUi: UILabel!
    
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        
        locationManager.delegate = self
        if NSString(string:UIDevice.current.systemVersion).doubleValue > 8 {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let location = locationManager.location{
            if (location.speed <= 0)
            {
                speed = 0
            }else{
                speed = location.speed*3600/1000;
            }
            actualDistance = distanceMgr.calculDistanceTotale(actualPosition: location)
            altitude = location.altitude
            map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }
        speedLabelUI.text = String(format: "%.2f", speed)
        altitudeLabelUI.text = String(format: "%.2f", altitude)
        distanceLabelUi.text = String(format: "%.2f", actualDistance)
        

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("hello")
        let location: CLLocation = manager.location!;
        let eventDate: Date = location.timestamp;
        let howRecent: TimeInterval = eventDate.timeIntervalSinceNow;
        if (abs(howRecent) < 15.0) {
            // If the event is recent, do something with it.
            NSLog("latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude, location.coordinate.longitude);
            if (location.speed <= 0){
                speed = 0
            }else{
                speed = location.speed*3600/1000;
            }
                altitude = location.altitude
            }
                print("speed = \(speed)");
                speedLabelUI.text = String(format: "%.2f", speed)
                altitudeLabelUI.text = String(format: "%.2f", altitude)
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//              print("locations = \(locValue.latitude) \(locValue.longitude)")
//
////        print("hello")
////        if let lastLocations = locations {
//            let location: CLLocation = lastLocations[lastLocations.endIndex] as! CLLocation;
//            let eventDate: Date = location.timestamp;
//            let howRecent: TimeInterval = eventDate.timeIntervalSinceNow;
//            if (abs(howRecent) < 15.0) {
//                // If the event is recent, do something with it.
//                NSLog("latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude, location.coordinate.longitude);
//                if (location.speed <= 0){
//                    speed = 0
//                }else{
//                    speed = location.speed;
//                }
//                altitude = location.altitude
//            }
//            print("speed = \(speed)");
//            speedLabelUI.text = "\(speed)"
//            altitudeLabelUI.text = "\(altitude)"
//        }
    
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.denied{
          locationManager.startUpdatingLocation()
      }
    }

}

