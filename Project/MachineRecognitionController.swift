//
//  MachineRecognitionController.swift
//  Project
//
//  Created by Brendan Milton on 04/12/2017.
//  Copyright © 2017 Brendan Milton. All rights reserved.
//
import UIKit
import CoreML
import Vision

class MachineRecognitionController: ViewController {
    
    // Image picker to grab image to compare ml library against
    private var imagePicker = UIImagePickerController()
    
    // Implement COREml library to model variable
    private var model = CarRecognition()
    
    @IBOutlet weak var photoImageView :UIImageView!
    @IBOutlet weak var descriptionTextView :UITextView!
    
    // Go back to main screen button
    @IBAction func mainScreenButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Image picker source type will be from photolibrary
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Dismiss standard animation
        dismiss(animated: true, completion: nil)
        // Get access to picked image then return image to UI image
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        // Assign image to photo image view
        self.photoImageView.image = pickedImage
        
        // Pass image to process image function
        processImage(image :pickedImage)
    }
    
    // Process image to compare coreML library to image
    private func processImage(image :UIImage) {
        
        // Converts image to ciImage to pass into vision request handler
        guard let ciImage = CIImage(image :image) else {
            fatalError("Unable to create the ciImage object")
        }
        
        // Create vision model using coreML model
        guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
            fatalError("Unable to create vision model")
        }
        
        // Create vision request: takes in vision model to return completion block
        let visionRequest = VNCoreMLRequest(model: visionModel) { request, error in
            
            // Stop process if error present
            if error != nil {
                return
            }
            
            // Show results including COREML confidence in VNCLassification Observation
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            // NOTE FOR FURTHER APPS: IDENTIFIER AND CONFIDENCE displays labels
            // Display results by mapping over current text, Each item is called and observation
            let classifications = results.map { observation in
                "\(observation.identifier) \(observation.confidence * 100)"
            }
            
            // Display results in description text view and join together with seperator
            DispatchQueue.main.async {
                self.descriptionTextView.text = classifications.joined(separator: "\n")
            }
            
        }
        
        // Vision request handler: pass in converted ciImage and photo orientation
        let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up, options: [:])
        
        // Invoke vision request array (in seperate queue)
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
        
    }
    
    @IBAction func openPhotoLibraryButtonPressed() {
        
        // Present image gallery on pressing button
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    
}


