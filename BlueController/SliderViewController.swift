//
//  SliderViewController.swift
//  BlueController
//
//  Created by Tran Khoa on 27/12/16.
//  Copyright © 2016 Tran Khoa. All rights reserved.
//

import UIKit

class SliderViewController: UIViewController {

    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var slider: UISlider!
    var blueConnection = btDiscoverySharedInstance.bleService;
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func valueOfSliderChanged(_ sender: UISlider) {
        
        let roundUp  =  Int(round(sender.value))
        sender.value = Float(roundUp)
        valueLabel.text = "Value: \(roundUp)"
        
        blueConnection?.sendBytes([0x22]);
    }
    


}
