//
//  SettingsView.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("connectAutomaticallyTo") var connectAutomaticallyTo: String = ""
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack{
            switch bleManager.isConnected {
            case true:
                ConnectedDeviceView()
                
            case false:
                ScannedDevicesListView()
            }
        }
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bleManager.startScanning()
                bleManager.isInitializated = true
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


struct ConnectedDeviceView: View {
    @AppStorage("connectAutomaticallyTo") var connectAutomaticallyTo: String = ""
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack{
            VStack(alignment: .leading){
                Text("\(bleManager.connectedPeripheral?.name ?? "Unknown name")")
                    .font(.system(size: 35))
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Connected")
                        .font(.system(size: 25))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Spacer()
                    HStack {
                        Image(systemName: "wifi")
                        Text("\(bleManager.rssi) dBm")
                    }
                    .font(.system(size: 20))
                    .padding()
                }
                
                HStack{
                    Text("Connect automatically")
                    Toggle(isOn: $bleManager.connectAutomatically) {
                    }
                    .padding()
                }
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 5, trailing:  0))
            Divider()
            
            HStack {
                Text("Available services:")
                    .font(.title2)
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing:  0))
            
            if bleManager.connectedPeripheral?.services != nil {
                List(){
                    ForEach((bleManager.connectedPeripheral?.services!)!, id: \.self){ service in
                        Section(header: Text("\(service.uuid)")){
                            if service.characteristics != nil {
                                ForEach(service.characteristics!, id: \.self) { characteristic in
                                    Text("\(characteristic.uuid)")
                                        .padding(.leading, 20)
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
            
            Button(action: {
                bleManager.disconnect()
            }
            , label: {
                Text("Disconnect")
                    .frame(width: 150, height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            
            
            .padding(.bottom, 30)
        }
    }
}


struct ScannedDevicesListView: View {
    @EnvironmentObject var bleManager: BLEManager
    var body: some View {
        ZStack {
            VStack{
                HStack {
                    Text("Devices:")
                        .font(.system(size: 35))
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 10, trailing:  0))
                
                List {
                    ForEach(bleManager.peripherals.enumerated().map({$0}), id: \.element.id) { index, peripheral in
                        HStack{
                            Text(peripheral.CBPeripheral.name ?? "Unknown")
                            Spacer()
                            Text("\(peripheral.rssi)")
                        }
                        .onTapGesture{
                            bleManager.connectToDevice(peripheral: peripheral, index: index)
                        }
                    }
                }
                
                Button(action: {
                    bleManager.switchScanning()
                }
                , label: {
                    Text(bleManager.isScanning ? "Stop Scanning" : "Start Scanning")
                        .frame(width: 350, height: 50)
                        .background(bleManager.isScanning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .padding(.bottom, 30)
                
            }
            if !bleManager.isInitializated{
                VStack {
                    Text("Initalizing scanner")
                        .padding()
                    ProgressView()
                }
            }
        }
    }
}

