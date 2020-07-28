//
//  ViewController.swift
//  EchoAR-iOS-SceneKit
//
//  Copyright © echoAR, Inc. 2018-2020.
//
//  Use subject to the Terms of Service available at https://www.echoar.xyz/terms,
//  or another agreement between echoAR, Inc. and you, your company or other organization.
//
//  Unless expressly provided otherwise, the software provided under these Terms of Service
//  is made available strictly on an “AS IS” BASIS WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
//  Please review the Terms of Service for details on these and other terms and conditions.
//
//  Created by Alexander Kutner.
//

import UIKit
import SceneKit
import ARKit
import Vision
import CoreML

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var e:EchoAR!;
    
    // Serial Queue For performing Vision Request
    let serialQueue = DispatchQueue(label: "com.mohitnihalani")
    
    // Active 3-D model
    var activeNode: SCNNode?
    
    // CVPixelBufffer to hold ARFrame
    var currentBuffer: CVPixelBuffer?
    
    // Vision Request Handler
    var request :  VNCoreMLRequest?
    
    var currentOrientation: CGImagePropertyOrientation?
    
    // CoreML Model for Performing Vision Request
    var gestureRecognitionModel = Hand_Sign_Recognition_3()
    
    let modelFileName = "Skyscraper.obj"
    
    //let modelName = "Skyscraper"

    let assetNames: Set = ["Skyscraper"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpModel()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        let e = EchoAR();
        
        let scene = SCNScene()
    
        e.loadNodesFromNames(modelNames: self.assetNames, completion: { (nodes: [SCNNode]) in
            for node in nodes {
                node.isHidden = true
                if(activeNode == nil){
                    self.activeNode = node
                }
                scene.rootNode.addChildNode(node);
            }
        })
        
       
        // Set the scene to the view
        sceneView.scene=scene;
        
        
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.delegate = self
        // Run the view's session
        sceneView.session.run(configuration)
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        sceneView.addGestureRecognizer(tapped)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        if(self.activeNode == nil || !self.activeNode!.isHidden) {
            return
        }
        self.activeNode?.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Set up the VNCoreMLModel for performing vision request, and add completion handler.
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: gestureRecognitionModel.model) {
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            
            request?.imageCropAndScaleOption = .scaleFill
            
        } else {
            fatalError()
        }
        
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // Delegate function which is called 30 times per second
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
      
        if(self.activeNode == nil || self.activeNode!.isHidden) {
            return
        }
        
        // We return early if currentBuffer is not nil or the tracking state of camera is not normal
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        
        // Check Device orientation
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            self.currentOrientation = .right
        case .portraitUpsideDown:
            self.currentOrientation = .left
        case .landscapeLeft:
            self.currentOrientation = .up
        case .landscapeRight:
            self.currentOrientation = .down
        case .unknown:
            print("The device orientation is unknown, the predictions may be affected")
            fallthrough
        default:
            if(self.currentOrientation == nil){
                self.currentOrientation = .right
            }
            print("No Orientation Changed")
        }
        
        // Start Vision Request
        startDetection()
        
        
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
