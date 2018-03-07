//
//  ViewController.swift
//  QuackChallenge
//
//  Created by Julio Brazil on 27/02/18.
//  Copyright © 2018 Julio Brazil. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var patoAmount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show debug info such as fps and timing information
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showPhysicsShapes, SCNDebugOptions.showBoundingBoxes]
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Lighting stuff
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        
        // Add the tap gesture recognizer
        self.addTapGestureToSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = Plane(with: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor, let planeNode = node.childNodes.first as? Plane else { return }
        
        planeNode.update(with: planeAnchor)
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
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
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addDuckToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func addDuckToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y + 1
        let z = translation.z
        
        guard let duckScene = SCNScene(named: "art.scnassets/motherDucker.scn"), let duckNode = duckScene.rootNode.childNode(withName: "duck", recursively: false) else { return }
        
        duckNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: duckNode, options: [SCNPhysicsShape.Option.scale : duckNode.scale]))
//        duckNode.physicsBody.
        duckNode.position = SCNVector3(x,y,z)
        
        guard let duckSound = SCNAudioSource(fileNamed: "quack.mp3") else {
            sceneView.scene.rootNode.addChildNode(duckNode)
            return
        }
        
        let toQuack = SCNAction.playAudio(duckSound, waitForCompletion: true)
        let jump = SCNAction.run { duck in
            duck.physicsBody?.applyForce(SCNVector3.init(0, 1, 0), asImpulse: true)
        }
        let quackAction = SCNAction.group([toQuack, jump])
        let notToQuack = SCNAction.wait(duration: 3)
        let duckSequence = SCNAction.sequence([notToQuack, quackAction])
        let foreverQuacking = SCNAction.repeatForever(duckSequence)
        
        sceneView.scene.rootNode.addChildNode(duckNode)
        duckNode.runAction(foreverQuacking)
        
        self.patoAmount += 1
        print(self.patoAmount)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
