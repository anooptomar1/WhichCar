//
//  ViewController.swift
//  Project
//
//  Created by Brendan Milton on 04/12/2017.
//  Copyright © 2017 Brendan Milton. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBAction func machineRecognitionPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MachineRecognitionSegue", sender: self)
    }
    
    @IBAction func ARButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier:
            "ARViewSegue", sender: self)
    }
    
    @IBAction func ScrapeComparisonButtonPressed(_ sender: Any) {
    
        self.performSegue(withIdentifier: "ScrapeComparisonSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

