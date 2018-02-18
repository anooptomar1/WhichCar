//
//  ScrapeComparisonController.swift
//  Project
//
//  Created by Brendan Milton on 05/12/2017.
//  Copyright © 2017 Brendan Milton. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ScrapeComparisonController: ViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    // Varible to picke images from photolibrary
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        
        // Ste properties on image picker
        imagePicker.allowsEditing = true // change to false if editing issues
        imagePicker.sourceType = .camera
    }
    
    // Tap into image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        // Let user pick image
        if let userPickedImage = info[UIImagePickerControllerEditedImage] as? UIImage { // change to Original image if issues
        
        // Converted into CIIMage
            guard let convertedCIImage = CIImage(image: userPickedImage) else {
                
                fatalError("Cannot convert to CIImage.")
            }
            
            // Pass image into detect method
            detect(image: convertedCIImage)
        
        // Take user picked image and cast to UIImage for use with machine learning library
        imageView.image = userPickedImage
        
        }
        // Once user picks image dismiss
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // Detect image for machine learning
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: CarRecognition().model) else {
            
            fatalError("Cannot import model")
        }
        
        // Classification and label print results
        let request = VNCoreMLRequest(model: model){ (request, error) in
            
            let classification = request.results?.first as? VNClassificationObservation
            
            self.classificationLabel.text = classification?.identifier.capitalized
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        
        catch {
            print(error)
        }
        
    }
    
    @IBAction func CameraButtonPressed(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func MainScreenButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MainScreenSegue3", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
