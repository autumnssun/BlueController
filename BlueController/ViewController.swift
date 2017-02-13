//
//  ViewController.swift
//  BlueController
//
//  Created by Tran Khoa on 29/01/2016.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//

import UIKit
import CoreMotion
class ViewController: UIViewController{
    
    var deviceUpdateInter:TimeInterval=0.2
    
    var underFinger:UITouch?
    var timer:Timer?
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var forwardArea: UIView!
    @IBOutlet weak var backwardArea: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.deviceMotionUpdateInterval=deviceUpdateInter
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            underFinger=touch
            if(underFinger!.view==forwardArea){
                car.driveDir = .forward
            }
            if(underFinger!.view==backwardArea){
                car.driveDir = .backward
            }
            if(underFinger!.view == forwardArea || underFinger!.view == backwardArea ){
                
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, eror) -> Void in
                    let motion = data! as CMDeviceMotion
                    let rotation = -atan2(motion.gravity.y, motion.gravity.x) + M_PI
                    
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(-rotation))
                    car.setRotation(rotation)
                })
                
            }
            
        }
        //super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        car.stop()
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        
    }
    
      
    
    
}

