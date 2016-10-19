//
//  SendAttempt.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 9/7/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import Foundation

internal func == (lhs: SendAttempt, rhs: SendAttempt) -> Bool {
    return (lhs.bluetoothDevice.peripheral?.identifier.isEqual(rhs.bluetoothDevice.peripheral?.identifier))!
}

internal class SendAttempt: Equatable {
    
    // MARK: Properties
    
    internal var timer: NSTimer
    internal let bluetoothDevice: BluetoothDevice
    // internal let completionHandler: ConnectAndSentCompletionHandler
    internal let uuidString : String
    internal var state: ConnectionState?
    
    // MARK: Initialization
    
    internal init(bluetoothDevice: BluetoothDevice, timer: NSTimer, uuidString: String) {
        self.bluetoothDevice = bluetoothDevice
        self.timer = timer
        self.uuidString = uuidString
    }
    
}


