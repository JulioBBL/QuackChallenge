//
//  Plane.swift
//  LearningARKit
//
//  Created by Erick Borges on 28/02/2018.
//  Copyright © 2018 Erick Borges. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class Plane: SCNNode {

    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(with anchor: ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        self.planeGeometry = SCNBox(width: width, height: 0.001, length: length, chamferRadius: 0)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry))
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.simdPosition = float3(anchor.center.x, 0, anchor.center.z)
        planeNode.opacity = 0.5
        
        self.addChildNode(planeNode)
    }
    
    func update(with anchor: ARPlaneAnchor){
        self.simdPosition = float3(anchor.center.x, 0, anchor.center.z)
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.length = CGFloat(anchor.extent.z)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
