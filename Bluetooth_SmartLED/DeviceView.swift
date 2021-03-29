//
//  DeviceView.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.
//

import SwiftUI

struct DeviceView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var LED: LEDDevice
    @StateObject var accelerometer = Accelerometer()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            VStack{
                HangingBulbView()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .environmentObject(LED)
                    .environmentObject(accelerometer)
                
                ControlsView()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .environmentObject(LED)
                    .environmentObject(accelerometer)
            }
            if !bleManager.isConnectedToLED {
                Color.gray.opacity(0.8).edgesIgnoringSafeArea(.top)
                VStack {
                    Text("Please connect to LED device")
                    Button(action: {
                        bleManager.selectedTab = selectedTabEnum.settings.rawValue
                    }
                    , label: {
                        Text("Go to settings")
                    })
                    .padding()
                }
            }
        }
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(LED: LEDDevice(bleManager: BLEManager()))
    }
}









struct HangingBulbView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var LED: LEDDevice
    @EnvironmentObject var accelerometer: Accelerometer
    @State var animate: Bool = false
    
    var body: some View {
        VStack {
            ZStack{
                RadialGradient(gradient: Gradient(colors: [LED.color,(colorScheme == .light ? Color.white : Color.black).opacity(0)]), center: .center, startRadius: LED.isOn ? 43 : 0, endRadius: CGFloat(LED.brightness * 900) + 44)
                    .opacity(0.8)
                    .frame(minWidth: 1500, minHeight: 1500, alignment: .center)
                    .offset(y: 23)
                    .animation(nil)
                
                Circle()
                    .fill(colorScheme == .light ? Color.white : Color.black)
                    .frame(width: 90, height: 90, alignment: .center)
                    .offset(y: 23)
                    .animation(nil)
                
                Image(systemName: LED.isOn ? "lightbulb.fill" : "lightbulb.slash")
                    .rotationEffect(.degrees(180))
                    .font(.system(size: 120))
                    .foregroundColor(LED.color)
                    .shadow(color: colorScheme == .light ? Color.gray : Color.black, radius: 5, x: 0, y: 0)
                    .animation(nil)
                    .onTapGesture {
                        LED.stateToogle()
                    }
                
                Image(systemName: "line.diagonal")
                    .rotationEffect(.degrees(-45))
                    .font(.system(size: 120))
                    .offset(y: -145)
                    .foregroundColor(LED.color)
                    .opacity(0.4)
                    .shadow(color: colorScheme == .light ? Color.gray : Color.black, radius: 5, x: 0, y: 0)
                    .animation(nil)
            }
            .rotationEffect(.degrees(-accelerometer.deviceRoll * 30), anchor: UnitPoint(x: 0.5, y: 0.35))
            .rotationEffect(
                animate ?  .zero : .degrees(10),
                anchor: UnitPoint(x: 0.5, y: 0.3)
            )
            .animation(.interpolatingSpring(stiffness: 100, damping: 1))
            Spacer()
        }
        .onAppear {
            animate = true
            accelerometer.start()
        }
    }
}

struct ControlsView: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var LED: LEDDevice
    @Environment(\.colorScheme) var colorScheme
    let wheelSize: CGFloat = 65
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Slider(value: $LED.brightness, in: 0...1, step: 0.001)
                    .accentColor(LED.color)
                    .shadow(color: colorScheme == .light ? Color.gray : Color.black, radius: 5, x: 0, y: 0)
                    .frame(width: 250)
                    .padding(.bottom, 20)
                
                HStack {
                    ColorPicker("Select color", selection: $LED.color, supportsOpacity: false)
                        .frame(width: wheelSize, height: wheelSize, alignment: .center)
                        .labelsHidden()
                        .scaleEffect(2.5)
                        .padding(5)
                    
                    Button(action: {
                        LED.color = .white
                    }, label: {
                        Circle()
                            .strokeBorder(Color.gray,lineWidth: 0.4)
                            .background(Circle().foregroundColor(Color.white))
                            .frame(width: wheelSize, height: wheelSize, alignment: .center)
                            .foregroundColor(.white)
                            .padding(5)
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        LED.stateToogle()
                    }, label: {
                        Circle()
                            .strokeBorder(Color.gray,lineWidth: 0.4)
                            .background(Circle().foregroundColor(colorScheme == .light ? Color.white : Color.black))
                            .frame(width: wheelSize, height: wheelSize, alignment: .center)
                            .overlay(
                                Image(systemName: LED.isOn ? "lightbulb.slash" : "lightbulb.fill")
                                    .rotationEffect(.degrees(180))
                                    .font(.system(size: 25))
                                    .foregroundColor(.gray)
                            )
                            .padding(5)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack{
                    ForEach(LED.quickColors, id: \.self){ color in
                        Button(action: {
                            LED.color = color
                        }, label: {
                            Circle()
                                .frame(width: wheelSize, height: wheelSize, alignment: .center)
                                .foregroundColor(color)
                                .padding(5)
                        })
                    }
                }
            }
            Spacer().frame(height: 35)
        }
    }
}

