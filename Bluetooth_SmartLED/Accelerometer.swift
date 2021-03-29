//
//  Accelerometer.swift
//  Bluetooth_SmartLED
//
//  Created by Jan Konieczny on 26/03/2021.


import Foundation
import CoreMotion

class Accelerometer: ObservableObject {
    //@Published var devicePitch = Double.zero
    //@Published var deviceYaw = Double.zero
    @Published var deviceRoll = Double.zero
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    func start(){
        self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
            guard let data = data else {
                //print("Error: \(error!)")
                return
            }
            let attitude: CMAttitude = data.attitude
            
            DispatchQueue.main.async {
                self.deviceRoll = attitude.roll
            }
        }
    }
}
