//
//  BTDiscovery.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
let BLEServiceUUID = CBUUID(string:"FFE0")
let BLESCharacterUUID = CBUUID(string:"FFE1")
let BLEUUID=CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    
    override init() {
        super.init()
        
        let centralQueue = DispatchQueue(label: "com.khoatrandang", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanning() {
        print("scaning for \(BLEServiceUUID.debugDescription)")
        if let central = centralManager {
            central.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
        }
    }
    
    var bleService: BTService? {
        didSet {
            if let service = self.bleService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Be sure to retain the peripheral or it will fail during connection.
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral
            
            // Reset service
            self.bleService = nil
            
            // Connect to peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            self.bleService = BTService(initWithPeripheral: peripheral)
        }
        
        // Stop scanning for new devices
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
            self.bleService = nil;
            self.peripheralBLE = nil;
        }
        
        // Start scanning for new devices
        self.startScanning()
    }
    
    // MARK: - Private
    
    func clearDevices() {
        self.bleService = nil
        self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case CBManagerState.poweredOff:
            self.clearDevices()
            print("OFF")
            
        case CBManagerState.unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
            
        case CBManagerState.unknown:
            print("UnKnown")
            // Wait for another event
            break
            
        case CBManagerState.poweredOn:
            print("Bluetooth is ON")
            self.startScanning()
            
        case CBManagerState.resetting:
            print("Reseting")
            self.clearDevices()
            
        case CBManagerState.unsupported:
            print("unsupported")
            break
        }
    }
    
}
