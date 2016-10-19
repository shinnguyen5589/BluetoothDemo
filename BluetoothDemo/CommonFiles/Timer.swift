//
//  Timer.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 9/5/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import UIKit

public class Timer: NSObject {
    
    public var time: Int
    private var count: Int = 0
    private var timer: NSTimer!
    private var timerEndedCallback: (() -> Void)!
    private var timerInProgressCallback: ((elapsedTime: Int) -> Void)!
    
    init(time: Int) {
        self.time = time
    }
    
    public func startTimer(timerEnded: () -> Void, timerInProgress: ((elapsedTime: Int) -> Void)!) {
        stopTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        timerEndedCallback = timerEnded
        timerInProgressCallback = timerInProgress
    }
    
    public func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        count = 0
    }
    
    @objc private func updateTime() {
        count += 1
        if count == time {
            stopTimer()
            // fire an event
            timerEndedCallback()
        } else {
            timerInProgressCallback(elapsedTime: count)
        }
    }
    
}




