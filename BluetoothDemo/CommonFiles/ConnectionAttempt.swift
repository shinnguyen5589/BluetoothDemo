//
//  BluetoothConnection.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 9/6/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import Foundation
import CoreBluetooth

// Connection Error
public enum ConnectionError: ErrorType {
    case BluetoothNotAvaiable
    case NoCentralManagerSet
    case InvalidConnectionState
    case Interrupted
    case ConnectionTimeoutElapsed
    case DiscoverServicesTimeoutElapsed
    case DiscoverCharacteristicsTimeoutElapsed
    case SendDataTimeoutElapsed
    case InvalidService
    case InvalidCharacteristic
    case Internal(underlyingError: ErrorType?)
}

public typealias ConnectCompletionHandler = ((bluetoothDeviceEntity: BluetoothDevice, error: ConnectionError?) -> Void)?
public typealias DiscoverServicesCompletionHandler = ((bluetoothDeviceEntity: BluetoothDevice, error: ConnectionError?) -> Void)?
public typealias DiscoverCharacteristicsCompletionHandler = ((bluetoothDeviceEntity: BluetoothDevice, error: ConnectionError?) -> Void)?
public typealias SentDataCompletionHandler = ((bluetoothDeviceEntity: BluetoothDevice, responseData: NSData?, error: ConnectionError?) -> Void)?

public enum ConnectionState {
    case Disconnected, Connecting, Connected, ServicesDiscovered, CharacteristicsDiscovered, Busy
}

// Define compare equal for ConnectionAttempt
internal func == (lhs: ConnectionAttempt, rhs: ConnectionAttempt) -> Bool {
    return (lhs.bluetoothDevice.peripheral?.identifier.isEqual(rhs.bluetoothDevice.peripheral?.identifier))!
}

internal class ConnectionAttempt: Equatable {
    
    // MARK: Properties
    
    internal var timer: NSTimer? // for all actions (connect, discover services, discover characteristics, send data)
    internal let bluetoothDevice: BluetoothDevice // device connect to
    
    internal var connectCompletionHandler: ConnectCompletionHandler? // completion handler for connect process
    internal var discoverServicesCompletionHandler: DiscoverServicesCompletionHandler? // completion handler for discover services process
    internal var discoverCharacteristicsCompletionHandler: DiscoverCharacteristicsCompletionHandler? // completion handler for discover characteristics process
    internal var sentDataCompletionHandler: SentDataCompletionHandler? // completion handler for send data process
    
    internal var connectionState: ConnectionState? // state of connection (Disconnected, Connecting, Connected, ServicesDiscovered, CharacteristicsDiscovered, Busy)
    internal var validService: CBService? // valid service
    internal var validCharacteristic: CBCharacteristic? // valid characteristic
    
    // MARK: Initialization
    
    internal init(bluetoothDevice: BluetoothDevice) {
        self.bluetoothDevice = bluetoothDevice
    }
    
}








