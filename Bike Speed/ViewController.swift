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
        
    let locationManager = CLLocationManager() //cntrole de la position objet de CoreLocation
    var actualSpeed: CLLocationSpeed = CLLocationSpeed() //vitesse actuelle
    var actualElevation: CLLocationDistance = CLLocationDistance() // altitude actuelle
    var actualDistance: CLLocationDistance = CLLocationDistance() // distance réalisée sur le parcourt
    var actualAverage: CLLocationSpeed = CLLocationSpeed() // vitesse moyenne sur le parcourt en cour réalisée sur le parcourt
    var actualMaxSpeed: CLLocationSpeed = CLLocationSpeed() // vitesse max sur le parcourt en cour réalisée sur le parcourt
    
    var distanceMgr: DistanceMgr = DistanceMgr() //objet de gestion du calcul de la distance
    var averageMgr : AverageMgr = AverageMgr() //objet de gestion de la vitesse moyenne
    var maxSpeedMgr : MaxSpeedMgr = MaxSpeedMgr() // objet de gestion de la vitesse max
    var timerMgr: TimerMgr = TimerMgr() // objet de gestion du chronomètre
    
    var previousLocation: CLLocation = CLLocation()
    
    var pauseOn:Bool = false // controleur d'état de la pause
    
    // Controleur de la vue
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
        
        // mise en route du GPS et controle des autorisation nécessaire
        locationManager.delegate = self
        if NSString(string:UIDevice.current.systemVersion).doubleValue > 8 {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        // paraméterage du GPS
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //
        chronoUITimerMgr() //lancement du rafraichissement du chrono
        
        // démarage de l'enregistrament dès la réception d'un premier signal GPS
        if let location = locationManager.location{
            updateInformation(location: location)
            timerMgr.startTimer()
        }
    }

    // Gestion du bouton pause
    @IBAction func pauseButton(_ sender: Any) {
        if pauseOn {
            locationManager.startUpdatingLocation()
            pauseButtonUI.tintColor = UIColor.white
            pauseOn = false
            chronoUITimerMgr()
        }else{
            pauseOn = true
            locationManager.stopUpdatingLocation()
            pauseButtonUI.tintColor = UIColor.red
        }
    }
    
    // Gestion des erreurs GPS
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.denied{
            locationManager.startUpdatingLocation()
        }
    }
    
    // reception d'une nouvelle position GPS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last{
            if UIApplication.shared.applicationState == .active { // verifiction si l'application est en BackGround
                updateInformation(location: lastLocation);
                
            } else { // action à réaliser en BG
                backGroundUpdateInformation(location: lastLocation)
                
            }
        }
    }
    
    // action réaliser en BG
    func backGroundUpdateInformation(location: CLLocation){
        if !pauseOn {
            let eventDate: Date = location.timestamp;
            let howRecent: TimeInterval = eventDate.timeIntervalSinceNow;
            print(timerMgr.time)
            if (abs(howRecent) < 15.0) {
                // If the event is recent, do something with it.
                if (location.speed <= 0){
                    actualSpeed = 0
                }else{
                    actualSpeed = location.speed*3600/1000;
                    actualAverage = averageMgr.calculateAverage(currentSpeed: location.speed)
                    actualMaxSpeed = maxSpeedMgr.checkMaxSpeed(actualSpeed: location.speed)
                }
                actualElevation = location.altitude
                if (location.horizontalAccuracy < 6) {
                    actualDistance = distanceMgr.calculDistanceTotale(actualPosition: location)
                }
            }
        }
    }
    
    // mise à jour des informations lors de la réception d'une nouvelle position
    func updateInformation(location: CLLocation){
        if !pauseOn {//controle si la pause est allumé
            let eventDate: Date = location.timestamp; //récupération du time stamps des derniers relevé GPS
            let howRecent: TimeInterval = eventDate.timeIntervalSinceNow //controle du temps pour vérifier si le point relevé est encore valide
            if (abs(howRecent) < 5.0) { //si le dernier relevé gps est inférieur à 5s on le prend en compte
                if (location.speed <= 0){ // relevé de la vitesse actuel uniquement si > 1
                    actualSpeed = 0
                }else{
                    actualSpeed = location.speed*3600/1000;
                    actualAverage = averageMgr.calculateAverage(currentSpeed: location.speed) // calcul de la cvitesse moyenne
                    actualMaxSpeed = maxSpeedMgr.checkMaxSpeed(actualSpeed: location.speed) // vérification si V max et toujours vrai
                }
                actualElevation = location.altitude // mis à jour de l'atitude
                if (location.horizontalAccuracy < 6) { //Calcul de la distance si la précision du relevé est inférieur à 6 m
                    actualDistance = distanceMgr.calculDistanceTotale(actualPosition: location)
                }
            }
            
            //ui update
            speedLabelUI.text = String(format: "%.2f", actualSpeed)
            altitudeLabelUI.text = String(format: "%.2f", actualElevation)
            distanceLabelUi.text = String(format: "%.2f", actualDistance)
            averageSpeedLabelUi.text = String(format: "%.2f", actualAverage)
            maxSpeedLabelUi.text = String(format: "%.2f", actualMaxSpeed)
            
            //déplacement de la map centrée sur le curseur 
            map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }
    }
    
    
    //Raffraichissement affichage du chrono
    private func chronoUITimerMgr() {
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

