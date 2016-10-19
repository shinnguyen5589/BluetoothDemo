//
//  BluetoothConnection.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 8/31/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import Foundation
import CoreBluetooth

// Scan Error
public enum ScanError: ErrorType {
    case NoCentralManagerSet
    case IsScanning
    case Interrupted
    case BluetoothNotAvaiable
}

public typealias ScanProgressHandler = ((newDevices: [BluetoothDevice]) -> Void)?
public typealias ScanCompletionHandler = ((result: [BluetoothDevice], error: ScanError?) -> Void)?

/// The bluetooth connection pool
public class BluetoothConnectionPool: NSObject {
    
    // CoreBluetooth related
    private var blueToothReady = false
    private var centralManager: CBCentralManager!
    
    // Connection Attempt List
    private var connectionAttempts = [ConnectionAttempt]() // contains connecting and connected attempts
    
    // Bluetooth Device List
    private var deviceList: [BluetoothDevice] = [] // contains all devices which have been scanned
    
    // Scan process
    private var scanHandlers: (progressHandler: ScanProgressHandler, completionHandler: ScanCompletionHandler)?
    private var scanDurationTimer: NSTimer?
    private var isScanning: Bool = false
    
    // MARK: Init BluetoothConnection
    override public init () {
        super.init()
        /// Init CBCentralManager
        startUpCentralManager()
    }
}

extension BluetoothConnectionPool {
    // MARK: Public Methods
    /**
     Scan for peripherals for a limited duration of time.
     - parameter duration: The number of seconds to scan for
     - parameter progressHandler: A progress handler allowing you to react immediately when a peripheral is discovered during scan.
     - parameter completionHandler: A completion handler allowing you to react on the full result of discovered peripherals or an error if one occured.
     */
    public func scanWithDuration(duration: NSTimeInterval, progressHandler: ScanProgressHandler, completionHandler: ScanCompletionHandler) {
        scanHandlers = (progressHandler: progressHandler, completionHandler: completionHandler)
        
        if isScanning == true {
            scanHandlers?.completionHandler?(result: [], error: .IsScanning)
            return
        }
        
        if centralManager == nil {
            scanHandlers?.completionHandler?(result: [], error: .NoCentralManagerSet)
            return
        }
        
        if blueToothReady == false {
            scanHandlers?.completionHandler?(result: [], error: .BluetoothNotAvaiable)
            return
        }
        
        isScanning = true
        retrieveConnectedPeripheral()
        centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: 0])
        scanDurationTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(self.scanDurationTimerElapsed), userInfo: nil, repeats: false)
    }
    
    /**
     Connect to a bluetooth device.
     - parameter timeout: The number of seconds the connection attempt should continue for before failing.
     - parameter bluetoothDevice: The bluetooth device connect to.
     - parameter connectCompletionHandler: A completion handler allowing you to react when connect succeed or failed.
     */
    public func connect(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, connectCompletionHandler: ConnectCompletionHandler) {
        self.connectWithTimeout(timeout, bluetoothDevice: bluetoothDevice) { bluetoothDevice, error in
            if error == nil {
                //
            } else {
                //
            }
            connectCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: error)
        }
    }
    
    /**
     Discover services of a bluetooth device.
     - parameter timeout: The number of seconds the discover services attempt should continue for before failing.
     - parameter bluetoothDevice: The bluetooth device want to discover services.
     - parameter discoverServicesCompletionHandler: A completion handler allowing you to react when discover services succeed or failed.
     */
    public func discoverServices(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, discoverServicesCompletionHandler: DiscoverServicesCompletionHandler) {
        self.discoverServicesWithTimeout(timeout, bluetoothDevice: bluetoothDevice) { (bluetoothDeviceEntity, error) in
            if error == nil {
                //
            } else {
                //
            }
            discoverServicesCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: error)
        }
    }
    
    /**
     Discover characteristics for a service of bluetooth device.
     - parameter timeout: The number of seconds the discover characteristics attempt should continue for before failing.
     - parameter bluetoothDevice: The bluetooth device want to discover characteristics.
     - parameter discoverCharacteristicsCompletionHandler: A completion handler allowing you to react when discover characteristics succeed or failed.
     */
    public func discoverCharacteristics(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, discoverCharacteristicsCompletionHandler: DiscoverCharacteristicsCompletionHandler) {
        self.discoverCharacteristicsWithTimeout(timeout, bluetoothDevice: bluetoothDevice, discoverCharacteristicsCompletionHandler: { (bluetoothDeviceEntity, error) in
            if error == nil {
                //
            } else {
                //
            }
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: error)
        })
    }
    
    /**
     Send data for a characteristic of bluetooth device.
     - parameter timeout: The number of seconds the send data attempt should continue for before failing.
     - parameter data: Data to send
     - parameter bluetoothDevice: The bluetooth device want to send data to.
     - parameter sentDataCompletionHandler: A completion handler allowing you to react when discover characteristics succeed or failed.
     */
    public func sendData(timeout: NSTimeInterval, data: NSData, bluetoothDevice: BluetoothDevice, sentDataCompletionHandler: SentDataCompletionHandler) {
        self.sendDataWithTimeout(timeout, data: data, bluetoothDevice: bluetoothDevice, sentDataCompletionHandler: { (bluetoothDeviceEntity, responseData, error) in
            if error == nil {
                //
            } else {
                //
            }
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: responseData, error: error)
        })
    }
}

extension BluetoothConnectionPool {
    // MARK: Private Methods
    /// Init CBCentralManager
    private func startUpCentralManager() {
        print("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Retrieve Connected Peripheral List
    private func retrieveConnectedPeripheral() {
        let serviceUUIDs:[CBUUID] = [CBUUID(string: Service_UUID_String)]
        let connectedPeripherals = centralManager.retrieveConnectedPeripheralsWithServices(serviceUUIDs)
        
        for peripheral in connectedPeripherals {
            let device = bluetoothDeviceFromPeripheral(peripheral, RSSI: nil)
            deviceList.append(device)
        }
    }
    
    private func sendDataForCharacteristic(peripheral: CBPeripheral, data: NSData, forCharacteristic characteristic: CBCharacteristic) {
        if peripheral.state == .Connected {
            // start writing value for this characteristic
            peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }
    
    private func connectWithTimeout(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, connectCompletionHandler: ConnectCompletionHandler) {
        
        if centralManager == nil {
            connectCompletionHandler?(bluetoothDeviceEntity:bluetoothDevice, error: .NoCentralManagerSet)
            return
        }
        
        if blueToothReady == false {
            connectCompletionHandler?(bluetoothDeviceEntity:bluetoothDevice, error: .BluetoothNotAvaiable)
            return
        }
        
        var connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(bluetoothDevice.peripheral!)
        if connectionAttempt == nil {
            // init connectionAttempt
            connectionAttempt = ConnectionAttempt(bluetoothDevice: bluetoothDevice)
            connectionAttempt.connectionState = .Disconnected
        }
        
        if connectionAttempt.connectionState != .Disconnected {
            connectCompletionHandler?(bluetoothDeviceEntity:bluetoothDevice, error: .InvalidConnectionState)
            return
        }
        
        // start timer, assign block to connectionAttempt
        connectionAttempt.connectCompletionHandler = connectCompletionHandler
        let timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: #selector(self.connectionTimerElapsed(_:)), userInfo: nil, repeats: false)
        connectionAttempt.timer = timer
        connectionAttempt.connectionState = .Connecting
        
        // append to connectionAttempts
        connectionAttempts.append(connectionAttempt)
        
        // start connecting to peripheral
        centralManager.connectPeripheral(bluetoothDevice.peripheral!, options: nil)
    }
    
    private func discoverServicesWithTimeout(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, discoverServicesCompletionHandler: DiscoverServicesCompletionHandler) {
        
        if centralManager == nil {
            discoverServicesCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .NoCentralManagerSet)
            return
        }
        
        if blueToothReady == false {
            discoverServicesCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .BluetoothNotAvaiable)
            return
        }
        
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(bluetoothDevice.peripheral!)
        if connectionAttempt == nil {
            discoverServicesCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .InvalidConnectionState)
            return
        }
        
        if connectionAttempt.connectionState != .Connected {
            discoverServicesCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .InvalidConnectionState)
            return
        }
        
        // start timer, assign block to connectionAttempt
        connectionAttempt.discoverServicesCompletionHandler = discoverServicesCompletionHandler
        connectionAttempt.timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: #selector(self.discoverServicesTimerElapsed(_:)), userInfo: nil, repeats: false)
        connectionAttempt.connectionState = .Busy
        
        // start discovering services
        bluetoothDevice.peripheral!.delegate = self
        bluetoothDevice.peripheral!.discoverServices(nil)
    }
    
    private func discoverCharacteristicsWithTimeout(timeout: NSTimeInterval, bluetoothDevice: BluetoothDevice, discoverCharacteristicsCompletionHandler: DiscoverCharacteristicsCompletionHandler) {
        
        if centralManager == nil {
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .NoCentralManagerSet)
            return
        }
        
        if blueToothReady == false {
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .BluetoothNotAvaiable)
            return
        }
        
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(bluetoothDevice.peripheral!)
        if connectionAttempt == nil {
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .InvalidConnectionState)
            return
        }
        
        if connectionAttempt.connectionState != .ServicesDiscovered {
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .InvalidConnectionState)
            return
        }
        
        if connectionAttempt.validService == nil {
            discoverCharacteristicsCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, error: .InvalidService)
            return
        }
        
        // start timer, assign block to connectionAttempt
        connectionAttempt.discoverCharacteristicsCompletionHandler = discoverCharacteristicsCompletionHandler
        connectionAttempt.timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: #selector(self.discoverCharacteristicsTimerElapsed(_:)), userInfo: nil, repeats: false)
        connectionAttempt.connectionState = .Busy
        
        // start discovering characteristics
        bluetoothDevice.peripheral!.discoverCharacteristics(nil, forService: connectionAttempt.validService!)
    }
    
    private func sendDataWithTimeout(timeout: NSTimeInterval, data: NSData, bluetoothDevice: BluetoothDevice, sentDataCompletionHandler: SentDataCompletionHandler) {
        
        if centralManager == nil {
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: nil, error: .NoCentralManagerSet)
            return
        }
        
        if blueToothReady == false {
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: nil, error: .BluetoothNotAvaiable)
            return
        }
        
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(bluetoothDevice.peripheral!)
        if connectionAttempt == nil {
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: nil, error: .InvalidConnectionState)
            return
        }
        
        if connectionAttempt.connectionState != .CharacteristicsDiscovered {
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: nil, error: .InvalidConnectionState)
            return
        }
        
        if connectionAttempt.validCharacteristic == nil {
            sentDataCompletionHandler?(bluetoothDeviceEntity: bluetoothDevice, responseData: nil, error: .InvalidCharacteristic)
            return
        }
        
        // start timer, assign block to connectionAttempt
        connectionAttempt.sentDataCompletionHandler = sentDataCompletionHandler
        connectionAttempt.timer = NSTimer.scheduledTimerWithTimeInterval(timeout, target: self, selector: #selector(self.sendDataTimerElapsed(_:)), userInfo: nil, repeats: false)
        connectionAttempt.connectionState = .Busy
        
        // start sending data
        self.sendDataForCharacteristic(bluetoothDevice.peripheral!, data: data, forCharacteristic: connectionAttempt.validCharacteristic!)
    }
    
    @objc private func scanDurationTimerElapsed() {
        endScan(nil)
    }
    
    @objc private func connectionTimerElapsed(timer: NSTimer) {
        failConnectionAttempt(connectionAttemptForTimer(timer)!, error: .ConnectionTimeoutElapsed)
    }
    
    @objc private func discoverServicesTimerElapsed(timer: NSTimer) {
        failDiscoverServices(connectionAttemptForTimer(timer)!, error: .DiscoverServicesTimeoutElapsed)
    }
    
    @objc private func discoverCharacteristicsTimerElapsed(timer: NSTimer) {
        failDiscoverCharacteristics(connectionAttemptForTimer(timer)!, error: .DiscoverCharacteristicsTimeoutElapsed)
    }
    
    @objc private func sendDataTimerElapsed(timer: NSTimer) {
        failSendData(connectionAttemptForTimer(timer)!, error: .SendDataTimeoutElapsed)
    }
    
    private func endScan(error: ScanError?) {
        invalidateTimer(scanDurationTimer)
        centralManager.stopScan()
        let devices = self.deviceList
        self.deviceList.removeAll()
        scanHandlers = nil
        isScanning = false
        // call back completionHandler for scanning
        scanHandlers?.completionHandler?(result: devices, error: error)
    }
    
    private func succeedConnectionAttempt(connectionAttempt: ConnectionAttempt) {
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.connectionState = .Connected
        connectionAttempt.connectCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, error: nil)
    }
    
    private func failConnectionAttempt(connectionAttempt: ConnectionAttempt, error: ConnectionError) {
        invalidateTimer(connectionAttempt.timer)
        let connectCompletionHandler = connectionAttempt.connectCompletionHandler
        switch error {
        case .ConnectionTimeoutElapsed:
            connectionAttempt.connectionState = .Disconnected
            if let peripheral = connectionAttempt.bluetoothDevice.peripheral {
                centralManager.cancelPeripheralConnection(peripheral)
                connectionAttempts.removeAtIndex(connectionAttempts.indexOf(connectionAttempt)!)
            }
        default:
            print(connectionAttempt.connectionState)
        }
        connectCompletionHandler??(bluetoothDeviceEntity:connectionAttempt.bluetoothDevice, error: error)
    }
    
    private func succeedDiscoverServices(connectionAttempt: ConnectionAttempt, service: CBService) {
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.connectionState = .ServicesDiscovered
        connectionAttempt.validService = service
        connectionAttempt.discoverServicesCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, error: nil)
    }
    
    private func failDiscoverServices(connectionAttempt: ConnectionAttempt, error: ConnectionError) {
        switch error {
        case .DiscoverServicesTimeoutElapsed:
            connectionAttempt.connectionState = .Connected
        default:
            print(connectionAttempt.connectionState)
        }
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.discoverServicesCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, error: error)
    }
    
    private func succeedDiscoverCharacteristics(connectionAttempt: ConnectionAttempt, characteristic: CBCharacteristic) {
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.connectionState = .CharacteristicsDiscovered
        connectionAttempt.validCharacteristic = characteristic
        connectionAttempt.discoverCharacteristicsCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, error: nil)
    }
    
    private func failDiscoverCharacteristics(connectionAttempt: ConnectionAttempt, error: ConnectionError) {
        switch error {
        case .DiscoverCharacteristicsTimeoutElapsed:
            connectionAttempt.connectionState = .ServicesDiscovered
        default:
            print(connectionAttempt.connectionState)
        }
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.discoverCharacteristicsCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, error: error)
    }
    
    private func succeedSendData(connectionAttempt: ConnectionAttempt, data: NSData?) {
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.connectionState = .CharacteristicsDiscovered
        connectionAttempt.sentDataCompletionHandler??(bluetoothDeviceEntity: connectionAttempt.bluetoothDevice, responseData: data, error: nil)
    }
    
    private func failSendData(connectionAttempt: ConnectionAttempt, error: ConnectionError) {
        invalidateTimer(connectionAttempt.timer)
        connectionAttempt.connectionState = .CharacteristicsDiscovered
        connectionAttempt.sentDataCompletionHandler??(bluetoothDeviceEntity:connectionAttempt.bluetoothDevice, responseData: nil, error: error)
    }
    
    private func connectionAttemptForTimer(timer: NSTimer) -> ConnectionAttempt? {
        return connectionAttempts.filter({ $0.timer == timer }).last
    }
    
    private func connectionAttemptForPeripheral(peripheral: CBPeripheral) -> ConnectionAttempt? {
        return connectionAttempts.filter({ $0.bluetoothDevice.peripheral == peripheral }).last
    }
    
    private func bluetoothDeviceFromPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) -> BluetoothDevice {
        let device = BluetoothDevice(peri: peripheral)
        device.RSSI = RSSI
        device.distance = device.distanceByRSSI()
        if let name = peripheral.name {
            device.name = name
        } else {
            device.name = "Unknown"
        }
        return device
    }
    
    private func reset() {
        // clear connectionAttempts list
        for connectionAttempt in connectionAttempts {
            connectionAttempt.connectionState = .Disconnected
            invalidateTimer(connectionAttempt.timer)
        }
        connectionAttempts.removeAll()
        
        // interrupt scanning process
        interruptScan()
    }
    
    private func interruptScan() {
        if isScanning == true {
            endScan(.Interrupted)
        }
    }
    
    private func invalidateTimer(timer: NSTimer?) {
        if let timer = timer {
            timer.invalidate()
        }
    }
}

extension BluetoothConnectionPool: CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: CBCentralManagerDelegate, CBPeripheralDelegate Methods
    /// CoreBluetooth Methods
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .Unknown, .Resetting:
            blueToothReady = false
        case .Unsupported, .Unauthorized, .PoweredOff:
            blueToothReady = false
            self.reset()
        case .PoweredOn:
            blueToothReady = true
        }
    }
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if !deviceList.contains({ device in device.peripheral == peripheral }) {
            let device = bluetoothDeviceFromPeripheral(peripheral, RSSI: RSSI)
            deviceList.append(device)
            
            // order devices according to their distance to the user
            if deviceList.count > 1 {
                deviceList.sortInPlace() { $0.distanceByRSSI() < $1.distanceByRSSI() }
            }
            
            // call back progressHandler for scanning
            scanHandlers?.progressHandler?(newDevices: deviceList)
        }
    }
    
    /// Connected says central manager
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        let connectionAttempt: ConnectionAttempt? = connectionAttemptForPeripheral(peripheral)
        if let connectionAttempt = connectionAttempt {
            succeedConnectionAttempt(connectionAttempt)
        }
    }
    
    /// Fail to connect says central manager
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("did fail to connect peripheral")
    }
    
    /// Disconnected says central manager
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let connectionAttempt: ConnectionAttempt? = connectionAttemptForPeripheral(peripheral)
        if let connectionAttempt = connectionAttempt {
            invalidateTimer(connectionAttempt.timer)
            connectionAttempt.connectionState = .Disconnected
            connectionAttempts.removeAtIndex(connectionAttempts.indexOf(connectionAttempt)!)
        }
    }
    
    /// Service discovered
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(peripheral)
        
        if let error = error {
            failDiscoverServices(connectionAttempt, error: .Internal(underlyingError: error))
            return
        }
        
        var hasValidService = false
        // find valid service
        if let services = peripheral.services {
            for service in services {
                let thisService = service as CBService
                if thisService.UUID.UUIDString.lowercaseString == Service_UUID_String {
                    hasValidService = true
                    succeedDiscoverServices(connectionAttempt, service: thisService)
                }
            }
        }
        
        if hasValidService == false {
            failDiscoverServices(connectionAttempt, error: .InvalidService)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(peripheral)
        
        if let error = error {
            failDiscoverCharacteristics(connectionAttempt, error: .Internal(underlyingError: error))
            return
        }
        
        var hasValidCharacteristic = false
        // find valid characteristic
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                let thisCharacteristic = characteristic as CBCharacteristic
                if thisCharacteristic.UUID.UUIDString.lowercaseString == Characteristics_UUID_String {
                    hasValidCharacteristic = true
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    succeedDiscoverCharacteristics(connectionAttempt, characteristic: thisCharacteristic)
                }
            }
        }
        
        if hasValidCharacteristic == false {
            failDiscoverCharacteristics(connectionAttempt, error: .InvalidCharacteristic)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("did update value for characteristic")
    }
    
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        let connectionAttempt: ConnectionAttempt! = connectionAttemptForPeripheral(peripheral)
        
        if let error = error {
            failSendData(connectionAttempt, error: .Internal(underlyingError: error))
            return
        }
        
        if characteristic.UUID.UUIDString.lowercaseString == Characteristics_UUID_String {
            succeedSendData(connectionAttempt, data: characteristic.value)
        } else {
            failSendData(connectionAttempt, error: .InvalidCharacteristic)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("did update notification state for characteristic")
    }
}




