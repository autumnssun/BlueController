//
//  IntroScreen.swift
//  BlueController
//
//  Created by Tran Khoa on 31/01/2016.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//
//Set up some global variable
import UIKit
var bluetoothConnected:Bool=false
var car:CarModel!
class IntroScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //triger bluetooth searching
        print("Searching for bluetooth");
        btDiscoverySharedInstance
        
        // register bluetooth connection change listener
        // once bluetooth has found the destinated bluetooth model
        // it iwll connect to that model, after sucessfully connnecting
        // to the model, a notification will be sent out
        // here we listen for that notifications and triger
        // the connectionChanged() function
        NotificationCenter.default.addObserver(self, selector: #selector(IntroScreen.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async(execute: {
            bluetoothConnected=userInfo["isConnected"]!
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    //hook up the car with the connection
                    car=CarModel(con: btDiscoverySharedInstance.bleService!);
                    
                    //after the car connected 
                self.performSegue(withIdentifier: "gotoController", sender: self)

                    
                } else {
                    //disable the car
                    car=nil
                    NotificationCenter.default.addObserver(self, selector: #selector(IntroScreen.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)

                }
            }
        });
    }
    
    
    
}
