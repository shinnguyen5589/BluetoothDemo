//
//  StringPublicDefine.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 8/31/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import Foundation

// MARK: Public String
// Public String
let Peripheral_UUID_String = "YOUR_PERIPHERAL_UUID_STRING"
let Service_UUID_String = "YOUR_SERVICE_UUID_STRING"
let Characteristics_UUID_String = "YOUR_CHARACTERISTICS_UUID_STRING"
let ITEM_CELL_REUSE_IDENTIFIER = "itemCellReuseIdentifier"
let CONNECTION_TIME_OUT: NSTimeInterval = 10 // 10 seconds
let DISCOVER_AND_SEND_TIME_OUT: NSTimeInterval = 3 // 3 seconds
let SCAN_DURATION: NSTimeInterval = 5 // 5 seconds
let MESSAGE_PLAY_LED: [UInt8] = [0x02, 0xf1, 0x05] // 0x02f105

// MARK: Public Enum
// Public Enum
public enum MessageType {
    case SentMessageSucceed // Sent Message
    case SentMessageFailed
    case SentMessageTimeout
    case InvalidService // Service
    case DiscoverServicesFailed
    case DiscoverServicesTimeOut
    case InvalidCharacteristic // Characteristic
    case DiscoverCharacteristicsFailed
    case DiscoverCharacteristicsTimeOut
    case BlueToothOff // Bluetooth off
    case ConnectionTimeOut // Connection
    case IsNotBluetoothDevice
}







