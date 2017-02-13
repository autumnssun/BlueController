//
//  TabBarController.swift
//  BlueController
//
//  Created by Tran Khoa on 27/12/16.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async(execute: {
            bluetoothConnected=userInfo["isConnected"]!
            if bluetoothConnected {
                return
            } else {
                // disable the car
                // send back to into view
                
                car.stop()
                car=nil
                self.performSegue(withIdentifier: "backToSearching", sender: self)
            }
        });
    }


}
