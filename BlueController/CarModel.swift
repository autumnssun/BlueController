//
//  CarModel.swift
//  BlueController
//
//  Created by Tran Khoa on 31/01/2016.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//

class CarModel: NSObject {
    var driveDir:drivingDirection = .forward
    var MASpeed:Int=0
    var MBSpeed:Int=0
    var MCSpeed:Int=0
    var MDSpeed:Int=0
    
    var dir:Int = 1

    var connection:BTService
    var delegate:CarModelDelegate?
    var steeringAngle:Double=0
    var steerDir:steeringDirection = .left
    var angle:Double=0;
    var StandDardSpeed:Int=150;
    var variationFactor:Double = 60 //(Percentage)

    
    init(con:BTService,delegate:CarModelDelegate!=nil){
        self.connection=con
        self.delegate=delegate
    }
    
    internal func changeDirection(){
        driveDir.changeDirection()
        delegate?.carDirectionDidChange(driveDir)
    }
    
    func setRotation(rot:Double){
        steeringAngle=rot
        drive()
    }
    
    func drive(){
        //print(steeringAngle)
        if(driveDir == .forward){
            dir = -1
        }else{
            dir = 1
        }
        print(steeringAngle)
        if(M_PI>steeringAngle && steeringAngle>0){
            angle=steeringAngle

        }else if(M_PI*2>steeringAngle && steeringAngle>M_PI){
            angle=steeringAngle-M_PI*2
        }
        else{
            stop()
            return
        }
        //print("Steering: \(angle)")
        let rightSpeed=Int((StandDardSpeed-Int(angle*variationFactor))*dir)
        let leftSpeed=Int((StandDardSpeed+Int(angle*variationFactor))*dir)
        MASpeed=rightSpeed
        MBSpeed=rightSpeed
        MCSpeed=leftSpeed
        MDSpeed=leftSpeed
        //Adjusting speed
        var ar=[MASpeed,MBSpeed,MCSpeed,MDSpeed]

        for (var i = 0; i<4;i++) {
            if(ar[i]>255){
                ar[i]=255
            }
            if(ar[i]<70){
                ar[i]=70
            }
        }
        setSpeed()

    }
    
    func stop(){
        MASpeed=0;      //Right Front Wheel
        MBSpeed=0;      //Right Back Wheel
        MCSpeed=0;      //Left Front Wheel
        MDSpeed=0;      //Left Back Wheel
        steeringAngle=0
        setSpeed()
        //print("carstop")
    }
    
    private func setSpeed(){
        //print("setting speed")
        
        let toBeSentString = ("^{dir:\(dir),mA:\(MASpeed),mB:\(MBSpeed),mC:\(MCSpeed),mD:\(MDSpeed)}^");
        connection.sendData(toBeSentString)
        delegate?.carDidSetSpeed()
    }
}
protocol CarModelDelegate{
    func carDirectionDidChange(currentDirection:drivingDirection)
    func carDidSetSpeed()
}

enum drivingDirection:String{
    case forward = "Forward"
    case backward = "Backward"
    mutating func changeDirection() {
        switch self {
        case .forward:
            self = .backward
        case .backward:
            self = .forward
        }
    }
}
enum steeringDirection:String{
    case right = "Right"
    case left = "Left"
    case straight = "Straight"
    mutating
    func changeDirection() {
        switch self {
        case .right:
            self = .left
        case .left:
            self = .right
        default:
            self = .straight
        }
    }
    mutating func setStraight(){
            self = .straight
        }
}