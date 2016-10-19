//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by Dung Nguyen on 8/29/16.
//  Copyright © 2016 Dung Nguyen. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: BaseViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: private - local params
    var connectionPool = BluetoothConnectionPool()
    var deviceList: [BluetoothDevice] = []
    
    // MARK: UIViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UITableViewDataSource and UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(ITEM_CELL_REUSE_IDENTIFIER) as! ItemTableViewCell
        
        let bluetoothDevice = self.deviceList[indexPath.row]
        cell.nameLbl.text = bluetoothDevice.name
        
        if bluetoothDevice.RSSI != nil {
            cell.rssiLabel.text = String(bluetoothDevice.RSSI!)
        } else {
            cell.rssiLabel.text = "0"
        }
        
        if bluetoothDevice.peripheral?.state == .Connected {
            cell.statusImgView.image = UIImage(named: "check")
        } else {
            cell.statusImgView.image = UIImage(named: "uncheck")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // self.showHudWithString("")
        let device = deviceList[indexPath.row]
        
        connectPeripheral(device)
        
        //        // action
        //        switch indexPath.row % 4 {
        //        case 0:
        //            //            for _ in 1...2 {
        //            //                connectPeripheral(device)
        //            //            }
        //
        ////            let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
        ////            randomTest(device, data: data)
        //        case 1:
        //            let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
        //            doFullAction(device, data: data)
        //        case 2:
        //            //            for _ in 1...4 {
        //            //                discoverCharacteristics(device)
        //            //            }
        //
        //            let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
        //            randomTest(device, data: data)
        //        case 3:
        //            //            for _ in 1...5 {
        //            //                let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
        //            //                sendData(device, data: data)
        //            //            }
        //
        //            let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
        //            randomTest(device, data: data)
        //        default:
        //            connectPeripheral(device)
        //        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    /// Reload cell with peripheral
    func reloadCellWithPeripheral(peripheral: CBPeripheral) {
        // self.tableView.reloadData()
        let rowNumber = self.deviceList.indexOf{$0.peripheral === peripheral}
        let indexPath = NSIndexPath(forRow: rowNumber!, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
}

extension ViewController {
    
    // MARK: Test Functions
    
    @IBAction func scanBtnTouch(sender: AnyObject) {
        scan()
    }
    
    private func connectPeripheral(bluetoothDevice: BluetoothDevice) {
        connectionPool.connect(5, bluetoothDevice: bluetoothDevice) { (bluetoothDeviceEntity, error) in
            if let error = error {
                print("connect peripheral fail with error: \(error)")
            } else {
                print("connect succeed")
            }
        }
    }
    
    private func discoverServices(bluetoothDevice: BluetoothDevice) {
        connectionPool.discoverServices(3, bluetoothDevice: bluetoothDevice) { (bluetoothDeviceEntity, error) in
            if let error = error {
                print("discover dervices fail with error: \(error)")
            } else {
                print("discover dervices succeed")
            }
        }
    }
    
    private func discoverCharacteristics(bluetoothDevice: BluetoothDevice) {
        connectionPool.discoverCharacteristics(3, bluetoothDevice: bluetoothDevice) { (bluetoothDeviceEntity, error) in
            if let error = error {
                print("discover characteristics fail with error: \(error)")
            } else {
                print("discover characteristics succeed")
            }
        }
    }
    
    private func sendData(bluetoothDevice: BluetoothDevice, data: NSData) {
        connectionPool.sendData(3, data: data, bluetoothDevice: bluetoothDevice) { (bluetoothDeviceEntity, responseData, error) in
            if let error = error {
                print("send data fail with error: \(error)")
            } else {
                print("send data succeed with responseData: \(responseData)")
            }
        }
    }
    
    private func doFullAction(bluetoothDevice: BluetoothDevice, data: NSData) {
        connectPeripheral(bluetoothDevice)
        
        let delay_1 = 5 * Double(NSEC_PER_SEC)
        let time_1 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay_1))
        dispatch_after(time_1, dispatch_get_main_queue()) {
            self.discoverServices(bluetoothDevice)
        }
        
        let delay_2 = 8 * Double(NSEC_PER_SEC)
        let time_2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay_2))
        dispatch_after(time_2, dispatch_get_main_queue()) {
            self.discoverCharacteristics(bluetoothDevice)
        }
        
        let delay_3 = 11 * Double(NSEC_PER_SEC)
        let time_3 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay_3))
        dispatch_after(time_3, dispatch_get_main_queue()) {
            self.sendData(bluetoothDevice, data: data)
        }
    }
    
    private func scan() {
        connectionPool.scanWithDuration(5, progressHandler: { (newDevices) in
            self.deviceList = newDevices
            self.tableView.reloadData()
        }) { (result, error) in
            if let error = error {
                print("scan fail with error \(error)")
            } else {
                print("scan succeed")
                self.deviceList = result
                self.tableView.reloadData()
            }
        }
    }
    
    private func randomTest(bluetoothDevice: BluetoothDevice, data: NSData) {
        for _ in 0...99 {
            // random integer between 0 and n-1
            let randomInt = Int(arc4random_uniform(4) + 1)
            switch randomInt % 4 {
            case 0:
                let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
                doFullAction(bluetoothDevice, data: data)
            case 1:
                discoverServices(bluetoothDevice)
            case 2:
                discoverCharacteristics(bluetoothDevice)
            case 3:
                let data = NSData(bytes: MESSAGE_PLAY_LED, length: MESSAGE_PLAY_LED.count)
                sendData(bluetoothDevice, data: data)
            default:
                connectPeripheral(bluetoothDevice)
            }
        }
    }
}




