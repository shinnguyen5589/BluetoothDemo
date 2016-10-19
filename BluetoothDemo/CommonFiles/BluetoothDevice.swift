//
//  BluetoothDevice.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 9/8/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: class Device
/// A representation for device
public class Device {
    /// The name of the device
    public var name = ""
    /// the distance from the device to the iOS device
    public var distance: Double = 0.0
    
    public init () {
        
    }
}

// MARK: class BluetoothDevice
/// An bluetooth device
public class BluetoothDevice: Device {
    var peripheral: CBPeripheral?
    var RSSI: NSNumber?
    
    // https://gist.github.com/eklimcz/446b56c0cb9cfe61d575
    // return distance in meter
    func distanceByRSSI() -> Double {
        if let rssi = RSSI {
            let txPower: Double = -59 // hard code power value. Usually ranges between -59 to -65
            
            if rssi == 0 {
                return -1.0
            }
            
            let ratio = rssi.doubleValue * 1.0 / txPower
            if ratio < 1.0 {
                let distance = pow(ratio, 10)
                return distance
            } else {
                let distance =  (0.89976) * pow(ratio,7.7095) + 0.111
                return distance;
            }
        }
        return -1.0
    }
    
    /**
     Create a device using a CBPeripheral
     - parameter peri: the peripheral instance
     - returns: nil
     */
    public init(peri: CBPeripheral) {
        super.init()
        peripheral = peri
    }
    
    public override init () {
        super.init()
    }
}








