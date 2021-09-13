//  VirtualSticksViewController.swift
//  Created by Dennis Baldwin on 3/18/20.
//  Copyright © 2020 DroneBlocks, LLC. All rights reserved.
//
//  Make sure you know what you're doing before running this code. This code makes use of the Virtual Sticks API.
//  This code has only been tested on DJI Spark, but should work on other DJI platforms. I recommend doing this outdoors to get familiar with the
//  functionality. It can certainly be run indoors since Virtual Sticks do not make use of GPS. Please make sure your flight mode switch is in
//  the default position. If any point you need to take control the switch can be toggled out of the default position so you have manual control
//  again. Virtual Sticks DOES NOT allow you to add any manual input to the flight controller when this mode is enabled. Good luck and I hope
//  to experiment with other flight paths soon.

import UIKit
import DJISDK
import CDJoystick

enum FLIGHT_MODE {
    case ROLL_LEFT_RIGHT
    case PITCH_FORWARD_BACK
    case THROTTLE_UP_DOWN
    case HORIZONTAL_ORBIT
    case VERTICAL_ORBIT
    case VERTICAL_SINE_WAVE
    case HORIZONTAL_SINE_WAVE
    case YAW
}

//static var Test: Float = 0.0

class VirtualSticksViewController: UIViewController {
    
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var leftJoystick: CDJoystick!
    @IBOutlet weak var rightJoystick: CDJoystick!
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    
    var flightController: DJIFlightController?
    var timer: Timer?
    
    static var Test: Float = 0.0
    
    var radians: Float = 0.0
    let velocity: Float = 0.1
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    var yaw: Float = 0.0
    var yawSpeed: Float = 30.0
    var throttle: Float = 0.0
    var roll: Float = 0.0
    var pitch: Float = 0.0
    
    var flightMode: FLIGHT_MODE?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Grab a reference to the aircraft
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            
            // Grab a reference to the flight controller
            if let fc = aircraft.flightController {
                
                // Store the flightController
                self.flightController = fc
                
                print("We have a reference to the FC")
                
                // Default the coordinate system to ground
                self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
                
                // Default roll/pitch control mode to velocity
                self.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
                
                // Set control modes
                self.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angularVelocity
            }
            
        }
        
        // Setup joysticks
        // Throttle/yaw
        leftJoystick.trackingHandler = { joystickData in
            self.yaw = Float(joystickData.velocity.x) * self.yawSpeed
            
            self.throttle = Float(joystickData.velocity.y) * 5.0 * -1.0 // inverting joystick for throttle
            
            self.sendControlData(x: 0, y: 0, z: 0)
        }
        
        // Pitch/roll
        rightJoystick.trackingHandler = { joystickData in
            
            self.pitch = Float(joystickData.velocity.y) * 1.0
            self.roll = Float(joystickData.velocity.x) * 1.0
            self.sendControlData(x: 0, y: 0, z: 0)
        }
    }
    
    // User clicks the enter virtual sticks button
    @IBAction func enableVirtualSticks(_ sender: Any) {
        toggleVirtualSticks(enabled: true)
    }
    
    // User clicks the exit virtual sticks button
    @IBAction func disableVirtualSticks(_ sender: Any) {
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
        
    }
    
    @IBAction func rollLeftRight(_ sender: Any) {
        
        //*************************************************************************************************//
        // LAND X
        //*************************************************************************************************//
        print("About to Land")
        DJIFlightControllerParamConfirmLanding
        //flightController?.startLanding()
        print("Landed")
        //*************************************************************************************************//
        // TEST
        //*************************************************************************************************//
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.ROLL_LEFT_RIGHT
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        //timer = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func pitchForwardBack(_ sender: Any) {
        
        
        //*************************************************************************************************//
        // GO HOME V
        //*************************************************************************************************//
        print("About to send Home")
        //self.flightController?.startGoHome(completion: <#T##DJICompletionBlock?##DJICompletionBlock?##(Error?) -> Void#>)
        flightController?.startGoHome()
        print("Sent Home")
        
        //let setHotPoint = self.flightController?
        //*************************************************************************************************//
        // TEST
        //*************************************************************************************************//
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.PITCH_FORWARD_BACK
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        //timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func throttleUpDown(_ sender: Any) {
        
        //*************************************************************************************************//
        // SET HOME X
        //*************************************************************************************************//
        print("About to set Home Location")
        //flightController?.setHomeLocationUsingAircraftCurrentLocationWithCompletion()
        //self.flightController?.setHomeLocation(CLLocation())
        //flightController?.getHomeLocation(completion: <#T##(CLLocation?, Error?) -> Void#>)
        //flightController?.setFlightOrientationMode(<#T##type: DJIFlightOrientationMode##DJIFlightOrientationMode#>, withCompletion: <#T##DJICompletionBlock?##DJICompletionBlock?##(Error?) -> Void#>)
        //flightController?.getAircraftHeadingTurningSpeed(onMode: <#T##DJIRCFlightModeSwitch#>, withCompletion: <#T##(Int, Error?) -> Void#>)
        //DJIFlightControllerState?.
        print("Home Location set")
        //*************************************************************************************************//
        // TEST
        //*************************************************************************************************//
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.THROTTLE_UP_DOWN
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        //timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func horizontalOrbit(_ sender: Any) {
        
        //*************************************************************************************************//
        // LAND V
        //*************************************************************************************************//
        print("About to Land")
        //DJIFlightControllerParamConfirmLanding
        var land = flightController?.startLanding
        flightController?.startLanding()
        print("Landed")
        //*************************************************************************************************//
        // TEST
        //*************************************************************************************************//
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.HORIZONTAL_ORBIT
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        //timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    //@IBAction func verticalOrbit(_ sender: Any) {
    @IBAction func verticalOrbit(_ sender: Any) {
        
        
        //sender.selectedSegmentIndex == 0
        print("Hello")
        
        //print("\(poiWay)")
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.VERTICAL_ORBIT
        
        var letsStart: DJIWaypointMissionOperator?
        var letsStartt: DJIMission?
        var letsStarttt: DJIMissionControl?
        
        var Craft: DJIAircraft?
        
        print("Mission Loaded \(letsStart?.loadedMission)")
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        //timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
        
        // TESTING //
        let userDefinedLatitude: Double = 35.180825793882455
        let userDefinedLongitude: Double = -97.43684159648761
//        let userDefinedLatitude: Double = 35.180810
//        let userDefinedLongitude: Double = -97.436893
//
//        print("Print Before");
//        print("\(userDefinedLatitude)");
//        print("Print After");
//
////        print("Hello")
////        let batteryLevelKey = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)
////        DJISDKManager.keyManager()?.getValueFor(batteryLevelKey!, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
////            guard error == nil && value != nil else {
////                // Insert graceful error handling here
////
////                self.getBatteryLevelLabel.text = "Error";
////                return
////            }
////            // DJIBatteryParamChargeRemainingInPercent is associated with a uint8_t value
////            self.getBatteryLevelLabel.text = "\(value!.unsignedIntegerValue) %"
////        })
////        print("Hello")
//
//        print("Hello")
////        let currentLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
////        DJISDKManager.keyManager()?.getValueFor(currentLocationKey!, withCompletion: { [unowned self] (value: DJIKeyedValue?, error: Error?) in
////            guard error == nil && value != nil else {
////                // Insert graceful error handling here
////
////                self.currentLocationLabel.text = "Error";
////                return
////            }
////            // DJIBatteryParamChargeRemainingInPercent is associated with a uint8_t value
////            //self.currentLocationLabel.text = "\(value!.unsignedIntegerValue) %"
////        })
//
//
//        print("Now")
////        print("\(currentLocationKey)");
//        print("\(userDefinedLatitude)")
        
        
        print("Hello")
        
//        let mission = DJIHotpointMission()
        print("Print Before Guard");
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return
        }
        print("\(droneLocationKey)");
        print("Print mid guard");
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            return
        }
        print("Print after guard");
        print("\(userDefinedLatitude)");
        
        let droneLocation = droneLocationValue.value as! CLLocation
        print("\(droneLocation)");
        var droneCoordinates = droneLocation.coordinate
        print("\(droneCoordinates)");
        
        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
            return
        }
        
        droneCoordinates.latitude = userDefinedLatitude
        droneCoordinates.longitude = userDefinedLongitude
        
        print("\(droneLocation)");
        print("\(droneCoordinates)");
        
//        let offset = 0.0000899322

//        mission.hotpoint = CLLocationCoordinate2DMake(droneCoordinates.latitude + offset, droneCoordinates.longitude)
//        mission.altitude = 15
//        mission.radius = 5.2
//        DJIHotpointMissionOperator.getMaxAngularVelocity(forRadius: Double(mission.radius), withCompletion: {(velocity:Float, error:Error?) in
//            mission.angularVelocity = velocity
//        })
//        mission.startPoint = .nearest
//        mission.heading = .alongCircleLookingForward
//
//        DJIHotpointAction(mission: mission, surroundingAngle: 180)
        
        
        let wantUserDefinedPos = 1
        // End of deciding if user defines point of interest
        
        // User defined position for the drone
//        var userDefinedLatitude: Double = 35.180810
//        var userDefinedLongitude: Double = -97.436893
        //End of user defined position for the drone
        
        // Defining a waypoint mission
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .pointToPoint
        mission.repeatTimes = 1
        // End of defining a waypoint mission
        
        print("Before Reading Current Position")
        // Reading a current position into a variable
        guard let currentDroneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return
        }
        print("Read Drone Loc Key")
        print("\(currentDroneLocationKey)")
        print("About to read Drone Loc Val")
        guard let currentDroneLocationValue = DJISDKManager.keyManager()?.getValueFor(currentDroneLocationKey) else {
            return
        }
        print("Read Drone Loc Val")
        let currentDroneLocation = currentDroneLocationValue.value as! CLLocation
        let currentDroneCoordinates = currentDroneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(currentDroneCoordinates) {
            return
        }
        mission.pointOfInterest = currentDroneCoordinates
        var finalDroneCoordinates = currentDroneCoordinates
        // End of reading a current position into a variable
        
//        print("\(droneLocation)");
        print("\(currentDroneCoordinates)");
        
        // Updating position of interest to user defined or current drone position
        if wantUserDefinedPos == 1 {
            finalDroneCoordinates.latitude = userDefinedLatitude
            finalDroneCoordinates.longitude = userDefinedLongitude
        } else {
        }
        
        print("\(finalDroneCoordinates)");
        let pointOfInterest = finalDroneCoordinates
        // End of updating position of interest to user defined position
        
        print("\(pointOfInterest)");
        
        // Preparing point of interest as a waypoint
        let poi = CLLocationCoordinate2DMake(pointOfInterest.latitude, pointOfInterest.longitude)
        print("\(poi.latitude)")
        let poiWaypoint = DJIWaypoint(coordinate: poi)
        poiWaypoint.altitude = 25
        poiWaypoint.heading = 0
        poiWaypoint.actionRepeatTimes = 1
        poiWaypoint.actionTimeoutInSeconds = 60
        poiWaypoint.cornerRadiusInMeters = 5
        poiWaypoint.turnMode = .clockwise
        poiWaypoint.gimbalPitch = 0
//        poiWaypoint.speed = 5
        // End of preparing point of interest as a waypoint
        
        // Printing point of interest as a waypoint
//        print("\(poiWaypoint.latitude)")
//        print("\(poiWaypoint.longitude)")
        print("\(poiWaypoint.speed)")
        print("\(poiWaypoint.coordinate)")
        // End of printing point of interest as a waypoint
        
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        
//        mission
        
//        var KKK = DJIMutableWaypointMission(mission: mission)
//        print("\(KKK.allWaypoints())")
//        print("\(mission)")
        
        var point: DJIWaypointMission = mission
        var point1: DJIWaypoint?
        
        point.run()
        
//        print("Mission points \(point.allWaypoints())")
//
//        letsStart?.load(point)
//
//        print("Mission points \(letsStart?.loadedMission)")
//
//        letsStart?.uploadMission()
//
//        print("Mission points \(letsStart?.loadedMission)")
        
//        var mission1 = DJIWaypointMission?
        
//        mission1.init(point1)
//
//        print("Mission Loaded \(letsStart?.loadedMission)")
//
//        letsStart?.load(DJIWaypointMission)
        
//        letsStart?.load(DJIMutableWaypointMission)
//        var Kool = letsStart?.loadedMission
//        wait(10)
//        print("Mission Loaded \(Kool)")
//        letsStart?.uploadMission()
//        wait(10)
//        print("Mission Loaded \(letsStart?.loadedMission)")
        
        
        
//        mission.run()
        
////        letsStart?.load(mission: mission)
//        letsStart?.load(mission)
//        print("Mission Loaded?")
//        print("Mission Loaded \(letsStart?.loadedMission)")
//        letsStart?.uploadMission()
//
//
//
//        print("Mission Uploaded?")
//        letsStart?.loadedMission
//        print("Mission Loaded \(letsStart?.loadedMission)")
//        print("Mission Uploaded?")
//
//        letsStart?.startMission()
        
        print("Mission Started")
        
        pause()
        
        print("Didn't pause")
    }
    
    @IBAction func sendYaw() {
        
        
        var Craft: DJIAircraft?
        var Model: String? = Craft?.model
        var FCC = Craft?.flightController
        print("\(Model)")
        print("\(FCC)")
        
        //setupFlightMode()
        //flightMode = FLIGHT_MODE.YAW
        
        //let poiWay = 0
        //verticalOrbit(poiWay);
        
        
        //FlightController.setStateCallback((@Nullable FlightControllerState.Callback callback))
        //self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
        //let setHome = self.flightController?.setHomeLocationUsingAircraftCurrentLocationWithCompletion
        //self.flightController?.setHomeLocation(<#T##homeLocation: CLLocation##CLLocation#>, withCompletion: <#T##DJICompletionBlock?##DJICompletionBlock?##(Error?) -> Void#>)
        //self.flightController?.setGoHomeHeightInMeters(<#T##height: UInt##UInt#>, withCompletion: <#T##DJICompletionBlock?##DJICompletionBlock?##(Error?) -> Void#>)
        //let goHome = self.flightController?.startGoHome()
        
        
        //*************************************************************************************************//
        // Setting Up Point of Interest Coordinates
        //*************************************************************************************************//
        
        // Deciding if user defines point of interest
        var wantUserDefinedPos = 1
        // End of deciding if user defines point of interest
        
        // User defined position for the drone
        var userDefinedLatitude: Double = 35.180810
        var userDefinedLongitude: Double = -97.436893
        //End of user defined position for the drone
        
        // Defining a waypoint mission
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .pointToPoint
        mission.repeatTimes = 1
        // End of defining a waypoint mission
        
        print("Before Reading Current Position")
        // Reading a current position into a variable
        guard let currentDroneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return
        }
        print("Read Drone Loc Key")
        print("\(currentDroneLocationKey)")
        print("About to read Drone Loc Val")
        guard let currentDroneLocationValue = DJISDKManager.keyManager()?.getValueFor(currentDroneLocationKey) else {
            return
        }
        print("Read Drone Loc Val")
        let currentDroneLocation = currentDroneLocationValue.value as! CLLocation
        let currentDroneCoordinates = currentDroneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(currentDroneCoordinates) {
            return
        }
        mission.pointOfInterest = currentDroneCoordinates
        var finalDroneCoordinates = currentDroneCoordinates
        // End of reading a current position into a variable
        
        // Updating position of interest to user defined or current drone position
        if wantUserDefinedPos == 1 {
            finalDroneCoordinates.latitude = userDefinedLatitude
            finalDroneCoordinates.longitude = userDefinedLongitude
        } else {
        }
        let pointOfInterest = finalDroneCoordinates
        // End of updating position of interest to user defined position
        
        // Preparing point of interest as a waypoint
        let poi = CLLocationCoordinate2DMake(pointOfInterest.latitude, pointOfInterest.longitude)
        let poiWaypoint = DJIWaypoint(coordinate: poi)
        poiWaypoint.altitude = 25
        poiWaypoint.heading = 0
        poiWaypoint.actionRepeatTimes = 1
        poiWaypoint.actionTimeoutInSeconds = 60
        poiWaypoint.cornerRadiusInMeters = 5
        poiWaypoint.turnMode = .clockwise
        poiWaypoint.gimbalPitch = 0
        // End of preparing point of interest as a waypoint
        
        // Printing point of interest as a waypoint
        print("\(poiWaypoint)")
        // End of printing point of interest as a waypoint
        
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        mission.add(poiWaypoint)
        
        DJIWaypointMission(mission: mission)
        //pause()
        var hello2 = verticalOrbit(poiWaypoint);
        //Float verticalOrbit(poiWaypoint)
        
        //*************************************************************************************************//
        // Next Step, Call Point of Interest Function.
        //*************************************************************************************************//
        
        var hotpoint = poiWaypoint
        var altitude: Double = 0.0
        var radius: Double = 0.0
        var angularVelocity: Float = 0.0
        var isClockwise: Bool = true
        
        //void setHotpoint(LocationCoordinate2D hotpoint)
        //var checkHotpoint = LocationCoordinate2D getHotpoint()
        //void setStartPoint(HotpointStartPoint startPoint)
        //var checkStartPoint = HotpointStartPoint getStartPoint()
        //void setAltitude(double altitude)
        //var checkAltitude: Double getAltitude()
        //void setRadius(double radius)
        //var checkRadius: Double getRadius()
        //void setAngularVelocity(float angularVelocity)
        //float getAngularVelocity()
        //void setClockwise(boolean clockwise)
        //boolean isClockwise()
        
        //var HotpointMission = HotpointMission(LocationCoordinate2D hotpoint,
        //                          Double altitude,
        //                          Double radius,
        //                          Float angularVelocity,
        //                          Bool isClockwise)
                                  //HotpointStartPoint startPoint,
                                  //HotpointHeading heading)
        
        //resetMissionWithData(HotpointMission data)
        
        //*************************************************************************************************//
        // Something
        //*************************************************************************************************//
        
        
        
        // TESTING
        print("End1")
        //guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
        //    return
        //}
        print("End2")
        //guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
        //    return
        //}
        //print("End3")
        
        //let droneLocation = droneLocationValue.value as! CLLocation
        //let droneCoordinates = droneLocation.coordinate
        print("End4")
        //var flightMode: FLIGHT_MODE?
        //var controlData = 0
        //let getPos = DJIWaypointMissionOperator
        //print("\(getPos)")
        
        //var controlData = droneCoordinates
        //let controlData = DJIFlightControllerParamCompassCalibrationState
        //print("\(controlData)")
        //controlData.verticalThrottle = throttle // in m/s
        //controlData.roll = 33
        //controlData.pitch = 55
        //controlData.yaw = 77
        //controlData.verticalThrottle = 99
        //controlData.append("Coco")
        
        //var controlData2 = DJIVirtualStickFlightControlData()
        //print("\(controlData)")
        
        //self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
        print("Sending x: \(x), y: \(y), z: \(z), yaw: \(yaw)")
        
        print("End")
        
        // TESTING
        // TESTING
        
        //sendControlData(x: 0, y: 0, z: 0)
        
        //timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
        
        //sendControlData(x: 0, y: 0, z: 0)
        
        //timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(yawLoop), userInfo: nil, repeats: true)
        
        
    }
    
    // Change the coordinate system between ground/body and observe the behavior
    // HIGHLY recommended to test first in the iOS simulator to observe the values in timerLoop and then test outdoors
    @IBAction func changeCoordinateSystem(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
        } else if sender.selectedSegmentIndex == 1 {
            self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.body
        }
        
    }
    
    // Change the control mode between velocity/angle and observe the behavior
    // HIGHLY recommended to test first in the iOS simulator to observe the values in timerLoop and then test outdoors
    @IBAction func changeRollPitchControlMode(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
        } else if sender.selectedSegmentIndex == 1 {
            self.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.angle
        }
    }
    
    // Change the yaw control mode between angular velocity and angle
    @IBAction func changeYawControlMode(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angularVelocity
        } else if sender.selectedSegmentIndex == 1 {
            self.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angle
        }
    }
    
    @IBAction func setYawAngularVelocity(_ slider: UISlider) {
        
        self.yawSpeed = slider.value
        yawLabel.text = "\(slider.value)"
        
    }
    
    var count = 0
    
    @objc func yawLoop() {
        
        sendControlData(x: x, y: y, z: z)
        
        // Based on 20 hz
        if count > 60 {
            self.timer?.invalidate()
            self.count = 0
            print("done counting")
        }
        
        count = count + 1
        
    }
    
    
    // Timer loop to send values to the flight controller
    // It's recommend to run this in the iOS simulator to see the x/y/z values printed to the debug window
    @objc func timerLoop() {
        
        // Add velocity to radians before we do any calculation
        radians += velocity
        
        // Determine the flight mode so we can set the proper values
        switch flightMode {
        case .ROLL_LEFT_RIGHT:
            x = cos(radians)
            y = 0
            z = 0
            //yaw = 0 let's see if this yaws while rolling
        case .PITCH_FORWARD_BACK:
            x = 0
            y = sin(radians)
            z = 0
            yaw = 0
        case .THROTTLE_UP_DOWN:
            x = 0
            y = 0
            z = sin(radians)
            yaw = 0
        case .HORIZONTAL_ORBIT:
            x = cos(radians)
            y = sin(radians)
            z = 0
            yaw = 0
        case .VERTICAL_ORBIT:
            x = cos(radians)
            y = 0
            z = sin(radians)
            yaw = 0
        case .YAW:
            x = 0
            y = 0
            z = 0
            
            break
        case .VERTICAL_SINE_WAVE:
            break
        case .HORIZONTAL_SINE_WAVE:
            break
        case .none:
            break
        }
        
        sendControlData(x: x, y: y, z: z)
        
    }
    
    private func sendControlData(x: Float, y: Float, z: Float) {
        
        print("Sending x: \(x), y: \(y), z: \(z), yaw: \(yaw)")
        
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = throttle // in m/s
        controlData.roll = roll
        controlData.pitch = pitch
        controlData.yaw = yaw
        
        // Send the control data to the FC
        print("Send the control data to the FC.")
        self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
            // There's an error so let's stop
            if error != nil {
                
                print("Error sending data")
                
                // Disable the timer
                self.timer?.invalidate()
            }
            
        })
    }
    
    // Called before any new flight mode is initiated
    private func setupFlightMode() {
        
        print("Called before any new flight mode is initiated.")
        // Reset radians
        radians = 0.0
        
        // Invalidate timer if necessary
        // This allows switching between flight modes
        if timer != nil {
            print("invalidating")
            timer?.invalidate()
        }
    }
    
    

}

class HotpointMission: UIViewController {
    
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var leftJoystick: CDJoystick!
    @IBOutlet weak var rightJoystick: CDJoystick!
    
    
    var flightController: DJIFlightController?
    var HotpointMission1: DJIHotpointMission?
    var Location1: DJIWaypoint?
    
    var timer: Timer?
    
    var hotpoint: Float = 0.0
    let altitude: Double = 0.1
    var radius: Double = 0.0
    let userDefinedLatitude: Double = 0.0
    var userDefinedLongitude: Double = 0.1
    var angularVelocity: Float = 0.0
    var z: Float = 0.0
    var yaw: Float = 0.0
    var yawSpeed: Float = 30.0
    var throttle: Float = 0.0
    var roll: Float = 0.0
    var pitch: Float = 0.0
    
   // var Location2 = DJIWaypoint(userDefinedLatitude, userDefinedLongitude, altitude)
    var flightMode1: FLIGHT_MODE?
    
    // User clicks the enter virtual sticks button
    @IBAction func setAHotpoint(_ sender: Any) {
        HotpointMission1?.altitude = 0.002
        
        var Test2 = VirtualSticksViewController.Test
        
        CLLocationCoordinate2DMake(userDefinedLatitude, userDefinedLongitude)
        
        //HotpointMission(LocationCoordinate2D(userDefinedLatitude, userDefinedLongitude,
                        //LocationCoordinate2D hotpoint,
        //                Double altitude,
        //                Double radius,
        //                Float angularVelocity,
        //                Bool isClockwise)
                        //HotpointStartPoint startPoint,
                        //HotpointHeading heading)
    }
    
}
// Contains map specific code
extension VirtualSticksViewController {
    
    
}
