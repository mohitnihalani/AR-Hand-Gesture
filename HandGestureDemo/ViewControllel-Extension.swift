//
//  ViewControllel-Extension.swift
//  HandGestureDemo
//
//  Created by Mohit Nihalani on 7/15/20.
//

import Foundation
import Vision
import CoreML
import SceneKit


// Enum for Different Hand Gesture
enum HandSign: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case zero = "0"
}

extension ViewController {
    
    
    // Callback function when CoreML model makes a prediction
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
       
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        
        DispatchQueue.main.async {
            
            // Get top 3 classification Results
            if let classifications = request.results as? [VNClassificationObservation] {
                let topClassification = classifications[0...2].map {
                    (confidence: $0.confidence, identifier: $0.identifier)
                  }
                let topPrediction = topClassification[0]
                let topPredictionIdentifier = topPrediction.identifier
            
                print(topPredictionIdentifier)
                //print(topClassification)
                
                // Check if there is a activeNode 3-D Model in the scene
                if let node = self.activeNode{
                    switch topPredictionIdentifier {
                    
                    // Perform Transformations based on Gesture
                    case HandSign.one.rawValue:
                        // Gesture "1" : Rotate the 3-D Model
                        let orientation = node.orientation
                        var glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
                        let multiplier = GLKQuaternionMakeWithAngleAndAxis(0.3, 0, 1, 0)
                        glQuaternion = GLKQuaternionMultiply(glQuaternion, multiplier)
                        node.orientation = SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
                    case HandSign.two.rawValue:
                        
                        // Gesture "2" : Scale Down the 3-D Model
                        node.simdScale /= simd_float3(repeating: 1.2)
                        node.simdScale.x = max(0.1, node.simdScale.x)
                        node.simdScale.y = max(0.1, node.simdScale.y)
                        node.simdScale.z = max(0.1, node.simdScale.z)
                        print(HandSign.two.rawValue)
                    case HandSign.three.rawValue:
                        
                        // Gesture "3" : Move 3-D Model around negative X axis
                        node.simdPosition += simd_float3(-0.15,0,0)
                    case HandSign.four.rawValue:
                        
                        // Gesture "4" : Scale Up the 3-D Model
                        node.simdScale *= simd_float3(repeating: 1.2)
                        node.simdScale.x = min(0.3, node.simdScale.x)
                        node.simdScale.y = min(0.3, node.simdScale.y)
                        node.simdScale.z = min(0.3, node.simdScale.z)
                    case HandSign.five.rawValue:
                        
                        // Move 3-D model around positive X axis.
                        node.simdPosition += simd_float3(0.15,0,0)
                    default:
                        // No Hand Detected
                        print("No hand")
                       
                    }
                }else {
                    // No active node currently on the scene
                    print("No Active Node")
                }
            }
            
            // Release current buffer for next frame.
            self.currentBuffer = nil
        }
    }
    
    // Start Detection
    func startDetection(){
        
        // Get current image from buffer
        guard let buffer = self.currentBuffer else { return }
        guard let imageOrientation = self.currentOrientation else { return }
        
        self.serialQueue.async {
            
            // Perform Vision Request using SerialQueue
            guard let request = self.request else {fatalError()}
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: imageOrientation, options: [:])
            do {
                print("Request Performed")
                try handler.perform([request])
            }catch {
                print(error)
            }
            
        }
    }
}
