//
//  LED.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.

import Foundation
import SwiftUI

class LEDDevice: ObservableObject {
    @Published var color: Color =  Color(red: 0.5, green: 0.5, blue: 0.5) {
        didSet{
            if isBlack() {
                brightness = 0
                color = .white
            } else {
                if isOn {
                    bleManager.writeRGBData(to: "FF04", rgbData: convertColorToData(color: self.color))
                }
            }
        }
    }
    @Published var brightness: Double = 0 {
        didSet{
            if brightness == 0 {
                isOn = false
            } else {
                isOn = true
            }
        }
    }
    @Published var isOn: Bool = false {
        didSet{
            if !isOn {
                bleManager.writeRGBData(to: "FF04", rgbData: convertColorToData(color: .black))
            } else {
                bleManager.writeRGBData(to: "FF04", rgbData: convertColorToData(color: self.color))
            }
        }
    }
    
    var bleManager: BLEManager
    init(bleManager: BLEManager){
        self.bleManager = bleManager
    }
    
    let quickColors: [Color] = [
        Color(red: 1, green: 0, blue: 0, opacity: 1),
        Color(red: 0, green: 1, blue: 0, opacity: 1),
        Color(red: 0, green: 0, blue: 1, opacity: 1)]
    
    func stateToogle(){
        if isOn == true {
            isOn = false
            brightness = 0
        } else {
            isOn = true
            brightness = 0.5
        }
    }
    
    func convertColorToData(color: Color) -> Data {
        var rgbData: Data
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        
        if color.components.red < 0 {
            red = 0
        } else if  color.components.red > 1 {
            red = 1
        } else {
            red = color.components.red
        }
        
        if color.components.green < 0 {
            green = 0
        } else if  color.components.green > 1 {
            green = 1
        } else {
            green = color.components.green
        }
        
        if color.components.blue < 0 {
            blue = 0
        } else if  color.components.blue > 1 {
            blue = 1
        } else {
            blue = color.components.blue
        }
        
        var redBrightness: CGFloat
        var greenBrightness: CGFloat
        var blueBrightness: CGFloat
        
        if brightness > 0 {
            redBrightness = red * CGFloat(brightness)
            greenBrightness = green * CGFloat(brightness)
            blueBrightness = blue * CGFloat(brightness)
        } else {
            redBrightness = red
            greenBrightness = green
            blueBrightness = blue
        }
        
        let redUInt = UInt8(redBrightness * 255)
        let greenUInt = UInt8(greenBrightness * 255)
        let blueUInt = UInt8(blueBrightness * 255)
        
        rgbData = Data([redUInt, greenUInt, blueUInt])
        return rgbData
    }
    
    func isBlack() -> Bool {
        if color.components.blue == 0 && color.components.green == 0 && color.components.red  == 0 {
            return true
        } else {
            return false
        }
    }
}

extension Double {
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }
        return (r, g, b, o)
    }
}
