//
//  BLEManager.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.

import Foundation
import CoreBluetooth
import Combine
import SwiftUI
enum selectedTabEnum: Int {
    case device = 1, settings = 2
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    @AppStorage("connectAutomatically") var connectAutomaticallyTo: String = ""
    @Published var rssi = 0
    @Published var isScanning = false
    @Published var isSwitchedOn = false
    @Published var isInitializated = false
    @Published var peripherals = [Peripheral]()
    @Published var connectedPeripheral: CBPeripheral?
    @Published var selectedTab = selectedTabEnum.settings.rawValue
    @Published var connectAutomatically = false {
        didSet {
            guard let peripheralName = connectedPeripheral?.name else { return }
            if connectAutomatically == true {
                connectAutomaticallyTo = peripheralName
            } else {
                connectAutomaticallyTo = ""
            }
        }
    }
    @Published var isConnected = false {
        didSet {
            DispatchQueue.main.async { [self] in
                if connectedPeripheral?.name == "Konifer_SmartLED"{
                    isConnectedToLED = true
                } else {
                    isConnectedToLED = false
                }
            }
        }
    }
    @Published var isConnectedToLED = false {
        didSet{
            selectedTab = isConnectedToLED ? selectedTabEnum.device.rawValue : selectedTabEnum.settings.rawValue
        }
    }
    
    var BLECentralManager: CBCentralManager!
    var character = [CBCharacteristic]()
    
    override init() {
        super.init()
        BLECentralManager = CBCentralManager(delegate: self, queue: nil)
        BLECentralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isSwitchedOn = central.state == .poweredOn ? true : false
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            rssi = RSSI.intValue
            DispatchQueue.main.async {
                if let peripheralName = peripheral.name {
                    if peripheralName == self.connectAutomaticallyTo {
                        self.connectAutomatically = true
                        self.BLECentralManager.connect(peripheral, options: nil)
                        // return
                    }
                }
                let newPeripheral = Peripheral(CBPeripheral: peripheral, isConnected: false, rssi: RSSI.intValue)
                self.peripherals.append(newPeripheral)
            }
        }
    }
    
    func connectToDevice(peripheral: Peripheral, index: Int) {
        BLECentralManager.connect(peripheral.CBPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        isConnected = true
        stopScanning()
        peripherals.removeAll()
        connectedPeripheral = peripheral
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        startScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Looking for services")
        if let errorService = error{
            print(errorService)
            return
        }
        if let services = peripheral.services {
            connectedPeripheral = peripheral
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Looking for characteristics in \(service.uuid)")
        if let characteristics = service.characteristics {
            connectedPeripheral = peripheral
            
            DispatchQueue.main.async {
                self.readRGBData()
                self.objectWillChange.send()
            }
            character.removeAll()
            for characteristic in  characteristics {
                character.append(characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //        guard let data = characteristic.value else {
        //            print("data == nil")
        //            return
        //        }
        //        let numbers = [UInt8](data)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.rssi = RSSI.intValue
    }
    
    func readRSSI(){
        connectedPeripheral?.readRSSI()
    }
    
    func startScanning() {
        self.peripherals.removeAll()
        self.BLECentralManager.scanForPeripherals(withServices: nil, options: nil)
        self.isScanning = self.BLECentralManager.isScanning
    }
    
    func stopScanning() {
        BLECentralManager.stopScan()
        self.isScanning = self.BLECentralManager.isScanning
        self.peripherals.removeAll()
    }
    
    func switchScanning(){
        if BLECentralManager.isScanning {
            stopScanning()
            return
        } else {
            startScanning()
        }
    }
    
    func disconnect() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        BLECentralManager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    func writeRGBData(to characteristic: String, rgbData: Data) {
        guard let connectedPeripheral = connectedPeripheral else { return }
        // print("Attempt to read data")
        
        for char in character {
            if char.uuid == CBUUID(string: characteristic)
            {
                connectedPeripheral.writeValue(rgbData, for: char, type: .withResponse)
                return
            }
        }
    }
    
    func readRGBData(){
        guard let connectedPeripheral = connectedPeripheral else { return }
        for characteristic in character {
            if characteristic.uuid == CBUUID(string: "FF04") {
                print("FOUND FF04")
                connectedPeripheral.readValue(for: characteristic)
            }
        }
    }
}



struct Peripheral: Identifiable {
    let id = UUID()
    let CBPeripheral: CBPeripheral
    var isConnected: Bool
    let rssi: Int
}





