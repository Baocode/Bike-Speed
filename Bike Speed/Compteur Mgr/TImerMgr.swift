 //
//  TImer.swift
//  Bike Speed
//
//  Created by Arnaud Lacroix on 24/03/2020.
//  Copyright © 2020 BaoCode. All rights reserved.
//

import Foundation

 class  TimerMgr {
    var time : Int = 0
    var timer = Timer()
    var chrono : Chrono = Chrono()

    
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDidEnd),userInfo: nil, repeats: true)
    }
 
    @objc public func timerDidEnd(){
        time += 1
        chrono.hours = time / (60*60)
        chrono.minutes = (time/60)%60
        chrono.second = time % 60
    }
    func pauseTimer(){
        timer.invalidate()
       }
    func stopAndResetTimer() {
        timer.invalidate()
        time = 0
    }
    
 }
