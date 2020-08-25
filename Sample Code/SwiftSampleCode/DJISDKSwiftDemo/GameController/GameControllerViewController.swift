//
//  GameControllerViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Dennis Baldwin on 8/23/20.
//  Copyright © 2020 DJI. All rights reserved.
//

import UIKit
import GameplayKit
import GameController

class GameControllerViewController: UIViewController {
    
    private var flightController: DJIFlightController?
    
    private var roll: Float = 0
    private var pitch: Float = 0
    private var yaw: Float = 0
    private var throttle: Float = 0
    
    // Handles sending commands to flight controller
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Grab a reference to the aircraft
//        if let aircraft = DJISDKManager.product() as? DJIAircraft {
//
//            // Grab a reference to the flight controller
//            if let fc = aircraft.flightController {
//
//                // Store the flightController
//                self.flightController = fc
//
//                // Default the coordinate system to ground
//                self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
//
//                // Default roll/pitch control mode to velocity
//                self.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
//
//                // Set control modes
//                self.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angularVelocity
//            }
//
//        }
        
        // Listen for when a controller is connected or disconnected
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        connectControllers()
    }
    
    @IBAction func enableVirtualSticks(_ sender: UIButton) {
        toggleVirtualSticks(enabled: true)
    }
    
    @IBAction func disableVirtualSticks(_ sender: UIButton) {
        toggleVirtualSticks(enabled: false)
    }
    
    // Handles enabling/disabling the virtual sticks
    private func toggleVirtualSticks(enabled: Bool) {
            
        // Let's set the VS mode
        self.flightController?.setVirtualStickModeEnabled(enabled, withCompletion: { (error: Error?) in
            
            // If there's an error let's stop
            guard error == nil else { return }
            
            print("Are virtual sticks enabled? \(enabled)")
            
        })
        
        // Begin the virtual stick timer
        if (enabled) {
            
            // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
            
        // Disable the virtual stick timer
        } else {
            
            timer?.invalidate()
            
        }
        
    }
    
    // Handles sending control data to the flight controller
    @objc func timerLoop() {
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = throttle // in m/s
        controlData.roll = roll
        controlData.pitch = pitch
        controlData.yaw = yaw
        
        print("Throttle: \(throttle), Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
        
        // Send the control data to the FC
        self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
            // There's an error so let's stop
            if error != nil {
                
                print("Error sending data")
                
                // Disable the timer
                self.timer?.invalidate()
            }
            
        })
    }
    
    
    // Called when a controller is connected
    @objc func connectControllers() {
        // Run through each controller currently connected to the system
        for controller in GCController.controllers() {
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                setupController(controller: controller)
            }
        }
    }
    
    func setupController(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        switch element {
        case gamepad.leftThumbstick:
            yaw = gamepad.leftThumbstick.xAxis.value * 30.0
            print("Controller: \(index), LeftThumbstickXAxis: \(gamepad.leftThumbstick.xAxis.value)")
            print("Controller: \(index), LeftThumbstickYAxis: \(gamepad.leftThumbstick.yAxis.value)")
        case gamepad.rightThumbstick:
            print("Controller: \(index), RightThumbstickXAxis: \(gamepad.rightThumbstick.xAxis.value)")
            print("Controller: \(index), RightThumbstickYAxis: \(gamepad.rightThumbstick.yAxis.value)")
        case gamepad.leftTrigger:
            print("Land")
        case gamepad.rightTrigger:
            print("Takeoff")
        default:
            print("Do nothing")
        }
    }
    
    // Called when a controller is disconnected
    @objc func disconnectControllers() {
        
        // Maybe disable virtual sticks here?
        
    }
    
    private func sendControlData(x: Float, y: Float, z: Float) {
        print("Sending x: \(x), y: \(y), z: \(z), yaw: \(yaw)")
        
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = 0 // in m/s
        controlData.roll = 0
        controlData.pitch = 0
        controlData.yaw = 0
        
        // Send the control data to the FC
        self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
            // There's an error so let's stop
            if error != nil {
                
                print("Error sending data")
            }
            
        })
    }

}
