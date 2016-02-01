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
    
    var deviceUpdateInter:NSTimeInterval=0.2
    
    var underFinger:UITouch?
    var timer:NSTimer?
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var forwardArea: UIView!
    @IBOutlet weak var backwardArea: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        motionManager.deviceMotionUpdateInterval=deviceUpdateInter
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            underFinger=touch
            if(underFinger!.view==forwardArea){
                car.driveDir = .forward
            }
            if(underFinger!.view==backwardArea){
                car.driveDir = .backward
            }
            if(underFinger!.view == forwardArea || underFinger!.view == backwardArea ){
                
                motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, eror) -> Void in
                    let motion = data! as CMDeviceMotion
                    let rotation = -atan2(motion.gravity.y, motion.gravity.x) + M_PI
                    
                    self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(-rotation))
                    car.setRotation(rotation)
                })
                
            }
            
        }
        //super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //timer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        car.stop()
        self.imageView.transform = CGAffineTransformMakeRotation(CGFloat(0))
        
    }
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dispatch_async(dispatch_get_main_queue(), {
            bluetoothConnected=userInfo["isConnected"]!
            if bluetoothConnected {
                return
            } else {
                // disable the car
                // send back to into view
                
                car.stop()
                car=nil
                self.performSegueWithIdentifier("backToSearching", sender: self)
            }
        });
    }
    
    
    
}

