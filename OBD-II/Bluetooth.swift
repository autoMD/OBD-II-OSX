//
//  Bluetooth.swift
//  OBD-II
//
//  Created by Manuel Stampfl on 03.11.15.
//  Copyright © 2015 mani1337. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - centralManagerDidUpdateState
let BluetoothDidUpdateState = "BluetoothDidUpdateState"

// MARK: - didDiscoverPeripheral Keys
let BluetoothDiscover = "BluetoothDiscover"
let BluetoothPeripheral = "BluetoothPeripheral"
let BluetoothAdvertisementData = "BluetoothAdvertisementData"
let BluetoothRSSI = "BluetoothRSSI"

class Bluetooth : NSObject, CBCentralManagerDelegate {
    // MARK: - Vars
    private(set) var manager: CBCentralManager
    private(set) var queue: dispatch_queue_t
    private(set) var notificationCenter: NSNotificationCenter
    private(set) var disoveredPeripherals = [String: CBPeripheral]()
    private(set) var isScanning = false
    
    private static var _sharedInstance: Bluetooth?
    
    // MARK: - Get singleton
    class func sharedBluetooth() -> Bluetooth {
        if _sharedInstance == nil {
            _sharedInstance = Bluetooth()
        }
        return _sharedInstance!
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        self.executeThreadSafe {
            $0.notificationCenter.postNotificationName(BluetoothDidUpdateState, object: $0)
            
            if $0.isScanning {
                $0.startScanning()
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        self.executeThreadSafe {
            if let name = peripheral.name {
                $0.disoveredPeripherals[name] = peripheral
            }
            
            $0.notificationCenter.postNotificationName(BluetoothDiscover, object: $0, userInfo: [
                BluetoothPeripheral: peripheral,
                BluetoothAdvertisementData: advertisementData,
                BluetoothRSSI: RSSI
            ])
        }
    }
    
    // MARK: - Constructor
    private override init() {
        self.queue = dispatch_queue_create("Bluetooth", DISPATCH_QUEUE_SERIAL)
        self.manager = CBCentralManager(delegate: nil, queue: self.queue)
        self.notificationCenter = NSNotificationCenter.defaultCenter()
        
        super.init()
        
        self.manager.delegate = self
    }
    
    // MARK: - Private methods
    private func executeThreadSafe(completion: Bluetooth -> Void) {
        dispatch_sync(dispatch_get_main_queue()) { [weak self] () -> Void in
            if self != nil {
                completion(self!)
            }
        }
    }
    
    // MARK: - Public methods
    func startScanning() {
        self.manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        self.isScanning = true
    }
    
    func stopScanning() {
        self.isScanning = false
        self.manager.stopScan()
    }
}