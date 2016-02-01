//
//  IntroScreen.swift
//  BlueController
//
//  Created by Tran Khoa on 31/01/2016.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//
//Set up some global variable
var bluetoothConnected:Bool=false
var car:CarModel!
class IntroScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //triger bluetooth searching
        print("Searching for bluetooth");
        btDiscoverySharedInstance
        
        // register bluetooth connection change listener
        // once bluetooth has found the destinated bluetooth model
        // it iwll connect to that model, after sucessfully connnecting
        // to the model, a notification will be sent out
        // here we listen for that notifications and triger
        // the connectionChanged() function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dispatch_async(dispatch_get_main_queue(), {
            bluetoothConnected=userInfo["isConnected"]!
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    //hook up the car with the connection
                    car=CarModel(con: btDiscoverySharedInstance.bleService!);
                    
                    //after the car connected 
                self.performSegueWithIdentifier("gotoController", sender: self)

                    
                } else {
                    //disable the car
                    car=nil
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)

                }
            }
        });
    }
    
    
    
}
