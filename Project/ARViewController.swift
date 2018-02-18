//
//  ARRecognitionController.swift
//  Project
//
//  Created by Brendan Milton on 05/12/2017.
//  Copyright © 2017 Brendan Milton. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ARViewController: ViewController, ARSCNViewDelegate  {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var predictionLabel: UILabel!
    
    var currentPrediction = "Empty"
    var visionRequests = [VNRequest]()
    
    // Use queue to make sure coreml requeusts are running smoothly without effecting other processes
    let coreMLQueue = DispatchQueue(label: "com.rume.coremlqueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Automatically adjust lightning for ARobjects
        sceneView.autoenablesDefaultLighting = true
        
        initializeModel()
        coreMLUpdate()
    }
    
    // Following functions are in charge of running pausing and resuming AR session
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    // Pauses session
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Gets called each time camera changes its tracking state
    // User indicates wether or not ready to recognize object
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        // Checks value of camera.tracking state
        switch camera.trackingState {
        // Camera could still be initializing
        case .limited(let reason):
            statusLabel.text = "Tracking limited: \(reason)"
        // Camera issue could be halting tracking
        case .notAvailable:
            statusLabel.text = "Tracking unavailable"
        case .normal:
            statusLabel.text = "Tap to add a Label"
        }
    }
    
    // Initialize coreml model
    func initializeModel() {
        guard let model = try? VNCoreMLModel(for: CarRecognition().model) else {
            print("Could not load model")
            return
        }
        
        // Completion handler
        let classificationRequest = VNCoreMLRequest(model: model, completionHandler: classificationCompletionHandler)
        // Crop photo and scale image from center to pass correct format to Carrecognition model
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
    }
    
    // get vision request result to work with
    func classificationCompletionHandler(request: VNRequest, error: Error?) {
        // Check error
        if error != nil {
            // print error and return so not to continue
            print(error?.localizedDescription as Any)
            return
        }
        // Access results of vision request
        guard let results = request.results else {
            print("No results found")
            return
        }
        
        // If not nil prediction will contain a classification
        if let prediction = results.first as? VNClassificationObservation {
            
            // ****** SHOW IN LIVE LABEL USE IN AR LABEL
            // Obtain prediction information for label
            let object = prediction.identifier
            currentPrediction = object
            DispatchQueue.main.async {
                self.predictionLabel.text = self.currentPrediction
            }
        }
    }
    
    // Continuously called from coreml update to check latest image
    func visionRequest() {
        // Create vision framework request
        let pixelBuffer = sceneView.session.currentFrame?.capturedImage
        if pixelBuffer == nil {
            return
        }
        
        let image = CIImage(cvPixelBuffer: pixelBuffer!)
        
        // Perform requests with vision framework
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            // Pass vision request that contains model
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    // APP DIFFERENCE due to augmented reality constant image changing model must update to keep up
    // Constantly update to offer predictions based on what is seen
    func coreMLUpdate() {
        // Runs in custom queue
        coreMLQueue.async {
            
            self.visionRequest()
            // calls itself to continually run
            self.coreMLUpdate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func MainScreenPressedButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MainScreenSegue4", sender: self)
    }
}


