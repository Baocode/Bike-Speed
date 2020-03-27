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
import BackgroundTasks

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    let locationManager = CLLocationManager()
    var speed: CLLocationSpeed = CLLocationSpeed()
    var altitude: CLLocationDistance = CLLocationDistance()
    var actualDistance: CLLocationDistance = CLLocationDistance()
    var actualAverage: CLLocationSpeed = CLLocationSpeed()
    var actualMaxSpeed: CLLocationSpeed = CLLocationSpeed()
    
    var distanceMgr: DistanceMgr = DistanceMgr()
    var averageMgr : AverageMgr = AverageMgr()
    var maxSpeedMgr : MaxSpeedMgr = MaxSpeedMgr()
    var timerMgr: TimerMgr = TimerMgr()
    
    var previousLocation: CLLocation = CLLocation()
    var pauseOn:Bool = false
    
    
    
    @IBOutlet weak var speedLabelUI: UILabel!
    @IBOutlet weak var altitudeLabelUI: UILabel!
    @IBOutlet weak var distanceLabelUi: UILabel!
    @IBOutlet weak var pauseButtonUI: RoundButton!
    @IBOutlet weak var averageSpeedLabelUi: UILabel!
    @IBOutlet weak var maxSpeedLabelUi: UILabel!
    @IBOutlet weak var hoursLabelUI: UILabel!
    @IBOutlet weak var minutsLabelUI: UILabel!
    @IBOutlet weak var secondsLabelUI: UILabel!
    
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIApplication.shared.isIdleTimerDisabled = true //empèche la mise en veille de l'écran
        
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
            updateInformation(location: location)
            timerMgr.startTimer()
        }
        startTimerUi()
    }
    
    
    
    @IBAction func pauseButton(_ sender: Any) {
        
        if pauseOn {
            locationManager.startUpdatingLocation()
            pauseButtonUI.tintColor = UIColor.white
            pauseOn = false
            startTimerUi()
        }else{
            pauseOn = true
            locationManager.stopUpdatingLocation()
            pauseButtonUI.tintColor = UIColor.red
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last{
            if UIApplication.shared.applicationState == .active {
                updateInformation(location: lastLocation);
            } else {
                backGroundUpdateInformation(location: lastLocation)
            }
        }
    }
    
    func backGroundUpdateInformation(location: CLLocation){
        
        if !pauseOn {
            let eventDate: Date = location.timestamp;
            let howRecent: TimeInterval = eventDate.timeIntervalSinceNow;
            print(timerMgr.time)
            if (abs(howRecent) < 15.0) {
                // If the event is recent, do something with it.
                if (location.speed <= 0){
                    speed = 0
                }else{
                    speed = location.speed*3600/1000;
                    actualAverage = averageMgr.calculateAverage(currentSpeed: location.speed)
                    actualMaxSpeed = maxSpeedMgr.checkMaxSpeed(actualSpeed: location.speed)
                }
                altitude = location.altitude
                if (location.horizontalAccuracy < 6) {
                    actualDistance = distanceMgr.calculDistanceTotale(actualPosition: location)
                }
            }
        }
    }
    
    
    func updateInformation(location: CLLocation){
        if !pauseOn {
            let eventDate: Date = location.timestamp;
            let howRecent: TimeInterval = eventDate.timeIntervalSinceNow;
            if (abs(howRecent) < 15.0) {
                // If the event is recent, do something with it.
                //NSLog("latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude, location.coordinate.longitude);
                if (location.speed <= 0){
                    speed = 0
                }else{
                    speed = location.speed*3600/1000;
                    actualAverage = averageMgr.calculateAverage(currentSpeed: location.speed)
                    actualMaxSpeed = maxSpeedMgr.checkMaxSpeed(actualSpeed: location.speed)
                }
                altitude = location.altitude
                if (location.horizontalAccuracy < 6) {
                    actualDistance = distanceMgr.calculDistanceTotale(actualPosition: location)
                }
            }
            
            speedLabelUI.text = String(format: "%.2f", speed)
            altitudeLabelUI.text = String(format: "%.2f", altitude)
            distanceLabelUi.text = String(format: "%.2f", actualDistance)
            averageSpeedLabelUi.text = String(format: "%.2f", actualAverage)
            maxSpeedLabelUi.text = String(format: "%.2f", actualMaxSpeed)
                      
            map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }
    }
    
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.denied{
            locationManager.startUpdatingLocation()
        }
    }
    
    private func startTimerUi() {

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !self.pauseOn {
                if self.timerMgr.chrono.hours < 10{
                    self.hoursLabelUI.text = ("0\(self.timerMgr.chrono.hours)")
                }else {
                    self.hoursLabelUI.text = ("\(self.timerMgr.chrono.hours)")
                }
                if self.timerMgr.chrono.minutes < 10{
                    self.minutsLabelUI.text = ("0\(self.timerMgr.chrono.minutes)")
                }else {
                    self.minutsLabelUI.text = ("\(self.timerMgr.chrono.minutes)")
                }
                if self.timerMgr.chrono.second < 10{
                    self.secondsLabelUI.text = ("0\(self.timerMgr.chrono.second)")
                }else {
                    self.secondsLabelUI.text = ("\(self.timerMgr.chrono.second)")
                }
            }
           else {
                timer.invalidate()
            }
        }
    }
    
}

