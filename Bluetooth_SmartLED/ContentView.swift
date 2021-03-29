//
//  ContentView.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.
//


import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        TabView(selection: $bleManager.selectedTab){
            DeviceView(LED: LEDDevice(bleManager: bleManager))
                .tabItem {
                    Label("Device", systemImage: "lightbulb")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BLEManager())
    }
}
