//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var UARTCharateristic:CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let uuidsForBTService: [CBUUID] = [BLESCharacterUUID]
        
        print("did discover device ")
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            print(service)
            if service.uuid == BLEServiceUUID {
                print("service of found device and wanting server match")
                print("Start discovering the characteristic of the service")
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
                
            }
        }
    }
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(":characteristic update")
        if let characteristicValue = characteristic.value{
            let datastring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue)
            if let datastring = datastring{
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                print(datastring)
                //navigationItem.title = datastring as String
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == BLESCharacterUUID {
                    self.UARTCharateristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                    
                }
            }
        }
    }
    
    // Mark: - Private
    func sendData(_ str:NSString){
        let data = str.data(using: String.Encoding.ascii.rawValue)
        print("data to be sent \(data?.base64EncodedString())")
        peripheral?.writeValue(data!, for: UARTCharateristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    
    func sendBytes(_ bytes:[UInt8]!){
        if( bytes == nil){
            let byte:[UInt8] = [ 0x52, 0x13, 0x00, 0x56, 0xFF, 0x00, 0x00, 0x00, 0xAA ]
            var data = Data(bytes:byte)
            print(data)
            peripheral?.writeValue(data, for: UARTCharateristic!, type: CBCharacteristicWriteType.withResponse)

        }else{
            var data = Data(bytes:bytes)
            print(data)

            peripheral?.writeValue(data, for: UARTCharateristic!, type: CBCharacteristicWriteType.withResponse)

        }
    }
    
    
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
}
