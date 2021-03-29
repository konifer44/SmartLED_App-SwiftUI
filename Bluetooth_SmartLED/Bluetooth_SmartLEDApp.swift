//
//  Bluetooth_SmartLEDApp.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.
//

import SwiftUI

@main
struct Bluetooth_SmartLEDApp: App {
    @StateObject var bleManager = BLEManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
